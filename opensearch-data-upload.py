import csv
import os
from time import sleep
from opensearchpy import OpenSearch
import re
import sys

def convert_position(pos_str):
    
    if pos_str is "":
        print("Leere Position")
        document_mapping["pos"]["numeric_pos"] = None
        document_mapping["pos"]["raw_pos"] = None
        document_mapping["pos"]["group"] = None
        return
    
    if "." in pos_str:
        document_mapping["pos"]["numeric_pos"] = pos_str.split(".")[0]
        document_mapping["pos"]["raw_pos"] = pos_str.split(".")[0]
        document_mapping["pos"]["group"] = None
        return
    
    if pos_str.isdigit():
        print(f"Position als Zahl: {pos_str}")
        document_mapping["pos"]["numeric_pos"] = int(pos_str)
        document_mapping["pos"]["raw_pos"] = pos_str
        document_mapping["pos"]["group"] = None
        return
    
    print(f"Position mit Gruppe: {pos_str}")
    pattern = r'^(\d+)([a-zA-Z]+)(\d+)$'
    match = re.match(pattern, pos_str)
    if match:
        position = match.group(1)
        phase = match.group(2)
        group = match.group(3)
        if phase in phases:
            string = phases[phase]
        document_mapping["pos"]["numeric_pos"] = position
        document_mapping["pos"]["raw_pos"] = pos_str
        group_and_phase = string + " " + group
        document_mapping["pos"]["group"] = group_and_phase
    
def convert_mark(mark_str, file_name): 
    if "h" in mark_str:
        print(f"Convert Mark: {mark_str}")
        mark_str = mark_str.replace("h", "0")
        print(f"Nach Ersetzung: {mark_str}")
    
    if mark_str == "":
        document_mapping["mark"]["raw_value"] = None
        document_mapping["mark"]["display_value"] = None
        document_mapping["mark"]["numeric_value"] = None
        document_mapping["mark"]["format_type"] = None
        document_mapping["mark"]["unit"] = None
        return
    
    #Punkte
    if ":" not in mark_str and "." not in mark_str:
        document_mapping["mark"]["raw_value"] = mark_str
        document_mapping["mark"]["display_value"] = mark_str
        document_mapping["mark"]["numeric_value"] = float(mark_str)
        document_mapping["mark"]["format_type"] = "Punkte"
        document_mapping["mark"]["unit"] = ""
        return

    #Zeiten unter einer Minute und Weiten
    if ":" not in mark_str and "." in mark_str:
        for char in file_name:
            if char.isdigit():
                # Sprintzeiten unter einer Minute
                document_mapping["mark"]["raw_value"] = mark_str
                document_mapping["mark"]["display_value"] = mark_str
                document_mapping["mark"]["numeric_value"] = float(mark_str)
                document_mapping["mark"]["format_type"] = "Sekunden"
                document_mapping["mark"]["unit"] = "s"
                return
            else:
                #Weiten
                document_mapping["mark"]["raw_value"] = mark_str
                document_mapping["mark"]["display_value"] = mark_str
                document_mapping["mark"]["numeric_value"] = float(mark_str)
                document_mapping["mark"]["format_type"] = "Meter"
                document_mapping["mark"]["unit"] = "m"
                return
    
    #Zeiten über einer Minute
    if ":" in mark_str:
        number_of_colons = mark_str.count(":")
        number_of_dots = mark_str.count(".")
        
        # 1 doppelpunkt und 1 punkt -> Minuten:Sekunden.Millisekunden
        if number_of_colons == 1 and number_of_dots == 1:
            minutes, rest = mark_str.split(":")
            seconds, milliseconds = rest.split(".")
            total_seconds = int(minutes) * 60 + int(seconds)
            total_time = f"{total_seconds}.{milliseconds}"
            document_mapping["mark"]["raw_value"] = mark_str
            document_mapping["mark"]["display_value"] = mark_str
            document_mapping["mark"]["numeric_value"] = float(total_time)
            document_mapping["mark"]["format_type"] = "Minuten"
            document_mapping["mark"]["unit"] = "min"
            return
        
        # 1 doppelpunkt und 0 punkte -> Minuten:Sekunden
        if number_of_colons == 1 and number_of_dots == 0:
            minutes, seconds = mark_str.split(":")
            total_seconds = int(minutes) * 60 + int(seconds)
            document_mapping["mark"]["raw_value"] = mark_str
            document_mapping["mark"]["display_value"] = mark_str
            document_mapping["mark"]["numeric_value"] = float(total_seconds)
            document_mapping["mark"]["format_type"] = "Minuten"
            document_mapping["mark"]["unit"] = "min"
            return
        
        # 2 doppelpunkte und 0 punkte -> Stunden:Minuten:Sekunden
        if number_of_colons == 2 and number_of_dots == 0:
            hours, minutes, seconds = mark_str.split(":")
            total_seconds = int(hours) * 3600 + int(minutes) * 60 + int(seconds)
            document_mapping["mark"]["raw_value"] = mark_str
            document_mapping["mark"]["display_value"] = mark_str
            document_mapping["mark"]["numeric_value"] = float(total_seconds)
            document_mapping["mark"]["format_type"] = "Stunden"
            document_mapping["mark"]["unit"] = "h"
            return
        
        # 1 doppelpunkt und 1 punkte -> Minuten:Sekunden.Millisekunden
        if number_of_colons == 1 and number_of_dots == 1:
            minutes, rest = mark_str.split(":")
            seconds, milliseconds = rest.split(".")
            total_seconds = int(minutes) * 60 + int(seconds)
            total_time = f"{total_seconds}.{milliseconds}"
            document_mapping["mark"]["raw_value"] = mark_str
            document_mapping["mark"]["display_value"] = mark_str
            document_mapping["mark"]["numeric_value"] = float(total_time)
            document_mapping["mark"]["format_type"] = "Stunden"
            document_mapping["mark"]["unit"] = "h"
            return
        
        # 2 doppelpunkte und 1 punkt -> Stunden:Minuten:Sekunden.Millisekunden
        if number_of_colons == 2 and number_of_dots == 1:
            hours, minutes, rest = mark_str.split(":")
            seconds, milliseconds = rest.split(".")
            total_seconds = int(hours) * 3600 + int(minutes) * 60 + int(seconds)
            total_time = f"{total_seconds}.{milliseconds}"
            document_mapping["mark"]["raw_value"] = mark_str
            document_mapping["mark"]["display_value"] = mark_str
            document_mapping["mark"]["numeric_value"] = float(total_time)
            document_mapping["mark"]["format_type"] = "Stunden"
            document_mapping["mark"]["unit"] = "h"
            return

