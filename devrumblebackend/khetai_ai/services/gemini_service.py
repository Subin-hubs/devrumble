import os
import json
import re
from google import genai
from google.genai import types
from pydantic import BaseModel, Field, ValidationError
from dotenv import load_dotenv

load_dotenv()

SUPPORTED_MIME_TYPES = {
    "jpeg": "image/jpeg",
    "jpg": "image/jpeg",
    "png": "image/png",
    "webp": "image/webp",
}

IMAGE_MAGIC_BYTES = {
    b"\xff\xd8\xff": "image/jpeg",
    b"\x89PNG": "image/png",
    b"RIFF": "image/webp",
}

ANALYSIS_PROMPT = """You are an expert agricultural assistant helping small-scale farmers in Nepal.

Analyze the provided crop image carefully and return a JSON object with the following fields:

- "crop": Name of the identified crop (e.g., "Rice", "Maize", "Tomato"). Use "Unknown" if you cannot identify it.
- "condition": Short name of the identified condition, disease, pest, or deficiency (e.g., "Bacterial Leaf Blight", "Iron Deficiency", "Healthy"). Use "Unknown" if unclear.
- "confidence": Integer from 0 to 100 representing your confidence in this analysis. Be honest and conservative when the image is unclear.
- "severity": One of "Low", "Moderate", "High", or "Unknown".
- "description": 2-4 sentences describing the visible symptoms and what you observe in the image.
- "recommendations": Array of 3-5 practical treatment or management steps. Prefer affordable, locally available solutions suitable for small-scale Nepali farmers.
- "prevention": Array of 2-4 preventive measures to avoid this problem in the future.

Rules you must follow:
- If the image is not a plant or crop, set crop to "Not a plant image", condition to "N/A", confidence to 0, severity to "Unknown", and explain in description.
- Never invent a disease or condition you are not confident about.
- Never claim certainty when the image is blurry, low quality, or ambiguous.
- Return ONLY a valid JSON object. No markdown. No code fences. No extra text before or after the JSON.
"""


class CropAnalysisResult(BaseModel):
    crop: str
    condition: str
    confidence: int = Field(ge=0, le=100)
    severity: str = Field(pattern="^(Low|Moderate|High|Unknown)$")
    description: str
    recommendations: list[str]
    prevention: list[str]


def _get_api_key() -> str:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise EnvironmentError("GEMINI_API_KEY is not set in environment variables.")
    return api_key


def _detect_mime_type(image_bytes: bytes) -> str:
    for magic, mime in IMAGE_MAGIC_BYTES.items():
        if image_bytes[:len(magic)] == magic:
            return mime
    if image_bytes[8:12] == b"WEBP":
        return "image/webp"
    raise ValueError("Unsupported image format. Only JPEG, PNG, and WebP are supported.")


def _extract_json(text: str) -> str:
    text = text.strip()
    fenced = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", text, re.DOTALL)
    if fenced:
        return fenced.group(1).strip()
    start = text.find("{")
    end = text.rfind("}")
    if start != -1 and end != -1 and end > start:
        return text[start:end + 1]
    raise ValueError("No valid JSON object found in Gemini response.")


async def analyze_crop_image(image_bytes: bytes) -> CropAnalysisResult:
    api_key = _get_api_key()
    mime_type = _detect_mime_type(image_bytes)

    client = genai.Client(api_key=api_key)

    image_part = types.Part.from_bytes(data=image_bytes, mime_type=mime_type)

    response = client.models.generate_content(
        model="gemini-3.5-flash-lite",
        contents=[image_part, ANALYSIS_PROMPT],
    )

    raw_text = response.text

    if not raw_text or not raw_text.strip():
        raise ValueError("Gemini returned an empty response.")

    json_str = _extract_json(raw_text)

    try:
        data = json.loads(json_str)
    except json.JSONDecodeError as e:
        raise ValueError(f"Gemini response could not be parsed as JSON: {e}")

    try:
        result = CropAnalysisResult(**data)
    except (ValidationError, TypeError) as e:
        raise ValueError(f"Gemini response did not match expected schema: {e}")

    return result
