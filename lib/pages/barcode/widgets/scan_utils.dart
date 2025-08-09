import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScanUtils {
  /// Validate barcode format (customize based on your RM format)
  static bool isValidRmFormat(String barcode) {
    // Example: RM format should be alphanumeric, length 6-20
    if (barcode.isEmpty || barcode.length < 6 || barcode.length > 20) {
      return false;
    }
    
    // Check if contains only alphanumeric characters
    final RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumeric.hasMatch(barcode);
  }

  /// Clean barcode data (remove unwanted characters)
  static String cleanBarcode(String barcode) {
    // Remove whitespace and convert to uppercase
    return barcode.trim().toUpperCase();
  }

  /// Generate vibration feedback on successful scan
  static void vibrateOnScan() {
    HapticFeedback.mediumImpact();
  }

  /// Generate sound feedback (you can add sound package later)
  static void playSuccessSound() {
    // TODO: Implement sound feedback using audioplayers package
    // AudioPlayer().play(AssetSource('sounds/beep.mp3'));
  }

  /// Show scan result with animation
  static void showScanResult(BuildContext context, String result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Barcode terdeteksi: $result'),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show scan error
  static void showScanError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(error),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Check camera permissions
  static Future<bool> checkCameraPermission() async {
    try {
      // This would require permission_handler package
      // For now, return true assuming permission is granted
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Format scan statistics
  static Map<String, String> formatScanStats({
    required int totalScans,
    required int successfulScans,
    required int failedScans,
  }) {
    final successRate = totalScans > 0 
        ? ((successfulScans / totalScans) * 100).toStringAsFixed(1)
        : '0.0';
    
    return {
      'total': totalScans.toString(),
      'successful': successfulScans.toString(),
      'failed': failedScans.toString(),
      'success_rate': '$successRate%',
    };
  }

  /// Get scan quality indicator
  static ScanQuality getScanQuality(String barcode) {
    if (barcode.length < 6) {
      return ScanQuality.poor;
    } else if (barcode.length < 10) {
      return ScanQuality.fair;
    } else if (isValidRmFormat(barcode)) {
      return ScanQuality.good;
    }
    return ScanQuality.excellent;
  }

  /// Convert timestamp to readable format for scan history
  static String formatScanTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Validate scan environment (lighting, etc.)
  static ScanEnvironment checkScanEnvironment() {
    // This would require more sophisticated analysis
    // For now, return a default value
    return ScanEnvironment.optimal;
  }

  /// Generate scan session ID for tracking
  static String generateScanSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Log scan attempt for analytics
  static void logScanAttempt({
    required String sessionId,
    required String result,
    required bool isSuccessful,
    String? errorMessage,
  }) {
    // TODO: Implement analytics logging
    debugPrint('Scan Attempt - Session: $sessionId, Result: $result, Success: $isSuccessful');
    if (errorMessage != null) {
      debugPrint('Error: $errorMessage');
    }
  }
}

enum ScanQuality {
  poor,
  fair,
  good,
  excellent,
}

enum ScanEnvironment {
  poor,      // Low light, blurry
  fair,      // Adequate conditions
  good,      // Good conditions
  optimal,   // Perfect conditions
}

extension ScanQualityExtension on ScanQuality {
  String get description {
    switch (this) {
      case ScanQuality.poor:
        return 'Kualitas scan rendah';
      case ScanQuality.fair:
        return 'Kualitas scan cukup';
      case ScanQuality.good:
        return 'Kualitas scan baik';
      case ScanQuality.excellent:
        return 'Kualitas scan sangat baik';
    }
  }

  Color get color {
    switch (this) {
      case ScanQuality.poor:
        return Colors.red;
      case ScanQuality.fair:
        return Colors.orange;
      case ScanQuality.good:
        return Colors.blue;
      case ScanQuality.excellent:
        return Colors.green;
    }
  }
}

extension ScanEnvironmentExtension on ScanEnvironment {
  String get description {
    switch (this) {
      case ScanEnvironment.poor:
        return 'Kondisi kurang baik';
      case ScanEnvironment.fair:
        return 'Kondisi cukup';
      case ScanEnvironment.good:
        return 'Kondisi baik';
      case ScanEnvironment.optimal:
        return 'Kondisi optimal';
    }
  }

  IconData get icon {
    switch (this) {
      case ScanEnvironment.poor:
        return Icons.warning;
      case ScanEnvironment.fair:
        return Icons.info;
      case ScanEnvironment.good:
        return Icons.check;
      case ScanEnvironment.optimal:
        return Icons.verified;
    }
  }
}