import 'package:data_retrieval/widgets/custom_search_bar.dart';
import 'package:data_retrieval/widgets/result_card.dart';
import 'package:flutter/material.dart';

import '../services/opensearch_service.dart';
import 'detail_screen.dart';

class ResultScreen extends StatefulWidget {
  final String query;

  const ResultScreen({
    super.key,
    required this. query,
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

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.query);
    _performSearch(widget.query);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Das Suchfeld darf nicht leer sein! ';
        _errorDetails = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorDetails = null;
    });

    try {
      final results = await _searchService.search(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = _getReadableErrorMessage(e. toString());
        _errorDetails = 'Technische Details:\n${e.toString()}\n\nStack Trace:\n${stackTrace. toString()}';
        _isLoading = false;
      });
    }
  }

  String _getReadableErrorMessage(String error) {
    if (error.contains('SocketException') || error.contains('Failed host lookup')) {
      return 'Keine Verbindung zu OpenSearch möglich.\n\n'
          'Bitte überprüfe:\n'
          '• Läuft Docker?\n'
          '• Ist OpenSearch gestartet?  (docker-compose ps)\n'
          '• Richtige URL in opensearch_service.dart? ';
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
    if (value.trim().isEmpty) {
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
        builder: (_) => ResultScreen(query: value),
      ),
    );
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

          // Identische SearchBar wie auf der Startseite
          CustomSearchBar(
            controller: searchController,
            onSubmitted: _handleSearch,
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
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
        child:  SingleChildScrollView(
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
                'Fehler',
                style:  Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                ),
              ),
              if (_errorDetails != null) ...[
                const SizedBox(height: 24),
                ExpansionTile(
                  title: const Text('Technische Details anzeigen'),
                  children:  [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey[200],
                      child: SelectableText(
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
                style: Theme. of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Für "${widget.query}" wurden keine Treffer gefunden.\nVersuche es mit anderen Suchbegriffen.',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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