import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ocr_service.dart';
import '../services/receipt_scanner_service.dart';
import 'receipt_review_screen.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  static const Color background = Color(0xFF081120);
  static const Color cardColor = Color(0xFF10192B);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color cyan = Color(0xFF4CC9F0);
  static const Color red = Color(0xFFFF6B81);

  bool _isProcessing = false;
  String _statusText = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> _scanWithCamera() async {
    // 1. Check & request camera permission
    try {
      final status = await Permission.camera.status;

      if (status.isPermanentlyDenied) {
        _showPermissionSettingsDialog();
        return;
      }

      if (!status.isGranted) {
        final reqResult = await Permission.camera.request();
        if (reqResult.isPermanentlyDenied) {
          _showPermissionSettingsDialog();
          return;
        }
      }
    } catch (_) {
      // If permission_handler fails on specific devices, fall back to native picker intent
    }

    // 2. Open actual device camera
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );

      if (image == null) {
        // User cancelled camera
        return;
      }

      await _processImage(image.path);
    } catch (e) {
      _showSnackbar('Could not open camera: $e');
    }
  }

  Future<void> _uploadFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) {
        // User cancelled picker
        return;
      }

      await _processImage(image.path);
    } catch (e) {
      _showSnackbar('Could not select receipt: $e');
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isProcessing = true;
      _statusText = 'Reading receipt...';
    });

    String recognizedText = '';
    try {
      // 3. Run real OCR
      recognizedText = await OcrService.extractTextFromImage(imagePath);
    } catch (e) {
      debugPrint('[ReceiptScannerScreen] OCR error: $e');
      // If OCR encounters an error (e.g. model downloading or desktop), continue with review fallback
    }

    setState(() {
      _statusText = 'Extracting transaction details...';
    });

    try {
      // 4. Parse receipt data
      final parsedReceipt = ReceiptScannerService.parseReceipt(
        recognizedText,
        imagePath: imagePath,
      );

      if (!mounted) return;

      // 5. Navigate to editable review screen (user can verify and edit)
      final saved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptReviewScreen(parsedReceipt: parsedReceipt),
        ),
      );

      if (saved == true && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackbar('Receipt processing error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = '';
        });
      }
    }
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Camera Permission Required',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Camera permission is disabled. Open Settings to enable it.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(backgroundColor: purple),
              child: const Text('OPEN SETTINGS', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: red,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Receipt Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),

                  // Hero Icon with gradient glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [purple, cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: purple.withValues(alpha: 0.35),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Instant Receipt Capture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Capture paper receipts or upload invoices. FinPilot AI extracts merchant, amount, tax, and date automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Option 1: SCAN WITH CAMERA
                  _actionButton(
                    label: 'SCAN WITH CAMERA',
                    icon: Icons.camera_alt_rounded,
                    gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF5344CA)]),
                    onTap: _isProcessing ? null : _scanWithCamera,
                  ),

                  const SizedBox(height: 16),

                  // Option 2: UPLOAD RECEIPT
                  _actionButton(
                    label: 'UPLOAD RECEIPT',
                    icon: Icons.photo_library_rounded,
                    gradient: const LinearGradient(colors: [Color(0xFF1B2A47), Color(0xFF10192B)]),
                    border: Border.all(color: cyan.withValues(alpha: 0.35)),
                    onTap: _isProcessing ? null : _uploadFromGallery,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    r'Supports ₹, $, €, and standard retail & tax invoices',
                    style: TextStyle(color: Colors.white30, fontSize: 11),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(cyan),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    BoxBorder? border,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            border: border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
