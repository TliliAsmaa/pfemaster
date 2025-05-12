from extract import preprocess_image

from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np
import cv2
import pytesseract
import tempfile
import os
app = Flask(__name__)
CORS(app)
# Charger ton modèle depuis un fichier .pkl
model = joblib.load('modele_heart_failure.pkl2') # Remplace par le chemin de ton modèle
pca = joblib.load('pca_model.pkl2')  # Modèle PCA
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

#if __name__ == '__main__':
    #port = int(os.environ.get('PORT', 5000))  # Render fournit un PORT
    #app.run(debug=True,host='0.0.0.0', port=port)
    #app.run(debug=True)



@app.route('/analyse', methods=['POST'])
def analyse():
    if 'image' not in request.files:
        return jsonify({'error': 'Aucune image envoyée'}), 400

    image = request.files['image']
    gender = request.form.get('gender')
    age = request.form.get('age')

    save_path = os.path.join('uploads', image.filename)
    os.makedirs('uploads', exist_ok=True)
    image.save(save_path)

    # Appeler ton script Python (decryption.py)
    result = subprocess.run(
        ['python', 'decryption.py', save_path, gender, age],
        capture_output=True, text=True
    )

    if result.returncode != 0:
        return jsonify({'error': 'Erreur script Python', 'details': result.stderr}), 500

    try:
        json_output = result.stdout
        return json_output
    except Exception as e:
        return jsonify({'error': 'Erreur parsing JSON', 'details': str(e)}), 500


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)