import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_front/Services/auth_service.dart';
import 'package:test_front/pages/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? errorMessage;
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> handleLogin() async {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "Email dan password tidak boleh kosong";
      });
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final user = await _authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );
      if (user != null) {
        goToHome();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Email tidak terdaftar';
            break;
          case 'wrong-password':
            errorMessage = 'Password salah';
            break;
          case 'invalid-email':
            errorMessage = 'Format email tidak valid';
            break;
          case 'user-disabled':
            errorMessage = 'Akun telah dinonaktifkan';
            break;
          default:
            errorMessage = 'Terjadi kesalahan: ${e.message}';
        }
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleAnonymousLogin() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final user = await _authService.signInAnonymously();
      if (user != null) {
        goToHome();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = 'Gagal login sebagai tamu: ${e.message}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void goToHome() {
    final user = _authService.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(user: user),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (errorMessage != null) ...[
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: handleLogin,
                          child: const Text('Login'),
                        ),
                        TextButton(
                          onPressed: handleAnonymousLogin,
                          child: const Text('Login sebagai Tamu'),
                        ),
                        
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
