import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prueba_app/auth/auth_page.dart';
import 'package:prueba_app/pages/niveles.dart';

//import 'package:app_quiz/screens/home.dart';
//import 'package:app_quiz/screens/home_screen.dart';

class Main_Page extends StatelessWidget {
  const Main_Page({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Niveles(); // Redirigimos a la pantalla de niveles cuando hay un usuario autenticado
          } else {
            return Auth_Page();
          }
        }
      ),
    );
  }
}