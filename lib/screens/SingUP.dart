import 'package:flutter/material.dart';
import 'package:prueba_app/const/colors.dart';
import 'package:prueba_app/data/auth_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:prueba_app/pages/niveles.dart'; 
//import 'package:app_quiz/pages/niveles.dart'; 

class SignUp_Screen extends StatefulWidget {
  final VoidCallback show;
  const SignUp_Screen(this.show, {super.key});

  @override
  State<SignUp_Screen> createState() => _SignUp_ScreenState();
}

class _SignUp_ScreenState extends State<SignUp_Screen> {
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();
  final PasswordConfirm = TextEditingController();
  
  bool isLoading = false;
  String? errorMessage;
  bool _isMounted = true;
 
  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(_handleFocus1Change);
    _focusNode2.addListener(_handleFocus2Change);
    _focusNode3.addListener(_handleFocus3Change);
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

  void _handleFocus3Change() {
    if (_isMounted) {
      setState(() {});
    }
  }

  // Función para validar el formato de email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Función para manejar el registro
  void signUp() async {
    if (!_isMounted) return;
    
    // Limpiar mensajes de error previos
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    // Validar campos vacíos
    if (email.text.trim().isEmpty || password.text.isEmpty || PasswordConfirm.text.isEmpty) {
      if (_isMounted) {
        setState(() {
          errorMessage = "Por favor, completa todos los campos";
          isLoading = false;
        });
      }
      return;
    }

    // Validar formato de email
    if (!isValidEmail(email.text.trim())) {
      if (_isMounted) {
        setState(() {
          errorMessage = "El formato del correo electrónico no es válido";
          isLoading = false;
        });
      }
      return;
    }

    // Validar que las contraseñas coincidan
    if (password.text != PasswordConfirm.text) {
      if (_isMounted) {
        setState(() {
          errorMessage = "Las contraseñas no coinciden";
          isLoading = false;
        });
      }
      return;
    }

    // Intentar registrar al usuario
    try {
      await AuthenticationRemote().register(
        email.text.trim(), 
        password.text.trim(), 
        PasswordConfirm.text.trim()
      );
      
      // Verificar si el widget sigue montado antes de navegar
      if (_isMounted) {
        // Si llegamos aquí, el registro fue exitoso
        // Navegar a la pantalla de niveles
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => Niveles())
        );
      }
      
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase
      if (_isMounted) {
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
        setState(() {
          errorMessage = message;
          isLoading = false;
        });
      }
    } catch (e) {
      if (_isMounted) {
        setState(() {
          errorMessage = 'Ocurrió un error inesperado';
          isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 71, 138, 238), 
              Color.fromARGB(255, 89, 127, 230), 
              Color.fromARGB(255, 255, 255, 255), // Blanco
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
                // Imagen estática
                image(),
                SizedBox(height: 30),
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
          '¡Aprende con nosotros!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 219, 68, 106),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Crea tu cuenta para empezar',
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 219, 68, 106),
            fontWeight: FontWeight.w400,
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
          SizedBox(height: 20),
          textfield(PasswordConfirm, _focusNode3, 'Confirmar contraseña', Icons.lock_outline, isPassword: true),
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
            
          SignUP_bottom(),
        ],
      ),
    );
  }

  Widget account() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "¿Ya tienes una cuenta? ",
          style: TextStyle(
            color: Color(0xFF52796F),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: widget.show,
          child: Text(
            'Ingresar',
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

  Widget SignUP_bottom() {
    return GestureDetector(
      onTap: isLoading ? null : signUp,
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
              'Registrarse',
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
  
  Widget image() {
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
          'images/Quiz.png', // Tu imagen estática
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D6A4F), Color(0xFF40916C)],
                ),
              ),
              child: Icon(
                Icons.person_add,
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
    _focusNode3.removeListener(_handleFocus3Change);
    
    // Disponer los controladores y nodos de foco
    email.dispose();
    password.dispose();
    PasswordConfirm.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    
    super.dispose();
  }
}