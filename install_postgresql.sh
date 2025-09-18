#!/bin/bash
set -e

# -----------------------------
# Variables à personnaliser
# -----------------------------
USER="pacha"                  
PASSWORD="passer"          
DB_NAME="video_games"

# -----------------------------
# Mise à jour des paquets
# -----------------------------
echo "=== Mise à jour des paquets ==="
sudo apt-get update -y
sudo apt-get upgrade -y

# -----------------------------
# Installer PostgreSQL
# -----------------------------
echo "=== Installation de PostgreSQL ==="
sudo apt-get install -y postgresql postgresql-client postgresql-contrib

# -----------------------------
# Démarrer et activer le service
# -----------------------------
echo "=== Démarrage du service PostgreSQL ==="
sudo systemctl enable postgresql
sudo systemctl start postgresql

# -----------------------------
# Créer l'utilisateur si nécessaire
# -----------------------------
echo "=== Création de l'utilisateur PostgreSQL ==="
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='$USER'" | grep -q 1 || \
sudo -u postgres psql -c "CREATE ROLE $USER LOGIN PASSWORD '$PASSWORD';"

# -----------------------------
# Créer la base si nécessaire
# -----------------------------
echo "=== Création de la base de données ==="
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1 || \
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $USER;"

# -----------------------------
# Vérification
# -----------------------------
echo "=== Bases de données disponibles ==="
sudo -u postgres psql -c "\l"

echo "=== Utilisateurs PostgreSQL ==="
sudo -u postgres psql -c "\du"

echo "✅ PostgreSQL installé et configuré avec succès !"
echo "Utilisateur : $USER"
echo "Base : $DB_NAME"