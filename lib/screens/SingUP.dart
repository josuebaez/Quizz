import 'package:flutter/material.dart';
import 'package:prueba_app/const/colors.dart';
import 'package:prueba_app/data/auth_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
 
  @override
  void initState() {
    super.initState();
    _focusNode1.addListener(() {
      setState(() {});
    });
    _focusNode2.addListener(() {
      setState(() {});
    });
    _focusNode3.addListener(() {
      setState(() {});
    });
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
      Navigator.pushReplacementNamed(context, '/preguntas');
      
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
      setState(() {
        errorMessage = message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Ocurrió un error inesperado';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFF8B1E41),
      body: SafeArea(
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
        image: DecorationImage(
          image: AssetImage('images/1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    PasswordConfirm.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    super.dispose();
  }
}