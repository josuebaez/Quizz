import 'package:flutter/material.dart';
//import '../constants.dart';

class QuestionWidget extends StatelessWidget {
  const QuestionWidget ({super.key, required this.question, required this.indexAction, required this.totalQuestions});

  final String question;
  final int indexAction;
  final int totalQuestions;
   
  @override 
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text('Pregunta ${indexAction +1}/$totalQuestions: $question',
      style: const TextStyle(
        fontSize: 22.0,
        color: Colors.white,
      ),
      ),
    );
  }
}