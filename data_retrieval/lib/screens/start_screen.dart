import 'package:data_retrieval/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'result_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Headline
                Text(
                  "Suche in der Leichtathletik",
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
                  onSubmitted: (value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultScreen(query: value),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
