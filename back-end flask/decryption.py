import os
import sys
import re
import json
import requests
import ocr_preprocess
from dotenv import load_dotenv

load_dotenv()
#API_KEY = "AIzaSyAAFm6SGgZpniwCJ-_LWSZtElaYeLxLjHU"  # assure-toi que .env contient GEMINI_API_KEY=ta_clé
API_KEY ="AIzaSyCS3medoSlJAgp9GjGWUZxgiQPW89HdNO4"
if len(sys.argv) != 4:
    sys.exit(1)

image_path = sys.argv[1]
gender = sys.argv[2]
age = sys.argv[3]

message = ocr_preprocess.getmessage(image_path)
message = message.replace('\n', ' ')
message = re.sub(r'\d{2}-\d{2}-\d{2,4}', '', message)

url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={API_KEY}"
headers = {"Content-Type": "application/json"}

if message:
    sex_num = 1 if gender.lower() in ['homme', 'male', 'masculin'] else 0

    prompt = f"""
Tu es un assistant médical expert.

Je te fournis un texte brut OCR contenant des résultats d’analyses médicales. Ce texte peut inclure :
- des noms d’analyses (ex. : Hémoglobine, Créatinine, etc.),
- des valeurs (ex. : 11.5 g/dL, 1.2 mg/dL),
- mais aussi des données non pertinentes (noms du laboratoire, informations administratives, détails du patient, etc.).

Voici le texte brut :
{message}


Informations supplémentaires :
- Le sexe du patient est déjà connu : - Sexe: {'Homme' if sex_num == 1 else 'Femme'}
- L'âge du patient est déjà connu : - Âge: {age} ans.
Ta mission :

1. Ignore tout le texte qui n’est pas une analyse médicale (exemple : nom du labo, informations patient, date, etc.).
2. Associe chaque nom d’analyse à sa valeur correspondante même si le format est perturbé.
3. Pour chaque test médical identifié :
   - Indique son identifiant (nom du test), sa valeur et son unité.
   - Interprète le résultat selon les normes médicales standards en indiquant si c’est : 'bad', 'normal' ou 'illogical'.
  - Structure chaque test sur une ligne au format JSON suivant :
  {{"identifiant": "nom_du_test", "value": 45, "measurement": "ml", "interpretation": "bad"}}

4. Analyse uniquement les résultats pertinents pour remplir les colonnes suivantes (comme dans un fichier CSV médical) :

["age", "anaemia", "creatinine_phosphokinase", "diabetes", "ejection_fraction", "high_blood_pressure", "platelets", "serum_creatinine", "serum_sodium", "sex", "smoking", "time"]
5. Si l'unité extraite ne correspond pas à celle de mon dataset, convertis la valeur dans l'unité attendue. Les unités attendues sont les suivantes :

age : années (ans)
anaemia : pas d'unité (valeur binaire)
creatinine_phosphokinase : UI/L (Unité Internationale par litre)
diabetes : pas d'unité (valeur binaire)
ejection_fraction : pourcentage (%)
high_blood_pressure : pas d'unité (valeur binaire)
platelets : cellules/µL (plaquettes par microlitre)
serum_creatinine : mg/dL (milligrammes par décilitre)
serum_sodium : mEq/L (milléquivalents par litre)
sex : pas d'unité (valeur binaire)
smoking : pas d'unité (valeur binaire)
time : mois
Règles de remplissage :

1. **Hématologie (NFS - Numération Formule Sanguine)** :
   - Si l'hémoglobine est inférieure à 12 g/dL, alors **anaemia** = 1, sinon 0.
   - **platelets** : Si la numération plaquettaire est présente, utilise la valeur pour ce champ.

2. **Biochimie Sanguine** :
   - **serum_creatinine** : Utilise le niveau de créatinine pour remplir ce champ.
   - **diabetes** : Si le glucose à jeun est supérieur à 1.26 g/L, alors **diabetes** = 1.
   - **serum_sodium** : Remplis ce champ avec la valeur du sodium dans le sang.

3. **Bilan Cardiaque** :
   - **creatinine_phosphokinase** : Si la CPK (créatine phosphokinase) est présente, utilise cette valeur pour le champ **creatinine_phosphokinase**.


Autres règles :
- **sex** = 1 si homme, sinon 0.
- Si une colonne reste vide (`null`) après avoir appliqué les règles ci-dessus, propose une valeur probable en te basant sur les autres résultats extraits et les tendances médicales habituelles. Sinon laisse `null`.

Retourne un objet JSON strictement valide avec deux sections : "results" et "data". Ne mets aucun commentaire (pas de // ou /* ... */). Le JSON doit être parfaitement décodable sans aucune explication dans les valeurs. Toute explication doit être faite hors du JSON si nécessaire.

1. **results** : Liste des tests avec leurs identifiants, valeurs, unités et interprétations sous forme d'objets JSON.
2. **data** : Un objet contenant les résultats agrégés pour remplir les colonnes du fichier CSV, y compris les champs comme `"anaemia"`, `"creatinine_phosphokinase"`, `"diabetes"`, `"platelets"`, etc., avec les valeurs interprétées.

"""

    data = {
        "contents": [
            {
                "parts": [{"text": prompt}]
            }
        ]
    }

    try:
        response = requests.post(url, headers=headers, json=data)
        response.raise_for_status()
        result = response.json()

        if ('candidates' in result and
            len(result['candidates']) > 0 and
            'content' in result['candidates'][0] and
            'parts' in result['candidates'][0]['content'] and
            len(result['candidates'][0]['content']['parts']) > 0 and
            'text' in result['candidates'][0]['content']['parts'][0]):

            reply = result['candidates'][0]['content']['parts'][0]['text']

            # Nettoyer automatiquement les balises Markdown inutiles
            reply_clean = reply.strip()
            if reply_clean.startswith('```json'):
                reply_clean = reply_clean.replace('```json', '').strip()
            if reply_clean.startswith('```'):
                reply_clean = reply_clean.replace('```', '').strip()
            if reply_clean.startswith("'''json"):
                reply_clean = reply_clean.replace("'''json", '').strip()
            if reply_clean.startswith("'''"):
                reply_clean = reply_clean.replace("'''", '').strip()
            if reply_clean.endswith('```'):
                reply_clean = reply_clean[:-3].strip()
            if reply_clean.endswith("'''"):
                reply_clean = reply_clean[:-3].strip()

            try:
                json_data = json.loads(reply_clean)
                print(json.dumps(json_data, indent=2, ensure_ascii=False))
            except json.JSONDecodeError:
                print(reply_clean)

        else:
            print("Réponse inattendue :", result)

    except requests.exceptions.RequestException as e:
        print(f"Erreur requête Gemini : {e}")
