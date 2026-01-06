import 'package:data_retrieval/screens/detail_screen.dart';
import 'package:data_retrieval/widgets/custom_search_bar.dart';
import 'package:data_retrieval/widgets/result_card.dart';
import 'package:flutter/material.dart';


class ResultScreen extends StatelessWidget {
  final String query;

  const ResultScreen({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController(text: query);

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
            onSubmitted: (value) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultScreen(query: value),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                return ResultCard(
                  title: "Max Mustermann",
                  subtitle: "100 m • U20",
                  meta: "12.34 s • Berlin • 2024",
                  icon: Icons.person,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DetailScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
