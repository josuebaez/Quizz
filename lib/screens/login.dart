import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:prueba_app/const/colors.dart';
import 'package:prueba_app/data/auth_data.dart';
import 'package:prueba_app/pages/niveles.dart';
import 'dart:math' as math;

class LogIN_Screen extends StatefulWidget {
  final VoidCallback show;
  const LogIN_Screen(this.show, {super.key});
 
  @override
  State<LogIN_Screen> createState() => _LogIN_ScreenState();
}

class _LogIN_ScreenState extends State<LogIN_Screen>
    with TickerProviderStateMixin {
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();
  
  bool isLoading = false;
  String? errorMessage;
  bool _isMounted = true;
  
  // Controladores de animación para las gotas
  late AnimationController _animationController;
  late List<AnimationController> _dropControllers;
  late List<Animation<double>> _dropAnimations;
  late List<Offset> _dropPositions;
  late List<Color> _dropColors;
  
  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(_handleFocus1Change);
    _focusNode2.addListener(_handleFocus2Change);
    
    // Inicializar animaciones
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    // Crear múltiples gotas
    _dropControllers = [];
    _dropAnimations = [];
    _dropPositions = [];
    _dropColors = [];
    
    final random = math.Random();
    
    // Colores para las gotas 
    final colors = [
      Color.fromARGB(255, 80, 200, 248), 
      Color.fromARGB(255, 223, 95, 138), 
      Color.fromARGB(255, 63, 182, 230), 
      Color.fromARGB(255, 245, 90, 134), 
    ];

    for (int i = 0; i < 25; i++) { // Aumentado de 15 a 25 gotas
      final controller = AnimationController(
        duration: Duration(milliseconds: 1500 + random.nextInt(4000)), // Más variación en velocidad
        vsync: this,
      );
      
      final animation = Tween<double>(
        begin: -100, // Comenzar más arriba
        end: 1200,   // Terminar más abajo
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
      
      _dropControllers.add(controller);
      _dropAnimations.add(animation);
      
      // Posiciones aleatorias para las gotas 
      _dropPositions.add(Offset(
        random.nextDouble() * 500, // Ancho más amplio
        random.nextDouble() * 800, // Alto más amplio
      ));
      
      _dropColors.add(colors[random.nextInt(colors.length)]);
      
      // Iniciar animación con delay aleatorio
      Future.delayed(Duration(milliseconds: random.nextInt(2000)), () {
        if (_isMounted) {
          controller.repeat();
        }
      });
    }
  }

  void _handleFocus1Change() {
    if (_isMounted) {
      setState(() {});
    }
  }

  void _handleFocus2Change() {
    if (_isMounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 123, 182, 177),
      body: Stack(
        children: [
          // Fondo con animación de gotas
          AnimatedBackground(),
          
          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  image(),
                  SizedBox(height: 50),
                  textfield(email, _focusNode1, 'Correo', Icons.email),
                  SizedBox(height: 10),
                  textfield(password, _focusNode2, 'Contraseña', Icons.password, isPassword: true),
                  SizedBox(height: 8),
                  
                  // Mostrar mensaje de error si existe
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                  SizedBox(height: 8),
                  account(),
                  SizedBox(height: 20),
                  Login_bottom(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el fondo animado
  Widget AnimatedBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: DropsPainter(
          animations: _dropAnimations,
          positions: _dropPositions,
          colors: _dropColors,
        ),
      ),
    );
  }

  Widget account() {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "¿No tienes una cuenta?",
                style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: widget.show,
                  child: Text(
                    'Registrarse',
                    style: TextStyle(color: custom_green, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                )
            ],
          ),
        );
  }

  Widget Login_bottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: isLoading ? null : _handleLogin,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: isLoading ? Colors.grey : Colors.blueAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: isLoading 
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Iniciar Sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
    );
  }
  
  Future<void> _handleLogin() async {
    if (!_isMounted) return;
    
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    if (email.text.trim().isEmpty || password.text.isEmpty) {
      if (_isMounted) {
        setState(() {
          errorMessage = "Por favor, completa todos los campos";
          isLoading = false;
        });
      }
      return;
    }

    try {
      await AuthenticationRemote().login(email.text.trim(), password.text.trim());
      
      if (_isMounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => Niveles())
        );
      }
      
    } catch (e) {
      if (_isMounted) {
        setState(() {
          errorMessage = "Error al iniciar sesión: ${e.toString()}";
          isLoading = false;
        });
        print('Error de autenticación: $e');
      }
    }
  }

  Widget textfield(
      TextEditingController controller, 
      FocusNode focusNode, 
      String typeName, 
      IconData iconss, 
      {bool isPassword = false}
  ) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: isPassword,
              style: TextStyle(fontSize: 18, color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  iconss,
                  color: focusNode.hasFocus
                   ? custom_green
                   : Color(0xffc5c5c5),
                ),
                contentPadding: 
                 EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                 hintText: typeName,
                 enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Color(0xffc5c5c5),
                    width: 2.0,
                    ),
                 ),
                 focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: custom_green,
                    width: 2.0,
                    ),
                 ),
              ),
            ),
          ),
        );
  }

  Widget image() {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Tamaño responsivo en el ancho de la pantalla
      double containerWidth = constraints.maxWidth;
      double containerHeight = containerWidth * 0.75; // Relación de aspecto 4:3

      return Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Gif(
            image: AssetImage('gifs/Scene_Quiz.gif'),
            autostart: Autostart.loop,
            fit: BoxFit.contain, // Para mantener la proporción
            placeholder: (context) => Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    },
  );
}

  @override
  void dispose() {
    _isMounted = false;
    
    _focusNode1.removeListener(_handleFocus1Change);
    _focusNode2.removeListener(_handleFocus2Change);
    
    email.dispose();
    password.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    
    // Disponer animaciones
    _animationController.dispose();
    for (var controller in _dropControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }
}

