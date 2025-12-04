import 'package:flutter/material.dart';
import 'log_history_page.dart';

class LogHistoryFilterPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const LogHistoryFilterPage({super.key, required this.user});

  @override
  State<LogHistoryFilterPage> createState() => _LogHistoryFilterPageState();
}

class _LogHistoryFilterPageState extends State<LogHistoryFilterPage> {
  String resultFilter = "All";
  String segmentFilter = "All";

  DateTime? startDate;
  DateTime? endDate;

  late List<String> segmentOptions;
  final resultOptions = ["All", "Match", "Mismatch"];

  @override
  void initState() {
    super.initState();

    final role = widget.user["role"].toString().toLowerCase();
    final segment = widget.user["segment"].toString().toUpperCase();

    if (role == "manager") {
      segmentOptions = ["All", segment];
    } else if (role == "salesman") {
      segmentOptions = [segment];
      segmentFilter = segment;
    } else {
      segmentOptions = ["All", "FMCG", "PIPES"];
    }
  }

  Future<void> pickStart() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (d != null) setState(() => startDate = d);
  }

  Future<void> pickEnd() async {
    final d = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (d != null) setState(() => endDate = d);
  }

  void applyFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogHistoryPage(
          user: widget.user,
          segment: segmentFilter,
          result: resultFilter,
          startDate: startDate,
          endDate: endDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007BFF),
              Color(0xFF66B2FF),
              Color(0xFFB8E0FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 BACK BUTTON + HEADING
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Filter Logs",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // WHITE CARD
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),

                  child: Column(
                    children: [
                      // SEGMENT DROPDOWN
                      DropdownButtonFormField(
                        decoration: inputDecor("Segment"),
                        value: segmentFilter,
                        items: segmentOptions
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => segmentFilter = v!),
                      ),

                      const SizedBox(height: 18),

                      DropdownButtonFormField(
                        decoration: inputDecor("Result"),
                        value: resultFilter,
                        items: resultOptions
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => resultFilter = v!),
                      ),

                      const SizedBox(height: 25),

                      // DATE ROW
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: pickStart,
                              style: dateBtn(),
                              child: Text(
                                startDate == null
                                    ? "Start Date"
                                    : "${startDate!.day}-${startDate!.month}-${startDate!.year}",
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: pickEnd,
                              style: dateBtn(),
                              child: Text(
                                endDate == null
                                    ? "End Date"
                                    : "${endDate!.day}-${endDate!.month}-${endDate!.year}",
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // SHOW LOGS BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: applyFilters,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Show Logs",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // TEXT FIELD / DROPDOWN DECORATION
  InputDecoration inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }

  // DATE BUTTON STYLE
  ButtonStyle dateBtn() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade100,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
