import cv2
import numpy as np
import pytesseract
import os

# Fonction pour corriger l’inclinaison de l’image (deskew)
def deskew(image):
    # On récupère les coordonnées des pixels non noirs (présence de texte)
    coords = np.column_stack(np.where(image > 0))
    
    # Si l’image est vide (aucun texte), on la retourne telle quelle
    if coords.shape[0] == 0:
        return image

    # On calcule l’angle de la boîte englobante minimale
    angle = cv2.minAreaRect(coords)[-1]

    # On ajuste l’angle selon sa valeur
    if angle < -45:
        angle = -(90 + angle)
    else:
        angle = -angle

    # Calcul du centre de l’image
    (h, w) = image.shape[:2]
    center = (w // 2, h // 2)

    # Création de la matrice de rotation
    M = cv2.getRotationMatrix2D(center, angle, 1.0)

    # Application de la rotation à l’image
    return cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)

# Fonction principale pour charger, prétraiter et extraire le texte OCR d’une image
def getmessage(imagefile):
    # Chargement de l'image à partir du chemin fourni
    img = cv2.imread(imagefile)
    
    # Vérification que l’image a bien été chargée
    if img is None:
        raise ValueError("Image non chargée. Vérifiez le chemin ou l'intégrité du fichier.")

    # Conversion de l’image en niveaux de gris
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Agrandissement de l’image pour améliorer l’OCR
    resized = cv2.resize(gray, None, fx=2, fy=2, interpolation=cv2.INTER_LINEAR)

    # Application d’un seuillage adaptatif pour améliorer le contraste du texte
    thresholded = cv2.adaptiveThreshold(
        resized,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        65,   # Taille de bloc (doit être impair)
        13    # Constante soustraite (ajustée empiriquement)
    )

    
    # === Affichage de l’image après traitement ===
    cv2.imshow("Image après prétraitement", thresholded)
    cv2.waitKey(0)  # Attend que l'utilisateur appuie sur une touche
    cv2.destroyAllWindows()  # Ferme la fenêtre

    # === Extraction du texte via Tesseract OCR ===
    custom_config = r'--oem 3 --psm 6'  # Configuration OCR
    text = pytesseract.image_to_string(thresholded, config=custom_config)

    return text
