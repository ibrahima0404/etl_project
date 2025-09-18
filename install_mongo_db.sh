#!/bin/bash
set -e

echo "=== Mise à jour des paquets ==="
sudo apt update && sudo apt upgrade -y

echo "=== Ajout de la clé GPG MongoDB ==="
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

echo "=== Ajout du dépôt MongoDB ==="
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] \
https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

echo "=== Installation de MongoDB ==="
sudo apt update
sudo apt install -y mongodb-org
sudo apt install -y mongodb-database-tools

echo "=== Activation du service ==="
sudo systemctl enable mongod
sudo systemctl start mongod

echo "=== Vérification ==="
sudo systemctl status mongod --no-pager