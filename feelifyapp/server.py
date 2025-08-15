# server.py

from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
import numpy as np
import cv2
from tensorflow.keras.models import load_model
import uvicorn

app = FastAPI()

# Modeli yükle
model = load_model('emotion_model.h5')

# Duygu etiketleri
labels = ['Angry', 'Disgust', 'Fear', 'Happy', 'Sad', 'Surprise', 'Neutral']

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    contents = await file.read()
    npimg = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)

    # Görüntüyü işleyelim
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = cv2.resize(img, (48, 48))
    img = img.astype('float32') / 255.0
    img = np.expand_dims(img, axis=-1)  # (48, 48, 1)
    img = np.expand_dims(img, axis=0)   # (1, 48, 48, 1)

    # Tahmin yap
    prediction = model.predict(img)
    predicted_index = np.argmax(prediction)
    predicted_label = labels[predicted_index]

    # JSON formatında cevap döndür
    return JSONResponse(content={"emotion": predicted_label})

if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)