// Para dibujar las gotas animadas
class DropsPainter extends CustomPainter {
  final List<Animation<double>> animations;
  final List<Offset> positions;
  final List<Color> colors;

  DropsPainter({
    required this.animations,
    required this.positions,
    required this.colors,
  }) : super(repaint: Listenable.merge(animations));

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < animations.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.4) 
        ..style = PaintingStyle.fill;

      // Crear forma de gota 
      final center = Offset(
        (positions[i].dx * size.width / 500).clamp(0.0, size.width), // Adaptar al ancho real
        animations[i].value % (size.height + 200), // Usar altura real + margen
      );
      
      final dropSize = 6.0 + (i % 4) * 3.0; // Tamaños más variados
      
      // Cuerpo principal de la gota 
      canvas.drawCircle(center, dropSize, paint);
      
      // Cola de la gota
      final tailPath = Path();
      tailPath.moveTo(center.dx, center.dy - dropSize);
      tailPath.quadraticBezierTo(
        center.dx - dropSize * 0.4,
        center.dy - dropSize * 2.0,
        center.dx,
        center.dy - dropSize * 2.5,
      );
      tailPath.quadraticBezierTo(
        center.dx + dropSize * 0.4,
        center.dy - dropSize * 2.0,
        center.dx,
        center.dy - dropSize,
      );
      
      canvas.drawPath(tailPath, paint);
      
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3) // Más brillo
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(center.dx - dropSize * 0.3, center.dy - dropSize * 0.3),
        dropSize * 0.25,
        highlightPaint,
      );
      
      // Gotas más pequeñas 
      if (i % 3 == 0) {
        final splashPaint = Paint()
          ..color = colors[i].withOpacity(0.2)
          ..style = PaintingStyle.fill;
          
        // Pequeñas gotas alrededor
        for (int j = 0; j < 3; j++) {
          final splashOffset = Offset(
            center.dx + (j - 1) * dropSize * 1.5,
            center.dy + dropSize * 0.8,
          );
          canvas.drawCircle(splashOffset, dropSize * 0.3, splashPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}