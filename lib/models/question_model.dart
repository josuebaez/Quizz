import 'dart:math';

class Question {
  final String id;
  final String title;
  final String? tema;
  final Map<String, bool>? options; // Para opción múltiple y verdadero/falso
  final String? type; // 'multiple', 'true_false', 'short', 'order'
  final String? answer; // Para respuesta simple
  final List<String>? orderOptions; // Para ordenar
  final List<String>? correctOrder; // Para ordenar

  Question({
    required this.id,
    required this.title,
    this.tema,
    this.options,
    this.type,
    this.answer,
    this.orderOptions,
    this.correctOrder,
  });

  @override
  String toString() {
    return 'Question(id: $id, title: $title, tema: $tema, type: $type, options: $options, answer: $answer, orderOptions: $orderOptions, correctOrder: $correctOrder)';
  }

  // Factory para JSON local
  factory Question.fromJson(Map<String, dynamic> json) {
    final type = json['type'] ?? 'multiple';
    final tema = json['tema'] as String?;
    if (type == 'true_false') {
      return Question(
        id: json['id'],
        title: json['title'],
        tema: tema,
        options: {
          'Verdadero': json['answer'] == true,
          'Falso': json['answer'] == false,
        },
        type: type,
      );
    } else if (type == 'short') {
      return Question(
        id: json['id'],
        title: json['title'],
        tema: tema,
        answer: json['answer'],
        type: type,
      );
    } else if (type == 'order') {
      return Question(
        id: json['id'],
        title: json['title'],
        tema: tema,
        orderOptions: List<String>.from(json['options']),
        correctOrder: List<String>.from(json['answer']),
        type: type,
      );
    } else {
      // Opción múltiple por defecto
      return Question(
        id: json['id'],
        title: json['title'],
        tema: tema,
        options: Map<String, bool>.from(json['options']),
        type: type,
      );
    }
  }

  // Método para convertir la respuesta de la API en un objeto Question
  factory Question.fromApiJson(Map<String, dynamic> json) {
    String questionText = json['question'];
    questionText = _decodeHtmlEntities(questionText);
    String correctAnswer = _decodeHtmlEntities(json['correct_answer']);
    List<String> incorrectAnswers =
        (json['incorrect_answers'] as List)
            .map((answer) => _decodeHtmlEntities(answer.toString()))
            .toList();
    Map<String, bool> options = {};
    options[correctAnswer] = true;
    for (String answer in incorrectAnswers) {
      options[answer] = false;
    }
    String id =
        DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(10000).toString();
    return Question(
      id: id,
      title: questionText,
      options: options,
      type: 'multiple',
    );
  }
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
