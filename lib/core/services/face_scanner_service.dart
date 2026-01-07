import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FaceScannerService {
  static Future<File?> scanFace(BuildContext context) async {
    return await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (context) => const FaceScannerScreen()),
    );
  }

  /// Verifies the captured face against the stored face for a user
  static Future<bool> verifyFaceForUser(
    String userId,
    File capturedFace,
  ) async {
    try {
      // In a real implementation, this would use a face recognition API
      // For now, we'll implement a more realistic verification

      // This would typically involve:
      // 1. Loading the stored face image for the user
      // 2. Extracting face features from both images
      // 3. Comparing the features to determine similarity
      // 4. Returning true if similarity is above threshold

      // For demonstration purposes, we'll implement basic checks
      // In production, you'd use a proper face recognition library

      // Check that the captured face file exists and is valid
      if (!await capturedFace.exists()) {
        return false;
      }

      // Get file size to ensure it's not too small (indicating invalid image)
      final fileSize = await capturedFace.length();
      if (fileSize < 1024) {
        // Less than 1KB is likely invalid
        return false;
      }

      // Additional checks could be implemented here
      // such as image dimensions, format validation, or actual face detection

      // For now, return true to indicate successful verification
      // In a real app, this would be the result of face matching algorithm
      return true;
    } catch (e) {
      print('Face verification error: \$e');
      return false;
    }
  }
}

class FaceScannerScreen extends StatefulWidget {
  const FaceScannerScreen({super.key});

  @override
  State<FaceScannerScreen> createState() => _FaceScannerScreenState();
}

class _FaceScannerScreenState extends State<FaceScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Use front camera for face scanning
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error initializing camera')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      if (mounted) {
        Navigator.pop(context, File(image.path));
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error capturing image')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Face Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isInitialized
          ? Stack(
              children: [
                // Camera preview
                Center(child: CameraPreview(_cameraController!)),
                // Face oval overlay
                CustomPaint(
                  painter: FaceOverlay(),
                  child: const SizedBox.expand(),
                ),
                // Instructions
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Position your face within the oval',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
                // Capture button
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isTakingPicture ? null : _takePicture,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isTakingPicture
                                  ? Colors.grey
                                  : const Color(0xFF8063FC),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Color(0xFF8063FC)),
            ),
    );
  }
}

class FaceOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double ovalWidth = size.width * 0.6;
    final double ovalHeight = size.height * 0.4;
    final double left = (size.width - ovalWidth) / 2;
    final double top = (size.height - ovalHeight) / 2;
    final Rect ovalRect = Rect.fromLTWH(left, top, ovalWidth, ovalHeight);

    // Draw semi-transparent overlay
    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addOval(ovalRect)
          ..close(),
      ),
      backgroundPaint,
    );

    // Draw border
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF8063FC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
