import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Product QR'),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              final String? code = capture.barcodes.firstOrNull?.rawValue;
              if (code != null) {
                Navigator.pop(context, code);
              }
            },
          ),
          _buildScannerOverlay(context),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    return CustomPaint(
      painter: ScannerOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Define scan window size (square, ~60-70% of screen width)
    final scanWindowSize = size.width * 0.65;
    final scanLeft = (size.width - scanWindowSize) / 2;
    final scanTop = (size.height - scanWindowSize) / 2 - 40; // slightly higher

    final scanRect = Rect.fromLTWH(
      scanLeft,
      scanTop,
      scanWindowSize,
      scanWindowSize,
    );

    // 1. Semi-transparent dark overlay everywhere
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.75); // ≈75% opacity

    // 2. Create path for the whole screen
    final outerPath = Path()..addRect(screenRect);

    // 3. Subtract the scan window (makes it transparent there)
    final cutoutPath = Path()..addRRect(
      RRect.fromRectAndRadius(
        scanRect,
        const Radius.circular(16), // optional: slight rounding
      ),
    );

    final backgroundPath = Path.combine(
      PathOperation.difference,
      outerPath,
      cutoutPath,
    );

    canvas.drawPath(backgroundPath, overlayPaint);

    // 4. Draw white corner indicators (L shapes) with 75% opacity
    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 32.0; // length of each arm
    const cornerGap = 8.0;     // space from edge of scanRect

    // Top-left
    canvas.drawLine(
      Offset(scanRect.left + cornerGap, scanRect.top + cornerGap + cornerLength),
      Offset(scanRect.left + cornerGap, scanRect.top + cornerGap),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left + cornerGap, scanRect.top + cornerGap),
      Offset(scanRect.left + cornerGap + cornerLength, scanRect.top + cornerGap),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(scanRect.right - cornerGap, scanRect.top + cornerGap + cornerLength),
      Offset(scanRect.right - cornerGap, scanRect.top + cornerGap),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right - cornerGap - cornerLength, scanRect.top + cornerGap),
      Offset(scanRect.right - cornerGap, scanRect.top + cornerGap),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(scanRect.left + cornerGap, scanRect.bottom - cornerGap - cornerLength),
      Offset(scanRect.left + cornerGap, scanRect.bottom - cornerGap),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left + cornerGap, scanRect.bottom - cornerGap),
      Offset(scanRect.left + cornerGap + cornerLength, scanRect.bottom - cornerGap),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(scanRect.right - cornerGap, scanRect.bottom - cornerGap - cornerLength),
      Offset(scanRect.right - cornerGap, scanRect.bottom - cornerGap),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right - cornerGap - cornerLength, scanRect.bottom - cornerGap),
      Offset(scanRect.right - cornerGap, scanRect.bottom - cornerGap),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}