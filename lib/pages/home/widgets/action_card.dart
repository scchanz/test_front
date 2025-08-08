import 'package:flutter/material.dart';
import 'package:test_front/pages/pasien/register_patient.dart';
import 'package:test_front/pages/rekammedis/input_rm.dart';
import 'package:test_front/pages/rekammedis/list_rm.dart';

class ActionCards extends StatelessWidget {
  const ActionCards({super.key});

  @override
  Widget build(BuildContext context) {
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
          // TODO: Navigate to settings page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Halaman pengaturan akan segera hadir'),
              duration: Duration(seconds: 2),
            ),
          );
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
              child: ActionCard(
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
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}