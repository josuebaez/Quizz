import 'dart:convert';
import 'package:flutter/services.dart';
import 'question_model.dart';

class LocalQuestionLoader {
  Future<List<Question>> loadQuestionsByType(String tipo) async {
    String assetPath;
    switch (tipo) {
      case 'true_false':
        assetPath = 'assets/questions_true_false.json';
        break;
      case 'short':
        assetPath = 'assets/questions_short.json';
        break;
      case 'order':
        assetPath = 'assets/questions_order.json';
        break;
      default:
        assetPath = 'assets/questions.json';
    }
    final String response = await rootBundle.loadString(assetPath);
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Question.fromJson(json)).toList();
  }

  String _normalize(String s) {
    // Quita acentos y pasa a minúsculas
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '');
  }

  Future<List<Question>> loadQuestionsByTypeAndTema(
    String tipo,
    String tema,
  ) async {
    final all = await loadQuestionsByType(tipo);
    final temaNorm = _normalize(tema);
    return all.where((q) {
      if (q.type != tipo) return false;
      if (q.tema == null) return false;
      final preguntaTemaNorm = _normalize(q.tema!);
      // Coincidencia parcial: si el tema buscado está contenido en el tema de la pregunta o viceversa
      return preguntaTemaNorm.contains(temaNorm) ||
          temaNorm.contains(preguntaTemaNorm);
    }).toList();
  }
}
