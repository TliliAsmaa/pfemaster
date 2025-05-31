import cv2
import numpy as np
import pytesseract
import matplotlib.pyplot as plt
import os
from PIL import Image, ExifTags
import io
import tempfile
import logging
from io import BytesIO

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
def fix_orientation(imagefile):
    image = Image.open(imagefile)

    try:
        for orientation in ExifTags.TAGS.keys():
            if ExifTags.TAGS[orientation] == 'Orientation':
                break

        exif = dict(image._getexif().items())

        if exif[orientation] == 3:
            image = image.rotate(180, expand=True)
        elif exif[orientation] == 6:
            image = image.rotate(270, expand=True)
        elif exif[orientation] == 8:
            image = image.rotate(90, expand=True)

    except (AttributeError, KeyError, IndexError):
        # L’image n’a pas de données EXIF ou orientation manquante
        pass

    return cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)

# 📁 Enregistre une image dans le dossier 'img'
def save_image(img, filename, cmap="gray"):
    output_dir = "img"
    os.makedirs(output_dir, exist_ok=True)
    path = os.path.join(output_dir, filename)

    if len(img.shape) == 2:
        plt.imsave(path, img, cmap=cmap)
    else:
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        plt.imsave(path, img_rgb)

# 🔁 Fait pivoter une image selon un angle
def rotate_image(image, angle):
    if angle == 0:
        return image
    elif angle == 90:
        return cv2.rotate(image, cv2.ROTATE_90_CLOCKWISE)
    elif angle == 180:
        return cv2.rotate(image, cv2.ROTATE_180)
    elif angle == 270:
        return cv2.rotate(image, cv2.ROTATE_90_COUNTERCLOCKWISE)

# 🔄 Essaie plusieurs rotations et retourne celle avec le plus de texte détecté
def try_rotations(gray_img):
    best_img = gray_img
    max_len = 0
    best_angle = 0

    for angle in [0, 90, 180, 270]:
        rotated = rotate_image(gray_img, angle)
        text = pytesseract.image_to_string(rotated,lang='fra', config='--oem 3 --psm 6')
        if len(text.strip()) > max_len:
            max_len = len(text.strip())
            best_img = rotated
            best_angle = angle

    return best_img

# 📐 Détecte l’angle d’inclinaison du texte avec Hough Transform
def get_skew_angle(image):
    inverted = cv2.bitwise_not(image)
    thresh = cv2.threshold(inverted, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
    edges = cv2.Canny(thresh, 50, 150, apertureSize=3)
    lines = cv2.HoughLines(edges, 1, np.pi / 180, 200)

    if lines is None:
        return 0

    angles = []
    for line in lines:
        rho, theta = line[0]
        angle = (theta * 180 / np.pi) - 90
        if -45 < angle < 45:
            angles.append(angle)

    if len(angles) == 0:
        return 0

    return np.median(angles)

# ↩️ Corrige l’inclinaison de l’image
def deskew(image):
    angle = get_skew_angle(image)
    (h, w) = image.shape[:2]
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    rotated = cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
    return rotated

# 🔍 Fonction principale de traitement d’image OCR
def getmessage(imagefile,debug_mode=True):
     try:
        # 1. Chargement de l'image
        if isinstance(image_input, str):  # Si c'est un chemin de fichier
            img = cv2.imread(image_input)
        elif isinstance(image_input, bytes):  # Si ce sont des bytes
            nparr = np.frombuffer(image_input, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        elif isinstance(image_input, np.ndarray):  # Si c'est déjà un array numpy
            img = image_input
        else:
            raise ValueError("Format d'image non supporté")

        if img is None:
            raise ValueError("Impossible de charger l'image")

        if debug_mode:
           save_image(img, "1. Image originale")
   

    

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    save_image(gray, "2_gray.png")

    rotated = try_rotations(gray)
    save_image(rotated, "3_rotated.png")

    deskewed = deskew(rotated)
    save_image(deskewed, "4_deskewed.png")

    resized = cv2.resize(deskewed, None, fx=2, fy=2, interpolation=cv2.INTER_LINEAR)
    save_image(resized, "5_resized.png")

    thresholded = cv2.adaptiveThreshold(
        resized, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY, 65, 13
    )
    save_image(thresholded, "6_thresholded.png")

    text = pytesseract.image_to_string(thresholded, config='--oem 3 --psm 6')
    logger.info("Traitement terminé avec succès")
        
        return text.strip()
    except Exception as e:
        logger.error(f"Erreur lors du traitement: {str(e)}")
        raise



