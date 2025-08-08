import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_front/pages/rekammedis/menu_rm.dart';
import 'package:test_front/pages/rekammedis/list_rm.dart';
import 'package:test_front/pages/barcode/scan_barcode_page.dart';

class CustomDrawer extends StatelessWidget {
  final User user;

  const CustomDrawer({super.key, required this.user});

  String _getUsername() {
    if (user.email != null) {
      return user.email!.split('@')[0];
    }
    return 'Tamu';
  }

  @override
  Widget build(BuildContext context) {
    final username = _getUsername();

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(username),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.add,
                  title: 'Menu Rekam Medis',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TambahMenuPage(fromDrawer: true), // ⬅️ penting
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.list,
                  title: 'Lihat Rekam Medis',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LihatRekamMedisPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.qr_code_scanner,
                  title: 'Scan Barcode RM',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanBarcodePage()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Pengaturan',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'Pengaturan');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help,
                  title: 'Bantuan',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'Bantuan');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'Tentang',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(String username) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: 32,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            user.email ?? 'guest@local.app',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 22,
        color: Colors.grey[700],
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
          size: 22,
        ),
        title: const Text(
          'Keluar',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w400,
          ),
        ),
        onTap: () => _showLogoutDialog(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),
    );
  }

 void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Tutup dialog
              await FirebaseAuth.instance.signOut(); // Logout

              // Arahkan ke halaman login dan hapus semua route sebelumnya
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}


  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coming Soon'),
          content: Text('Fitur $feature sedang dikembangkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Rekam Medis App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.medical_information,
        size: 48,
        color: Colors.blue,
      ),
      children: const [
        Text('Aplikasi untuk mengelola rekam medis dengan mudah dan efisien.'),
      ],
    );
  }
}
