#!/bin/bash
set -o errexit

# Installer Tesseract OCR et ses dépendances
apt-get update
apt-get install -y tesseract-ocr libtesseract-dev libleptonica-dev

# Installer les dépendances Python
pip install -r requirements.txt