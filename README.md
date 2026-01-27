# DataRetreival

Ein Projekt zur Verwaltung und Abfrage von Sportresultaten mit OpenSearch und Flutter/Dart.

## Voraussetzungen

Bevor du mit dem Setup beginnst, stelle sicher, dass folgende Tools installiert sind:

- [Docker](https://www.docker.com/get-started) und Docker Compose
- [Python 3.x](https://www.python.org/downloads/)
- [pip](https://pip.pypa.io/en/stable/installation/) (Python Package Manager)
- Eine IDE für Flutter-Entwicklung (empfohlen: [Android Studio](https://developer.android.com/studio))
- [Flutter SDK](https://flutter.dev/docs/get-started/install)

## Setup-Anleitung

### Schritt 1: Repository klonen

```bash
git clone https://github.com/Riggi0815/DataRetreival.git
cd DataRetreival
```

### Schritt 2: OpenSearch Container starten

Starte den OpenSearch-Cluster mit Docker Compose:

```bash
docker-compose up -d
```

Dies startet:

- **OpenSearch Node** auf Port `9200`
- **OpenSearch Dashboards** auf Port `5601`

Überprüfe, ob die Container laufen:

```bash
docker ps
```

Du solltest `opensearch-node` und `opensearch-dashboards` sehen.

### Schritt 3: Python-Abhängigkeiten installieren

Installiere die benötigte OpenSearch-Python-Bibliothek:

```bash
pip install opensearch-py
```

### Schritt 4: OpenSearch-Index erstellen

Erstelle den Index `sport-results` mit dem vordefinierten Mapping:

```bash
python create-index.py
```

**Erwartete Ausgabe:**

```
Index 'sport-results' erfolgreich erstellt:
{
  "acknowledged": true,
  "shards_acknowledged": true,
  "index": "sport-results"
}
```

### Schritt 5: Daten in OpenSearch hochladen

Lade die Sportresultate aus den CSV-Dateien in den OpenSearch-Index hoch:

```bash
python opensearch-data-upload.py
```

**Hinweis:** Dieser Vorgang kann je nach Datenmenge einige Zeit dauern.

### Schritt 6: Flutter-Projekt öffnen und ausführen

1. Öffne den Ordner `data_retrieval` in deiner IDE (z.B. Android Studio)
2. Stelle sicher, dass alle Flutter-Abhängigkeiten installiert sind:
   ```bash
   cd data_retrieval
   flutter pub get
   ```
3. Starte die Anwendung:
   - Für **Web-Entwicklung**:
     ```bash
     flutter run -d chrome
     ```
   - Für **Android**:
     ```bash
     flutter run
     ```

## Projektstruktur

```
DataRetreival/
├── data/                          # CSV-Dateien mit Sportresultaten
├── data_retrieval/                # Flutter/Dart-Anwendung
├── opensearch-cluster/            # OpenSearch-Konfigurationen
├── clean-data.py                  # Skript zur Datenbereinigung
├── create-index.py                # Erstellt den OpenSearch-Index
├── opensearch-data-upload.py     # Lädt Daten in OpenSearch hoch
├── opensearchtest.py             # Test-Skript für OpenSearch
├── helper.py                      # Hilfsfunktionen
└── docker-compose.yml            # Docker-Konfiguration
```

## Testen der Installation

### OpenSearch-Verbindung testen

```bash
curl http://localhost:9200
```

Oder öffne im Browser: [http://localhost:9200](http://localhost:9200)

### OpenSearch Dashboards öffnen

Öffne im Browser: [http://localhost:5601](http://localhost:5601)

### Test-Dokument hinzufügen

```bash
python opensearchtest.py
```

## Nützliche Befehle

### Docker Container stoppen

```bash
docker-compose down
```

### Docker Container neu starten

```bash
docker-compose restart
```

### Index löschen (falls neu erstellt werden soll)

```bash
curl -X DELETE http://localhost:9200/sport-results
```

### Alle Dokumente im Index anzeigen

```bash
curl -X GET "http://localhost:9200/sport-results/_search?pretty"
```

## Datenmodell

Der OpenSearch-Index `sport-results` enthält folgende Felder:

- **competitor**: Name des Athleten/der Athletin
- **discipline**: Sportart/Disziplin
- **date**: Datum des Wettkampfs
- **mark**: Leistung/Ergebnis (mit Einheit und numerischem Wert)
- **pos**: Position/Platzierung
- **venue**: Austragungsort (Stadt, Land, Stadion)
- **gender**: Geschlecht
- **nat**: Nationalität
- **world_rank**: Weltranglistenposition
- **age_at_competition**: Alter beim Wettkampf
- **wind**: Windgeschwindigkeit (bei relevanten Disziplinen)

## Troubleshooting

### Problem: Docker Container startet nicht

- Stelle sicher, dass die Ports 9200, 9600 und 5601 nicht bereits belegt sind
- Überprüfe Docker-Logs: `docker-compose logs`

### Problem: Python-Verbindung zu OpenSearch schlägt fehl

- Stelle sicher, dass der Container läuft: `docker ps`
- Warte einige Sekunden nach dem Start, bis OpenSearch vollständig initialisiert ist

### Problem: Flutter-App kann sich nicht mit OpenSearch verbinden

- Überprüfe die CORS-Einstellungen in der `docker-compose.yml`
- Stelle sicher, dass die OpenSearch-URL in der Flutter-App korrekt konfiguriert ist

## Entwicklung

Das Projekt wurde mit **Android Studio** entwickelt und für **Web** getestet.

### Empfohlene IDEs:

- Android Studio (für Flutter/Dart)
- VS Code mit Flutter-Extension
- PyCharm oder VS Code (für Python-Skripte)
