import 'package:data_retrieval/widgets/custom_search_bar.dart';
import 'package:data_retrieval/widgets/filter_sheet.dart';
import 'package:flutter/material.dart';
import 'result_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController searchController = TextEditingController();
  FilterData? _currentFilters;

  void _handleSearch(String value) async {  // <-- async hinzufügen
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

    // Navigation mit await - wartet auf Rückgabe
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          query: value,
          initialFilters: _currentFilters,
        ),
      ),
    );

    // Wenn Daten zurückkommen, übernehme sie
    if (result != null) {
      setState(() {
        if (result['query'] != null) {
          searchController.text = result['query'];
        }
        if (result['filters'] != null) {
          _currentFilters = result['filters'];
        }
      });
    }
  }

  void _handleFilterApplied(FilterData filterData) {
    setState(() {
      _currentFilters = filterData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Headline
                Text(
                  "Leichtathletik Suche",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: const Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 12),

                // Subline
                Text(
                  "Suche nach allen Disziplinen, Sportlern und Bestzeiten auf der ganzen Welt.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 32),

                // Hero Image
                Image.asset(
                  'assets/images/StartseiteBild1.png',
                  height: size.height * 0.28,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                // SearchBar
                CustomSearchBar(
                  controller: searchController,
                  onSubmitted: _handleSearch,
                  onFilterApplied: _handleFilterApplied,
                  currentFilters: _currentFilters,
                ),

                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildFilterChips(),
                )
              ],
            ),
          ),
        ),
      ),
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
              _currentFilters = null;
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
