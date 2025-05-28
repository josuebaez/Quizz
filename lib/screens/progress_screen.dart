import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progreso del Usuario')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : progress.isEmpty
              ? const Center(child: Text('No hay progreso guardado'))
              : ListView(children: _buildProgressList()),
    );
  }

  List<Widget> _buildProgressList() {
    // Agrupar por tipo y tema
    Map<String, Map<String, int>> grouped = {};
    progress.forEach((key, value) {
      // key: tipo_tema
      final parts = key.split('__');
      if (parts.length == 2) {
        final tipo = parts[0];
        final tema = parts[1];
        grouped.putIfAbsent(tipo, () => {});
        grouped[tipo]![tema] = value;
      }
    });
    List<Widget> widgets = [];
    grouped.forEach((tipo, temas) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            tipo.toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
      temas.forEach((tema, score) {
        widgets.add(
          ListTile(
            title: Text('Tema: $tema'),
            trailing: Text('Puntuación: $score'),
          ),
        );
      });
      widgets.add(const Divider());
    });
    return widgets;
  }
}
