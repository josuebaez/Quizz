import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationDatasource {
  Future<UserCredential> register(String email, String password, String passwordConfirm);
  Future<UserCredential> login(String email, String password);
}

class AuthenticationRemote extends AuthenticationDatasource {
  @override
  Future<UserCredential> login(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(), 
      password: password.trim()
    );
  }

  @override
  Future<UserCredential> register(String email, String password, String passwordConfirm) async {
    if(passwordConfirm != password) {
      throw FirebaseAuthException(
        code: 'passwords-dont-match',
        message: 'Las contraseñas no coinciden',
      );
    }
    
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(), 
      password: password.trim()
    );
  }
}