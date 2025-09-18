#!/bin/bash
set -e

# Variables
FILE_ID="1BX1Lbr4CIqpZEaPrTX05oO6sSY286YKN"  
FILE_NAME="video_games.json"         
JSON_PATH="/home/dataengineertraining4336/$FILE_NAME" 
MONGO_DB="videoGames"
MONGO_COLLECTION="games"

# Installer virtualenv si nécessaire
sudo apt-get update
sudo apt-get install -y python3-venv

# Créer un environnement Python dédié
python3 -m venv ~/gdown_env

# Activer l'environnement
source ~/gdown_env/bin/activate

echo "=== Mise à jour des paquets et installation de Python/pip ==="
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip curl gnupg

# Vérifier si gdown est installé
if ! command -v gdown &> /dev/null
then
    echo "gdown non trouvé, installation..."
    pip install --upgrade gdown
fi

# Télécharger le fichier depuis Google Drive
echo "=== Téléchargement du fichier depuis Google Drive ==="
if [ ! -f "$JSON_PATH" ]; then
    gdown --id "$FILE_ID" -O "$JSON_PATH"
else
  echo "Fichier $FILE_NAME déjà téléchargé"
fi

# Vérifier que le fichier a bien été téléchargé
if [ ! -f "$JSON_PATH" ]; then
    echo "Erreur : le fichier $JSON_PATH n'a pas été téléchargé."
    exit 1
fi

# Importer dans MongoDB
echo "=== Import du fichier dans MongoDB ==="
mongoimport --db "$MONGO_DB" --collection "$MONGO_COLLECTION" --file "$JSON_PATH"

echo "=== Vérification de l'import ==="
DOC_COUNT=$(mongosh --quiet --eval "db.getSiblingDB('$MONGO_DB').$MONGO_COLLECTION.countDocuments()")
DOC_COUNT=${DOC_COUNT:-0}  # Si vide, mettre 0
echo "Nombre de documents importés dans $MONGO_DB.$MONGO_COLLECTION : $DOC_COUNT"

if [ "$DOC_COUNT" -eq 0 ]; then
    echo "⚠️ Attention : aucun document n'a été importé."
    exit 1
else
    echo "✅ Import réussi !"
fi
