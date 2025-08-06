import 'package:flutter/material.dart';

class CustomNotification {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = Colors.blueAccent,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.notifications,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        backgroundColor: backgroundColor,
        duration: duration,
        icon: icon,
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}

class _NotificationWidget extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final IconData icon;

  const _NotificationWidget({
    required this.message,
    required this.backgroundColor,
    required this.duration,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
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
