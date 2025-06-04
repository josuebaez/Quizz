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

class _LogIN_ScreenState extends State<LogIN_Screen> {
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();
  
  bool isLoading = false; // Para mostrar indicador de carga
  String? errorMessage; // Para mostrar mensajes de error
  bool _isMounted = true; // Flag para verificar si el widget está montado
 
  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(_handleFocus1Change);
    _focusNode2.addListener(_handleFocus2Change);
  }

  // Métodos separados para los listeners
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
             Color.fromARGB(255, 61, 180, 248), // Azul ESCOM
             Color.fromARGB(255, 53, 163, 226), // Variación más oscura del azul ESCOM
             Color.fromARGB(255, 112, 192, 245),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30),
                // Título de bienvenida
                welcomeTitle(),
                SizedBox(height: 20),
                // GIF o imagen animada
                animatedImage(),
                SizedBox(height: 40),
                // Formulario con diseño moderno
                formContainer(),
                SizedBox(height: 20),
                account(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget welcomeTitle() {
    return Column(
      children: [
        Text(
          '¡Bienvenido!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF98272B), // Color guinda 
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Inicia sesión para continuar',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF98272B), // Color guinda 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget formContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2D6A4F).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          textfield(email, _focusNode1, 'Correo electrónico', Icons.email_outlined),
          SizedBox(height: 20),
          textfield(password, _focusNode2, 'Contraseña', Icons.lock_outline, isPassword: true),
          SizedBox(height: 15),
          
          // Mostrar mensaje de error si existe
          if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          Login_bottom(),
        ],
      ),
    );
  }

  Widget account() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "¿No tienes una cuenta? ",
          style: TextStyle(
            color: Color(0xFF52796F),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: widget.show,
          child: Text(
            'Registrarse',
            style: TextStyle(
              color: Color(0xFF2D6A4F),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }

  Widget Login_bottom() {
    return GestureDetector(
      onTap: isLoading ? null : _handleLogin,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading 
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [Color(0xFF2D6A4F), Color(0xFF40916C)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: (isLoading ? Colors.grey : Color(0xFF2D6A4F)).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: isLoading 
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              'Iniciar Sesión',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
      ),
    );
  }
  
  // Método para manejar el login
  Future<void> _handleLogin() async {
    // Verificar si el widget sigue montado antes de continuar
    if (!_isMounted) return;
    
    // Limpiar mensajes de error previos
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    // Validar campos
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
      
      // Verificar si el widget sigue montado antes de navegar
      if (_isMounted) {
        // Si llegamos aquí, el login fue exitoso
        // Navegar a la pantalla de niveles
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => Niveles())
        );
      }
      
    } catch (e) {
      // Verificar si el widget sigue montado antes de actualizar el estado
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
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF8FFFE),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: focusNode.hasFocus 
            ? Color(0xFF2D6A4F)
            : Color(0xFFE6F2EF),
          width: 2.0,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        style: TextStyle(
          fontSize: 16, 
          color: Color(0xFF2D6A4F),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            iconss,
            color: focusNode.hasFocus
             ? Color(0xFF2D6A4F)
             : Color(0xFF74A189),
            size: 22,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          hintText: typeName,
          hintStyle: TextStyle(
            color: Color(0xFF74A189),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget animatedImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2D6A4F).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
          'gifs/Scene_Quiz.gif', 
          fit: BoxFit.cover,
          // 'images/1.jpg',
          
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D6A4F), Color(0xFF40916C)],
                ),
              ),
              child: Icon(
                Icons.quiz,
                size: 80,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Marcar que el widget ya no está montado
    _isMounted = false;
    
    // Eliminar los listeners antes de llamar a dispose
    _focusNode1.removeListener(_handleFocus1Change);
    _focusNode2.removeListener(_handleFocus2Change);
    
    // Disponer los controladores y nodos de foco
    email.dispose();
    password.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    
    super.dispose();
  }
}