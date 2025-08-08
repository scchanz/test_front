import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_front/pages/home/widgets/action_card.dart';
import 'package:test_front/pages/home/widgets/welcome_card.dart';
import 'package:test_front/pages/home/widgets/profile_menu.dart';
import 'package:test_front/components/customdrawer.dart';
import 'package:test_front/components/customnotification.dart';
import 'package:test_front/pages/login/login_page.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _pageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageAnimationController,
            curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
          ),
        );

    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    super.dispose();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: CustomDrawer(user: widget.user),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _pageAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Card
                        WelcomeCard(user: widget.user),

                        const SizedBox(height: 32),

                        // Section Header
                        _buildSectionHeader(
                          'Menu Utama',
                          'Pilih menu yang ingin Anda akses',
                        ),

                        const SizedBox(height: 20),

                        // Action Cards
                        ActionCards(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF2D3748),
      title: const Text(
        'Dashboard',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D3748),
          fontSize: 22,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
            iconSize: 20,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => CustomNotification(),
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF4A5568),
                  size: 20,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53E3E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Profile Photo in AppBar
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => ProfileMenu.show(context, widget.user, _logout),
            child: ProfileAvatar(user: widget.user, size: 32, borderWidth: 2),
          ),
        ),
      ],
    );
  }
}