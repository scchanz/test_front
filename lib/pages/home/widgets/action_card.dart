import 'package:flutter/material.dart';
import 'package:test_front/pages/pasien/register_patient.dart';
import 'package:test_front/pages/rekammedis/input_rm.dart';
import 'package:test_front/pages/rekammedis/list_rm.dart';

class ActionCards extends StatelessWidget {
  const ActionCards({super.key});

  int _getCrossAxisCount(double width) {
    if (width < 600) {
      return 2; // Mobile: 2 columns
    } else if (width < 900) {
      return 3; // Tablet: 3 columns
    } else {
      return 4; // Desktop: 4 columns
    }
  }

  double _getChildAspectRatio(double width) {
    if (width < 600) {
      return 1.1; // Mobile
    } else if (width < 900) {
      return 1.0; // Tablet
    } else {
      return 0.9; // Desktop
    }
  }

  double _getCrossAxisSpacing(double width) {
    if (width < 600) {
      return 12; // Mobile
    } else if (width < 900) {
      return 16; // Tablet
    } else {
      return 20; // Desktop
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        'icon': Icons.add_circle_outline,
        'title': 'Input Data',
        'subtitle': 'Tambah rekam medis',
        'color': const Color(0xFF4CAF50), // Hospital green
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InputRekamMedisPage()),
        ),
      },
      {
        'icon': Icons.list_alt_rounded,
        'title': 'Lihat Data',
        'subtitle': 'Browse rekam medis',
        'color': const Color(0xFF81C784), // Light green
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LihatRekamMedisPage()),
        ),
      },
      {
        'icon': Icons.person_add_alt_1,
        'title': 'Register Pasien',
        'subtitle': 'Daftar pasien baru',
        'color': const Color(0xFF66BB6A), // Medium green
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterPatientPage()),
        ),
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Pengaturan',
        'subtitle': 'Konfigurasi sistem',
        'color': const Color(0xFF26A69A), // Teal green
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Halaman pengaturan akan segera hadir'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = _getCrossAxisCount(width);
        final childAspectRatio = _getChildAspectRatio(width);
        final spacing = _getCrossAxisSpacing(width);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
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
                    width: width,
                  ),
                );
              },
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
  final double width;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.width,
  });

  // Responsive sizing methods
  double _getIconContainerSize() {
    if (width < 600) {
      return 48; // Mobile
    } else if (width < 900) {
      return 52; // Tablet
    } else {
      return 56; // Desktop
    }
  }

  double _getIconSize() {
    if (width < 600) {
      return 24; // Mobile
    } else if (width < 900) {
      return 26; // Tablet
    } else {
      return 28; // Desktop
    }
  }

  double _getTitleFontSize() {
    if (width < 600) {
      return 15; // Mobile
    } else if (width < 900) {
      return 16; // Tablet
    } else {
      return 17; // Desktop
    }
  }

  double _getSubtitleFontSize() {
    if (width < 600) {
      return 11; // Mobile
    } else if (width < 900) {
      return 12; // Tablet
    } else {
      return 13; // Desktop
    }
  }

  double _getPadding() {
    if (width < 600) {
      return 16; // Mobile
    } else if (width < 900) {
      return 20; // Tablet
    } else {
      return 24; // Desktop
    }
  }

  double _getBorderRadius() {
    if (width < 600) {
      return 12; // Mobile
    } else {
      return 16; // Tablet & Desktop
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: Container(
          constraints: BoxConstraints(
            minHeight: width < 600 ? 120 : 140,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(_getPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: _getIconContainerSize(),
                  height: _getIconContainerSize(),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_getBorderRadius() * 0.75),
                  ),
                  child: Icon(
                    icon, 
                    color: color, 
                    size: _getIconSize(),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: _getTitleFontSize(),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                          letterSpacing: -0.2,
                        ),
                        maxLines: width < 600 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: width < 600 ? 2 : 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: _getSubtitleFontSize(),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: width < 600 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}