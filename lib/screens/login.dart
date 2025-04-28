import 'package:flutter/material.dart';
import 'package:prueba_app/const/colors.dart';
import 'package:prueba_app/data/auth_data.dart'; 

class LogIN_Screen extends StatefulWidget {
  final VoidCallback show;
  const LogIN_Screen(this.show,{super.key});
 
  @override
  State<LogIN_Screen> createState() => _LogIN_ScreenState();
}

class _LogIN_ScreenState extends State<LogIN_Screen> {
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  final email = TextEditingController();
  final password = TextEditingController();
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode1.addListener(() {setState(() {
      
    });});

    super.initState();
    _focusNode2.addListener(() {setState(() {
      
    });});
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
          textfield(password, _focusNode2, 'Contraseña',Icons.password),
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
      onTap: () async {
        try {
          await AuthenticationRemote().login(email.text, password.text);
          // Si la autenticación es exitosa, redirige a la pantalla principal
          // Ejemplo: Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
        } catch (e) {
          // Muestra un mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error de inicio de sesión: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          print('Error de autenticación: $e');
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'LogIn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
} //Cambie el login bottom

  Widget textfield(TextEditingController controller, FocusNode focusNode, String typeName, IconData iconss ) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
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

  /*Widget image() {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/1.jpg'), 
                fit: BoxFit.cover,
            ),
            ), 
          ),
        );
  } -- Este Widget es para que la imagen tenga cierto tamañao para que se alinie con lo demas*/

  Widget image() { //Este Widget es para que ocupe todo el ancho de la pantalla
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
  
}