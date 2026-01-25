import os
import csv

def get_unique_column_3_values_from_csv_files():
    """
    Geht durch alle CSV-Dateien in den Unterordnern des data Verzeichnisses
    und sammelt alle einzigartigen Werte aus der 3. Spalte (Index [3])
    """
    data_folder = os.path.join(os.path.dirname(__file__), 'data')
    unique_values = set()
    
    # Durch alle Unterordner im data Ordner gehen
    for root, dirs, files in os.walk(data_folder):
        for file in files:
            if file.endswith('.csv'):  # Nur CSV Dateien berücksichtigen
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as csvfile:
                        reader = csv.reader(csvfile)
                        for row in reader:
                            # Prüfen ob die Zeile mindestens 4 Spalten hat (Index 0-3)
                            if len(row) > 3:
                                value = row[3].strip()  # Spalte 3 (Index [3])
                                if value:  # Nur nicht-leere Werte hinzufügen
                                    unique_values.add(value)
                except Exception as e:
                    print(f"Fehler beim Lesen der Datei {file_path}: {e}")
    
    # Set zu sortierter Liste konvertieren
    return sorted(list(unique_values))

# Funktion aufrufen und Ergebnis anzeigen
if __name__ == "__main__":
    values = get_unique_column_3_values_from_csv_files()
    print("Eindeutige Werte aus Spalte 3 (Index [3]):")
    print(f'"{values}"')
    print(f"\nGesamtanzahl: {len(values)} eindeutige Werte")