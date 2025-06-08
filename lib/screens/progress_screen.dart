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
    // Debug prints to inspect progress data
    print('Building chart for theme: $theme');
    print('All progress keys: ${progress.keys.toList()}');
    // Filter progress entries by theme, case-insensitive
    final filteredProgress = Map.fromEntries(
      // Debug: log entries before filtering
      progress.entries
          .map((e) => e)
          .toList()
          .where((entry) {
            final parts = entry.key.split('__');
            return parts.length == 2 &&
                parts[1].toLowerCase() == theme.toLowerCase();
          })
          .map((entry) {
            final parts = entry.key.split('__');
            return MapEntry(parts[0], entry.value as int);
          }),
    );
    print('Filtered progress: $filteredProgress');

    List<BarChartGroupData> barGroups = [];
    List<String> xLabels = [];
    int index = 0;
    filteredProgress.forEach((tipo, score) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [BarChartRodData(toY: score.toDouble(), color: Colors.blue)],
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
          const SizedBox(height: 28),
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
                          return Text(
                            xLabels[idx],
                            textAlign: TextAlign.center,
                          );
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

  // Nueva gráfica para progreso de preguntas de la API por nivel de dificultad
  Widget _buildApiProgressChart() {
    Map<String, int> apiProgress = {};
    progress.forEach((key, value) {
      final parts = key.split('__');
      if (parts.length == 2 &&
          (parts[0] == 'facil' ||
              parts[0] == 'intermedio' ||
              parts[0] == 'dificil') &&
          parts[1] == 'general') {
        apiProgress[parts[0]] = value;
      }
    });

    List<BarChartGroupData> barGroups = [];
    List<String> xLabels = ['Fácil', 'Intermedio', 'Difícil'];
    List<String> keysOrder = ['facil', 'intermedio', 'dificil'];
    for (int i = 0; i < keysOrder.length; i++) {
      final score = apiProgress[keysOrder[i]] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: score.toDouble(), color: Colors.green),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preguntas nivel Dios',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25), // Espacio entre el título y el gráfico
          SizedBox(
            height: 300,
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
                          return Text(
                            xLabels[idx],
                            textAlign: TextAlign.center,
                          );
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : progress.isEmpty
              ? const Center(child: Text('No hay progreso guardado'))
              : ListView(
                children: [
                  _buildBarChartForTheme('Matemáticas'),
                  _buildBarChartForTheme('Astronomía'),
                  _buildBarChartForTheme('Historia'),
                  _buildBarChartForTheme('Cultura General'),
                  _buildApiProgressChart(), // Gráfico extra para API
                ],
              ),
    );
  }
}
