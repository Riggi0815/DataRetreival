from opensearchpy import OpenSearch
import json

# Client verbinden
client = OpenSearch(
    hosts=[{'host': 'localhost', 'port': 9200}],
    http_auth=('admin', 'admin'),  # Wenn benötigt
    use_ssl=False,
    verify_certs=False
)

index_name = "sport-results"

# OpenSearch-kompatibles Mapping
index_body = {
    "settings": {
        "index": {
            "number_of_shards": 2,
            "number_of_replicas": 1,
            "refresh_interval": "1s"
        },
        "analysis": {
            "analyzer": {
                "default": {
                    "type": "standard"
                }
            }
        }
    },
    "mappings": {
        "properties": {
            "age_at_competition": {
                "type": "integer"
            },
            "competitor": {
                "type": "text",
                "fields": {
                    "keyword": {
                        "type": "keyword",
                        "ignore_above": 256
                    }
                }
            },
            "date": {
                "type": "date",
                "format": "strict_date_optional_time||epoch_millis||yyyy-MM-dd"
            },
            "discipline": {
                "type": "keyword"
            },
            "dob": {
                "type": "date",
                "format": "strict_date_optional_time||epoch_millis||yyyy-MM-dd"
            },
            "gender": {
                "type": "keyword"
            },
            "mark": {
                "type": "object",
                "properties": {
                    "raw_value": {
                        "type": "text"
                    },
                    "display_value": {
                        "type": "text"
                    },
                    "numeric_value": {
                        "type": "float"
                    },
                    "unit": {
                        "type": "keyword"
                    },
                    "format_type": {
                        "type": "keyword"
                    }
                }
            },
            "nat": {
                "type": "keyword"
            },
            "pos": {
                "type": "object",
                "properties": {
                    "raw_pos": {
                        "type": "text"
                    },
                    "numeric_pos": {
                        "type": "integer"
                    },
                    "group": {
                        "type": "keyword"
                    }
                }
            },
            "world_rank": {
                "type": "integer"
            },
            "venue": {
                "type": "object",
                "properties": {
                    "venue_raw": {
                        "type": "text"
                    },
                    "city": {
                        "type": "keyword",
                        "fields": {
                            "text": {
                                "type": "text"
                            }
                        }
                    },
                    "country": {
                        "type": "keyword",
                        "fields": {
                            "text": {
                                "type": "text"
                            }
                        }
                    },
                    "stadium": {
                        "type": "text"
                    },
                    "extra": {
                        "type": "text"
                    }
                }
            },
            "wind": {
                "type": "float"
            }
        }
    }
}

# Index erstellen
try:
    response = client.indices.create(index=index_name, body=index_body)
    print(f"Index '{index_name}' erfolgreich erstellt:")
    print(json.dumps(response, indent=2, ensure_ascii=False))
except Exception as e:
    print(f"Fehler beim Erstellen des Index: {e}")