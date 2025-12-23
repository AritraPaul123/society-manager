import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GuardActivePatrolScreen extends StatefulWidget {
  const GuardActivePatrolScreen({super.key});

  @override
  State<GuardActivePatrolScreen> createState() =>
      _GuardActivePatrolScreenState();
}

class _GuardActivePatrolScreenState extends State<GuardActivePatrolScreen> {
  bool showReportModal = false;
  final TextEditingController _descriptionController = TextEditingController();
  String incidentType = '';
  String reportVenue = 'Main Entrance Gate';
  final String guardId =
      'GRD-2024-001'; // This would come from auth in production
  final ImagePicker _imagePicker = ImagePicker();
  File? _incidentPhoto;
  String currentTime = '';
  String currentDate = '';

  final List<String> venues = [
    'Main Entrance Gate',
    'Parking Lot A',
    'Parking Lot B',
    'Building A Lobby',
    'Building B Lobby',
    'Swimming Pool Area',
    'Gym Entrance',
    'Playground',
  ];

  final List<String> incidentTypes = [
    'Security Breach',
    'Suspicious Activity',
    'Medical Emergency',
    'Fire Hazard',
    'Equipment Malfunction',
    'Vandalism',
    'Noise Complaint',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      currentTime = DateFormat('h:mm:ss a').format(now);
      currentDate = DateFormat('MM/dd/yyyy').format(now);
    });
  }

  bool get isFormValid =>
      incidentType.isNotEmpty && _descriptionController.text.trim().isNotEmpty;

  Future<void> _takeIncidentPhoto() async {
    // Only allow camera source, no gallery option
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 85,
    );

    if (photo != null && mounted) {
      setState(() {
        _incidentPhoto = File(photo.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo captured successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E5F7),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: showReportModal
                            ? _buildReportForm()
                            : _buildQRScannerCard(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                'assets/icons/app_logo.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guard Patrol System',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
                height: 1.5,
                letterSpacing: -0.312,
              ),
            ),
            Text(
              'Field Operations Dashboard',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF7B7A80),
                height: 1.43,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQRScannerCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 448),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Column(
            children: [
              Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.5,
                  letterSpacing: -0.439,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Main Entrance Gate',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF7B7A80),
                  height: 1.5,
                  letterSpacing: -0.312,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildQRCodeDisplay(),
          const SizedBox(height: 24),
          _buildSimulateButton(),
        ],
      ),
    );
  }

  Widget _buildQRCodeDisplay() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(32),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8063FC), width: 3.39),
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: 0.4,
                  child: Icon(
                    Icons.qr_code_2,
                    size: 96,
                    color: const Color(0xFF8063FC),
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8063FC).withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            showReportModal = true;
            _updateDateTime();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8063FC),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Simulate QR Scan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                height: 1.5,
                letterSpacing: -0.312,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 448),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
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
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.5,
              letterSpacing: -0.439,
            ),
          ),
          const SizedBox(height: 24),
          // Guard ID Display
          _buildInfoField('Guard ID', guardId),
          const SizedBox(height: 16),
          // Venue Dropdown
          _buildVenueDropdown(),
          const SizedBox(height: 16),
          _buildIncidentTypeDropdown(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          // Photo capture button
          _buildPhotoButton(),
          const SizedBox(height: 16),
          _buildDateTimeInfo(),
          const SizedBox(height: 24),
          _buildFormButtons(),
        ],
      ),
    );
  }

  Widget _buildIncidentTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Incident Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF7B7A80),
            height: 1.43,
            letterSpacing: -0.15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonFormField<String>(
            value: incidentType.isEmpty ? null : incidentType,
            hint: const Text(
              'Select incident type',
              style: TextStyle(fontSize: 16, color: Color(0xFF7B7A80)),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            icon: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF7B7A80)),
            ),
            dropdownColor: Colors.white,
            items: incidentTypes.map((String type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              setState(() {
                incidentType = value ?? '';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF7B7A80),
            height: 1.43,
            letterSpacing: -0.15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Venue',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF7B7A80),
            height: 1.43,
            letterSpacing: -0.15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonFormField<String>(
            value: reportVenue,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            icon: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF7B7A80)),
            ),
            dropdownColor: Colors.white,
            items: venues.map((String venue) {
              return DropdownMenuItem<String>(value: venue, child: Text(venue));
            }).toList(),
            onChanged: (value) {
              setState(() {
                reportVenue = value ?? venues[0];
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Incident Photo (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF7B7A80),
            height: 1.43,
            letterSpacing: -0.15,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _takeIncidentPhoto,
            icon: Icon(
              _incidentPhoto == null ? Icons.camera_alt : Icons.check_circle,
              size: 20,
            ),
            label: Text(
              _incidentPhoto == null ? 'Take Photo' : 'Photo Captured',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _incidentPhoto == null
                  ? Colors.white
                  : const Color(0xFF10B981),
              foregroundColor: _incidentPhoto == null
                  ? const Color(0xFF8063FC)
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _incidentPhoto == null
                      ? const Color(0xFFE5E7EB)
                      : const Color(0xFF10B981),
                ),
              ),
              elevation: 0,
            ),
          ),
        ),
        if (_incidentPhoto != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      _incidentPhoto!,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.all(4),
                        ),
                        onPressed: () {
                          setState(() {
                            _incidentPhoto = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF7B7A80),
            height: 1.43,
            letterSpacing: -0.15,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Describe the incident...',
            hintStyle: const TextStyle(color: Color(0xFF7B7A80), fontSize: 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8063FC), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeInfo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF7B7A80),
                  height: 1.43,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentTime,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF7B7A80),
                  height: 1.43,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentDate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                showReportModal = false;
                incidentType = '';
                _descriptionController.clear();
              });
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                letterSpacing: -0.312,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isFormValid
                ? () {
                    // Handle submit incident report
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incident report submitted'),
                      ),
                    );
                    setState(() {
                      showReportModal = false;
                      incidentType = '';
                      _descriptionController.clear();
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8063FC),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF8063FC).withOpacity(0.6),
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Submit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                letterSpacing: -0.312,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
