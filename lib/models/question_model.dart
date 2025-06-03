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
      // Para preguntas verdadero/falso, mezclar aleatoriamente el orden
      var options = {
        'Verdadero': json['answer'] == true,
        'Falso': json['answer'] == false,
      };
      var entries = options.entries.toList()..shuffle(Random());
      return Question(
        id: json['id'],
        title: json['title'],
        tema: tema,
        options: Map.fromEntries(entries),
        type: type,
      );
    } else if (type == 'multiple') {
      // Para preguntas de opción múltiple
      var options = Map<String, bool>.from(json['options']);
      var entries = options.entries.toList()..shuffle(Random());
      return Question(
        id: json['id'],
        title: json['title'],
        tema: tema,
        options: Map.fromEntries(entries),
        type: type,
      );
    } else if (type == 'order') {
      var originalOptions = List<String>.from(json['options']);
      var originalAnswer = List<String>.from(json['answer']);
      
      var shuffledOptions = List<String>.from(originalOptions);
      shuffledOptions.shuffle(Random());
      
      return Question(
        id: json['id'],
        title: json['title'],
        tema: tema,
        orderOptions: shuffledOptions, // Lista mezclada independiente
        correctOrder: originalAnswer,   // Lista correcta independiente
        type: type,
      );
    } else {
      // Para preguntas de respuesta corta
      return Question(
        id: json['id'],
        title: json['title'],
        tema: tema,
        answer: json['answer'],
        type: type,
      );
    }
  }

  // Método para convertir la respuesta de la API en un objeto Question
  // Cambio de formato, soluciones se generan de forma random
  factory Question.fromApiJson(Map<String, dynamic> json) {
    String questionText = _decodeHtmlEntities(json['question']);
    
    List<String> allOptions = [
      ...json['incorrect_answers'].map((e) => _decodeHtmlEntities(e.toString())),
      _decodeHtmlEntities(json['correct_answer'])
    ];

    // Mezclar las opciones aleatoriamente
    allOptions.shuffle(Random());

    // Crear el mapa de opciones donde guardamos cuál es correcta
    Map<String, bool> optionsMap = {};
    for (String option in allOptions) {
      // Comparamos cada opción con la respuesta correcta
      optionsMap[option] = (option == _decodeHtmlEntities(json['correct_answer']));
    }

    return Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID único
      title: questionText,
      options: optionsMap,
      answer: _decodeHtmlEntities(json['correct_answer']),
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