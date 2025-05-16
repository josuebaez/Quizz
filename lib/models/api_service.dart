import 'dart:convert';
import 'package:http/http.dart' as http;
import 'question_model.dart';
import 'local_question_loader.dart';

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
          return results
              .map<Question>((json) => Question.fromApiJson(json))
              .toList();
        } else {
          throw Exception(
            "No se encontraron preguntas para el nivel seleccionado",
          );
        }
      } else {
        throw Exception(
          "Error al cargar preguntas: Código ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  Future<List<Question>> fetchAllQuestions(String difficulty) async {
    final localLoader = LocalQuestionLoader();
    final localQuestions = await localLoader.loadQuestions();
    final apiQuestions = await fetchQuestionsByDifficulty(difficulty);
    return [...apiQuestions, ...localQuestions];
  }
}
