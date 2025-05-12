import cv2
import numpy as np
import pytesseract
import os

# Fonction principale pour traiter une image et extraire le texte OCR
def getmessage(imagefile):
    # Chargement de l'image depuis le chemin donné
    img = cv2.imread(imagefile)

    # Vérification que l'image a bien été chargée
    if img is None:
        raise ValueError("Image not loaded. Check path or file integrity.")

    # === Étapes de prétraitement amélioré ===

    # 1. Mise à l’échelle de l’image (augmentation de la taille à 400%)
    # Cela améliore la lisibilité des petits caractères pour l’OCR
    scale_percent = 400  
    width = int(img.shape[1] * scale_percent / 100)
    height = int(img.shape[0] * scale_percent / 100)
    img_resized = cv2.resize(img, (width, height), interpolation=cv2.INTER_LINEAR)

    # 2. Conversion en niveaux de gris
    # Supprime les informations de couleur pour simplifier l’analyse
    gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)

    # 3. Réduction du bruit avec l’algorithme Non-Local Means Denoising
    # Permet de conserver les contours tout en supprimant le bruit
    denoised = cv2.fastNlMeansDenoising(gray, h=15)

    # 4. Amélioration locale du contraste avec CLAHE
    # Utile pour renforcer les caractères peu visibles
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(4, 4))
    contrast = clahe.apply(denoised)

    # 5. Binarisation de l’image (noir et blanc) avec seuillage d’Otsu
    # + inversion des couleurs pour faciliter l’OCR
    _, thresh = cv2.threshold(contrast, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

    # 6. Opération morphologique de fermeture
    # Supprime les petits trous et imperfections à l’intérieur des lettres
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2, 2))
    clean = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)

    # 7. (Optionnel) Affichage et sauvegarde de l’image prétraitée
    cv2.imshow("Image nettoyée", clean)
    cv2.imwrite("nettoyage_amelioré.png", clean)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # === Exécution de l’OCR avec Tesseract ===
    # Définition du chemin vers Tesseract (à adapter selon le système)
    pytesseract.pytesseract.tesseract_cmd = r'C:\\Program Files\\Tesseract-OCR\\tesseract.exe'

    # Configuration personnalisée : OEM = 3 (mode par défaut), PSM = 6 (OCR par bloc)
    custom_config = r'--oem 3 --psm 6'

    # Extraction du texte depuis l’image nettoyée
    message = pytesseract.image_to_string(clean, config=custom_config)

    return message

# Fonction pour corriger l'inclinaison de l'image (deskew)
def deskew(image):
    # Extraction des coordonnées des pixels non nuls (présence de texte)
    coords = np.column_stack(np.where(image > 0))

    # Vérification qu’il y a des éléments à traiter
    if coords.shape[0] == 0:
        return image

    # Calcul de l’angle d’inclinaison de la boîte englobante minimale
    angle = cv2.minAreaRect(coords)[-1]

    # Ajustement de l’angle pour les cas où la rotation dépasse -45°
    if angle < -45:
        angle = -(90 + angle)
    else:
        angle = -angle

    # Calcul de la matrice de transformation pour redresser l’image
    (h, w) = image.shape[:2]
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, angle, 1.0)

    # Application de la transformation affine (redressement)
    return cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
