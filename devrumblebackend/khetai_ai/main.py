import base64
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from services.gemini_service import analyze_crop_image, CropAnalysisResult

MAX_IMAGE_SIZE_BYTES = 10 * 1024 * 1024


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(title="KhetAI API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class AnalyzeRequest(BaseModel):
    imageBase64: str


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/analyze", response_model=CropAnalysisResult)
async def analyze(request: AnalyzeRequest):
    if not request.imageBase64 or not request.imageBase64.strip():
        raise HTTPException(status_code=400, detail="imageBase64 field is empty.")

    try:
        image_bytes = base64.b64decode(request.imageBase64, validate=True)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid Base64 string.")

    if len(image_bytes) == 0:
        raise HTTPException(status_code=400, detail="Decoded image is empty.")

    if len(image_bytes) > MAX_IMAGE_SIZE_BYTES:
        raise HTTPException(
            status_code=413,
            detail=f"Image exceeds maximum allowed size of {MAX_IMAGE_SIZE_BYTES // (1024 * 1024)} MB.",
        )

    try:
        result = await analyze_crop_image(image_bytes)
    except EnvironmentError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except ValueError as e:
        error_message = str(e)
        if "Unsupported image format" in error_message:
            raise HTTPException(status_code=415, detail=error_message)
        raise HTTPException(status_code=502, detail=error_message)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Gemini API error: {str(e)}")

    return result
