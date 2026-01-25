import 'package:flutter/material.dart';

enum SearchFieldType {
  competitor,  // Sportler
  city,  // Stadt
  country,     // Stadt
}

class FilterData {
  String? lastName;
  String? firstName;
  String? gender;
  String? nationality;
  String? discipline;
  String? venue;
  DateTime? eventDate;
  double?  minLength;
  double? maxLength;
  TimeOfDay?  minTime;
  TimeOfDay?  maxTime;
  String? points;
  DateTime? birthDate;
  SearchFieldType? searchField;

  FilterData({
    this.lastName,
    this.firstName,
    this. gender,
    this.nationality,
    this.discipline,
    this.venue,
    this. eventDate,
    this.minLength,
    this.maxLength,
    this.minTime,
    this.maxTime,
    this.points,
    this.birthDate,
    this.searchField,
  });

  bool get hasActiveFilters =>
      (lastName != null && lastName! .isNotEmpty) ||
          (firstName != null && firstName!. isNotEmpty) ||
          gender != null ||
          nationality != null ||
          (discipline != null && discipline!.isNotEmpty) ||
          (venue != null && venue!.isNotEmpty) ||
          eventDate != null ||
          (minLength != null && minLength!  > 0) ||
          (maxLength != null && maxLength!  < 100) ||
          minTime != null ||
          maxTime != null ||
          (points != null && points!.isNotEmpty) ||
          birthDate != null ||
          searchField != null;

}

class FilterSheet extends StatefulWidget {
  final FilterData? initialFilters;

  const FilterSheet({super.key, this.initialFilters});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TextEditingController lastNameController;
  late TextEditingController firstNameController;
  late TextEditingController disciplineController;
  late TextEditingController nationalityController;
  late TextEditingController venueController;
  late TextEditingController pointsController;

  String? selectedGender;
  String? selectedNationality;
  DateTime? selectedEventDate;
  DateTime? selectedBirthDate;

  double minLengthValue = 0;
  double maxLengthValue = 100;

  TimeOfDay?  startTime;
  TimeOfDay?  endTime;

  SearchFieldType? selectedSearchField;

