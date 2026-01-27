import 'package:data_retrieval/widgets/custom_search_bar.dart';
import 'package:data_retrieval/widgets/result_card.dart';
import 'package:data_retrieval/widgets/filter_sheet.dart';
import 'package:flutter/material.dart';

import '../services/opensearch_service.dart';
import 'detail_screen.dart';

class ResultScreen extends StatefulWidget {
  final String query;
  final FilterData? initialFilters;

  const ResultScreen({
    super.key,
    required this. query,
    this.initialFilters,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final OpenSearchService _searchService = OpenSearchService();
  late TextEditingController searchController;

  List<SearchResult> _results = [];
  bool _isLoading = true;
  String?  _errorMessage;
  String? _errorDetails;
  FilterData? _currentFilters;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.query);
    _currentFilters = widget.initialFilters;
    _performSearch(widget.query);
  }

  Future<void> _performSearch(String query) async {
    debugPrint('🔍 _performSearch called with query: "$query"');
    debugPrint('🔍 _currentFilters: $_currentFilters');
    debugPrint('🔍 hasActiveFilters: ${_currentFilters?. hasActiveFilters}');

    if (query.trim().isEmpty && !(_currentFilters?.hasActiveFilters ?? false)) {
      setState(() {
        _errorMessage = 'Das Suchfeld darf nicht leer sein! ';
        _errorDetails = null;
        _isLoading = false;
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorDetails = null;
    });

    try {
      final results = await _searchService.combinedSearch(
        query: query,
        firstName: _currentFilters?.firstName,
        lastName: _currentFilters?.lastName,
        gender: _currentFilters?. gender,
        nationality: _currentFilters?.nationality,
        discipline: _currentFilters?.discipline,
        venue: _currentFilters?.venue,
        date: _currentFilters?.eventDate,
        birthDate: _currentFilters?.birthDate,
        searchField: _currentFilters?.searchField,
      );

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler bei der Suche';
        _errorDetails = e.toString();
        _isLoading = false;
      });
    }
  }

  String _parseErrorMessage(String error) {
    if (error.contains('SocketException') || error.contains('Failed host lookup')) {
      return 'Verbindungsfehler\n\nOpenSearch-Server ist nicht erreichbar.\n'
          'Stelle sicher, dass der Server läuft (Docker).';
    }
    if (error.contains('Connection refused')) {
      return 'Verbindung abgelehnt.\n\n'
          'OpenSearch läuft nicht oder falsche Port-Konfiguration.';
    }
    if (error.contains('type') && error.contains('is not a subtype')) {
      return 'Datenformat-Fehler.\n\n'
          'Die Daten in OpenSearch haben ein falsches Format.\n'
          'Siehe Details unten für mehr Informationen.';
    }
    if (error.contains('404')) {
      return 'Index nicht gefunden.\n\n'
          'Der Index "sport-results" existiert nicht in OpenSearch.';
    }
    return 'Ein Fehler ist aufgetreten';
  }

  void _handleSearch(String value) {
    if (value.trim().isEmpty && !(_currentFilters?.hasActiveFilters ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Das Suchfeld darf nicht leer sein!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          query: value,
          initialFilters: _currentFilters,
        ),
      ),
    );
  }

  void _handleFilterApplied(FilterData filterData) {
    setState(() {
      _currentFilters = filterData. hasActiveFilters ? filterData :  null;
    });
    _performSearch(searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(  // <-- Füge WillPopScope hinzu
        onWillPop: () async {
          // Gib Suchtext und Filter zurück beim Zurücknavigieren
          Navigator.pop(context, {
            'query': searchController.text,
            'filters': _currentFilters,
          });
          return false; // false, weil wir bereits pop aufgerufen haben
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            title: const Text("Suchergebnisse"),
            centerTitle: true,
            leading: IconButton(  // <-- Überschreibe den Back-Button
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, {
                  'query': searchController.text,
                  'filters': _currentFilters,
                });
              },
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 16),

              // SearchBar mit Filter
              CustomSearchBar(
                controller: searchController,
                onSubmitted: _handleSearch,
                onFilterApplied: _handleFilterApplied,
                currentFilters: _currentFilters,
              ),

          const SizedBox(height: 8),

          // Active Filters Chips
          if (_currentFilters?.hasActiveFilters ?? false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child:  Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildFilterChips(),
              ),
            ),

          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    )
    );
  }

  List<Widget> _buildFilterChips() {
    final chips = <Widget>[];

    // SearchField Chip
    if (_currentFilters?.searchField != null) {
      String label = '';
      IconData icon = Icons.search;

      switch (_currentFilters!.searchField!) {
        case SearchFieldType.competitor:
          label = 'Suche: Sportler';
          icon = Icons.person;
          break;
        case SearchFieldType.city:
          label = 'Suche: Stadt';
          icon = Icons.stadium;
          break;
        case SearchFieldType.country:
          label = 'Suche: Land';
          icon = Icons.public;
          break;
      }

      chips.add(
        Chip(
          avatar: Icon(icon, size: 16, color: Colors.blue.shade700),
          label: Text(label),
          backgroundColor: Colors.blue.shade100,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _currentFilters = FilterData(
                firstName: _currentFilters?.firstName,
                lastName: _currentFilters?.lastName,
                gender: _currentFilters?.gender,
                nationality: _currentFilters?.nationality,
                discipline: _currentFilters?.discipline,
                venue: _currentFilters?.venue,
                eventDate: _currentFilters?.eventDate,
                birthDate: _currentFilters?.birthDate,
                minLength: _currentFilters?.minLength,
                maxLength: _currentFilters?.maxLength,
                minTime: _currentFilters?.minTime,
                maxTime: _currentFilters?.maxTime,
                points: _currentFilters?.points,
                searchField: null, // <-- Nur searchField löschen
              );
            });
          },
        ),
      );
    }

    if (_currentFilters?.firstName != null) {
      chips.add(_buildChip('Vorname: ${_currentFilters!.firstName}', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: null, // <-- Nur firstName löschen
            lastName: _currentFilters?.lastName,
            gender: _currentFilters?.gender,
            nationality: _currentFilters?.nationality,
            discipline: _currentFilters?.discipline,
            venue: _currentFilters?.venue,
            eventDate: _currentFilters?.eventDate,
            birthDate: _currentFilters?.birthDate,
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.lastName != null) {
      chips.add(_buildChip('Nachname: ${_currentFilters!.lastName}', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: null, // <-- Nur lastName löschen
            gender: _currentFilters?.gender,
            nationality: _currentFilters?.nationality,
            discipline: _currentFilters?.discipline,
            venue: _currentFilters?.venue,
            eventDate: _currentFilters?.eventDate,
            birthDate: _currentFilters?.birthDate,
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.gender != null) {
      final genderLabel = _currentFilters!.gender == 'Men' ? 'Männlich' : 'Weiblich';
      chips.add(_buildChip('Geschlecht: $genderLabel', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: _currentFilters?.lastName,
            gender: null, // <-- Nur gender löschen
            nationality: _currentFilters?.nationality,
            discipline: _currentFilters?.discipline,
            venue: _currentFilters?.venue,
            eventDate: _currentFilters?.eventDate,
            birthDate: _currentFilters?.birthDate,
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.nationality != null) {
      chips.add(_buildChip('Nationalität: ${_currentFilters!.nationality}', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: _currentFilters?.lastName,
            gender: _currentFilters?.gender,
            nationality: null, // <-- Nur nationality löschen
            discipline: _currentFilters?.discipline,
            venue: _currentFilters?.venue,
            eventDate: _currentFilters?.eventDate,
            birthDate: _currentFilters?.birthDate,
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.discipline != null) {
      chips.add(_buildChip('Disziplin: ${_currentFilters!.discipline}', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: _currentFilters?.lastName,
            gender: _currentFilters?.gender,
            nationality: _currentFilters?.nationality,
            discipline: null, // <-- Nur discipline löschen
            venue: _currentFilters?.venue,
            eventDate: _currentFilters?.eventDate,
            birthDate: _currentFilters?.birthDate,
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.venue != null) {
      chips.add(_buildChip('Ort: ${_currentFilters!.venue}', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: _currentFilters?.lastName,
            gender: _currentFilters?.gender,
            nationality: _currentFilters?.nationality,
            discipline: _currentFilters?.discipline,
            venue: null, // <-- Nur venue löschen
            eventDate: _currentFilters?.eventDate,
            birthDate: _currentFilters?.birthDate,
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.eventDate != null) {
      final date = _currentFilters!.eventDate!;
      chips.add(_buildChip('Datum: ${date.day}.${date.month}.${date.year}', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: _currentFilters?.lastName,
            gender: _currentFilters?.gender,
            nationality: _currentFilters?.nationality,
            discipline: _currentFilters?.discipline,
            venue: _currentFilters?.venue,
            eventDate: null, // <-- Nur eventDate löschen
            birthDate: _currentFilters?.birthDate,
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.birthDate != null) {
      final date = _currentFilters!.birthDate!;
      chips.add(_buildChip('Geburtstag: ${date.day}.${date.month}.${date.year}', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: _currentFilters?.lastName,
            gender: _currentFilters?.gender,
            nationality: _currentFilters?.nationality,
            discipline: _currentFilters?.discipline,
            venue: _currentFilters?.venue,
            eventDate: _currentFilters?.eventDate,
            birthDate: null, // <-- Nur birthDate löschen
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.minLength != null || _currentFilters?.maxLength != null) {
      final min = _currentFilters?.minLength ?? 0;
      final max = _currentFilters?.maxLength ?? 100;
      chips.add(_buildChip('Länge: ${min.toInt()}-${max.toInt()}m', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: _currentFilters?.lastName,
            gender: _currentFilters?.gender,
            nationality: _currentFilters?.nationality,
            discipline: _currentFilters?.discipline,
            venue: _currentFilters?.venue,
            eventDate: _currentFilters?.eventDate,
            birthDate: _currentFilters?.birthDate,
            minLength: null, // <-- Länge löschen
            maxLength: null,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.minTime != null || _currentFilters?.maxTime != null) {
      chips.add(_buildChip('Zeit gefiltert', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: _currentFilters?.lastName,
            gender: _currentFilters?.gender,
            nationality: _currentFilters?.nationality,
            discipline: _currentFilters?.discipline,
            venue: _currentFilters?.venue,
            eventDate: _currentFilters?.eventDate,
            birthDate: _currentFilters?.birthDate,
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: null, // <-- Zeit löschen
            maxTime: null,
            points: _currentFilters?.points,
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    if (_currentFilters?.points != null) {
      chips.add(_buildChip('Punkte: ${_currentFilters!.points}', () {
        setState(() {
          _currentFilters = FilterData(
            firstName: _currentFilters?.firstName,
            lastName: _currentFilters?.lastName,
            gender: _currentFilters?.gender,
            nationality: _currentFilters?.nationality,
            discipline: _currentFilters?.discipline,
            venue: _currentFilters?.venue,
            eventDate: _currentFilters?.eventDate,
            birthDate: _currentFilters?.birthDate,
            minLength: _currentFilters?.minLength,
            maxLength: _currentFilters?.maxLength,
            minTime: _currentFilters?.minTime,
            maxTime: _currentFilters?.maxTime,
            points: null, // <-- Nur points löschen
            searchField: _currentFilters?.searchField,
          );
        });
      }));
    }

    // Clear all filters chip (nur wenn es andere Chips gibt)
    if (chips.isNotEmpty) {
      chips.add(
        ActionChip(
          label: const Text('Alle löschen'),
          onPressed: () {
            setState(() {
              _currentFilters = null;  // Alle Filter löschen
            });
          },
          backgroundColor: Colors.red.shade100,
        ),
      );
    }

    return chips;
  }

// Aktualisiere die _buildChip Methode mit onDeleted Parameter
  Widget _buildChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.deepPurple.shade100,
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Suche läuft... '),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child:  Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_errorDetails != null) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Technische Details anzeigen'),
                  children:  [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:  BorderRadius.circular(8),
                      ),
                      child:  SelectableText(
                        _errorDetails!,
                        style:  const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton. icon(
                    onPressed:  () => _performSearch(widget.query),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Erneut versuchen'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label:  const Text('Zurück'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child:  Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons. search_off,
                size:  64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Keine Ergebnisse gefunden',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _currentFilters?.hasActiveFilters ?? false
                    ? 'Keine Treffer für die gewählten Filter.\nVersuche es mit weniger Filtern.'
                    : 'Für "${widget.query}" wurden keine Treffer gefunden.\nVersuche es mit anderen Suchbegriffen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical:  8),
          child: Text(
            '${_results.length} Ergebnis${_results.length != 1 ? "se" : ""} gefunden',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final result = _results[i];
              return ResultCard(
                title: result.competitor,
                subtitle: "${result.discipline} • ${result. ageAtCompetition} Jahre",
                meta: "${result.mark. displayValue} • ${result.venue.city} • ${result.venue.country} • ${_formatDate(result.date)}",
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:  (_) => DetailScreen(result: result),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _getAgeCategory(int?  age) {
    if (age == null) return 'Erwachsene';
    if (age < 16) return 'U16';
    if (age < 18) return 'U18';
    if (age < 20) return 'U20';
    if (age < 23) return 'U23';
    return 'Erwachsene';
  }

  String _formatDate(String date) {
    try {
      final parts = date. split('-');
      if (parts.length >= 1) {
        return parts[0]; // Jahr
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}