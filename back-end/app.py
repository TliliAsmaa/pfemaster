
import subprocess
import sys

from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
#import cv2
import pytesseract
#import tempfile
import os
import logging

app = Flask(__name__)

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
#pytesseract.pytesseract.tesseract_cmd = 'C:\\Program Files\\Tesseract-OCR\\tesseract.exe'  # Chemin vers l'exécutable Tesseract
# Le chemin typique pour Ubuntu sur Render après installation via apt
pytesseract.pytesseract.tesseract_cmd = "/usr/bin/tesseract"
CORS(app)

model = joblib.load('modele_heart_failure.pkl')

pca = joblib.load('pca_model.pkl')  # Modèle 

modell=joblib.load('modele_heart_failure_p.pkl') # Modèle pour l'image
pcaa = joblib.load('pca_model_p.pkl') 
@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Recevoir les données envoyées par l'application Flutter
        data = request.get_json()  # Récupérer le JSON envoyé par Flutter
        
          # Convertir les données pour qu'elles soient de type Python natif (int, float)
        data = {key: int(value) if isinstance(value, np.int64) else float(value) if isinstance(value, np.float64) else value for key, value in data.items()}
        
        # Extraire les valeurs du JSON
        age = data['age']
        anaemia = data['anaemia']
        creatinine_phosphokinase = data['creatinine_phosphokinase']
        diabetes = data['diabetes']
        ejection_fraction = data['ejection_fraction']
        high_blood_pressure = data['high_blood_pressure']
        platelets = data['platelets']
        serum_creatinine = data['serum_creatinine']
        serum_sodium = data['serum_sodium']
        sex = data['sex']
        smoking = data['smoking']
        time = data['time']
        
        # Préparer les features pour la prédiction
        features = np.array([[age, anaemia, creatinine_phosphokinase, diabetes,
                              ejection_fraction, high_blood_pressure, platelets,
                              serum_creatinine, serum_sodium, sex, smoking, time]])
        
         # Appliquer la transformation PCA sur les features
        features_pca = pca.transform(features)  # Utiliser le même modèle PCA

        # Faire la prédiction avec le modèle RandomForest
        prediction = model.predict(features_pca)
        
        # Retourner la prédiction
        return jsonify({'prediction': int(prediction[0])})

    
    except Exception as e:
        return jsonify({'error': str(e)})
    
@app.route('/prediction_img', methods=['POST'])
def prediction_img():
    try:
        data = request.get_json()
        logger.info(f"Requête reçue pour /prediction_img : {data}")
        # Extraction des 4 caractéristiques utilisées dans le modèle
        age = float(data['age'])
        ejection_fraction = int(data['ejection_fraction'])
        serum_creatinine = float(data['serum_creatinine'])
        time = int(data['time'])
        logger.info(f"Valeurs extraites : age={age}, ejection_fraction={ejection_fraction}, serum_creatinine={serum_creatinine}, time={time}")
        # Créer un tableau avec les 4 features dans le bon ordre
        input_data = np.array([[age, ejection_fraction, serum_creatinine, time]])


        logger.info(f"Input data pour PCA : {input_data}")
        # Appliquer le PCA sur les données
        input_pca = pcaa.transform(input_data)
       
        # Prédire avec le modèle
        prediction = modell.predict(input_pca)
        logger.info(f"Prédiction effectuée : {prediction[0]}")
        return jsonify({'prediction': int(prediction[0])})
        
    except Exception as e:
        logger.error(f"Erreur lors de la prédiction : {e}")
        return jsonify({'error': str(e)})

#if __name__ == '__main__':
    #port = int(os.environ.get('PORT', 5000))  # Render fournit un PORT
    #app.run(debug=True,host='0.0.0.0', port=port)
    #app.run(debug=True)



