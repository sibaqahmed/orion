
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
  final FirebaseAuth _auth=FirebaseAuth.instance;

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password
})async{
    return _auth.signInWithEmailAndPassword(email: email.trim(),
        password: password);
  }

  Future<UserCredential> signupWithEmail({
    required String email,
    required String password,
})async{
    return _auth.createUserWithEmailAndPassword(email: email.trim(),
        password: password);
  }

  Future<void> logout()async{
    await _auth.signOut();
  }

  Future<UserCredential> loginWithGoogle()async{
    final GoogleSignInAccount? googleUser=await GoogleSignIn().signIn();
    if(googleUser==null){
      throw Exception("Google sign-in cancelled");
    }

    final GoogleSignInAuthentication googleAuth=
        await googleUser.authentication;

    final credential=GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );
    return _auth.signInWithCredential(credential);
  }
}