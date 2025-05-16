import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../models/question_model.dart';
import '../widgets/question_widget.dart';
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';
import '../widgets/result_box.dart';
import '../models/api_service.dart'; // Importar el servicio de API
import 'dart:async';

//Se modifico este archivo solo para agregar un LogOut

class HomeScreen extends StatefulWidget {
  final String difficulty;

  const HomeScreen({super.key, required this.difficulty});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
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
  String get timerText => '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';

  // Definimos los colores para el degradado
  final Color guindaClaro = Color(0xFFAA4465); // Guinda claro
  final Color azulClaro = Color(0xFF7FB3D5);   // Azul claro

  @override
  void initState() {
    super.initState();
    _loadQuestions();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose(){
    _timer.cancel();
    super.dispose();
  }

  void _loadQuestions() {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    _questions = apiService.fetchQuestionsByDifficulty(widget.difficulty);
    
    _questions.then((_) {
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ResultBox(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aplicamos el degradado como fondo usando un BoxDecoration
      extendBodyBehindAppBar: true,  // Para que el degradado se extienda detrás del AppBar
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
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text('Cargando preguntas...',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                )
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: Colors.white),
                          SizedBox(height: 20),
                          Text(errorMessage,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                              textAlign: TextAlign.center),
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
                              child: Text('${snapshot.error}', style: TextStyle(color: Colors.white)),
                            );
                          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            var extractedData = snapshot.data!;
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Column(
                                children: [
                                  QuestionWidget(
                                    indexAction: index,
                                    question: extractedData[index].title,
                                    totalQuestions: extractedData.length,
                                  ),
                                  const Divider(color: Colors.white),
                                  const SizedBox(height: 25.0),
                                  ...extractedData[index].options.entries.map((entry) => 
                                    GestureDetector(
                                      onTap: () => checkAnswerAndUpdate(entry.value),
                                      child: OptionCard(
                                        option: entry.key,
                                        color: isPressed
                                            ? entry.value == true
                                                ? correct
                                                : incorrect
                                            : Colors.white,
                                      ),
                                    ),
                                  ).toList(),
                                ],
                              ),
                            );
                          }
                        }
                        return Center(
                          child: Text('No hay preguntas disponibles', style: TextStyle(color: Colors.white)),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: errorMessage.isEmpty
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