import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:society_man/core/services/ocr_service.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/models/auth_models.dart';

class VisitorManagementScanScreen extends StatefulWidget {
  const VisitorManagementScanScreen({super.key});

  @override
  State<VisitorManagementScanScreen> createState() =>
      _VisitorManagementScanScreenState();
}

class _VisitorManagementScanScreenState
    extends State<VisitorManagementScanScreen> {
  Map<String, dynamic> _drafts = {};
  final OCRService _ocrService = OCRService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _loadDrafts() async {
    // Auto-cleanup expired drafts (24 hours)
    await LocalStorageService.deleteExpiredDrafts(const Duration(hours: 24));
    final drafts = await LocalStorageService.getAllDrafts();
    if (mounted) {
      setState(() {
        _drafts = drafts;
      });
    }
  }

  Future<void> _handleEIDScan() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final results = await _ocrService.scanEmiratesId(image);
        if (mounted) {
          Navigator.pop(context); // Dismiss loading

          // Auto-save as draft if we have basic info
          if (results['idNumber']!.isNotEmpty || results['name']!.isNotEmpty) {
            final draftEntry = VisitorEntry(
              id: 'DRAFT_${DateTime.now().millisecondsSinceEpoch}',
              visitorName: results['name']!,
              eidNumber: results['idNumber']!,
              phoneNumber: '',
              purpose: '',
              entryTime: DateTime.now(),
              status: 'draft',
              guardId: 1,
            );
            await LocalStorageService.saveDraft(draftEntry);
          }

          await Navigator.pushNamed(
            context,
            AppRoutes.visitorEntryScan,
            arguments: {
              'eidNumber': results['idNumber'],
              'visitorName': results['name'],
              'nationality': results['nationality'],
              'isDraft': false,
            },
          );
          _loadDrafts();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scan failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6E5F7), Color(0xFFE6E5F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildScanCard(),
                      if (_drafts.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _buildDraftsSection(),
                      ],
                      const SizedBox(height: 32),
                      _buildBackButton(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.layers, size: 40, color: Color(0xFF8063FC)),
        ),
        const SizedBox(height: 24),
        const Column(
          children: [
            Text(
              'Visitor Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Security Guard Portal',
              style: TextStyle(fontSize: 16, color: Color(0xFF7B7A80)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScanCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 448),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildScanArea(),
          const SizedBox(height: 24),
          const Text(
            'Scan Visitor EID',
            style: TextStyle(fontSize: 16, color: Color(0xFF7B7A80)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildScanButton(),
        ],
      ),
    );
  }

  Widget _buildScanArea() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 250),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E5F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8063FC), width: 1.4),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: Color(0xFF8063FC)),
            SizedBox(height: 16),
            Text(
              'Ready to scan',
              style: TextStyle(fontSize: 16, color: Color(0xFF7B7A80)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _handleEIDScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8063FC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF8063FC).withOpacity(0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 24),
                SizedBox(width: 12),
                Text(
                  'Scan EID',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.visitorEntryScan,
                arguments: {
                  'eidNumber': null,
                  'visitorName': null,
                  'nationality': null,
                  'isDraft': false,
                },
              );
              _loadDrafts();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8063FC)),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_outlined, size: 24, color: Color(0xFF8063FC)),
                SizedBox(width: 12),
                Text(
                  'Manual Entry',
                  style: TextStyle(fontSize: 18, color: Color(0xFF8063FC)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Drafts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _drafts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final draftId = _drafts.keys.elementAt(index);
            final draft = _drafts[draftId];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8063FC).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF8063FC),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draft['visitorName'] ?? 'Unknown Visitor',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'EID: ${draft['eidNumber'] ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.visitorEntryScan,
                        arguments: {'entryId': draftId, 'isDraft': true},
                      );
                      _loadDrafts();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8063FC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Resume'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back, size: 16, color: Color(0xFF7B7A80)),
          SizedBox(width: 4),
          Text(
            'Back to Dashboard',
            style: TextStyle(fontSize: 14, color: Color(0xFF7B7A80)),
          ),
        ],
      ),
    );
  }
}