@app.route('/analyse', methods=['POST'])
def analyse():
    try:
        print("📝 Formulaire reçu :", request.form)
        print("🖼️ Fichiers reçus :", request.files)
        # 1. Vérification du fichier image
        if 'image' not in request.files:
            logger.error("Aucun fichier image reçu")
            return jsonify({'error': 'Aucune image envoyée'}), 400

        image_file = request.files['image']
        if image_file.filename == '':
            logger.error("Nom de fichier vide")
            return jsonify({'error': 'Nom de fichier vide'}), 400

        gender = request.form.get('gender')
        age = request.form.get('age')
        smoking = request.form.get('smoking', 'oui')

        save_path = os.path.join('uploads', image_file.filename)
        os.makedirs('uploads', exist_ok=True)
        image_file.save(save_path)

        # Appeler ton script Python (decryption.py)
        result = subprocess.run(
            [sys.executable, 'decryption.py', save_path, gender, age, smoking],
            capture_output=True, text=True, timeout=300
        )
        print("🔧 stdout:", result.stdout)
        print("❌ stderr:", result.stderr)


        if result.returncode != 0:
            print("Erreur script Python :", result.stderr)
            return jsonify({'error': 'Erreur script Python', 'details': result.stderr}), 500

        try:
            json_output = result.stdout
            return json_output
        except Exception as e:
            print("Erreur parsing JSON :", str(e))
            return jsonify({'error': 'Erreur parsing JSON', 'details': str(e)}), 500

    except Exception as e:
        logger.error("Erreur générale : " + str(e))
        return jsonify({'error': 'Erreur interne', 'details': str(e)}), 500
"""
@app.route('/analyse', methods=['POST'])
def analyse():
    try:
        logger.info("Début de la requête /analyse")
        if 'image' not in request.files:
            logger.error("Aucun fichier image reçu")
            return jsonify({'error': 'Aucune image envoyée'}), 400

        image_file = request.files['image']
        logger.debug(f"Fichier image reçu : {image_file.filename}")
        if image_file.filename == '':
            logger.error("Nom de fichier vide")
            return jsonify({'error': 'Nom de fichier vide'}), 400

        gender = request.form.get('gender')
        age = request.form.get('age')
        smoking = request.form.get('smoking', 'oui')
        logger.info(f"Paramètres reçus : gender={gender}, age={age}, smoking={smoking}")

        save_path = os.path.join('uploads', image_file.filename)
        os.makedirs('uploads', exist_ok=True)
        logger.debug(f"Sauvegarde de l'image à : {save_path}")
        image_file.save(save_path)
        logger.info(f"Image sauvegardée avec succès à {save_path}")

        logger.info("Exécution du script decryption.py")
        result = subprocess.run(
            ['python', 'decryption.py', save_path, gender, age, smoking],
            capture_output=True, text=True, timeout=300 ,stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
    
        )
        logger.info("Logs de decryption.py :\n" + result.stdout)
        logger.info("Erreurs de decryption.py :\n" + result.stderr)
        # Capturer et logger stderr pour voir les logs de decryption.py et ocr_preprocess.py
        if result.stderr:
            logger.info(f"Logs ou erreurs de decryption.py (stderr) : {result.stderr}")
        logger.debug(f"Résultat de subprocess : returncode={result.returncode}, stdout={result.stdout}, stderr={result.stderr}")

        if result.returncode != 0:
            logger.error(f"Erreur script Python : {result.stderr}")
            print("Erreur script Python :", result.stderr)
            return jsonify({'error': 'Erreur script Python', 'details': result.stderr}), 500

        try:
            logger.info("Parsing de la sortie JSON")
            json_output = result.stdout
            logger.debug(f"Sortie JSON : {json_output}")
            logger.info("Requête /analyse terminée avec succès")
            return json_output
        except Exception as e:
            logger.error(f"Erreur parsing JSON : {str(e)}")
            print("Erreur parsing JSON :", str(e))
            return jsonify({'error': 'Erreur parsing JSON', 'details': str(e)}), 500

    except Exception as e:
        logger.error(f"Erreur générale : {str(e)}")
        return jsonify({'error': 'Erreur interne', 'details': str(e)}), 500
    """
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)



