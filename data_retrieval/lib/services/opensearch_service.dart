import 'dart:convert';
import 'package:data_retrieval/widgets/filter_sheet.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OpenSearchService {
  final String baseUrl = 'http://localhost:9200'; // oder deine Docker-IP
  final String indexName = 'sport-results';

  Future<List<String>> getAutocompleteSuggestions({
    required String prefix,
    SearchFieldType? searchField,
    String? gender,
    String? nationality,
    String? discipline,
  }) async {
    if (prefix.trim().isEmpty) {
      return [];
    }

    final mustClauses = <Map<String, dynamic>>[];

    // 🔥 MATCH_PHRASE_PREFIX für Autocomplete
    if (searchField != null) {
      String fieldName;

      switch (searchField) {
        case SearchFieldType.competitor:
          fieldName = "competitor"; // text field
          break;
        case SearchFieldType.city:
          fieldName = "venue.city.text"; // .text subfield verwenden!
          break;
        case SearchFieldType.country:
          fieldName = "venue.country.text"; // .text subfield verwenden!
          break;
        default:
          fieldName = "competitor";
      }

      mustClauses.add({
        "match_phrase_prefix": {
          fieldName: {
            "query": prefix,
            "max_expansions": 10,
            "slop": 3
          }
        }
      });
    } else {
      // Wenn kein spezifisches Feld gewählt ist, suche in allen relevanten Feldern
      mustClauses.add({
        "bool": {
          "should": [
            {
              "match_phrase_prefix": {
                "competitor": {
                  "query": prefix,
                  "max_expansions": 10,
                  "boost": 3
                }
              }
            },
            {
              "match_phrase_prefix": {
                "discipline": {
                  "query": prefix,
                  "max_expansions": 10,
                  "boost": 2
                }
              }
            },
            {
              "match_phrase_prefix": {
                "venue.city.text": { // .text verwenden
                  "query": prefix,
                  "max_expansions": 10,
                  "boost": 1
                }
              }
            },
            {
              "match_phrase_prefix": {
                "venue.country.text": { //.text verwenden
                  "query": prefix,
                  "max_expansions": 10,
                  "boost": 1
                }
              }
            }
          ],
          "minimum_should_match": 1
        }
      });
    }

    // Filter hinzufügen
    if (gender != null) {
      mustClauses.add({
        "term": {"gender": gender}
      });
    }

    if (nationality != null) {
      mustClauses.add({
        "term": {"nat": nationality}
      });
    }

    if (discipline != null) {
      mustClauses.add({
        "term": {"discipline.keyword": discipline}
      });
    }

    final body = jsonEncode({
      "query": {
        "bool": {"must": mustClauses}
      },
      "size": 10,
      "_source": ["competitor", "discipline", "venue.city", "venue.country"],
      "collapse": {
        "field": searchField == SearchFieldType.competitor
            ? "competitor.keyword"
            : (searchField == SearchFieldType.city
            ? "venue.city" // 🔥 keyword field für collapse
            : (searchField == SearchFieldType.country
            ? "venue.country" // 🔥 keyword field für collapse
            : "discipline.keyword"))
      }
    });

    final url = Uri.parse('$baseUrl/$indexName/_search');

    try {
      debugPrint('🔍 Autocomplete search: $url');
      debugPrint('📤 Request body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      //debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hits = data['hits']['hits'] as List;

        final suggestions = <String>{};

        for (var hit in hits) {
          final source = hit['_source'];

          // Je nach Suchfeld die passenden Vorschläge extrahieren
          if (searchField == SearchFieldType.competitor) {
            if (source['competitor'] != null) {
              suggestions.add(source['competitor']);
            }
          } else if (searchField == SearchFieldType.city) {
            if (source['venue'] != null && source['venue']['city'] != null) {
              suggestions.add(source['venue']['city']);
            }
          } else if (searchField == SearchFieldType.country) {
            if (source['venue'] != null && source['venue']['country'] != null) {
              suggestions.add(source['venue']['country']);
            }
          } else {
            // Alle relevanten Felder sammeln
            if (source['competitor'] != null) {
              suggestions.add(source['competitor']);
            }
            if (source['discipline'] != null) {
              suggestions.add(source['discipline']);
            }
            if (source['venue'] != null && source['venue']['city'] != null) {
              suggestions.add(source['venue']['city']);
            }
            if (source['venue'] != null && source['venue']['country'] != null) {
              suggestions.add(source['venue']['country']);
            }
          }
        }

        final result = suggestions.take(10).toList();
        debugPrint('✅ Found ${result.length} suggestions');
        return result;
      } else {
        debugPrint('❌ Autocomplete error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('💥 Exception in autocomplete: $e');
      return [];
    }
  }

  Future<List<SearchResult>> combinedSearch({
    required String query,
    String? firstName,
    String? lastName,
    String? gender,
    String? nationality,
    String? discipline,
    String? venue,
    DateTime? date,
    double? minTime,
    double? maxTime,
    double? minDistance,
    double? maxDistance,
    SearchFieldType? searchField,
  }) async {
    final mustClauses = <Map<String, dynamic>>[];

    debugPrint('🔍 combinedSearch called with: ');
    debugPrint('   query: "$query"');
    debugPrint('   query. trim().isNotEmpty: ${query.trim().isNotEmpty}');
    debugPrint('   firstName: $firstName');
    debugPrint('   lastName: $lastName');
    debugPrint('   searchField: $searchField');

    if (query.trim().isNotEmpty) {

      if (searchField != null) {
        // Spezifisches Feld durchsuchen
        List<String> fields = [];

        switch (searchField) {
          case SearchFieldType.competitor:
            fields = ["competitor^3"];
            break;
          case SearchFieldType.country:
            fields = [ "venue.country"];
            break;
          case SearchFieldType.city:
            fields = ["venue.city"];
            break;
        }
        mustClauses.add({
          "multi_match": {
            "query": query,
            "fields": fields,
            "type": "best_fields",
            "fuzziness": "AUTO",
          }
        });
      } else {
        // Standard:  Alle Felder durchsuchen
        mustClauses.add({
          "multi_match":  {
            "query": query,
            "fields": [
              "competitor^3",
              "discipline^2",
              "venue.city",
              "venue. country",
              "nat"
            ],
            "type": "best_fields",
            "fuzziness": "AUTO",
          }
        });
      }
    } else {
      debugPrint('⚠️ Query is empty, skipping multi_match');
    }

    // FILTER:  Nur wenn gesetzt
    if (firstName != null && firstName.isNotEmpty) {
      mustClauses.add({
        "match": {"competitor":  firstName}
      });
    }

    if (lastName != null && lastName.isNotEmpty) {
      mustClauses.add({
        "match": {"competitor":  lastName}
      });
    }

    if (gender != null) {
      mustClauses. add({
        "term": {"gender": gender}
      });
    }

    if (nationality != null) {
      mustClauses.add({
        "term": {"nat": nationality}
      });
    }

    if (discipline != null && discipline.isNotEmpty) {
      mustClauses.add({
        "match": {"discipline": discipline}
      });
    }

    if (venue != null && venue.isNotEmpty) {
      mustClauses.add({
        "multi_match": {
          "query": venue,
          "fields":  ["venue.city", "venue.venue_raw", "venue.country"]
        }
      });
    }

    if (date != null) {
      mustClauses.add({
        "match": {"date": date. toIso8601String().split('T')[0]}
      });
    }

    if (minTime != null || maxTime != null) {
      final rangeQuery = <String, dynamic>{};
      if (minTime != null) rangeQuery["gte"] = minTime;
      if (maxTime != null) rangeQuery["lte"] = maxTime;

      mustClauses.add({
        "range": {"mark. numeric_value": rangeQuery}
      });
    }

    if (minDistance != null || maxDistance != null) {
      final rangeQuery = <String, dynamic>{};
      if (minDistance != null) rangeQuery["gte"] = minDistance;
      if (maxDistance != null) rangeQuery["lte"] = maxDistance;

      mustClauses.add({
        "range": {"mark.numeric_value": rangeQuery}
      });
    }

    debugPrint('📋 Final mustClauses count: ${mustClauses.length}');
    debugPrint('📋 mustClauses: $mustClauses');

    final body = jsonEncode({
      "query": {
        "bool":  {
          "must": mustClauses.isEmpty ? [{"match_all": {}}] : mustClauses
        }
      },
      "size": 100,
    });

    final url = Uri.parse('$baseUrl/$indexName/_search');

    try {
      debugPrint('🔍 Combined search: $url');
      debugPrint('📤 Request body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response. body);
        final hits = data['hits']['hits'] as List;

        debugPrint('✅ Found ${hits.length} results');

        final results = <SearchResult>[];
        for (var i = 0; i < hits.length; i++) {
          try {
            final result = SearchResult.fromJson(hits[i]['_source'], hits[i]['_id']);
            results.add(result);
          } catch (e, stackTrace) {
            debugPrint('❌ Error parsing result $i: $e');
            debugPrint('📄 Problematic data: ${hits[i]['_source']}');
            debugPrint('Stack trace: $stackTrace');
          }
        }

        return results;
      } else {
        throw Exception('OpenSearch Fehler (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Exception in combinedSearch: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Verbindungsfehler zu OpenSearch: $e');
    }
  }
}

class SearchResult {
  final String id;
  final int?  ageAtCompetition;
  final String competitor;
  final String date;
  final String discipline;
  final String?  dob;
  final String gender;
  final Mark mark;
  final String nat;
  final Position pos;
  final int? worldRank;
  final Venue venue;
  final double?  wind;

  SearchResult({
    required this.id,
    this.ageAtCompetition,
    required this.competitor,
    required this.date,
    required this.discipline,
    this.dob,
    required this.gender,
    required this. mark,
    required this.nat,
    required this.pos,
    this.worldRank,
    required this.venue,
    this.wind,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json, String documentId) {
    try {

      return SearchResult(
        id: documentId,
        ageAtCompetition: _parseNullableInt(json['age_at_competition'], 'age_at_competition'),
        competitor: json['competitor']?. toString() ?? 'Unbekannt',
        date:  json['date']?.toString() ?? '',
        discipline: json['discipline']?.toString() ?? '',
        dob: json['dob']?.toString(),
        gender: json['gender']?.toString() ?? '',
        mark: Mark.fromJson(json['mark'] ?? {}, documentId),
        nat: json['nat']?.toString() ?? '',
        pos: Position.fromJson(json['pos'] ?? {}, documentId),
        worldRank: _parseNullableInt(json['world_rank'], 'world_rank'),
        venue: Venue.fromJson(json['venue'] ?? {}, documentId),
        wind: _parseNullableDouble(json['wind'], 'wind'),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in SearchResult.fromJson for document $documentId: $e');
      debugPrint('📄 JSON:  $json');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static int? _parseNullableInt(dynamic value, String fieldName) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        debugPrint('⚠️ Could not parse "$value" as int for field $fieldName');
        return null;
      }
    }
    debugPrint('⚠️ Unexpected type ${value.runtimeType} for int field $fieldName:  $value');
    return null;
  }

  static double?  _parseNullableDouble(dynamic value, String fieldName) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        debugPrint('⚠️ Could not parse "$value" as double for field $fieldName');
        return null;
      }
    }
    debugPrint('⚠️ Unexpected type ${value.runtimeType} for double field $fieldName: $value');
    return null;
  }
}