def calculate_age_at_comp(date_venue, dob):
    from datetime import datetime
    if dob == "" or date_venue == "":
        document_mapping["age_at_competition"] = None
        document_mapping["dob"] = None
        document_mapping["date"] = None
        return
    
    month_map = {
        'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4,
        'MAY': 5, 'JUN': 6, 'JUL': 7, 'AUG': 8,
        'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
    }
    
    def to_date(date_str):
        number_of_chars = len(date_str)
        if number_of_chars == 11:
            day, month_str, year = date_str.split()
            month = month_map[month_str.upper()]
            return datetime(int(year), month, int(day))
        if number_of_chars == 8:
            month_str, year = date_str.split()
            month = month_map[month_str.upper()]
            return datetime(int(year), month, 1)
        elif number_of_chars == 4:
            year = date_str
            return datetime(int(year), 1, 1)
         
    dob_date = to_date(dob)
    comp_date = to_date(date_venue)
    
    #print(f"Geburtsdatum: {dob_date}, Wettkampdatum: {comp_date}")
    
     # Altersberechnung
    alter = comp_date.year - dob_date.year
    
    # Korrektur für Geburtstag, der noch nicht stattgefunden hat
    if (comp_date.month, comp_date.day) < (dob_date.month, dob_date.day):
        alter -= 1
    
    document_mapping["age_at_competition"] = alter
    document_mapping["dob"] = str(dob_date.date())
    document_mapping["date"] = str(comp_date.date())     

def convert_venue(venue_str):
    # Venue kann Land(in Klammern), Stadt und eventuell Stadion enthalten
    
    if venue_str is None or venue_str == "":
        return
    
    number_of_commas = venue_str.count(",")
    
    if number_of_commas == 0:
        klammer_start = venue_str.find("(")
        
        vor_klammer = venue_str[:klammer_start].strip()
        in_klammer = venue_str[klammer_start:].strip("()")
        document_mapping["venue"]["venue_raw"] = venue_str
        document_mapping["venue"]["city"] = vor_klammer
        document_mapping["venue"]["country"] = in_klammer
        document_mapping["venue"]["extra"] = ""
        document_mapping["venue"]["stadium"] = ""
        return 
    
    if number_of_commas == 1:
        stadium, rest = venue_str.split(",", 1)
        klammer_start = rest.find("(")
        
        vor_klammer = rest[:klammer_start].strip()
        in_klammer = rest[klammer_start:].strip("()")
        document_mapping["venue"]["venue_raw"] = venue_str
        document_mapping["venue"]["city"] = vor_klammer
        document_mapping["venue"]["country"] = in_klammer
        document_mapping["venue"]["extra"] = ""
        document_mapping["venue"]["stadium"] = stadium.strip()
        
        return
    elif number_of_commas == 2:
        stadium, city, rest = venue_str.split(",", 2)
        klammer_start = rest.find("(")
        vor_klammer = rest[:klammer_start].strip()
        in_klammer = rest[klammer_start:].strip("()")
        document_mapping["venue"]["venue_raw"] = venue_str
        document_mapping["venue"]["city"] = city.strip()
        document_mapping["venue"]["country"] = in_klammer
        document_mapping["venue"]["extra"] = vor_klammer
        document_mapping["venue"]["stadium"] = stadium.strip()
        return
        
