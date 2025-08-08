import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_front/pages/home/widgets/welcome_card.dart';
import 'package:test_front/pages/profile/edit_profile.dart';

class ProfileMenu {
  static void show(BuildContext context, User user, VoidCallback onLogout) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ProfileMenuSheet(
        user: user,
        onLogout: onLogout,
      ),
    );
  }
}

class ProfileMenuSheet extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const ProfileMenuSheet({
    super.key,
    required this.user,
    required this.onLogout,
  });

  String _getUsername() {
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user.email != null) {
      return user.email!.split('@')[0];
    }
    return 'Tamu';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              ProfileAvatar(user: user, size: 60),
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
                    if (user.email != null)
                      Text(
                        user.email!,
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
          _buildMenuItem(
            context,
            Icons.person_outline,
            'Edit Profil',
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            Icons.settings_outlined,
            'Pengaturan',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Halaman pengaturan akan segera hadir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            Icons.help_outline,
            'Bantuan',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Halaman bantuan akan segera hadir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            Icons.logout,
            'Keluar',
            () {
              Navigator.pop(context);
              onLogout();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : Colors.black87;
    
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}