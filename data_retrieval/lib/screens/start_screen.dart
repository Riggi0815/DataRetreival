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

  void _handleSearch(String value) {
    if (value.trim().isEmpty && !(_currentFilters?.hasActiveFilters ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Das Suchfeld darf nicht leer sein! '),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
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

    if (_currentFilters?.searchField != null) {
      String label = '';
      IconData icon = Icons.search;

      switch (_currentFilters! .searchField!) {
        case SearchFieldType.competitor:
          label = 'Suche: Sportler';
          icon = Icons.person;
          break;
        case SearchFieldType.city:
          label = 'Suche: Stadt';
          icon = Icons.stadium;
          break;
        case SearchFieldType.country:
          label = 'Suche:  Land';
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
                searchField: null,
              );
            });
          },
        ),
      );
    }

    if (_currentFilters?.firstName != null) {
      chips.add(_buildChip('Vorname:  ${_currentFilters! .firstName}'));
    }
    if (_currentFilters?.lastName != null) {
      chips.add(_buildChip('Nachname: ${_currentFilters! .lastName}'));
    }
    if (_currentFilters?.gender != null) {
      final genderLabel = _currentFilters!.gender == 'm' ? 'Männlich' : 'Weiblich';
      chips.add(_buildChip('Geschlecht: $genderLabel'));
    }
    if (_currentFilters?.nationality != null) {
      chips.add(_buildChip('Nationalität: ${_currentFilters! .nationality}'));
    }
    if (_currentFilters?.discipline != null) {
      chips.add(_buildChip('Disziplin: ${_currentFilters!.discipline}'));
    }
    if (_currentFilters?.venue != null) {
      chips.add(_buildChip('Ort: ${_currentFilters!.venue}'));
    }
    if (_currentFilters?.eventDate != null) {
      final date = _currentFilters!.eventDate! ;
      chips.add(_buildChip('Datum: ${date. day}. ${date.month}.${date. year}'));
    }
    if (_currentFilters?.birthDate != null) {
      final date = _currentFilters!. birthDate!;
      chips. add(_buildChip('Geburtstag: ${date.day}.${date.month}.${date.year}'));
    }
    if (_currentFilters?.minLength != null || _currentFilters?.maxLength != null) {
      final min = _currentFilters?. minLength ?? 0;
      final max = _currentFilters?. maxLength ?? 100;
      chips.add(_buildChip('Länge: ${min.toInt()}-${max.toInt()}m'));
    }
    if (_currentFilters?.minTime != null || _currentFilters?. maxTime != null) {
      chips.add(_buildChip('Zeit gefiltert'));
    }
    if (_currentFilters?.points != null) {
      chips.add(_buildChip('Punkte: ${_currentFilters! .points}'));
    }

    // Clear all filters chip
    if (chips.isNotEmpty) {
      chips.add(
        ActionChip(
          label: const Text('Alle löschen'),
          onPressed: () {
            setState(() {
              _currentFilters = null;  // ✅ null statt FilterData()
            });
          },
          backgroundColor: Colors.red.shade100,
        ),
      );
    }

    return chips;
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.deepPurple.shade100,
      side: BorderSide(
        color: Colors.deepPurple.shade200,
        width: 1,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
