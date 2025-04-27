class Question {
  final String id;
  final String title;
  final Map<String, bool> options;

  Question({required this.id, required this.title, required this.options});

  @override
  String toString() {
    return 'Question(id: $id, title: $title, option: $options)';
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      title: json['title'],
      options: Map<String, bool>.from(json['options']),
    );
  }

  factory Question.fromApiJson(Map<String, dynamic> json) {
    // Combinar respuestas correctas e incorrectas en un mapa de opciones
    final options = {
      json['correct_answer'] as String: true,
      ...Map.fromIterable(
        json['incorrect_answers'],
        key: (answer) => answer as String,
        value: (_) => false,
      ),
    };

    return Question(
      id: json['question'] as String, // Usar la pregunta como ID único
      title: json['question'] as String,
      options: options,
    );
  }
}