def add_rest(competitor_str, nat_str, gender_folder, file_name, wold_rank):   
    if competitor_str == "":
        document_mapping["competitor"] = None
    else:
        document_mapping["competitor"] = competitor_str
        
    if nat_str == "":
        document_mapping["nat"] = None
    else:
        document_mapping["nat"] = nat_str   
        
    document_mapping["discipline"] = file_name.replace(".csv","")
    document_mapping["gender"] = gender_folder.capitalize()  
    document_mapping["world_rank"] = wold_rank
  
    
def add_index(client, index_name, document_id, document_body):
    try:
        response = client.index(
            index=index_name,
            id=document_id,
            body=document_body
        )
        
        print(f"Dokument erfolgreich erstellt!")
        print(f"Index: {response['_index']}")
        print(f"ID: {response['_id']}")
        print(f"Version: {response['_version']}")
    
    except Exception as e: 
        print(f"Fehler beim Erstellen des Dokuments: {e}")
    
phases = {
    "f": "Finale",
    "h": "Vorrunde",
    "er": "Extra",
    "sf": "Halbfinale",
    "sr": "Halbfinale",
    "pr": "Vorausscheid",
    "ce": "Kombiniert",
    "qf": "Viertelfinale",
    "q": "Qualifikation"
}  


client = OpenSearch(
    hosts = [{'host': 'localhost', 'port': 9200}],
    http_compress = True,
    use_ssl = False,
    verify_certs = False,
    ssl_show_warn = False,
    ssl_assert_hostname = False,
)

document_mapping = {
    "age_at_competition": int,
    "competitor": str,
    "date": str,
    "discipline": str,
    "dob": str,
    "gender": str,
    "mark": {
        "raw_value": str,
        "display_value": str,
        "numeric_value": float,
        "unit": str,
        "format_type": str,
    },
    "nat": str,
    "pos": {
        "raw_pos": str,
        "numeric_pos": int,
        "group": str,
        },
    "world_rank": int,
    "venue":{
        "venue_raw": str,
        "city": str,
        "country": str,
        "stadium": str,
        "extra": str,
    },
    "wind": float,
}

bad_words = ["", "Rank", "Results Score", "Unnamed: 6"]
good_words = ["Mark","WIND","Competitor","DOB","Nat","Pos","Venue","Date"]

id_number = 1
index_name = "sport-results"

data_path = "data"
# Durchsuche die Verzeichnisse
for folder_name in ["men","women"]:
    folder_path = os.path.join(data_path, folder_name)
    
    if os.path.isdir(folder_path):
        # Durchsuche die CSV-Dateien im Verzeichnis
        for file_name in os.listdir(folder_path):
            if file_name.lower().endswith('.csv'):
                file_path = os.path.join(folder_path, file_name)
                
                print(f"\n Datei: {file_name}")
                print("-" * 40)
                #Lese die CSV-Datei
                try:
                    with open(file_path, "r", encoding="utf-8") as csvfile:
                        csv_reader = csv.reader(csvfile)
                        
                        header = next(csv_reader, None)
                        if header:
                            print(f"Ordner: {folder_name} | Spaltenüberschriften: {header}")
                            
                        for row_num, row in enumerate(csv_reader, 1):
                            print(f"\n Verarbeitung Zeile {row_num}: {row}")
                            print(f"convert_position {row[4]}")
                            convert_position(row[4])
                            print(f"convert_mark")
                            convert_mark(row[0], file_name)
                            print("calculate_age_at_comp")
                            calculate_age_at_comp(row[6], row[2])
                            print("convert_venue")
                            convert_venue(row[5])
                            if len(row) > 7:
                                document_mapping["wind"] = row[7]
                            print("Add Rest")
                            add_rest(row[1], row[3], folder_name, file_name, row_num)
                            #add_index(client, index_name, id_number, document_mapping)
                            print(document_mapping)
                            id_number += 1
                            #break  # Nur die erste Datenzeile verarbeiten
                            
                except Exception as e:
                    print(f"Fehler beim Lesen der Datei {file_name}: {e}")
                    sys.exit()
    