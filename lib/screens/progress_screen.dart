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
    // Prepare best and previous scores by theme
    Map<String, int> bestProgress = {};
    Map<String, int> prevProgress = {};
    progress.forEach((key, value) {
      final parts = key.split('__');
      if (parts.length == 2 && parts[1].toLowerCase() == theme.toLowerCase()) {
        bestProgress[parts[0]] = value as int;
      } else if (parts.length == 3 &&
          parts[1].toLowerCase() == theme.toLowerCase() &&
          parts[2] == 'prev') {
        prevProgress[parts[0]] = value as int;
      }
    });
    // Determine all labels
    List<String> tipos =
        {...bestProgress.keys, ...prevProgress.keys}.toList()..sort();
    // Build bar groups with two rods: previous (gray) and best (blue)
    List<BarChartGroupData> barGroups = [];
    List<String> xLabels = [];
    for (int i = 0; i < tipos.length; i++) {
      String tipo = tipos[i];
      double prevY = prevProgress[tipo]?.toDouble() ?? 0;
      double bestY = bestProgress[tipo]?.toDouble() ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: prevY, color: Colors.grey),
            BarChartRodData(toY: bestY, color: Colors.blue),
          ],
          showingTooltipIndicators: [0, 1],
        ),
      );
      xLabels.add(tipo);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            theme.toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Legend for previous and best
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('Último'),
              const SizedBox(width: 16),
              Icon(Icons.circle, size: 10, color: Colors.blue),
              const SizedBox(width: 4),
              const Text('Mejor'),
            ],
          ),
          const SizedBox(height: 20),
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
