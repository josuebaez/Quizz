import 'package:flutter/material.dart';
import 'package:gif/gif.dart'; // Biblioteca correcta para GIFs
//import 'package:app_quiz/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:prueba_app/screens/home_screen.dart';

class Niveles extends StatefulWidget {
  const Niveles({super.key});

  @override
  State<Niveles> createState() => _NivelesState();
}

class _NivelesState extends State<Niveles> with TickerProviderStateMixin {
  // Controladores para los GIFs
  late GifController controllerFacil;
  late GifController controllerIntermedio;
  late GifController controllerDificil;

  @override
  void initState() {
    super.initState();
    controllerFacil = GifController(vsync: this);
    controllerIntermedio = GifController(vsync: this);
    controllerDificil = GifController(vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controllerFacil.repeat(period: const Duration(milliseconds: 2000));
      controllerIntermedio.repeat(period: const Duration(milliseconds: 2000));
      controllerDificil.repeat(period: const Duration(milliseconds: 2000));
    });
  }

  @override
  void dispose() {
    // Liberar recursos 
    controllerFacil.dispose();
    controllerIntermedio.dispose();
    controllerDificil.dispose();
    super.dispose();
  }

  // Método para cerrar sesión
  void cerrarSesion() {
    FirebaseAuth.instance.signOut().catchError((error) {
      // Manejar errores si ocurren al cerrar sesión
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${error.toString()}')),
      );
    });
  }

  //Navegar a la pantalla de quiz 
  void navegarAQuiz(String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: cerrarSesion,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38), 
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Icon(Icons.logout, color: Colors.blue),
                    ),
                  )
                ],
              ),
              SizedBox(height: 5.0,),
              Text("Quiz App",style: TextStyle(color: Color(0xFFF45E7A),fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text("Hasta donde podras llegar",style: TextStyle(color: Colors.black38,fontSize: 24.0,fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20.0),
              // Nivel Fácil
              GestureDetector(
                onTap: () => navegarAQuiz('facil'),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 50),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.only(top: 10.0, bottom: 20.0, left: 20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [
                            Color(0xffef729e),
                            Color(0xffec7c86),
                            Color(0xffed896d)
                            ],begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(30)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadiusDirectional.circular(10)),
                                child: Icon(Icons.play_arrow, color: Colors.white,),
                              ),
                              SizedBox(height: 10.0),
                              Text("Quien no!",style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.w500),
                              ),
                              Text("Nivel facil",style: TextStyle(color: Colors.white,fontSize: 24.0,fontWeight: FontWeight.bold),
                              ),  
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Gif(
                              image: AssetImage("gifs/facil.gif"),
                              controller: controllerFacil,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              autostart: Autostart.loop,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Nivel Intermedio
              SizedBox(height: 30),
              GestureDetector(
                onTap: () => navegarAQuiz('intermedio'),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 50),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.only(top: 10.0, bottom: 20.0, left: 20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [
                            Color(0xff5174ed),
                            Color(0xff2f95f4),
                            Color(0xff0bb7fc)
                            ],begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(30)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadiusDirectional.circular(10)),
                                child: Icon(Icons.play_arrow, color: Colors.white,),
                              ),
                              SizedBox(height: 10.0),
                              Text("Tu puedes",style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.w500),
                              ),
                              Text("Nivel Intermedio",style: TextStyle(color: Colors.white,fontSize: 24.0,fontWeight: FontWeight.bold),
                              ),  
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Gif(
                              image: AssetImage("gifs/intermedio.gif"),
                              controller: controllerIntermedio,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              autostart: Autostart.loop,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Nivel Difícil
              SizedBox(height: 30),
              GestureDetector(
                onTap: () => navegarAQuiz('dificil'),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 50),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.only(top: 10.0, bottom: 20.0, left: 20.0),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [
                            Color(0xffa58ed2),
                            Color(0xffcfa7dd),
                            Color(0xfff6bfea)
                            ],begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(30)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadiusDirectional.circular(10)),
                                child: Icon(Icons.play_arrow, color: Colors.white,),
                              ),
                              SizedBox(height: 10.0),
                              Text("Solo intentalo!",style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.w500),
                              ),
                              Text("Nivel Dificil",style: TextStyle(color: Colors.white,fontSize: 24.0,fontWeight: FontWeight.bold),
                              ),  
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Gif(
                              image: AssetImage("gifs/dificil.gif"),
                              controller: controllerDificil,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              autostart: Autostart.loop,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}