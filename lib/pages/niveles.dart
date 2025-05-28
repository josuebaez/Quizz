import 'package:flutter/material.dart';
import 'package:gif/gif.dart'; // Biblioteca correcta para GIFs
//import 'package:app_quiz/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prueba_app/screens/home_screen.dart';
import 'niveles_api.dart';
import 'temas_screen.dart';
import 'package:prueba_app/screens/progress_screen.dart'; // Asegúrate de importar la pantalla de progreso

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

  void navegarPorTipo(String tipo) {
    if (tipo == 'api') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NivelesApi()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(difficulty: tipo)),
      );
    }
  }

  void navegarATemas(String tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TemasScreen(tipo: tipo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            top: 50.0,
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.logout, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.0),
              Text(
                "Quiz App",
                style: TextStyle(
                  color: Color(0xFFF45E7A),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Selecciona el tipo de preguntas",
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgressScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.bar_chart),
                label: Text('Ver Progreso'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              // Botón para preguntas de la API
              GestureDetector(
                onTap: () => navegarPorTipo('api'),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 10.0,
                            bottom: 20.0,
                            left: 20.0,
                          ),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffef729e),
                                Color(0xffec7c86),
                                Color(0xffed896d),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius:
                                      BorderRadiusDirectional.circular(10),
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "¿Quieres ir más allá?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Prueba la versión mejorada",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Botón para preguntas de verdadero/falso
              GestureDetector(
                onTap: () => navegarATemas('true_false'),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 10.0,
                            bottom: 20.0,
                            left: 20.0,
                          ),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xff5174ed),
                                Color(0xff2f95f4),
                                Color(0xff0bb7fc),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius:
                                          BorderRadiusDirectional.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ), // Espacio entre los contenedores
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius:
                                          BorderRadiusDirectional.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "Falso o Verdadero",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Que no te vean la cara",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Botón para preguntas abiertas
              GestureDetector(
                onTap: () => navegarATemas('short'),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 10.0,
                            bottom: 20.0,
                            left: 20.0,
                          ),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffa58ed2),
                                Color(0xffcfa7dd),
                                Color(0xfff6bfea),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius:
                                      BorderRadiusDirectional.circular(10),
                                ),
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "Preguntas abiertas",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "¿Que tanto sabes?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Botón para preguntas de ordenar
              GestureDetector(
                onTap: () => navegarATemas('order'),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 10.0,
                            bottom: 20.0,
                            left: 20.0,
                          ),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xfff6bfea),
                                Color(0xffcfa7dd),
                                Color(0xffa58ed2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.0),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius:
                                      BorderRadiusDirectional.circular(10),
                                ),
                                child: Icon(Icons.list, color: Colors.white),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                "Ordenar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Arrastra para ordenar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
