import 'package:data_retrieval/services/opensearch_service.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final SearchResult result;

  const DetailScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              context,
              title: "Athlet",
              children: [
                _buildDetailRow("Name", result.competitor),
                _buildDetailRow("Geschlecht", _formatGender(result.gender)),
                _buildDetailRow("Nationalität", result.nat),
                if (result.dob != null) _buildDetailRow("Geburtsdatum", result.dob!),
                if (result. ageAtCompetition != null)
                  _buildDetailRow("Alter bei Wettkampf", "${result. ageAtCompetition} Jahre"),
                if (result.worldRank != null)
                  _buildDetailRow("Weltrangliste", "#${result.worldRank}"),
              ],
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              title: "Leistung",
              children: [
                _buildDetailRow("Disziplin", result.discipline),
                _buildDetailRow("Ergebnis", result.mark.displayValue),
                _buildDetailRow("Position", result.pos.rawPos),
                if (result.wind != null)
                  _buildDetailRow("Wind", "${result.wind} m/s"),
              ],
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              title: "Wettkampf",
              children:  [
                _buildDetailRow("Datum", _formatDate(result.date)),
                _buildDetailRow("Ort", result.venue.city),
                if (result.venue.country. isNotEmpty)
                  _buildDetailRow("Land", result. venue.country),
                if (result.venue.stadium.isNotEmpty)
                  _buildDetailRow("Stadion", result. venue.stadium),
                if (result.venue.extra. isNotEmpty)
                  _buildDetailRow("Zusatzinfo", result.venue.extra),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:  Theme.of(context).textTheme.titleLarge?. copyWith(
                fontWeight:  FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding:  const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:  const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGender(String gender) {
    switch (gender. toLowerCase()) {
      case 'm':
        return 'Männlich';
      case 'w':
      case 'f':
        return 'Weiblich';
      case 'd':
        return 'Divers';
      default:
        return gender;
    }
  }

  String _formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return "${parts[2]}. ${parts[1]}.${parts[0]}";
      }
      return date;
    } catch (e) {
      return date;
    }
  }
}