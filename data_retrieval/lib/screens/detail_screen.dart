import 'package:data_retrieval/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String athleteName;
  final String birthDate;
  final int points;
  final List<Map<String, String>> competitions;

  const DetailScreen({
    super.key,
    this.athleteName = "Max Mustermann",
    this.birthDate = "01.01.2006",
    this.points = 1234,
    this.competitions = const [
      {
        "event": "100 m",
        "place": "1",
        "location": "Berlin",
        "result": "12,34 s",
        "date": "01.05.2024",
      },
      {
        "event": "Weitsprung",
        "place": "2",
        "location": "Hamburg",
        "result": "6,45 m",
        "date": "12.06.2024",
      },
    ],
  });

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController(text: athleteName);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Detailansicht"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SearchBar
            CustomSearchBar(
              controller: searchController,
              onSubmitted: (value) {
                // Optional: neue Suche starten
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 16),

            // Basisinformationen Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athleteName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Geburtsdatum: $birthDate"),
                    const SizedBox(height: 4),
                    Text("Bewertungspunkte: $points"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Wettkämpfe",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Wettbewerbe Liste
            Column(
              children: competitions.map((competition) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          competition["event"] ?? "",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Rang: ${competition["place"]}"),
                        Text("Ort: ${competition["location"]}"),
                        Text("Ergebnis: ${competition["result"]}"),
                        Text("Datum: ${competition["date"]}"),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
