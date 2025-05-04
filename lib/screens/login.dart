import 'package:flutter/material.dart';
import 'package:prueba_app/const/colors.dart';
import 'package:prueba_app/data/auth_data.dart';
import 'package:prueba_app/pages/niveles.dart';


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
      backgroundColor: Color(0xFF8B1E41),
      body: SafeArea(child: SingleChildScrollView(child: Column(
        children: [
          SizedBox(height: 20),
          image(),
          SizedBox(height: 50),
          textfield(email, _focusNode1, 'Correo',Icons.email),
          SizedBox(height: 10),
          textfield(password, _focusNode2, 'Contraseña',Icons.password, isPassword: true),
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
                style: TextStyle(color: Colors.white,fontSize: 14),
                ),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: widget.show,
                  child: Text(
                    'Registrarse',
                    style: TextStyle(color: custom_green,fontSize: 14,fontWeight: FontWeight.bold),
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
  
  // Método para manejar el login
  Future<void> _handleLogin() async {
    // Verificar si el widget sigue montado antes de continuar
    if (!_isMounted) return;
    
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
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,borderRadius: BorderRadius.circular(15),
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
                   :Color(0xffc5c5c5),
                ),
                contentPadding: 
                 EdgeInsets.symmetric(horizontal: 15,vertical: 15),
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