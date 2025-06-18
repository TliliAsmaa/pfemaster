# Image légère avec Python
FROM python:3.11-slim

# Installer Tesseract OCR + langue française + dépendances
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-fra \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Créer un dossier de travail
WORKDIR /app

# Copier les fichiers du backend
#COPY back-end /app/back-end
COPY . .

# Installer les dépendances Python (depuis le bon chemin)
#RUN pip install --no-cache-dir -r /app/back-end/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt


# Exposer le port Flask
EXPOSE 5000

# Commande pour lancer l'application
#CMD ["python", "app.py"]


CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--timeout", "300", "--log-level", "debug", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
