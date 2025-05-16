import 'package:flutter/material.dart';
//import '../constants.dart';

class NextButton extends StatelessWidget {
  const NextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: const Text('Siguiente Pregunta',textAlign: TextAlign.center, style: TextStyle(fontSize: 18.0),),
    );
  }
}