  final Map<String, String> nationalityMap = {
    "Niederländische Antillen (historisch)": "AHO",
    "Anguilla": "AIA",
    "Albanien": "ALB",
    "Algerien": "ALG",
    "Neutrale Athleten (Sonderteam)": "ANA",
    "Andorra": "AND",
    "Angola": "ANG",
    "Antigua und Barbuda": "ANT",
    "Argentinien": "ARG",
    "Armenien": "ARM",
    "Vereintes Arabisches Team (historisch, 1992)": "ART",
    "Aruba": "ARU",
    "Amerikanisch-Samoa": "ASA",
    "Australien": "AUS",
    "Österreich": "AUT",
    "Aserbaidschan": "AZE",

    "Bahamas": "BAH",
    "Bangladesch": "BAN",
    "Barbados": "BAR",
    "Burundi": "BDI",
    "Belgien": "BEL",
    "Benin": "BEN",
    "Bermuda": "BER",
    "Bosnien und Herzegowina": "BIH",
    "Belize": "BIZ",
    "Belarus (Weißrussland)": "BLR",
    "Bolivien": "BOL",
    "Botswana": "BOT",
    "Brasilien": "BRA",
    "Bahrain": "BRN",
    "Bulgarien": "BUL",
    "Burkina Faso": "BUR",

    "Zentralafrikanische Republik": "CAF",
    "Kanada": "CAN",
    "Cayman Islands": "CAY",
    "Republik Kongo": "CGO",
    "Tschad": "CHA",
    "Chile": "CHI",
    "China": "CHN",
    "Elfenbeinküste": "CIV",
    "Kamerun": "CMR",
    "Demokratische Republik Kongo": "COD",
    "Kolumbien": "COL",
    "Komoren": "COM",
    "Kap Verde": "CPV",
    "Costa Rica": "CRC",
    "Kroatien": "CRO",
    "Kuba": "CUB",
    "Zypern": "CYP",
    "Tschechien": "CZE",

    "Dänemark": "DEN",
    "Dschibuti": "DJI",
    "Dominica": "DMA",
    "Dominikanische Republik": "DOM",

    "Ecuador": "ECU",
    "Ägypten": "EGY",
    "Eritrea": "ERI",
    "El Salvador": "ESA",
    "Spanien": "ESP",
    "Estland": "EST",
    "Äthiopien": "ETH",
    "Vereintes Team (historisch, 1992)": "EUN",

    "Fidschi": "FIJ",
    "Finnland": "FIN",
    "Frankreich": "FRA",
    "Bundesrepublik Deutschland (historisch)": "FRG",

    "Gabun": "GAB",
    "Gambia": "GAM",
    "Großbritannien": "GBR",
    "Deutsche Demokratische Republik (historisch)": "GDR",
    "Georgien": "GEO",
    "Deutschland": "GER",
    "Ghana": "GHA",
    "Griechenland": "GRE",
    "Grenada": "GRN",
    "Guatemala": "GUA",
    "Guinea": "GUI",
    "Guyana": "GUY",

    "Haiti": "HAI",
    "Hongkong (Sonderverwaltungszone)": "HKG",
    "Honduras": "HON",
    "Ungarn": "HUN",

    "Indonesien": "INA",
    "Indien": "IND",
    "Unabhängige Athleten (Sonderteam)": "INT",
    "Iran": "IRI",
    "Irland": "IRL",
    "Irak": "IRQ",
    "Island": "ISL",
    "Israel": "ISR",
    "Amerikanische Jungferninseln": "ISV",
    "Italien": "ITA",
    "Britische Jungferninseln": "IVB",

    "Jamaika": "JAM",
    "Jordanien": "JOR",
    "Japan": "JPN",

    "Kasachstan": "KAZ",
    "Kenia": "KEN",
    "Kirgisistan": "KGZ",
    "Südkorea": "KOR",
    "Saudi-Arabien": "KSA",
    "Kuwait": "KUW",

    "Lettland": "LAT",
    "Libyen": "LBA",
    "Libanon": "LBN",
    "Liberia": "LBR",
    "St. Lucia": "LCA",
    "Lesotho": "LES",
    "Litauen": "LTU",
    "Luxemburg": "LUX",

    "Madagaskar": "MAD",
    "Marokko": "MAR",
    "Malaysia": "MAS",
    "Malawi": "MAW",
    "Moldau": "MDA",
    "Mexiko": "MEX",
    "Mongolei": "MGL",
    "Mali": "MLI",
    "Malta": "MLT",
    "Montenegro": "MNE",
    "Mosambik": "MOZ",
    "Mauritius": "MRI",
    "Myanmar": "MYA",

    "Namibia": "NAM",
    "Nicaragua": "NCA",
    "Niederlande": "NED",
    "Nigeria": "NGR",
    "Niger": "NIG",
    "Norwegen": "NOR",
    "Neuseeland": "NZL",

    "Oman": "OMA",

    "Pakistan": "PAK",
    "Panama": "PAN",
    "Paraguay": "PAR",
    "Peru": "PER",
    "Philippinen": "PHI",
    "Palästina": "PLE",
    "Papua-Neuguinea": "PNG",
    "Polen": "POL",
    "Portugal": "POR",
    "Nordkorea": "PRK",
    "Puerto Rico": "PUR",

    "Katar": "QAT",

    "Rumänien": "ROU",
    "Südafrika": "RSA",
    "Russland": "RUS",
    "Ruanda": "RWA",

    "Samoa": "SAM",
    "Serbien und Montenegro (historisch)": "SCG",
    "Senegal": "SEN",
    "Seychellen": "SEY",
    "Singapur": "SGP",
    "St. Kitts und Nevis": "SKN",
    "Sierra Leone": "SLE",
    "Slowenien": "SLO",
    "San Marino": "SMR",
    "Somalia": "SOM",
    "Serbien": "SRB",
    "Sri Lanka": "SRI",
    "Südsudan": "SSD",
    "São Tomé und Príncipe": "STP",
    "Sudan": "SUD",
    "Schweiz": "SUI",
    "Suriname": "SUR",
    "Slowakei": "SVK",
    "Schweden": "SWE",
    "Eswatini (ehemals Swasiland)": "SWZ",
    "Syrien": "SYR",

    "Tansania": "TAN",
    "Tonga": "TGA",
    "Thailand": "THA",
    "Tadschikistan": "TJK",
    "Turkmenistan": "TKM",
    "Turks- und Caicosinseln": "TKS",
    "Togo": "TOG",
    "Chinesisch Taipeh (Taiwan)": "TPE",
    "Trinidad und Tobago": "TTO",
    "Tunesien": "TUN",
    "Türkei": "TUR",

    "Vereinigte Arabische Emirate": "UAE",
    "Uganda": "UGA",
    "Ukraine": "UKR",
    "Sowjetunion (historisch)": "URS",
    "Uruguay": "URU",
    "Vereinigte Staaten von Amerika": "USA",
    "Usbekistan": "UZB",

    "Venezuela": "VEN",
    "Vietnam": "VIE",
    "St. Vincent und die Grenadinen": "VIN",

    "Jugoslawien (historisch)": "YUG",

    "Sambia": "ZAM",
    "Simbabwe": "ZIM"
  };


