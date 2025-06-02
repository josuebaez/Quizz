import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic> progress = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    Map<String, dynamic> loaded = {};
    for (var key in keys) {
      loaded[key] = prefs.getInt(key) ?? 0;
    }
    setState(() {
      progress = loaded;
      isLoading = false;
    });
  }

  Widget _buildBarChartForTheme(String theme) {
    Map<String, int> filteredProgress = {};
    progress.forEach((key, value) {
      final parts = key.split('__');
      if (parts.length == 2 && parts[1] == theme) {
        filteredProgress[parts[0]] = value;
      }
    });

    List<BarChartGroupData> barGroups = [];
    List<String> xLabels = [];
    int index = 0;
    filteredProgress.forEach((tipo, score) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(toY: score.toDouble(), color: Colors.blue),
          ],
          showingTooltipIndicators: [0],
        ),
      );
      xLabels.add(tipo);
      index++;
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            theme.toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 300, // Altura fija para evitar conflictos de tamaño
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString());
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < xLabels.length) {
                          return Text(xLabels[idx], textAlign: TextAlign.center);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progreso del Usuario')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : progress.isEmpty
              ? const Center(child: Text('No hay progreso guardado'))
              : ListView(
                  children: [
                    _buildBarChartForTheme('Matemáticas'),
                    _buildBarChartForTheme('Astronomía'),
                    _buildBarChartForTheme('Historia'),
                    _buildBarChartForTheme('Cultura General'),
                  ],
                ),
    );
  }
}
