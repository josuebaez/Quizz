import 'package:flutter/material.dart';
import '../constants.dart';

class ResultBox extends StatelessWidget {
  const ResultBox({
    super.key, 
    required this.result, 
    required this.questionLeght,required this.onPressed,});

    final int result;
    final int questionLeght;
    final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: background,
      content: Padding(padding: const EdgeInsets.all(60.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Result', style: TextStyle(color: neutral,fontSize: 22.0),
          ),
          const SizedBox(height: 20.0),
          CircleAvatar(
            radius: 70.0,
            backgroundColor: result == questionLeght/2?Colors.yellow:result < questionLeght/2? incorrect:correct,
            child: Text('$result/$questionLeght',style: const TextStyle(fontSize: 30.0),
            ),
            ),
            const SizedBox(height: 20.0),
            Text(result == questionLeght/2?'Almos there':result < questionLeght/2? 'No te rindas':'Excelente!',style:  const TextStyle(color: neutral),
            ),
            const SizedBox(height: 25.0),
            GestureDetector(onTap: onPressed,
            child: const Text('Start Over',style: TextStyle(color: Colors.blue, fontSize: 20.0, letterSpacing: 1.0),),
            ),
        ],
      ),
      ),
    );
  }
}