  final List<String> disciplines = [
    "10000m",
    "10000m Gehen",
    "1000m",
    "100m",
    "100m Huerden",
    "10km",
    "10km Gehen",
    "110m Huerden",
    "1500m",
    "15km",
    "20000m Gehen",
    "2000m",
    "2000m Hindernislauf",
    "200m",
    "20km",
    "20km Gehen",
    "3000m",
    "3000m Gehen",
    "3000m Hindernislauf",
    "300m",
    "30km Gehen",
    "35km Gehen",
    "400m",
    "400m Huerden",
    "4x100m",
    "4x1500m",
    "4x200m",
    "4x400m",
    "4x800m",
    "5000m",
    "5000m Gehen",
    "50km Gehen",
    "5km",
    "5km Gehen",
    "600m",
    "800m",
    "Diskuswurf",
    "Dreisprung",
    "Halbmarathon 21km",
    "Hammerwurf",
    "Hochsprung",
    "Kugelstossen",
    "Marathon 42km",
    "Siebenkampf",
    "Speerwurf",
    "Stabhochsprung",
    "Weitsprung",
    "Zehnkampf"
  ];

  @override
  void initState() {
    super.initState();
    lastNameController = TextEditingController(text: widget.initialFilters?. lastName);
    firstNameController = TextEditingController(text: widget.initialFilters?.firstName);
    disciplineController = TextEditingController(text: widget.initialFilters?.discipline);
    venueController = TextEditingController(text: widget.initialFilters?.venue);
    pointsController = TextEditingController(text: widget. initialFilters?.points);

    nationalityController = TextEditingController(
        text: widget.initialFilters?.nationality != null
            ? _getNationalityDisplayName(widget.initialFilters!.nationality!)
            : ''
    );

    selectedGender = widget.initialFilters?. gender;
    selectedNationality = widget.initialFilters?.nationality;
    selectedEventDate = widget.initialFilters?.eventDate;
    selectedBirthDate = widget.initialFilters?.birthDate;
    selectedSearchField = widget.initialFilters?.searchField;

    if (widget.initialFilters?.minLength != null) {
      minLengthValue = widget.initialFilters!.minLength!;
    }
    if (widget.initialFilters?.maxLength != null) {
      maxLengthValue = widget.initialFilters!. maxLength!;
    }

    startTime = widget.initialFilters?.minTime;
    endTime = widget.initialFilters?.maxTime;
  }

  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    disciplineController.dispose();
    venueController.dispose();
    pointsController.dispose();
    nationalityController.dispose();
    super.dispose();
  }
  String? _getNationalityDisplayName(String abbreviation) {
    return nationalityMap.entries
        .firstWhere(
          (entry) => entry.value == abbreviation,
      orElse: () => MapEntry(abbreviation, abbreviation),
    )
        .key;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child:  Column(
            crossAxisAlignment:  CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header mit Titel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  const Text(
                    "Filteroptionen",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:  FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // NEUE SEKTION: Suchfelder spezifizieren
              _buildSearchFieldsSection(),
              const SizedBox(height:  16),

              // Person Section
              _buildSectionCard(
                icon: Icons.person,
                title: "Person Filter",
                children: [
                  /*
                  TextField(
                    controller: lastNameController,
                    decoration:  const InputDecoration(
                      labelText: "Nachname, Vorname",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  */
                  // Geschlecht & Nationalität Row
                  Row(
                    children: [
                      // Geschlecht Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment:  CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Geschlecht",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildGenderRadio("Weiblich", "Women"),
                            _buildGenderRadio("Männlich", "Men"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Nationalität Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Nationalität",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Autocomplete<String>(
                              initialValue: TextEditingValue(text: nationalityController.text),
                              optionsBuilder: (textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return nationalityMap.keys; // Zeige alle Länder
                                }
                                return nationalityMap.keys.where((countryName) =>
                                    countryName.toLowerCase().contains(
                                        textEditingValue.text.toLowerCase()
                                    )
                                );
                              },
                              onSelected: (value) {
                                nationalityController.text = value;
                                selectedNationality = value;
                              },
                              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: const InputDecoration(
                                    hintText: "Land eingeben oder suchen",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Geburtstag
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Geburtstag",
                      hintText: "DD/MM/YYYY",
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 20),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                            initialDate: selectedBirthDate ?? DateTime(2000),
                          );
                          if (date != null) {
                            setState(() => selectedBirthDate = date);
                          }
                        },
                      ),
                    ),
                    controller: TextEditingController(
                      text: selectedBirthDate == null
                          ? ""
                          : "${selectedBirthDate!.day. toString().padLeft(2, '0')}/"
                          "${selectedBirthDate!. month.toString().padLeft(2, '0')}/"
                          "${selectedBirthDate! .year}",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sportliche xyz Section
              _buildSectionCard(
                icon: Icons.sports,
                title: "Wettkampf Filter",
                children: [
                  // Disziplin
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: disciplineController.text),
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return disciplines.where((d) =>
                          d.toLowerCase().contains(textEditingValue.text. toLowerCase()));
                    },
                    onSelected: (value) {
                      disciplineController.text = value;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: "Disziplin",
                          hintText: "Disziplin eingeben oder im Dropdown suchen",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Veranstaltungsort
                  TextField(
                    controller: venueController,
                    decoration: const InputDecoration(
                      labelText: "Veranstaltungsort / Venue",
                      hintText:  "Venue eingeben oder im Dropdown suchen",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Datum der Veranstaltung mit Kalender
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment:  CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Datum der Veranstaltung",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight. w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: "DD/MM/YYYY",
                                border: const OutlineInputBorder(),
                                isDense: true,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today, size: 20),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context:  context,
                                      firstDate: DateTime(1990),
                                      lastDate:  DateTime(2030),
                                      initialDate: selectedEventDate ?? DateTime. now(),
                                    );
                                    if (date != null) {
                                      setState(() => selectedEventDate = date);
                                    }
                                  },
                                ),
                              ),
                              controller: TextEditingController(
                                text:  selectedEventDate == null
                                    ? ""
                                    :  "${selectedEventDate!.day. toString().padLeft(2, '0')}/"
                                    "${selectedEventDate!.month. toString().padLeft(2, '0')}/"
                                    "${selectedEventDate!.year}",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Werte Section
                      /*
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Werte",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "0 - n max",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      */
                    ],
                  ),
                  /*
                  const SizedBox(height: 12),

                  // Längenangabe in Meter
                  const Text(
                    "Längenangabe in Meter",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RangeSlider(
                    min: 0,
                    max: 100,
                    values: RangeValues(minLengthValue, maxLengthValue),
                    onChanged: (values) {
                      setState(() {
                        minLengthValue = values.start;
                        maxLengthValue = values. end;
                      });
                    },
                    divisions: 100,
                    labels: RangeLabels(
                      minLengthValue.toStringAsFixed(0),
                      maxLengthValue.toStringAsFixed(0),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Zeitangaben
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Zeitangaben",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: "00:00:00 - n max",
                                border: const OutlineInputBorder(),
                                isDense: true,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.access_time, size: 20),
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: startTime ?? TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setState(() => startTime = time);
                                    }
                                  },
                                ),
                              ),
                              controller: TextEditingController(
                                text: startTime == null && endTime == null
                                    ? ""
                                    : "${startTime?. format(context) ?? '00:00:00'} - ${endTime?.format(context) ?? 'n max'}",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bewertungspunkte
                  TextField(
                    controller: pointsController,
                    decoration: const InputDecoration(
                      labelText: "Bewertungspunkte",
                      hintText: "Punkte",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType. number,
                  ),
                  */
                ],
              ),
              const SizedBox(height: 24),

              // Daten übernehmen Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final filterData = FilterData(
                      lastName: lastNameController.text. trim().isEmpty
                          ? null
                          :  lastNameController.text.trim(),
                      firstName: firstNameController.text.trim().isEmpty
                          ? null
                          : firstNameController.text.trim(),
                      gender: selectedGender,
                      nationality: selectedNationality != null
                          ? nationalityMap[selectedNationality]
                          : null,
                      discipline: disciplineController.text.trim().isEmpty
                          ? null
                          : disciplineController.text.trim(),
                      venue: venueController.text.trim().isEmpty
                          ? null
                          : venueController.text. trim(),
                      eventDate: selectedEventDate,
                      birthDate: selectedBirthDate,
                      minLength: minLengthValue > 0 ? minLengthValue : null,
                      maxLength: maxLengthValue < 100 ? maxLengthValue : null,
                      minTime: startTime,
                      maxTime: endTime,
                      points: pointsController.text.trim().isEmpty
                          ? null
                          : pointsController.text.trim(),
                      searchField: selectedSearchField,
                    );
                    Navigator.pop(context, filterData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor:  Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Daten übernehmen",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight. w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFieldsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, size: 24, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                "Suche spezifizieren",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors. blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Wähle aus, in welchen Feldern gesucht werden soll:",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height:  12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchFieldChip(
                label: "Sportler",
                icon: Icons.person,
                type: SearchFieldType.competitor,
              ),
              _buildSearchFieldChip(
                label: "Stadt",
                icon: Icons.location_city,
                type: SearchFieldType.city,
              ),
              _buildSearchFieldChip(
                label: "Land",
                icon: Icons.public,
                type: SearchFieldType.country,
              ),
            ],
          ),
          if (selectedSearchField == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Keine Auswahl = Suche in allen Feldern",
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey. shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchFieldChip({
    required String label,
    required IconData icon,
    required SearchFieldType type,
  }) {
    final isSelected = selectedSearchField == type;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors. white : Colors.blue.shade700),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectedSearchField = type;
          } else {
            selectedSearchField = null;
          }
        });
      },
      selectedColor: Colors.blue.shade600,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white :  Colors.blue.shade900,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.blue.shade600 : Colors.blue.shade300,
        width: 1.5,
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildGenderRadio(String label, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedGender,
          onChanged: (v) => setState(() => selectedGender = v),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Text(label, style: const TextStyle(fontSize:  14)),
      ],
    );
  }
}