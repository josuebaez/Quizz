import 'package:flutter/material.dart';
import 'package:prueba_app/screens/home_screen.dart';

class TemasScreen extends StatelessWidget {
  final String tipo;
  TemasScreen({required this.tipo});

  // Puedes personalizar los temas por tipo si lo deseas
  final Map<String, List<String>> temasPorTipo = const {
    'true_false': ['Historia', 'Matemáticas', 'Astronomía', 'Cultura general'],
    'short': ['Literatura', 'Ciencia', 'Arte', 'Deportes'],
    'order': ['Astronomía', 'Historia', 'Ciencia', 'Tecnología'],
  };

  final Map<String, List<Color>> coloresPorTipo = const {
    'true_false': [Color(0xff5174ed), Color(0xff2f95f4), Color(0xff0bb7fc)],
    'short': [Color(0xffa58ed2), Color(0xffcfa7dd), Color(0xfff6bfea)],
    'order': [Color(0xfff6bfea), Color(0xffcfa7dd), Color(0xffa58ed2)],
  };

  @override
  Widget build(BuildContext context) {
    final temas = temasPorTipo[tipo] ?? ['General'];
    final colores =
        coloresPorTipo[tipo] ??
        [Colors.blue, Colors.blueAccent, Colors.lightBlueAccent];
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
              Text(
                "Selecciona un tema",
                style: TextStyle(
                  color: Color(0xFFF45E7A),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              ...temas.map(
                (tema) => Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => HomeScreen(
                                difficulty: tipo + '_' + tema.toLowerCase(),
                              ),
                        ),
                      );
                    },
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
                            colors: colores,
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
                                borderRadius: BorderRadiusDirectional.circular(
                                  10,
                                ),
                              ),
                              child: Icon(Icons.menu_book, color: Colors.white),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              tema,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
