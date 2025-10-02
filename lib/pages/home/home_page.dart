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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  // Helper untuk menentukan ukuran layar
  bool _isMobile(double width) => width < 600;
  bool _isTablet(double width) => width >= 600 && width < 1024;
  bool _isDesktop(double width) => width >= 1024;

  // Helper untuk mendapatkan padding responsif
  double _getHorizontalPadding(double width) {
    if (_isMobile(width)) return 20;
    if (_isTablet(width)) return 40;
    return 60;
  }

  // Helper untuk mendapatkan max width konten
  double _getMaxContentWidth(double width) {
    if (_isMobile(width)) return width;
    if (_isTablet(width)) return 720;
    return 1200;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final horizontalPadding = _getHorizontalPadding(screenWidth);
        final maxContentWidth = _getMaxContentWidth(screenWidth);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          extendBodyBehindAppBar: false,
          appBar: _buildAppBar(screenWidth),
          drawer: _isMobile(screenWidth) || _isTablet(screenWidth)
              ? CustomDrawer(user: widget.user)
              : null,
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
              child: Row(
                children: [
                  // Sidebar untuk desktop
                  if (_isDesktop(screenWidth))
                    Container(
                      width: 280,
                      child: CustomDrawer(user: widget.user),
                    ),
                  // Konten utama
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: AnimatedBuilder(
                          animation: _pageAnimationController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.all(horizontalPadding),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Welcome Card
                                      WelcomeCard(user: widget.user),

                                      SizedBox(
                                          height: _isMobile(screenWidth)
                                              ? 32
                                              : 40),

                                      // Section Header
                                      _buildSectionHeader(
                                        'Menu Utama',
                                        'Pilih menu yang ingin Anda akses',
                                        screenWidth,
                                      ),

                                      SizedBox(
                                          height: _isMobile(screenWidth)
                                              ? 20
                                              : 24),

                                      // Action Cards
                                      ActionCards(),

                                      SizedBox(
                                          height: _isMobile(screenWidth)
                                              ? 32
                                              : 40),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, double screenWidth) {
    final isMobile = _isMobile(screenWidth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3748),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(double screenWidth) {
    final isMobile = _isMobile(screenWidth);
    final isDesktop = _isDesktop(screenWidth);

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF2D3748),
      title: Text(
        'Dashboard',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2D3748),
          fontSize: isMobile ? 22 : 24,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: !isDesktop,
      leading: !isDesktop
          ? Builder(
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
            )
          : null,
      actions: [
        // Notification Button
        Container(
          margin: EdgeInsets.only(
            right: isMobile ? 12 : 16,
            top: 8,
            bottom: 8,
          ),
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
                Icon(
                  Icons.notifications_outlined,
                  color: const Color(0xFF4A5568),
                  size: isMobile ? 20 : 22,
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
          margin: EdgeInsets.only(
            right: isMobile ? 16 : 24,
            top: 8,
            bottom: 8,
          ),
          child: GestureDetector(
            onTap: () => ProfileMenu.show(context, widget.user, _logout),
            child: ProfileAvatar(
              user: widget.user,
              size: isMobile ? 32 : 36,
              borderWidth: 2,
            ),
          ),
        ),
      ],
    );
  }
}