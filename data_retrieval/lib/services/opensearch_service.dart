import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OpenSearchService {
  final String baseUrl = 'http://localhost:9200'; // oder deine Docker-IP
  final String indexName = 'sport-results';

  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) {
      throw Exception('Suchfeld darf nicht leer sein');
    }

    final url = Uri.parse('$baseUrl/$indexName/_search');

    // Multi-Match Query für mehrere Felder
    final body = jsonEncode({
      "query": {
        "multi_match": {
          "query":  query,
          "fields": [
            "competitor^3",
            "discipline^2",
            "venue.city",
            "venue.country",
            "nat"
          ],
          "type":  "best_fields",
          "fuzziness": "AUTO"
        }
      },
      "size": 50,
      "sort": [
        {"world_rank": {"order": "asc", "missing": "_last"}},
        {"date": {"order": "desc"}}
      ]
    });

    try {
      debugPrint('🔍 Searching OpenSearch:  $url');
      debugPrint('📤 Request body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
      debugPrint('💥 Exception in search: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Verbindungsfehler zu OpenSearch: $e');
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
  }) async {
    final mustClauses = <Map<String, dynamic>>[];

    // ✅ FUZZY SEARCH auf dem Suchfeld-Text (wenn nicht leer)
    if (query.trim().isNotEmpty) {
      mustClauses.add({
        "multi_match": {
          "query": query,
          "fields": [
            "competitor^3",
            "discipline^2",
            "venue.city",
            "venue.country",
            "nat"
          ],
          "type": "best_fields",
          "fuzziness": "AUTO"
        }
      });
    }

    // ✅ FILTER:  Nur wenn gesetzt
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

    final body = jsonEncode({
      "query": {
        "bool":  {
          "must": mustClauses. isEmpty ? [{"match_all": {}}] : mustClauses
        }
      },
      "size": 100,
      "sort": [
        {"world_rank": {"order": "asc", "missing": "_last"}},
        {"date": {"order": "desc"}}
      ]
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

  Future<List<SearchResult>> advancedSearch({
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
  }) async {
    final mustClauses = <Map<String, dynamic>>[];

    if (firstName != null && firstName.isNotEmpty) {
      mustClauses.add({
        "match": {"competitor":  firstName}
      });
    }

    if (lastName != null && lastName.isNotEmpty) {
      mustClauses.add({
        "match": {"competitor": lastName}
      });
    }

    if (gender != null) {
      mustClauses. add({
        "term": {"gender": gender}
      });
    }

    if (nationality != null) {
      mustClauses. add({
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
          "fields":  ["venue.city", "venue. venue_raw", "venue.country"]
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
        "range": {"mark.numeric_value": rangeQuery}
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

    final body = jsonEncode({
      "query": {
        "bool":  {
          "must": mustClauses. isEmpty ? [{"match_all": {}}] : mustClauses
        }
      },
      "size": 100,
      "sort": [
        {"world_rank": {"order": "asc", "missing": "_last"}},
        {"date": {"order": "desc"}}
      ]
    });

    final url = Uri.parse('$baseUrl/$indexName/_search');

    try {
      debugPrint('🔍 Advanced search: $url');
      debugPrint('📤 Request body:  $body');

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
      debugPrint('💥 Exception in advancedSearch: $e');
      debugPrint('Stack trace:  $stackTrace');
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
      debugPrint('🔄 Parsing document: $documentId');
      debugPrint('📄 JSON data: $json');

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
      debugPrint('🔄 Parsing Mark for document $documentId');

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
      debugPrint('🔄 Parsing Position for document $documentId');

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
      debugPrint('🔄 Parsing Venue for document $documentId');

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