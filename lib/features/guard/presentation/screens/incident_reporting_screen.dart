import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'dart:io';

class IncidentReportingScreen extends StatefulWidget {
  final String guardId;
  final String patrolId;
  final String checkpointId;

  const IncidentReportingScreen({
    super.key,
    required this.guardId,
    required this.patrolId,
    required this.checkpointId,
  });

  @override
  State<IncidentReportingScreen> createState() =>
      _IncidentReportingScreenState();
}

class _IncidentReportingScreenState extends State<IncidentReportingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _incidentPhoto;
  bool _isSubmitting = false;
  String _incidentType = 'security';

  final List<Map<String, String>> _incidentTypes = [
    {'value': 'security', 'label': 'Security Issue'},
    {'value': 'maintenance', 'label': 'Maintenance Needed'},
    {'value': 'safety', 'label': 'Safety Hazard'},
    {'value': 'other', 'label': 'Other Issue'},
  ];

  Future<void> _pickImage() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
    );

    if (photo != null && mounted) {
      setState(() {
        _incidentPhoto = File(photo.path);
      });
    }
  }

  Future<void> _submitIncident() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create incident data
      final incidentData = {
        'id': 'incident_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().toIso8601String(),
        'guardId': widget.guardId,
        'patrolId': widget.patrolId,
        'checkpointId': widget.checkpointId,
        'type': _incidentType,
        'description': _descriptionController.text,
        'photoPath': _incidentPhoto?.path,
        'status': 'pending',
        'ticketNumber': 'TKT-${DateTime.now().millisecondsSinceEpoch}',
      };

      // Save incident locally for offline sync
      await LocalStorageService.savePendingPatrolData(incidentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Incident reported successfully! Helpdesk ticket created.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to patrol screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to report incident: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Report Incident',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildIncidentTypeSelector(),
                        const SizedBox(height: 24),
                        _buildDescriptionField(),
                        const SizedBox(height: 24),
                        _buildPhotoSection(),
                        const SizedBox(height: 24),
                        _buildHelpdeskInfo(),
                      ],
                    ),
                  ),
                ),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Incident',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fill in the details below to create a helpdesk ticket',
            style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2196F3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2196F3)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This incident will be automatically sent to the helpdesk system and assigned a ticket number.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF2196F3)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incident Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _incidentTypes.map((type) {
              return ChoiceChip(
                label: Text(type['label']!),
                selected: _incidentType == type['value'],
                selectedColor: const Color(0xFF8063FC),
                backgroundColor: const Color(0xFFF4F5FA),
                labelStyle: TextStyle(
                  color: _incidentType == type['value']
                      ? Colors.white
                      : const Color(0xFF7B7A80),
                ),
                onSelected: (selected) {
                  setState(() {
                    _incidentType = selected ? type['value']! : 'other';
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please provide a description of the incident';
              }
              if (value.length < 10) {
                return 'Description must be at least 10 characters long';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Describe the incident in detail...',
              hintStyle: const TextStyle(color: Color(0xFF7B7A80)),
              filled: true,
              fillColor: const Color(0xFFF4F5FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photo Evidence (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _incidentPhoto == null
              ? _buildPhotoPlaceholder()
              : _buildPhotoPreview(),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: const Color(0xFF8063FC),
            strokeWidth: 2.0,
            gap: 5.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: const Color(0xFF8063FC),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap to take a photo',
                style: TextStyle(fontSize: 16, color: Color(0xFF7B7A80)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Photos help with incident investigation',
                style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(_incidentPhoto!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _pickImage,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF8063FC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retake Photo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _incidentPhoto = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Remove'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpdeskInfo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(
            Icons.assignment_outlined,
            color: Color(0xFFFFC107),
            size: 32,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Helpdesk Integration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This incident will be automatically converted to a helpdesk ticket with priority level based on incident type.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitIncident,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8063FC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Submit Incident Report',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw top dashed border
    _drawDashedLine(canvas, Offset(0, 0), Offset(size.width, 0), paint);

    // Draw right dashed border
    _drawDashedLine(
      canvas,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      paint,
    );

    // Draw bottom dashed border
    _drawDashedLine(
      canvas,
      Offset(size.width, size.height),
      Offset(0, size.height),
      paint,
    );

    // Draw left dashed border
    _drawDashedLine(canvas, Offset(0, size.height), Offset(0, 0), paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);

    if (length == 0) return;

    final directionX = dx / length;
    final directionY = dy / length;

    double current = 0.0;
    bool drawSegment = true;

    while (current < length) {
      final segmentLength = drawSegment ? strokeWidth * 3 : gap;
      final next = current + segmentLength;

      final fromX = start.dx + directionX * current;
      final fromY = start.dy + directionY * current;

      final toX = next > length
          ? start.dx + directionX * length
          : start.dx + directionX * next;
      final toY = next > length
          ? start.dy + directionY * length
          : start.dy + directionY * next;

      if (drawSegment) {
        canvas.drawLine(Offset(fromX, fromY), Offset(toX, toY), paint);
      }

      current = next;
      drawSegment = !drawSegment;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
