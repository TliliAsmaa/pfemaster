import cv2
import numpy as np
import pytesseract

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

    print(f"Orientation choisie : {best_angle}°")
    return best_img

def rotate_image(image, angle):
    if angle == 0:
        return image
    elif angle == 90:
        return cv2.rotate(image, cv2.ROTATE_90_CLOCKWISE)
    elif angle == 180:
        return cv2.rotate(image, cv2.ROTATE_180)
    elif angle == 270:
        return cv2.rotate(image, cv2.ROTATE_90_COUNTERCLOCKWISE)

# 🔧 Nouvelle version robuste de deskew (pour textes inclinés)
def get_skew_angle(image):
    inverted = cv2.bitwise_not(image)
    thresh = cv2.threshold(inverted, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
    edges = cv2.Canny(thresh, 50, 150, apertureSize=3)
    lines = cv2.HoughLines(edges, 1, np.pi / 180, 200)

    if lines is None:
        print("Aucune ligne détectée.")
        return 0

    angles = []
    for line in lines:
        rho, theta = line[0]
        angle = (theta * 180 / np.pi) - 90
        if -45 < angle < 45:  # ignorer les verticales
            angles.append(angle)

    if len(angles) == 0:
        return 0

    median_angle = np.median(angles)
    print(f"Angle détecté (Hough) : {median_angle:.2f}°")
    return median_angle

def deskew(image):
    angle = get_skew_angle(image)
    (h, w) = image.shape[:2]
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    rotated = cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
    return rotated

def getmessage(imagefile):
    img = cv2.imread(imagefile)
    if img is None:
        raise ValueError("Image non chargée. Vérifiez le chemin ou l'intégrité du fichier.")

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # 🔄 Choisir la meilleure rotation automatiquement
    rotated = try_rotations(gray)

    # 🔧 Correction de l’inclinaison (oblique)
    deskewed = deskew(rotated)

    

    # 🔍 Redimensionnement et seuillage
    resized = cv2.resize(deskewed, None, fx=2, fy=2, interpolation=cv2.INTER_LINEAR)
    thresholded = cv2.adaptiveThreshold(
        resized, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY, 65, 13
    )

    # 🖼️ Affichage
    cv2.imshow("Image après prétraitement", thresholded)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    # 🔠 OCR
    text = pytesseract.image_to_string(thresholded, config='--oem 3 --psm 6')
    return text
