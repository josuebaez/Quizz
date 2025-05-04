/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'question_model.dart';

class ApiService {
  final String apiUrl =
      "https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple"; // Reemplaza con tu URL real

  Future<List<Question>> fetchQuestions() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      // Convertir cada entrada en una instancia de Question
      return results.map((json) => Question.fromApiJson(json)).toList();
    } else {
      throw Exception("Failed to load questions");
    }
  }
}*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'question_model.dart';

class ApiService {
  //Obtener preguntas según el nivel de dificultad
  Future<List<Question>> fetchQuestionsByDifficulty(String difficulty) async {
    String apiDifficulty;
    switch (difficulty.toLowerCase()) {
      case 'facil':
        apiDifficulty = 'easy';
        break;
      case 'intermedio':
        apiDifficulty = 'medium';
        break;
      case 'dificil':
        apiDifficulty = 'hard';
        break;
      default:
        apiDifficulty = 'easy'; 
    }

    final String apiUrl =
        "https://opentdb.com/api.php?amount=10&category=9&difficulty=$apiDifficulty&type=multiple";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Verificar si la API devolvió resultados
        if (data['response_code'] == 0 && data['results'] != null) {
          final List<dynamic> results = data['results'];
          return results.map<Question>((json) => Question.fromApiJson(json)).toList();
        } else {
          throw Exception("No se encontraron preguntas para el nivel seleccionado");
        }
      } else {
        throw Exception("Error al cargar preguntas: Código ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }
}
