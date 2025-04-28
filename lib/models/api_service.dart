import 'dart:convert';
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
}
