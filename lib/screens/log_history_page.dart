import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/log_service.dart';
import '../models/log_model.dart';

class LogHistoryPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final String segment;
  final String result;
  final DateTime? startDate;
  final DateTime? endDate;

  const LogHistoryPage({
    super.key,
    required this.user,
    required this.segment,
    required this.result,
    this.startDate,
    this.endDate,
  });

  @override
  State<LogHistoryPage> createState() => _LogHistoryPageState();
}

class _LogHistoryPageState extends State<LogHistoryPage> {
  final logService = LogService();
  List<LogModel> logs = [];
  bool loading = true;

  String search = "";

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    loading = true;
    setState(() {});

    List<dynamic> raw = await logService.getLogs();
    List<LogModel> all = raw.map((e) => LogModel.fromJson(e)).toList();

    final role = widget.user["role"].toString().toLowerCase();
    final userId = widget.user["user_id"]?.toString();
    final segment = widget.user["segment"]?.toUpperCase();

    List<LogModel> filtered = all;

    // SALES ONLY → Own logs
    if (role == "salesman") {
      filtered = filtered.where((l) => l.userId == userId).toList();
    }

    // MANAGER → segment only
    if (role == "manager") {
      filtered = filtered.where((l) => l.segment == segment).toList();
    }

    // FILTER PAGE → SEGMENT
    if (widget.segment != "All") {
      filtered = filtered
          .where((l) => l.segment.toUpperCase() == widget.segment.toUpperCase())
          .toList();
    }

    // FILTER PAGE → RESULT
    if (widget.result != "All") {
      filtered = filtered
          .where((l) => l.result.toLowerCase() == widget.result.toLowerCase())
          .toList();
    }

    // FILTER PAGE → DATE RANGE
    filtered = filtered.where((l) {
      try {
        final parts = l.date.split("-");
        final d = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final y = int.parse(parts[2]);
        final dt = DateTime(y, m, d);

        if (widget.startDate != null && dt.isBefore(widget.startDate!)) {
          return false;
        }
        if (widget.endDate != null && dt.isAfter(widget.endDate!)) {
          return false;
        }

        return true;
      } catch (e) {
        return false;
      }
    }).toList();

    logs = filtered;
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final matched =
        logs.where((l) => l.result.toLowerCase() == "match").length;
    final mismatched =
        logs.where((l) => l.result.toLowerCase() == "mismatch").length;

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
            children: [
              // 🔙 BACK BUTTON + TITLE
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Log History",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),

                  child: Column(
                    children: [
                      buildSearchBar(),
                      buildPieChart(matched, mismatched),
                      Expanded(child: buildList()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔍 SEARCH BAR
  Widget buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => search = v),
      decoration: InputDecoration(
        hintText: "Search shop...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // 🟢🔴 PIE CHART
  Widget buildPieChart(int match, int mismatch) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 220,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 45,
            sections: [
              PieChartSectionData(
                color: Colors.green,
                value: match.toDouble(),
                title: "Match\n$match",
                radius: 60,
              ),
              PieChartSectionData(
                color: Colors.red,
                value: mismatch.toDouble(),
                title: "Mismatch\n$mismatch",
                radius: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LIST OF LOGS
  Widget buildList() {
    if (loading) return const Center(child: CircularProgressIndicator());

    final result = logs.where((l) {
      return l.shopName.toLowerCase().contains(search.toLowerCase());
    }).toList();

    if (result.isEmpty) {
      return const Center(child: Text("No logs found"));
    }

    return ListView.builder(
      itemCount: result.length,
      itemBuilder: (_, i) {
        final log = result[i];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.store, color: Colors.blue),
            ),
            title: Text(
              log.shopName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${log.date} • ${log.time}\n${log.segment} | ${log.result}",
            ),
            trailing: Text(
              "${log.distance}m",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        );
      },
    );
  }
}
