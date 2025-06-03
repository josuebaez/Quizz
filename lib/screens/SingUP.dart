import 'package:flutter/material.dart';
import 'package:prueba_app/const/colors.dart';
import 'package:prueba_app/data/auth_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class SignUp_Screen extends StatefulWidget {
  final VoidCallback show;
  const SignUp_Screen(this.show, {super.key});

  @override
  State<SignUp_Screen> createState() => _SignUp_ScreenState();
}

class _SignUp_ScreenState extends State<SignUp_Screen>
    with TickerProviderStateMixin {
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();
  final PasswordConfirm = TextEditingController();
  
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
    _focusNode1.addListener(() {
      if (_isMounted) setState(() {});
    });
    _focusNode2.addListener(() {
      if (_isMounted) setState(() {});
    });
    _focusNode3.addListener(() {
      if (_isMounted) setState(() {});
    });
    
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
    
    // Colores para las gotas (azul claro y guinda claro)
    final colors = [
      Color.fromARGB(255, 80, 200, 248), 
      Color.fromARGB(255, 223, 95, 138), 
      Color.fromARGB(255, 63, 182, 230), 
      Color.fromARGB(255, 245, 90, 134), 
    ];

    for (int i = 0; i < 25; i++) { // 25 gotas para cobertura completa
      final controller = AnimationController(
        duration: Duration(milliseconds: 1500 + random.nextInt(4000)),
        vsync: this,
      );
      
      final animation = Tween<double>(
        begin: -100,
        end: 1200,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
      
      _dropControllers.add(controller);
      _dropAnimations.add(animation);
      
      // Posiciones aleatorias para las gotas cubriendo toda la pantalla
      _dropPositions.add(Offset(
        random.nextDouble() * 500,
        random.nextDouble() * 800,
      ));
      
      // Colores aleatorios
      _dropColors.add(colors[random.nextInt(colors.length)]);
      
      // Iniciar animación con delay aleatorio
      Future.delayed(Duration(milliseconds: random.nextInt(2000)), () {
        if (_isMounted) {
          controller.repeat();
        }
      });
    }
  }

  // Función para validar el formato de email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Función para manejar el registro
  void signUp() async {
    // Limpiar mensajes de error previos
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    // Validar campos vacíos
    if (email.text.trim().isEmpty || password.text.isEmpty || PasswordConfirm.text.isEmpty) {
      setState(() {
        errorMessage = "Por favor, completa todos los campos";
        isLoading = false;
      });
      return;
    }

    // Validar formato de email
    if (!isValidEmail(email.text.trim())) {
      setState(() {
        errorMessage = "El formato del correo electrónico no es válido";
        isLoading = false;
      });
      return;
    }

    // Validar que las contraseñas coincidan
    if (password.text != PasswordConfirm.text) {
      setState(() {
        errorMessage = "Las contraseñas no coinciden";
        isLoading = false;
      });
      return;
    }

    // Intentar registrar al usuario
    try {
      await AuthenticationRemote().register(
        email.text.trim(), 
        password.text.trim(), 
        PasswordConfirm.text.trim()
      );
      
      // Si llegamos aquí, el registro fue exitoso
      // Navegar a la pantalla de preguntas
      if (_isMounted) {
        Navigator.pushReplacementNamed(context, '/preguntas');
      }
      
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Ya existe una cuenta con este correo electrónico';
          break;
        case 'invalid-email':
          message = 'El formato del correo electrónico no es válido';
          break;
        case 'weak-password':
          message = 'La contraseña es demasiado débil';
          break;
        default:
          message = 'Error al registrar usuario: ${e.message}';
      }
      if (_isMounted) {
        setState(() {
          errorMessage = message;
        });
      }
    } catch (e) {
      if (_isMounted) {
        setState(() {
          errorMessage = 'Ocurrió un error inesperado';
        });
      }
    } finally {
      if (_isMounted) {
        setState(() {
          isLoading = false;
        });
      }
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
                  SizedBox(height: 10),
                  textfield(PasswordConfirm, _focusNode3, 'Confirmar contraseña', Icons.password, isPassword: true),
                  SizedBox(height: 10),
                  
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
                  
                  SizedBox(height: 10),
                  account(),
                  SizedBox(height: 20),
                  SignUP_bottom(),
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
            "¿Ya tienes una cuenta?",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: widget.show,
            child: Text(
              'Ingresar',
              style: TextStyle(color: custom_green, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget SignUP_bottom() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: isLoading ? null : signUp,
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
                'Registrarse',
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
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          'icon/Quiz.png', // Mantiene la imagen estática como solicitaste
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Widget de respaldo si no se encuentra la imagen
            return Container(
              color: Colors.grey[300],
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey[600],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    
    email.dispose();
    password.dispose();
    PasswordConfirm.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    
    // Disponer animaciones
    _animationController.dispose();
    for (var controller in _dropControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }
}

// Painter personalizado para dibujar las gotas animadas
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

      // Crear forma de gota que se adapta al tamaño de pantalla
      final center = Offset(
        (positions[i].dx * size.width / 500).clamp(0.0, size.width),
        animations[i].value % (size.height + 200),
      );
      
      // Dibujar gota como una elipse con cola
      final dropSize = 6.0 + (i % 4) * 3.0;
      
      // Cuerpo principal de la gota (círculo)
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
      
      // Agregar brillo a la gota
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(center.dx - dropSize * 0.3, center.dy - dropSize * 0.3),
        dropSize * 0.25,
        highlightPaint,
      );
      
      // Agregar gotas más pequeñas como salpicaduras ocasionales
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