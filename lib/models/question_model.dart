import 'dart:math';

class Question {
  final String id;
  final String title;
  final Map<String, bool> options;

  Question({
    required this.id,
    required this.title,
    required this.options,
  });

  @override
  String toString() {
    return 'Question(id: $id, title: $title, options: $options)';
  }

  // Método para convertir la respuesta de la API en un objeto Question
  factory Question.fromApiJson(Map<String, dynamic> json) {
    // Extraer pregunta
    String questionText = json['question'];
    
    // Descodificar HTML entities si es necesario
    questionText = _decodeHtmlEntities(questionText);
    
    // Obtener respuesta correcta y opciones incorrectas
    String correctAnswer = _decodeHtmlEntities(json['correct_answer']);
    List<String> incorrectAnswers = (json['incorrect_answers'] as List)
        .map((answer) => _decodeHtmlEntities(answer.toString()))
        .toList();
    
    // Crear mapa de opciones
    Map<String, bool> options = {};
    
    options[correctAnswer] = true;
    
    for (String answer in incorrectAnswers) {
      options[answer] = false;
    }

    // Crear ID único
    String id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(10000).toString();
    
    return Question(
      id: id,
      title: questionText,
      options: options,
    );
  }
  
  // Función simple para decodificar entidades HTML básicas
  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#039;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"');
  }
}