# On part d'une image Python légère officielle
FROM python:3.11-slim

# Installer Tesseract et les librairies système nécessaires
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    tesseract-ocr-fra \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Définir le dossier de travail dans le container
WORKDIR /app

# Copier les fichiers du backend
#COPY back-end /app/back-end
COPY . /app

# Installer les dépendances Python (depuis le bon chemin)
RUN pip install --no-cache-dir -r /app/back-end/requirements.txt

# Exposer le port utilisé par Flask
EXPOSE 5000

# Commande pour lancer l'application
CMD ["python", "back-end/app.py"]

