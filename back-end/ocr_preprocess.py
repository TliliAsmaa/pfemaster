import cv2
import numpy as np
import pytesseract

# 🔄 Essaie plusieurs rotations (0°, 90°, 180°, 270°) et retourne celle qui donne le plus de texte reconnu par OCR
def try_rotations(gray_img):
    best_img = gray_img
    max_len = 0
    best_angle = 0

    for angle in [0, 90, 180, 270]:
        rotated = rotate_image(gray_img, angle)
        text = pytesseract.image_to_string(rotated, config='--oem 3 --psm 6')
        if len(text.strip()) > max_len:
            max_len = len(text.strip())
            best_img = rotated
            best_angle = angle

    
    return best_img

# 🔁 Fonction utilitaire pour faire pivoter une image selon un angle spécifique
def rotate_image(image, angle):
    if angle == 0:
        return image
    elif angle == 90:
        return cv2.rotate(image, cv2.ROTATE_90_CLOCKWISE)
    elif angle == 180:
        return cv2.rotate(image, cv2.ROTATE_180)
    elif angle == 270:
        return cv2.rotate(image, cv2.ROTATE_90_COUNTERCLOCKWISE)

# 📐 Détecte l'angle d'inclinaison d'un texte dans l'image en utilisant la transformée de Hough
def get_skew_angle(image):
    inverted = cv2.bitwise_not(image)  # Inversion des couleurs (texte noir sur fond blanc)
    thresh = cv2.threshold(inverted, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
    edges = cv2.Canny(thresh, 50, 150, apertureSize=3)  # Détection de contours
    lines = cv2.HoughLines(edges, 1, np.pi / 180, 200)  # Détection de lignes avec Hough

    if lines is None:
        
        return 0

    angles = []
    for line in lines:
        rho, theta = line[0]
        angle = (theta * 180 / np.pi) - 90  # Conversion de radians en degrés
        if -45 < angle < 45:  # Ignore les lignes trop verticales
            angles.append(angle)

    if len(angles) == 0:
        return 0

    median_angle = np.median(angles)  # Angle moyen des lignes détectées
    
    return median_angle

# ↩️ Redresse l'image en utilisant l'angle détecté
def deskew(image):
    angle = get_skew_angle(image)
    (h, w) = image.shape[:2]
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    rotated = cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
    return rotated

# 🔍 Fonction principale : lit une image, prétraite et effectue l’OCR
def getmessage(imagefile):
    # 📥 Lecture de l'image
    img = cv2.imread(imagefile)
    if img is None:
        raise ValueError("Image non chargée. Vérifiez le chemin ou l'intégrité du fichier.")

    # ⚫ Conversion en niveaux de gris
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # 🔄 Rotation pour corriger l’orientation globale
    rotated = try_rotations(gray)

    # ↩️ Redressement du texte (si incliné)
    deskewed = deskew(rotated)

    # 🔍 Agrandissement pour améliorer la précision OCR
    resized = cv2.resize(deskewed, None, fx=2, fy=2, interpolation=cv2.INTER_LINEAR)

    # 🧪 Seuillage adaptatif pour binariser l'image
    thresholded = cv2.adaptiveThreshold(
        resized, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY, 65, 13
    )

    # 🖼️ Affichage de l’image traitée pour débogage
    cv2.imshow("Image après prétraitement", thresholded)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # 🔠 Lecture du texte avec OCR (Tesseract)
    text = pytesseract.image_to_string(thresholded, config='--oem 3 --psm 6')
    return text
