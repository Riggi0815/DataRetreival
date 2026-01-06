import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String gender = "m";
  double lengthValue = 50;
  double timeValue = 10;

  final List<String> disciplines = [
    "100m",
    "200m",
    "400m",
    "Weitsprung",
    "Hochsprung",
    "Speerwurf",
  ];

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Person", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            TextField(decoration: const InputDecoration(labelText: "Nachname")),
            TextField(decoration: const InputDecoration(labelText: "Vorname")),

            const SizedBox(height: 8),
            const Text("Geschlecht"),
            RadioListTile(
              title: const Text("Männlich"),
              value: "m",
              groupValue: gender,
              onChanged: (v) => setState(() => gender = v!),
            ),
            RadioListTile(
              title: const Text("Weiblich"),
              value: "w",
              groupValue: gender,
              onChanged: (v) => setState(() => gender = v!),
            ),
            RadioListTile(
              title: const Text("Divers"),
              value: "d",
              groupValue: gender,
              onChanged: (v) => setState(() => gender = v!),
            ),

            DropdownButtonFormField(
              items: ["German", "Spanish", "French", "Japanese"]
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: (_) {},
              decoration: const InputDecoration(labelText: "Nationalität"),
            ),

            const Divider(),

            const Text("Sportliche Daten", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // Autocomplete Disziplin
            Autocomplete<String>(
              optionsBuilder: (text) {
                return disciplines.where(
                      (d) => d.toLowerCase().startsWith(text.text.toLowerCase()),
                );
              },
              fieldViewBuilder: (context, controller, focusNode, _) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: "Disziplin (suchen oder Dropdown)",
                  ),
                );
              },
            ),

            TextField(
              decoration: const InputDecoration(
                labelText: "Veranstaltungsort / Venue",
              ),
            ),

            const SizedBox(height: 8),

            // Datum
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Datum der Veranstaltung",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2030),
                      initialDate: DateTime.now(),
                    );
                    setState(() => selectedDate = date);
                  },
                ),
              ),
              controller: TextEditingController(
                text: selectedDate == null
                    ? ""
                    : "${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}",
              ),
            ),

            const SizedBox(height: 16),

            const Text("Längenangabe (Meter)"),
            Slider(
              min: 0,
              max: 100,
              value: lengthValue,
              onChanged: (v) => setState(() => lengthValue = v),
            ),

            const Text("Zeitangaben (Sekunden)"),
            Slider(
              min: 0,
              max: 20,
              value: timeValue,
              onChanged: (v) => setState(() => timeValue = v),
            ),

            TextField(
              decoration: const InputDecoration(labelText: "Bewertungspunkte"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Daten übernehmen"),
            ),
          ],
        ),
      ),
    );
  }
}
