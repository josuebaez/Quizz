import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prueba_app/auth/auth_page.dart';
//import 'package:prueba_app/screens/home.dart';
import 'package:prueba_app/screens/home_screen.dart';


class Main_Page extends StatelessWidget {
  const Main_Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges() ,builder:(context, snapshot){
        if(snapshot.hasData){
          return HomeScreen();
        }else{
          return Auth_Page();
        }
      }),
    );
  }
}