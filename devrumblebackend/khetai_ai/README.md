# KhetAI Backend

AI-powered crop disease analysis API for Nepal's small-scale farmers. Built with FastAPI and Google Gemini.

---

## Project Setup

### 1. Create a Python virtual environment

```bash
python -m venv venv
```

Activate it:

- **Windows**: `venv\Scripts\activate`
- **macOS / Linux**: `source venv/bin/activate`

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Create your `.env` file

```bash
cp .env.example .env
```

On Windows:

```bash
copy .env.example .env
```

### 4. Add your Gemini API key

Open `.env` and replace the placeholder:

```
GEMINI_API_KEY=your_actual_gemini_api_key_here
```

Get your key at: https://aistudio.google.com/app/apikey

---

## Running the Server

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://0.0.0.0:8000`.

Interactive docs: `http://localhost:8000/docs`

---

## API Endpoints

### GET `/health`

Health check.

**Response:**
```json
{ "status": "ok" }
```

---

### POST `/analyze`

Analyze a crop image for diseases, pests, or deficiencies.

**Request body:**
```json
{
  "imageBase64": "<base64-encoded image string>"
}
```

Supported image formats: **JPEG, PNG, WebP**  
Maximum image size: **10 MB**

**Response:**
```json
{
  "crop": "Rice",
  "condition": "Bacterial Leaf Blight",
  "confidence": 85,
  "severity": "High",
  "description": "The leaves show yellow to white lesions along the margins, typical of bacterial leaf blight caused by Xanthomonas oryzae.",
  "recommendations": [
    "Remove and destroy infected plant material.",
    "Apply copper-based bactericide such as Bordeaux mixture.",
    "Ensure proper field drainage to reduce moisture.",
    "Avoid overhead irrigation."
  ],
  "prevention": [
    "Use certified disease-resistant rice varieties.",
    "Treat seeds with hot water before planting.",
    "Maintain field hygiene by removing crop debris after harvest."
  ]
}
```

**Error responses:**

| Status | Meaning |
|--------|---------|
| 400 | Invalid or empty Base64 |
| 413 | Image exceeds 10 MB |
| 415 | Unsupported image format |
| 500 | Missing API key (server misconfiguration) |
| 502 | Gemini API error or invalid response |

---

## Connecting Flutter to the API

### Android Emulator

The Android emulator cannot reach `localhost` or `127.0.0.1` of your host machine. Use the special emulator loopback address instead:

```
http://10.0.2.2:8000
```

Example in Flutter:

```dart
const String baseUrl = 'http://10.0.2.2:8000';
```

### Physical Android / iOS Device

Make sure your phone and computer are on the **same Wi-Fi network**. Find your machine's local IP:

- **Windows**: Run `ipconfig` and look for IPv4 Address (e.g., `192.168.1.105`)
- **macOS / Linux**: Run `ifconfig` or `ip addr`

Then use:

```
http://192.168.1.105:8000
```

Example in Flutter:

```dart
const String baseUrl = 'http://192.168.1.105:8000';
```

### Sending a request from Flutter

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> analyzeImage(String base64Image) async {
  final response = await http.post(
    Uri.parse('$baseUrl/analyze'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'imageBase64': base64Image}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Analysis failed: ${response.body}');
  }
}
```

---

## Project Structure

```
khetai_ai/
├── main.py                  # FastAPI app, routes
├── requirements.txt
├── .env.example
├── .gitignore
├── README.md
└── services/
    ├── __init__.py
    └── gemini_service.py    # Gemini API logic, prompt, response parsing
```
