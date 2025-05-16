import 'package:flutter/material.dart';
import '../constants.dart';

class ResultBox extends StatelessWidget {
  const ResultBox({
    Key? key,
    required this.result,
    required this.questionLeght,
    required this.onPressed,
    required this.completionTime,
  }) : super(key: key);
  
  final int result;
  final int questionLeght;
  final VoidCallback onPressed;
  final String completionTime;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 77, 121, 179), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Resultado',
              style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            CircleAvatar(
              child: Text(
                '$result/$questionLeght',
                style: TextStyle(fontSize: 30.0),
              ),
              radius: 60.0,
              backgroundColor: result == questionLeght / 2
                ? Colors.yellow
                : result < questionLeght / 2
                  ? incorrect
                  : correct,
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 20.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Tiempo: $completionTime',
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: Colors.lightGreenAccent,
                    size: 18.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Iniciar de nuevo',
                    style: TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: 15.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}