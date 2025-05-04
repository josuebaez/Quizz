import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../models/question_model.dart';
import '../widgets/question_widget.dart';
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';
import '../widgets/result_box.dart';
import '../models/api_service.dart'; // Importar el servicio de API

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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ResultBox(
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
          /*IconButton(
            icon: Icon(Icons.logout),
            onPressed: cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),*/
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              'Score: $score',
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Cargando preguntas...',
                      style: TextStyle(fontSize: 16)),
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
                      Text(errorMessage,
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center),
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
                        return Center(
                          child: Text('${snapshot.error}'),
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
                              const Divider(color: neutral),
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
                                        : neutral,
                                  ),
                                ),
                              ).toList(),
                            ],
                          ),
                        );
                      }
                    }
                    return Center(
                      child: Text('No hay preguntas disponibles'),
                    );
                  },
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