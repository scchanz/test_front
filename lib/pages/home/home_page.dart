import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_front/pages/home/widgets/stats_card.dart';
import 'package:test_front/pages/pasien/register_patient.dart';
import 'package:test_front/components/customdrawer.dart';
import 'package:test_front/pages/profile/edit_profile.dart';
import 'package:test_front/pages/rekammedis/input_rm.dart';
import 'package:test_front/pages/rekammedis/list_rm.dart';
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {

  late AnimationController _pageAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _pageAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  String _getUsername() {
    // Prioritas: displayName > email username > 'Tamu'
    if (widget.user.displayName != null &&
        widget.user.displayName!.isNotEmpty) {
      return widget.user.displayName!;
    }
    if (widget.user.email != null) {
      return widget.user.email!.split('@')[0];
    }
    return 'Tamu';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  // Widget untuk menampilkan foto profil
  Widget _buildProfileImage({required double size, double borderWidth = 3}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(child: _buildProfileImageContent(size)),
    );
  }

  Widget _buildProfileImageContent(double size) {
    // Jika user memiliki foto profil (biasanya dari Google)
    if (widget.user.photoURL != null && widget.user.photoURL!.isNotEmpty) {
      return Image.network(
        widget.user.photoURL!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Jika gagal load gambar, tampilkan avatar default
          return _buildDefaultAvatar(size);
        },
      );
    } else {
      // Jika tidak ada foto profil, tampilkan avatar default
      return _buildDefaultAvatar(size);
    }
  }

  Widget _buildDefaultAvatar(double size) {
    final username = _getUsername();
    final initials = username.isNotEmpty
        ? username
              .split(' ')
              .take(2)
              .map((name) => name.isNotEmpty ? name[0].toUpperCase() : '')
              .join()
        : 'T';

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
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
    final username = _getUsername();
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: CustomDrawer(user: widget.user),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                        // Enhanced Welcome Section with Profile Photo
                        _buildEnhancedWelcomeCard(greeting, username),

                        const SizedBox(height: 32),

                        // Quick Actions Section
                        _buildSectionHeader(
                          'Menu Utama',
                          'Pilih menu yang ingin Anda akses',
                        ),

                        const SizedBox(height: 20),

                        // Action Cards with staggered animation
                        _buildActionCards(context),

                        const SizedBox(height: 32),

                        // Stats Section
                        _buildSectionHeader(
                          'Ringkasan Data',
                          'Statistik dan informasi penting',
                        ),

                        const SizedBox(height: 20),

                        const StatsCard(),

                        const SizedBox(height: 32),

                        // Recent Activity Section
                        _buildRecentActivity(),

                        const SizedBox(height: 100), // Space for FAB
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

  Widget _buildEnhancedWelcomeCard(String greeting, String username) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Photo
          _buildProfileImage(size: 70),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.user.email != null)
                  Text(
                    widget.user.email!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),

          // Login Provider Indicator
          _buildLoginProviderIndicator(),
        ],
      ),
    );
  }

  Widget _buildLoginProviderIndicator() {
    // Deteksi provider login
    bool isGoogleLogin = false;

    // Cek apakah user login dengan Google
    for (final providerData in widget.user.providerData) {
      if (providerData.providerId == 'google.com') {
        isGoogleLogin = true;
        break;
      }
    }

    if (isGoogleLogin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.g_mobiledata,
                    size: 14,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Google',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.email, size: 12, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Email',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
            onTap: () {
              // TODO: Show profile menu or navigate to profile
              _showProfileMenu();
            },
            child: _buildProfileImage(size: 32, borderWidth: 2),
          ),
        ),
      ],
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Profile info
            Row(
              children: [
                _buildProfileImage(size: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUsername(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.user.email != null)
                        Text(
                          widget.user.email!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),

            // Menu items
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profil'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer atau bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InputRekamMedisPage()),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              label: const Text(
                'Input Cepat',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCards(BuildContext context) {
    final cards = [
      {
        'icon': Icons.add_circle_outline,
        'title': 'Input Data',
        'subtitle': 'Tambah rekam medis',
        'color': const Color(0xFF48BB78),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InputRekamMedisPage()),
        ),
      },
      {
        'icon': Icons.list_alt_rounded,
        'title': 'Lihat Data',
        'subtitle': 'Browse rekam medis',
        'color': const Color(0xFFED8936),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LihatRekamMedisPage()),
        ),
      },
      {
        'icon': Icons.person_add_alt_1,
        'title': 'Register Pasien',
        'subtitle': 'Daftar pasien baru',
        'color': const Color(0xFF4299E1),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterPatientPage()),
        ),
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Pengaturan',
        'subtitle': 'Konfigurasi sistem',
        'color': const Color(0xFF9F7AEA),
        'onTap': () {
          // Tambahkan navigasi jika ada
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: _buildEnhancedActionCard(
                icon: card['icon'] as IconData,
                title: card['title'] as String,
                subtitle: card['subtitle'] as String,
                color: card['color'] as Color,
                onTap: card['onTap'] as VoidCallback,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aktivitas Terkini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Color(0xFF667eea),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Input rekam medis berhasil',
            'Pasien: Ahmad Rizki',
            '2 jam yang lalu',
            Icons.check_circle,
            const Color(0xFF48BB78),
          ),
          _buildActivityItem(
            'Pasien baru terdaftar',
            'Pasien: Siti Aminah',
            '4 jam yang lalu',
            Icons.person_add,
            const Color(0xFF4299E1),
          ),
          _buildActivityItem(
            'Data rekam medis diperbarui',
            'Pasien: Budi Santoso',
            '1 hari yang lalu',
            Icons.edit,
            const Color(0xFFED8936),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
