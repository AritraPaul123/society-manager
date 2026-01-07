import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocietyConfigurationScreen extends StatefulWidget {
  const SocietyConfigurationScreen({super.key});

  @override
  State<SocietyConfigurationScreen> createState() =>
      _SocietyConfigurationScreenState();
}

class _SocietyConfigurationScreenState extends State<SocietyConfigurationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _requireApproval = true;
  bool _allowUnregisteredDelivery = true;
  bool _requirePhotoId = true;
  bool _nightRestriction = true;
  final TextEditingController _maxDurationController = TextEditingController(
    text: '240',
  );
  final TextEditingController _nightStartController = TextEditingController(
    text: '22:00',
  );
  final TextEditingController _nightEndController = TextEditingController(
    text: '06:00',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Society Configuration',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(color: const Color(0xFFE5E7EB), height: 1),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF8063FC),
                indicatorWeight: 3,
                labelColor: const Color(0xFF8063FC),
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.door_sliding_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Gates'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.apartment_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Buildings'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.rule_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Visitor Rules'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGatesTab(),
          _buildBuildingsTab(),
          _buildVisitorRulesTab(),
        ],
      ),
    );
  }

  Widget _buildVisitorRulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggleRow(
                  'Require Resident Approval',
                  'Visitors must be approved by residents',
                  _requireApproval,
                  (v) => setState(() => _requireApproval = v),
                ),
                const SizedBox(height: 24),
                Text(
                  'Maximum Visit Duration (minutes)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 8),
                _buildRuleTextField(_maxDurationController),
                const SizedBox(height: 24),
                _buildToggleRow(
                  'Allow Unregistered Delivery',
                  'Delivery personnel can enter without pre-registration',
                  _allowUnregisteredDelivery,
                  (v) => setState(() => _allowUnregisteredDelivery = v),
                ),
                const SizedBox(height: 24),
                _buildToggleRow(
                  'Require Photo ID',
                  'Capture visitor ID photo at gate',
                  _requirePhotoId,
                  (v) => setState(() => _requirePhotoId = v),
                ),
                const SizedBox(height: 24),
                _buildToggleRow(
                  'Night Visitor Restriction',
                  'Restrict visitor access during night hours',
                  _nightRestriction,
                  (v) => setState(() => _nightRestriction = v),
                ),
                if (_nightRestriction) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Night Start Time',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRuleTextField(_nightStartController),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Night End Time',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRuleTextField(_nightEndController),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Visitor rules updated successfully!'),
                      ),
                    );
                    Future.delayed(
                      const Duration(seconds: 1),
                      () => Navigator.pop(context),
                    );
                  },
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Rules'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8063FC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF111827),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF8063FC),
        ),
      ],
    );
  }

  Widget _buildRuleTextField(TextEditingController controller) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBuildingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Building addition form opened...'),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Building'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8063FC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 2.8,
            children: [
              _buildBuildingCard(name: 'Building A', units: 50, floors: 10),
              _buildBuildingCard(name: 'Building B', units: 45, floors: 9),
              _buildBuildingCard(name: 'Building C', units: 60, floors: 12),
              _buildBuildingCard(name: 'Building D', units: 40, floors: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingCard({
    required String name,
    required int units,
    required int floors,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8063FC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.apartment,
              color: Color(0xFF8063FC),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Units: $units',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Floors: $floors',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF8063FC).withOpacity(0.2),
              ),
            ),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editing $name details...')),
                );
              },
              child: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF8063FC),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Add Gate form...')),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Gate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8063FC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildGateCard(
            name: 'Main Gate A',
            location: 'North Entrance',
            status: 'active',
            access: '24/7',
          ),
          const SizedBox(height: 24),
          _buildGateCard(
            name: 'Service Gate B',
            location: 'South Entrance',
            status: 'active',
            access: '6 AM - 10 PM',
          ),
          const SizedBox(height: 24),
          _buildGateCard(
            name: 'Emergency Exit C',
            location: 'East Side',
            status: 'emergency-only',
            access: 'Emergency Only',
          ),
        ],
      ),
    );
  }

  Widget _buildGateCard({
    required String name,
    required String location,
    required String status,
    required String access,
  }) {
    Color statusColor = status == 'active'
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location: $location',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                status,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Access:',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            access,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF8063FC).withOpacity(0.2),
              ),
            ),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editing $name configuration...')),
                );
              },
              child: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF8063FC),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
