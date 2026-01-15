import os

def get_unique_filenames_from_data_folder():
    """
    Geht durch alle Ordner im data Verzeichnis und sammelt alle Dateinamen
    ohne Dateierweiterung in einer Liste ohne Duplikate
    """
    data_folder = os.path.join(os.path.dirname(__file__), 'data')
    unique_filenames = set()
    
    # Durch alle Unterordner im data Ordner gehen
    for root, dirs, files in os.walk(data_folder):
        for file in files:
            if file.endswith('.csv'):  # Nur CSV Dateien berücksichtigen
                filename_without_extension = os.path.splitext(file)[0]
                unique_filenames.add(filename_without_extension)
    
    # Set zu sortierter Liste konvertieren
    return sorted(list(unique_filenames))

# Funktion aufrufen und Ergebnis anzeigen
if __name__ == "__main__":
    filenames = get_unique_filenames_from_data_folder()
    print("Eindeutige Dateinamen:")
    for name in filenames:
        print(f'"{name}",')
    print(f"\nGesamtanzahl: {len(filenames)} eindeutige Dateien")