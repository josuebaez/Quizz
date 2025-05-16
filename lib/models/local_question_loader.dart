import 'dart:convert';
import 'package:flutter/services.dart';
import 'question_model.dart';

class LocalQuestionLoader {
  Future<List<Question>> loadQuestions() async {
    final String response = await rootBundle.loadString(
      'assets/questions.json',
    );
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
    final all = await loadQuestions();
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
