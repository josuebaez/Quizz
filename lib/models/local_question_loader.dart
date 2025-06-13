import 'dart:convert';
import 'package:flutter/services.dart';
import 'question_model.dart';
import 'dart:math';

//Igual, formato de preguntas random
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
    
    final String jsonString = await rootBundle.loadString(assetPath);
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Question.fromJson(json)).toList();
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .trim();
  }

  Future<List<Question>> loadQuestionsByTypeAndTema(
    String tipo,
    String tema,
  ) async {
    final all = await loadQuestionsByType(tipo);
    final temaNorm = _normalize(tema);
    
    var filteredQuestions = all.where((q) {
      if (q.type != tipo) return false;
      if (q.tema == null) return false;
      final preguntaTemaNorm = _normalize(q.tema!);
      return preguntaTemaNorm.contains(temaNorm) ||
          temaNorm.contains(preguntaTemaNorm);
    }).toList();

    // Mezclar aleatoriamente las preguntas
    filteredQuestions.shuffle(Random());
    
    return filteredQuestions;
  }
}