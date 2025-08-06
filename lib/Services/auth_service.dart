import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔐 Login Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // 👤 Login Anonim
  Future<User?> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    return cred.user;
  }

  // 🚪 Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 📌 Ambil user saat ini
  User? get currentUser => _auth.currentUser;
}