class Mark {
  final String rawValue;
  final String displayValue;
  final double numericValue;
  final String unit;
  final String formatType;

  Mark({
    required this.rawValue,
    required this.displayValue,
    required this.numericValue,
    required this. unit,
    required this.formatType,
  });

  factory Mark.fromJson(Map<String, dynamic> json, String documentId) {
    try {

      final numericValue = _parseDouble(json['numeric_value'], 'mark.numeric_value');

      return Mark(
        rawValue: json['raw_value']?. toString() ?? '',
        displayValue: json['display_value']?. toString() ?? '',
        numericValue: numericValue,
        unit: json['unit']?.toString() ?? '',
        formatType:  json['format_type']?.toString() ?? '',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in Mark.fromJson for document $documentId: $e');
      debugPrint('📄 JSON: $json');
      debugPrint('Stack trace:  $stackTrace');
      rethrow;
    }
  }

  static double _parseDouble(dynamic value, String fieldName) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        debugPrint('⚠️ Could not parse "$value" as double for field $fieldName, using 0.0');
        return 0.0;
      }
    }
    debugPrint('⚠️ Unexpected type ${value.runtimeType} for double field $fieldName: $value, using 0.0');
    return 0.0;
  }
}

class Position {
  final String rawPos;
  final int numericPos;
  final String group;

