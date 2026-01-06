import 'package:data_retrieval/screens/start_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AthleticsSearchApp());
}

class AthleticsSearchApp extends StatelessWidget {
  const AthleticsSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leichtathletik Suche',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}
