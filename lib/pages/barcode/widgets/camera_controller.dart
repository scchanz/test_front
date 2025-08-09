import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraControllerWidget extends StatefulWidget {
  final Function(String) onBarcodeDetected;
  final bool isScanning;

  const CameraControllerWidget({
    super.key,
    required this.onBarcodeDetected,
    required this.isScanning,
  });

  @override
  State<CameraControllerWidget> createState() => _CameraControllerWidgetState();
}

class _CameraControllerWidgetState extends State<CameraControllerWidget>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isFlashOn = false;
  bool _isBackCamera = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _initializeController();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _controller?.dispose();
        _controller = null;
        break;
      case AppLifecycleState.inactive:
        // Do nothing
        break;
      case AppLifecycleState.hidden:
        // Do nothing
        break;
    }
  }

  void _initializeController() {
    if (_controller == null) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: _isFlashOn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _controller!,
          onDetect: (BarcodeCapture capture) {
            if (!widget.isScanning) return;
            
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                widget.onBarcodeDetected(barcode.rawValue!);
                break;
              }
            }
          },
        ),
        _buildCameraControls(),
      ],
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      top: 20,
      right: 20,
      child: Column(
        children: [
          _buildControlButton(
            icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
            onPressed: _toggleFlash,
            tooltip: 'Toggle Flash',
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            onPressed: _switchCamera,
            tooltip: 'Switch Camera',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
      ),
    );
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    
    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await _controller!.toggleTorch();
    } catch (e) {
      // Handle error silently or show snackbar
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_controller == null) return;
    
    try {
      setState(() {
        _isBackCamera = !_isBackCamera;
      });
      await _controller!.switchCamera();
    } catch (e) {
      // Handle error silently or show snackbar
      debugPrint('Error switching camera: $e');
    }
  }

  // Public methods for external control
  Future<void> resumeCamera() async {
    if (_controller == null) {
      _initializeController();
    }
  }

  Future<void> pauseCamera() async {
    _controller?.dispose();
    _controller = null;
  }

  bool get isFlashOn => _isFlashOn;
  bool get isBackCamera => _isBackCamera;
}