  Position({
    required this.rawPos,
    required this.numericPos,
    required this.group,
  });

  factory Position.fromJson(Map<String, dynamic> json, String documentId) {
    try {

      final numericPos = _parseInt(json['numeric_pos'], 'pos.numeric_pos');

      return Position(
        rawPos: json['raw_pos']?. toString() ?? '',
        numericPos: numericPos,
        group: json['group']?.toString() ?? '',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in Position.fromJson for document $documentId: $e');
      debugPrint('📄 JSON: $json');
      debugPrint('Stack trace:  $stackTrace');
      rethrow;
    }
  }

  static int _parseInt(dynamic value, String fieldName) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      try {
        return int. parse(value);
      } catch (e) {
        debugPrint('⚠️ Could not parse "$value" as int for field $fieldName, using 0');
        return 0;
      }
    }
    debugPrint('⚠️ Unexpected type ${value.runtimeType} for int field $fieldName: $value, using 0');
    return 0;
  }
}

class Venue {
  final String venueRaw;
  final String city;
  final String country;
  final String stadium;
  final String extra;

  Venue({
    required this.venueRaw,
    required this.city,
    required this.country,
    required this.stadium,
    required this.extra,
  });

  factory Venue.fromJson(Map<String, dynamic> json, String documentId) {
    try {

      return Venue(
        venueRaw: json['venue_raw']?.toString() ?? '',
        city: json['city']?. toString() ?? '',
        country:  json['country']?.toString() ?? '',
        stadium: json['stadium']?.toString() ?? '',
        extra: json['extra']?.toString() ?? '',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in Venue.fromJson for document $documentId: $e');
      debugPrint('📄 JSON: $json');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}