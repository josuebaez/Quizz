import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/question_model.dart';
import '../widgets/question_widget.dart';
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';
import '../widgets/result_box.dart';
import '../models/api_service.dart'; // Importar el servicio de API
import 'dart:async';

import '../models/local_question_loader.dart';

//Se modifico este archivo solo para agregar un LogOut

class HomeScreen extends StatefulWidget {
  final String difficulty;

  const HomeScreen({super.key, required this.difficulty});

  @override
  HomeScreenState createState() => HomeScreenState();
}


//Clase nueva para poder limpiar respuesta
class ClearFieldsNotification extends Notification {
  const ClearFieldsNotification();
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
  late Timer _timer;
  int _seconds = 0;
  String finalTime = '';
  String get timerText =>
      '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';

  // Definimos los colores para el degradado
  final Color guindaClaro = Color(0xFFAA4465); // Guinda claro
  final Color azulClaro = Color(0xFF7FB3D5); // Azul claro

  @override
  void initState() {
    super.initState();
    _loadQuestions();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        if (_seconds >= 180) {
          _timer.cancel();
          _questions.then((questions) {
            if (mounted) {
              _saveProgress(); // Guardar progreso al terminar
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (ctx) => ResultBox(
                      result: score,
                      questionLeght: questions.length,
                      onPressed: startOver,
                      completionTime: timerText,
                    ),
              );
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _loadQuestions() {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    if (widget.difficulty == 'facil' ||
        widget.difficulty == 'intermedio' ||
        widget.difficulty == 'dificil') {
      _questions = apiService.fetchQuestionsByDifficulty(widget.difficulty);
    } else if (widget.difficulty == 'api') {
      _questions = Future.value([]);
    } else if (widget.difficulty.contains('_')) {
      String tipo;
      String tema;
      if (widget.difficulty.startsWith('true_false_')) {
        tipo = 'true_false';
        tema = widget.difficulty.substring('true_false_'.length);
      } else {
        final parts = widget.difficulty.split('_');
        tipo = parts[0];
        tema = parts.sublist(1).join('_');
      }
      _questions = localLoader.loadQuestionsByTypeAndTema(tipo, tema);
    } else {
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
      _timer.cancel();
      finalTime = timerText;
      _saveProgress(); // Guardar progreso al terminar
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (ctx) => ResultBox(
              result: score,
              questionLeght: questionLength,
              onPressed: startOver,
              completionTime: finalTime,
            ),
      );
    } else {
      if (isPressed) {
        setState(() {
          index++;
          isPressed = false;
          isAlreadySelected = false;
          _clearAllFields();
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

  void _clearAllFields() {
  // Enviar la notificación para limpiar los campos
  const ClearFieldsNotification().dispatch(context);
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
      _seconds = 0;
      finalTime = '';
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });

    _loadQuestions();
    Navigator.pop(context);
  }

  void _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // Usar tipo y tema si están disponibles, si no, usar dificultad
    String tipo = '';
    String tema = '';
    if (widget.difficulty.contains('_')) {
      if (widget.difficulty.startsWith('true_false_')) {
        tipo = 'true_false';
        tema = widget.difficulty.substring('true_false_'.length);
      } else {
        final parts = widget.difficulty.split('_');
        tipo = parts[0];
        tema = parts.sublist(1).join('_');
      }
    } else {
      tipo = widget.difficulty;
      tema = 'general';
    }
    String key = '${tipo}__${tema}';
    int prevScore = prefs.getInt(key) ?? 0;
    if (score > prevScore) {
      await prefs.setInt(key, score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aplicamos el degradado como fondo usando un BoxDecoration
      extendBodyBehindAppBar:
          true, // Para que el degradado se extienda detrás del AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Volver',
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, color: Colors.white, size: 18),
            SizedBox(width: 4),
            Text(
              timerText,
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Score: $score',
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        // Aquí aplicamos el degradado de fondo
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [guindaClaro, azulClaro],
          ),
        ),
        child: SafeArea(
          child:
              isLoading
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          'Cargando preguntas...',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  )
                  : errorMessage.isNotEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 20),
                        Text(
                          errorMessage,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadQuestions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: guindaClaro,
                          ),
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
                          return Center(
                            child: Text(
                              '${snapshot.error}',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else if (snapshot.hasData &&
                            snapshot.data!.isNotEmpty) {
                          var extractedData = snapshot.data!;
                          final current = extractedData[index];
                          Widget questionWidget;

                          if (current.type == 'multiple' ||
                              current.type == null) {
                            questionWidget = Column(
                              children: [
                                QuestionWidget(
                                  indexAction: index,
                                  question: current.title,
                                  totalQuestions: extractedData.length,
                                ),
                                const Divider(color: Colors.white),
                                const SizedBox(height: 25.0),
                                ...current.options!.entries
                                    .map(
                                      (entry) => GestureDetector(
                                        onTap:
                                            () => checkAnswerAndUpdate(
                                              entry.value,
                                            ),
                                        child: OptionCard(
                                          option: entry.key,
                                          color:
                                              isPressed
                                                  ? entry.value == true
                                                      ? correct
                                                      : incorrect
                                                  : Colors.white,
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
                                const Divider(color: Colors.white),
                                const SizedBox(height: 25.0),
                                ...current.options!.entries
                                    .map(
                                      (entry) => GestureDetector(
                                        onTap:
                                            () => checkAnswerAndUpdate(
                                              entry.value,
                                            ),
                                        child: OptionCard(
                                          option: entry.key,
                                          color:
                                              isPressed
                                                  ? entry.value == true
                                                      ? correct
                                                      : incorrect
                                                  : Colors.white,
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
                                const Divider(color: Colors.white),
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
                                const Divider(color: Colors.white),
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
                              child: Text(
                                'Tipo de pregunta no soportado',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: questionWidget,
                          );
                        }
                      }
                      return Center(
                        child: Text(
                          'No hay preguntas disponibles',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
        ),
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


//Modificado para que se limpie el campo de respuesta al cambiar de pregunta
class _ShortAnswerWidgetState extends State<ShortAnswerWidget> {
  final TextEditingController controller = TextEditingController();
  bool hasInitialized = false;
  
  @override
  void initState() {
    super.initState();
    hasInitialized = true;
  }

  @override
  void didUpdateWidget(ShortAnswerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo limpiar cuando cambia de pregunta
    if (oldWidget.isPressed && !widget.isPressed) {
      controller.clear();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ClearFieldsNotification>(
      onNotification: (notification) {
        controller.clear();
        return true;
      },
      child: Column(
        children: [
          TextField(
            controller: controller,
            enabled: !widget.isPressed,
            decoration: InputDecoration(
              labelText: 'Respuesta',
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
            ),
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: widget.isPressed 
                ? null 
                : () => widget.onValidate(controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFFAA4465),
            ),
            child: Text('Validar'),
          ),
          if (widget.isPressed)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                padding: EdgeInsets.all(4),
                color: Colors.white,
                child: Text(
                  'Respuesta correcta: ${widget.correctAnswer}',
                  style: TextStyle(color: correct),
                ),
              ),
            ),
        ],
      ),
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
  void didUpdateWidget(OrderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar userOrder cuando las opciones cambien
    if (widget.options != oldWidget.options) {
      userOrder = List<String>.from(widget.options);
    }
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
                tileColor: Colors.white,
                textColor: Colors.black,
              ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed:
              widget.isPressed ? null : () => widget.onValidate(_isCorrect()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFFAA4465),
          ),
          child: Text('Validar'),
        ),
        if (widget.isPressed)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.white,
              child: Text(
                _isCorrect() ? '¡Orden correcto!' : 'Orden incorrecto',
                style: TextStyle(color: _isCorrect() ? correct : incorrect),
              ),
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
