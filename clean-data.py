import os
import csv

def process_csv_file(file_path):
    """Verarbeitet eine einzelne CSV-Datei und verschiebt Spalten mit 'WIND' im Header in die letzte Spalte."""
    
    # CSV-Datei einlesen
    with open(file_path, 'r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        rows = list(reader)
    
    if not rows:  # Leere Datei
        return
    
    header = rows[0]
    
    # Prüfen, ob "WIND" im Header vorkommt
    wind_indices = []
    non_wind_indices = []
    
    for i, column in enumerate(header):
        if 'WIND' in column.upper():
            wind_indices.append(i)
        else:
            non_wind_indices.append(i)
    
    # Falls keine WIND-Spalte gefunden wurde, nichts ändern
    if not wind_indices:
        return
    
    # Neue Reihenfolge der Spalten erstellen
    new_rows = []
    
    for row in rows:
        # Neue Zeile erstellen: erstens alle Nicht-WIND-Spalten, dann alle WIND-Spalten
        new_row = []
        
        # Nicht-WIND-Spalten hinzufügen
        for i in non_wind_indices:
            if i < len(row):
                new_row.append(row[i])
            else:
                new_row.append('')
        
        # WIND-Spalten hinten anhängen
        for i in wind_indices:
            if i < len(row):
                new_row.append(row[i])
            else:
                new_row.append('')
        
        new_rows.append(new_row)
    
    # Verarbeitete Datei zurück schreiben
    with open(file_path, 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerows(new_rows)

def process_folder(root_folder):
    """Durchläuft alle CSV-Dateien in den Unterordnern."""
    
    for foldername, subfolders, filenames in os.walk(root_folder):
        for filename in filenames:
            if filename.lower().endswith('.csv'):
                file_path = os.path.join(foldername, filename)
                print(f"Verarbeite: {file_path}")
                process_csv_file(file_path)

# Hauptprogramm
if __name__ == "__main__":
    data_folder = "data"
    
    # Prüfen, ob der Ordner existiert
    if not os.path.exists(data_folder):
        print(f"Ordner '{data_folder}' existiert nicht!")
    else:
        print(f"Starte Verarbeitung von Ordner: {data_folder}")
        process_folder(data_folder)
        print("Verarbeitung abgeschlossen!")