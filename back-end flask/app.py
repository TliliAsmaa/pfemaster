from flask import Flask, request, jsonify
import pickle  # Pour charger le modèle enregistré
import numpy as np
import joblib
app = Flask(__name__)
 
# Charger ton modèle depuis un fichier .pkl
model = joblib.load('modele_heart_failure.pkl') # Remplace par le chemin de ton modèle
pca = joblib.load('pca_model.pkl')  # Modèle PCA
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

if __name__ == '__main__':
    app.run(debug=True)
