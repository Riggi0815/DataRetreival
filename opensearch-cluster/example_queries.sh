# Allgemeine Suche
curl "http://localhost:9200/search?q=rock"

# Suche nach Künstler
curl "http://localhost:5000/search/artist?artist=Queen"

# Suche nach Genre
curl "http://localhost:5000/search/genre?genre=Rock"

# Suche nach Jahresbereich
curl "http://localhost:5000/search/year?from=1970&to=1980"

# Statistiken abrufen
curl "http://localhost:5000/stats"

# Direkte OpenSearch Query
curl -X GET "localhost:9200/music_database/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  }
}
'