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
    // ✅ Debug-Print hinzufügen
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
      List<SearchResult> results;

      // ✅ Nutze IMMER combinedSearch wenn Text ODER Filter vorhanden
      if (_currentFilters?.hasActiveFilters ?? false || query.trim().isNotEmpty) {
        debugPrint('✅ Using combinedSearch');
        results = await _searchService.combinedSearch(
          query: query,
          firstName: _currentFilters?.firstName,
          lastName: _currentFilters?.lastName,
          gender: _currentFilters?.gender,
          nationality: _currentFilters?.nationality,
          discipline: _currentFilters?.discipline,
          venue: _currentFilters?.venue,
          date: _currentFilters?.eventDate,
        );
      } else {
        debugPrint('⚠️ No search criteria - returning empty results');
        results = [];
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _performSearch: $e');
      setState(() {
        _errorMessage = _parseErrorMessage(e.toString());
        _errorDetails = 'Details:\n$e\n\nStacktrace:\n$stackTrace';
        _isLoading = false;
        _results = [];
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Suchergebnisse"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // SearchBar mit Filter
          CustomSearchBar(
            controller: searchController,
            onSubmitted:  _handleSearch,
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
    );
  }

  List<Widget> _buildFilterChips() {
    final chips = <Widget>[];

    if (_currentFilters?.firstName != null) {
      chips.add(_buildChip('Vorname:  ${_currentFilters! .firstName}'));
    }
    if (_currentFilters?.lastName != null) {
      chips.add(_buildChip('Nachname: ${_currentFilters! .lastName}'));
    }
    if (_currentFilters?.gender != null) {
      chips.add(_buildChip('Geschlecht: ${_currentFilters!.gender}'));
    }
    if (_currentFilters?. nationality != null) {
      chips.add(_buildChip('Nationalität: ${_currentFilters!.nationality}'));
    }
    if (_currentFilters?. discipline != null) {
      chips.add(_buildChip('Disziplin: ${_currentFilters!.discipline}'));
    }
    if (_currentFilters?.venue != null) {
      chips.add(_buildChip('Ort: ${_currentFilters! .venue}'));
    }

    // Clear all filters chip
    if (chips.isNotEmpty) {
      chips.add(
        ActionChip(
          label: const Text('Alle löschen'),
          onPressed: () {
            setState(() {
              _currentFilters = null;  // ✅ Setze auf null statt leeres Objekt!
            });
            // ✅ Rufe Suche mit dem aktuellen Text auf
            _performSearch(searchController.text);
          },
          backgroundColor: Colors.red. shade100,
        ),
      );
    }

    return chips;
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.deepPurple.shade100,
      //deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        // Implement individual filter removal if needed
      },
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
                subtitle: "${result.discipline} • ${_getAgeCategory(result. ageAtCompetition)}",
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