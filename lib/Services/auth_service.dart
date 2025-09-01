import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  // 📝 Registrasi Email & Password
  Future<User?> registerWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
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

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // 🔐 Login
  Future<void> loginWithEmailPassword(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    errorMessage = null;
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Navigation will be handled outside
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e.code);
    } finally {
      isLoading = false;
    }
  }

  // 📝 Registrasi
  Future<void> registerWithEmailPassword(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    errorMessage = null;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Navigation after register can be handled here or outside
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e.code);
    } finally {
      isLoading = false;
    }
  }

  // 🔐 Login Google
  Future<void> loginWithGoogle(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    try {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});
      if (kIsWeb) {
        await _auth.signInWithPopup(provider);
      } else {
        await _auth.signInWithProvider(provider);
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e.code);
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      isLoading = false;
    }
  }

  // 🧾 Pesan Error
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi';
    }
  }
}
