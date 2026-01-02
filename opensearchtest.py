from opensearchpy import OpenSearch


client = OpenSearch(
    hosts = [{'host': 'localhost', 'port': 9200}],
    http_compress = True,
    use_ssl = False,
    verify_certs = False,
    ssl_show_warn = False,
    ssl_assert_hostname = False,
)

document_id = "1"
    
index_name = "sport-results"
mark = "7.85m"

if mark.endswith('m'):
    mark_numeric = float(mark[:-1])
    mark_raw = mark
    mark_unit = "distance"

document = {
    "age_at_competition": 29,
    "competitor": "John Doe",
    "date": "2024-06-15",
    "discipline": "Long Jump",
    "gender": "Male",
    "mark": {
        "display_value": mark,
        "numeric_value": mark_numeric,
        "raw_value": mark_raw,
        "unit": mark_unit
    }
}

try:
    # Dokument hinzufügen (mit automatischer ID)
    response = client.index(
        index=index_name,
        id=document_id,
        body=document
    )
    
    print(f"Dokument erfolgreich erstellt!")
    print(f"Index: {response['_index']}")
    print(f"ID: {response['_id']}")
    print(f"Version: {response['_version']}")
    
except Exception as e: 
    print(f"Fehler beim Erstellen des Dokuments: {e}")