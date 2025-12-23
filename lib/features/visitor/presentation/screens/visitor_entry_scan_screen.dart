import 'package:flutter/material.dart';
import 'package:society_man/core/models/auth_models.dart';
import 'package:society_man/core/services/local_storage_service.dart';
import 'package:society_man/core/routes/app_routes.dart';
import 'package:camera/camera.dart';

class VisitorEntryScanScreen extends StatefulWidget {
  final String? eidNumber;
  final String? visitorName;
  final String? nationality;
  final bool isDraft;

  const VisitorEntryScanScreen({
    super.key,
    this.eidNumber,
    this.visitorName,
    this.nationality,
    this.isDraft = false,
  });

  @override
  State<VisitorEntryScanScreen> createState() => _VisitorEntryScanScreenState();
}

class _VisitorEntryScanScreenState extends State<VisitorEntryScanScreen> {
  final TextEditingController _visitorNameController = TextEditingController();
  final TextEditingController _eidController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  String? _existingVisitorPhone;
  String? _existingVisitorCompany;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isDraft = false;
  String? _selectedPurpose;

  @override
  void initState() {
    super.initState();

    // Pre-populate fields if visitor exists or is from draft
    if (widget.eidNumber != null) {
      _eidController.text = widget.eidNumber!;
    }

    if (widget.visitorName != null) {
      _visitorNameController.text = widget.visitorName!;
    }

    // Check if this is a repeat visitor
    _checkForExistingVisitor();

    // Check if this is a draft
    if (widget.isDraft) {
      _isDraft = true;
      _loadDraftData();
    }
  }

  @override
  void dispose() {
    _visitorNameController.dispose();
    _eidController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dateTime) {
    // Format the date as "DD/MM/YYYY HH:MM"
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _checkForExistingVisitor() async {
    if (widget.eidNumber != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final existingVisitor = await LocalStorageService.getVisitorProfile(
          widget.eidNumber!,
        );
        if (existingVisitor != null && mounted) {
          _existingVisitorPhone = existingVisitor.phoneNumber;
          _existingVisitorCompany = existingVisitor
              .companyName; // Fixed: was using phoneNumber instead of companyName
          _phoneController.text = existingVisitor.phoneNumber;

          // Show info about repeat visitor
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome back, ${existingVisitor.visitorName}! Last visit: ${_formatDate(existingVisitor.lastVisit)}',
                ),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error checking visitor: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _loadDraftData() async {
    // In a real implementation, this would load draft data from storage
    // For now, this is a placeholder
  }

  Future<void> _saveAsDraft() async {
    if (_eidController.text.isEmpty || _visitorNameController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('EID and Name are required to save as draft'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final visitorEntry = VisitorEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eidNumber: _eidController.text,
        visitorName: _visitorNameController.text,
        phoneNumber: _phoneController.text,
        purpose: _purposeController.text,
        companyName: _companyController.text, // Added company name to draft
        entryTime: DateTime.now(),
        guardId: 'GRD001', // This should be the actual guard ID
        status: 'draft',
        isDraft: true,
      );

      await LocalStorageService.saveDraft(visitorEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry saved as draft successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.attendanceManagement);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving draft: ${e.toString()}'),
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

  Future<void> _submitEntry() async {
    if (_eidController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('EID number is required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_visitorNameController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visitor name is required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_phoneController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number is required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_purposeController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purpose is required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Check if visitor profile already exists to update visit count
      VisitorProfile? existingProfile =
          await LocalStorageService.getVisitorProfile(_eidController.text);

      VisitorProfile visitorProfile;
      if (existingProfile != null) {
        // Update existing profile
        visitorProfile = VisitorProfile(
          eidNumber: _eidController.text,
          visitorName: _visitorNameController.text,
          phoneNumber: _phoneController.text,
          nationality: widget.nationality,
          companyName: _companyController.text, // Added company name
          firstVisit: existingProfile.firstVisit, // Keep original first visit
          lastVisit: DateTime.now(),
          visitCount: existingProfile.visitCount + 1, // Increment visit count
        );
      } else {
        // Create new profile
        visitorProfile = VisitorProfile(
          eidNumber: _eidController.text,
          visitorName: _visitorNameController.text,
          phoneNumber: _phoneController.text,
          nationality: widget.nationality,
          companyName: _companyController.text, // Added company name
          firstVisit: DateTime.now(),
          lastVisit: DateTime.now(),
        );
      }

      await LocalStorageService.saveVisitorProfile(visitorProfile);

      // Create visitor entry
      final visitorEntry = VisitorEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eidNumber: _eidController.text,
        visitorName: _visitorNameController.text,
        phoneNumber: _phoneController.text,
        purpose: _purposeController.text,
        companyName: _companyController.text,
        entryTime: DateTime.now(),
        guardId: 'GRD001', // This should be the actual guard ID
        status:
            'pending_resident', // Will be updated based on resident approval
      );

      // In a real app, this would be saved to a backend
      // For now, we'll navigate to permission screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.visitorPermission,
          arguments: {
            'visitorName': _visitorNameController.text,
            'visitorPhone': _phoneController.text,
            'visitorPurpose': _purposeController.text,
            'visitorCompany': _companyController.text,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting entry: ${e.toString()}'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Entry'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6E5F7), Color(0xFFE6E5F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildVisitorInfoCard(),
                        const SizedBox(height: 16),
                        _buildInputFields(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visitor Entry Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please fill in the visitor information',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visitor Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // EID Number (read-only if scanned)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge, size: 20, color: Color(0xFF8063FC)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _eidController,
                    enabled: widget.eidNumber == null,
                    decoration: const InputDecoration(
                      labelText: 'EID Number',
                      border: InputBorder.none,
                      hintText: 'Enter EID number',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Visitor Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 20, color: Color(0xFF8063FC)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _visitorNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: InputBorder.none,
                      hintText: 'Enter visitor name',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Phone Number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, size: 20, color: Color(0xFF8063FC)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: InputBorder.none,
                      hintText: 'Enter phone number',
                      suffixIcon: _existingVisitorPhone != null
                          ? Tooltip(
                              message:
                                  'Previously used phone: $_existingVisitorPhone',
                              child: Icon(
                                Icons.info,
                                size: 20,
                                color: Colors.blue[600],
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visit Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Purpose of Visit
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, size: 20, color: Color(0xFF8063FC)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _purposeController,
                    decoration: const InputDecoration(
                      labelText: 'Purpose of Visit',
                      border: InputBorder.none,
                      hintText: 'Delivery, Cab, Guest, etc.',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Company Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.business, size: 20, color: Color(0xFF8063FC)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: 'Company Name',
                      border: InputBorder.none,
                      hintText: 'Amazon, Uber, etc.',
                      suffixIcon: _existingVisitorCompany != null
                          ? Tooltip(
                              message:
                                  'Previously used company: $_existingVisitorCompany',
                              child: Icon(
                                Icons.info,
                                size: 20,
                                color: Colors.blue[600],
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8063FC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Submitting...'),
                    ],
                  )
                : const Text(
                    'Submit Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : _saveAsDraft,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8063FC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _isDraft ? 'Update Draft' : 'Save as Draft',
              style: const TextStyle(fontSize: 16, color: Color(0xFF8063FC)),
            ),
          ),
        ),
      ],
    );
  }
}
