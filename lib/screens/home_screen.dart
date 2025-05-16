import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../models/question_model.dart';
import '../widgets/question_widget.dart';
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';
import '../widgets/result_box.dart';
import '../models/api_service.dart'; // Importar el servicio de API
import '../models/local_question_loader.dart';

//Se modifico este archivo solo para agregar un LogOut

class HomeScreen extends StatefulWidget {
  final String difficulty;

  const HomeScreen({super.key, required this.difficulty});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  final LocalQuestionLoader localLoader = LocalQuestionLoader();
  late Future<List<Question>> _questions;

  int index = 0;
  bool isPressed = false;
  int score = 0;
  bool isAlreadySelected = false;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    // Si es tipo API clásico
    if (widget.difficulty == 'facil' ||
        widget.difficulty == 'intermedio' ||
        widget.difficulty == 'dificil') {
      _questions = apiService.fetchQuestionsByDifficulty(widget.difficulty);
    } else if (widget.difficulty == 'api') {
      // fallback, no debería usarse
      _questions = Future.value([]);
    } else if (widget.difficulty.contains('_')) {
      final parts = widget.difficulty.split('_');
      final tipo = parts[0];
      final tema = parts.sublist(1).join('_');
      _questions = localLoader.loadQuestionsByTypeAndTema(tipo, tema);
    } else {
      // fallback
      _questions = Future.value([]);
    }
    _questions
        .then((_) {
          setState(() {
            isLoading = false;
          });
        })
        .catchError((error) {
          setState(() {
            isLoading = false;
            errorMessage = 'Error al cargar preguntas: ${error.toString()}';
          });
        });
  }

  void nextQuestion(int questionLength) {
    if (index == questionLength - 1) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (ctx) => ResultBox(
              result: score,
              questionLeght: questionLength,
              onPressed: startOver,
            ),
      );
    } else {
      if (isPressed) {
        setState(() {
          index++;
          isPressed = false;
          isAlreadySelected = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor seleccione una opción'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(vertical: 20.0),
          ),
        );
      }
    }
  }

  void checkAnswerAndUpdate(bool value) {
    if (isAlreadySelected) {
      return;
    } else {
      if (value == true) {
        score++;
      }
      setState(() {
        isPressed = true;
        isAlreadySelected = true;
      });
    }
  }

  void startOver() {
    setState(() {
      index = 0;
      score = 0;
      isPressed = false;
      isAlreadySelected = false;
    });
    _loadQuestions();
    Navigator.pop(context);
  }

  void cerrarSesion() {
    FirebaseAuth.instance.signOut().catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${error.toString()}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Volver',
        ),
        title: Text('Nivel ${widget.difficulty}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              'Score: $score',
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Cargando preguntas...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              : errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: incorrect),
                    SizedBox(height: 20),
                    Text(
                      errorMessage,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadQuestions,
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              )
              : FutureBuilder<List<Question>>(
                future: _questions,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(child: Text('${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      var extractedData = snapshot.data!;
                      final current = extractedData[index];
                      Widget questionWidget;
                      if (current.type == 'multiple' || current.type == null) {
                        questionWidget = Column(
                          children: [
                            QuestionWidget(
                              indexAction: index,
                              question: current.title,
                              totalQuestions: extractedData.length,
                            ),
                            const Divider(color: neutral),
                            const SizedBox(height: 25.0),
                            ...current.options!.entries
                                .map(
                                  (entry) => GestureDetector(
                                    onTap:
                                        () => checkAnswerAndUpdate(entry.value),
                                    child: OptionCard(
                                      option: entry.key,
                                      color:
                                          isPressed
                                              ? entry.value == true
                                                  ? correct
                                                  : incorrect
                                              : neutral,
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        );
                      } else if (current.type == 'true_false') {
                        questionWidget = Column(
                          children: [
                            QuestionWidget(
                              indexAction: index,
                              question: current.title,
                              totalQuestions: extractedData.length,
                            ),
                            const Divider(color: neutral),
                            const SizedBox(height: 25.0),
                            ...current.options!.entries
                                .map(
                                  (entry) => GestureDetector(
                                    onTap:
                                        () => checkAnswerAndUpdate(entry.value),
                                    child: OptionCard(
                                      option: entry.key,
                                      color:
                                          isPressed
                                              ? entry.value == true
                                                  ? correct
                                                  : incorrect
                                              : neutral,
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        );
                      } else if (current.type == 'short') {
                        questionWidget = Column(
                          children: [
                            QuestionWidget(
                              indexAction: index,
                              question: current.title,
                              totalQuestions: extractedData.length,
                            ),
                            const Divider(color: neutral),
                            const SizedBox(height: 25.0),
                            ShortAnswerWidget(
                              onValidate: (userAnswer) {
                                if (isAlreadySelected) return;
                                if (userAnswer.trim().toLowerCase() ==
                                    (current.answer ?? '')
                                        .trim()
                                        .toLowerCase()) {
                                  score++;
                                }
                                setState(() {
                                  isPressed = true;
                                  isAlreadySelected = true;
                                });
                              },
                              isPressed: isPressed,
                              correctAnswer: current.answer ?? '',
                            ),
                          ],
                        );
                      } else if (current.type == 'order') {
                        questionWidget = Column(
                          children: [
                            QuestionWidget(
                              indexAction: index,
                              question: current.title,
                              totalQuestions: extractedData.length,
                            ),
                            const Divider(color: neutral),
                            const SizedBox(height: 25.0),
                            OrderWidget(
                              options: current.orderOptions!,
                              correctOrder: current.correctOrder!,
                              onValidate: (isCorrect) {
                                if (isAlreadySelected) return;
                                if (isCorrect) score++;
                                setState(() {
                                  isPressed = true;
                                  isAlreadySelected = true;
                                });
                              },
                              isPressed: isPressed,
                            ),
                          ],
                        );
                      } else {
                        questionWidget = Center(
                          child: Text('Tipo de pregunta no soportado'),
                        );
                      }
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: questionWidget,
                      );
                    }
                  }
                  return Center(child: Text('No hay preguntas disponibles'));
                },
              ),
      floatingActionButton:
          errorMessage.isEmpty
              ? GestureDetector(
                onTap: () async {
                  if (isLoading) return;

                  final questions = await _questions;
                  if (questions.isNotEmpty) {
                    nextQuestion(questions.length);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: NextButton(),
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Widgets para respuesta corta y ordenar
class ShortAnswerWidget extends StatefulWidget {
  final void Function(String) onValidate;
  final bool isPressed;
  final String correctAnswer;
  const ShortAnswerWidget({
    super.key,
    required this.onValidate,
    required this.isPressed,
    required this.correctAnswer,
  });
  @override
  State<ShortAnswerWidget> createState() => _ShortAnswerWidgetState();
}

class _ShortAnswerWidgetState extends State<ShortAnswerWidget> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          enabled: !widget.isPressed,
          decoration: InputDecoration(
            labelText: 'Respuesta',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed:
              widget.isPressed
                  ? null
                  : () => widget.onValidate(controller.text),
          child: Text('Validar'),
        ),
        if (widget.isPressed)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Respuesta correcta: ${widget.correctAnswer}',
              style: TextStyle(color: correct),
            ),
          ),
      ],
    );
  }
}

class OrderWidget extends StatefulWidget {
  final List<String> options;
  final List<String> correctOrder;
  final void Function(bool) onValidate;
  final bool isPressed;
  const OrderWidget({
    super.key,
    required this.options,
    required this.correctOrder,
    required this.onValidate,
    required this.isPressed,
  });
  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  late List<String> userOrder;
  @override
  void initState() {
    super.initState();
    userOrder = List<String>.from(widget.options);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = userOrder.removeAt(oldIndex);
              userOrder.insert(newIndex, item);
            });
          },
          children: [
            for (final item in userOrder)
              ListTile(
                key: ValueKey(item),
                title: Text(item),
                tileColor: neutral,
              ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed:
              widget.isPressed ? null : () => widget.onValidate(_isCorrect()),
          child: Text('Validar'),
        ),
        if (widget.isPressed)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _isCorrect() ? '¡Orden correcto!' : 'Orden incorrecto',
              style: TextStyle(color: _isCorrect() ? correct : incorrect),
            ),
          ),
      ],
    );
  }

  bool _isCorrect() {
    if (userOrder.length != widget.correctOrder.length) return false;
    for (int i = 0; i < userOrder.length; i++) {
      if (userOrder[i] != widget.correctOrder[i]) return false;
    }
    return true;
  }
}
