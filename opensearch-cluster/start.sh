#!/bin/bash

# 1. Docker Container starten
docker-compose up -d

# 2. Warten bis OpenSearch bereit ist
echo "Warte auf OpenSearch..."
sleep 30

# 3. Datenbank initialisieren
pip install -r requirements.txt