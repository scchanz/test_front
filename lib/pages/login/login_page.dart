import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_front/pages/home/home_page.dart';
import 'package:test_front/pages/register/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animationController;
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardScaleAnimation;

  // Hospital green color palette
  static const Color primaryGreen = Color(0xFF4CAF50);      // Main green
  static const Color lightGreen = Color(0xFF81C784);        // Light green
  static const Color paleGreen = Color(0xFFE8F5E8);         // Very light green
  static const Color mintGreen = Color(0xFFA5D6A7);         // Mint green
  static const Color backgroundGreen = Color(0xFFF1F8E9);   // Background green

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _headerAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Header animations
    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _titleSlideAnimation = Tween<Offset>(begin: Offset(-0.3, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerAnimationController,
            curve: Interval(0.3, 1.0, curve: Curves.easeOutBack),
          ),
        );

    // Card animations
    _cardSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );
    _cardScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
    _headerAnimationController.forward();
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  Future<void> _loginWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final user = _auth.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(user: user),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        setState(() {
          _errorMessage = 'Login Google gagal: token tidak valid';
          _isLoading = false;
        });
        return;
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _auth.signInWithCredential(credential);
      final user = _auth.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(user: user),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Coba lagi nanti';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi';
    }
  }

  Widget _buildWelcomeHeader() {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _headerScaleAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Decorative elements with hospital green design
              FadeTransition(
                opacity: _titleFadeAnimation,
                child: Row(
                  children: [
                    // Simple gradient bar in hospital green
                    Container(
                      width: 6,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: SlideTransition(
                        position: _titleSlideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Enhanced main greeting
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Selamat Datang',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ✨',
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            
                            // Enhanced subtitle
                            Text(
                              'Kami rindu dengan kehadiran Anda\nMari mulai perjalanan luar biasa ini!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Enhanced decorative elements
              FadeTransition(
                opacity: _titleFadeAnimation,
                child: Row(
                  children: [
                    SizedBox(width: 22),
                    ...List.generate(5, (index) {
                      return Container(
                        margin: EdgeInsets.only(right: index == 2 ? 12 : 6),
                        width: index == 2 ? 16 : index == 1 || index == 3 ? 10 : 6,
                        height: index == 2 ? 8 : index == 1 || index == 3 ? 6 : 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            index == 2 ? 0.9 : index == 1 || index == 3 ? 0.6 : 0.3
                          ),
                          borderRadius: BorderRadius.circular(
                            index == 2 ? 4 : 2
                          ),
                          boxShadow: index == 2 ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ] : null,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          // Simplified hospital green gradient
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryGreen,
              lightGreen,
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.06),

                      // Enhanced Welcome Header
                      _buildWelcomeHeader(),

                      SizedBox(height: size.height * 0.05),

                      // Enhanced Card with hospital green accents
                      AnimatedBuilder(
                        animation: _cardAnimationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _cardSlideAnimation.value),
                            child: ScaleTransition(
                              scale: _cardScaleAnimation,
                              child: Container(
                                padding: EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 40,
                                      offset: Offset(0, 20),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: primaryGreen.withOpacity(0.1),
                                      blurRadius: 60,
                                      offset: Offset(0, 30),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.08),
                                              blurRadius: 15,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _emailController,
                                          validator: _validateEmail,
                                          keyboardType: TextInputType.emailAddress,
                                          style: TextStyle(fontSize: 16),
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                            labelStyle: TextStyle(color: Colors.grey[600]),
                                            prefixIcon: Container(
                                              margin: EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: paleGreen,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.email_outlined,
                                                color: primaryGreen,
                                                size: 22,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: BorderSide(
                                                color: primaryGreen,
                                                width: 2.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 20,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 24),

                                      // Password Field with hospital green styling
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.08),
                                              blurRadius: 15,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _passwordController,
                                          validator: _validatePassword,
                                          obscureText: _obscurePassword,
                                          style: TextStyle(fontSize: 16),
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            labelStyle: TextStyle(color: Colors.grey[600]),
                                            prefixIcon: Container(
                                              margin: EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: paleGreen,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.lock_outlined,
                                                color: primaryGreen,
                                                size: 22,
                                              ),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                color: Colors.grey[600],
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
                                                });
                                              },
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(18),
                                              borderSide: BorderSide(
                                                color: primaryGreen,
                                                width: 2.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey[50],
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 20,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 16),

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: TextButton(
                                            onPressed: () {},
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                            child: Text(
                                              'Lupa Password?',
                                              style: TextStyle(
                                                color: primaryGreen,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 20),

                                      if (_errorMessage != null) ...[
                                        Container(
                                          padding: EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.red.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red.shade600,
                                                size: 22,
                                              ),
                                              SizedBox(width: 14),
                                              Expanded(
                                                child: Text(
                                                  _errorMessage!,
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
                                        SizedBox(height: 24),
                                      ],

                                      // Login Button with hospital green color
                                      Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(18),
                                          color: primaryGreen,
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryGreen.withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _loginWithEmailPassword,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryGreen,
                                            foregroundColor: Colors.white,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? SizedBox(
                                                  height: 26,
                                                  width: 26,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.8,
                                                  ),
                                                )
                                              : Text(
                                                  'Masuk Sekarang',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                        ),
                                      ),

                                      SizedBox(height: 32),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                              thickness: 1.2,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Text(
                                              'atau masuk dengan',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                              thickness: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 28),

                                      // Google Sign In Button
                                      Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.12),
                                              blurRadius: 15,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: OutlinedButton.icon(
                                          onPressed: _isLoading
                                              ? null
                                              : _loginWithGoogle,
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.grey.shade700,
                                            side: BorderSide.none,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                          ),
                                          icon: Container(
                                            width: 26,
                                            height: 26,
                                            child: Image.network(
                                              'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                                              errorBuilder:
                                                  (context, error, stackTrace) => Icon(
                                                    Icons.account_circle,
                                                    color: Colors.red,
                                                    size: 26,
                                                  ),
                                            ),
                                          ),
                                          label: Text(
                                            'Masuk dengan Google',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 36),

                      // Registration prompt with hospital green theme
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RegisterPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'Daftar Sekarang',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}