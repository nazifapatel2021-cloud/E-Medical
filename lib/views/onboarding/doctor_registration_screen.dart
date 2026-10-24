import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<DoctorRegistrationScreen> createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _councilNoController = TextEditingController();
  final _clinicController = TextEditingController();
  final _feeController = TextEditingController();

  String _selectedDegree = 'MBBS';
  String _selectedSpecialty = 'General Physician';
  String _selectedCouncil = 'Gujarat Medical Council';
  bool _certificateUploaded = false;

  final List<String> _degrees = ['MBBS', 'MBBS, MD', 'MBBS, MS', 'BAMS (Ayurvedic)', 'BHMS (Homeopathy)', 'BDS (Dental)'];
  final List<String> _specialties = [
    'General Physician', 'Cardiologist', 'Pediatrician', 'Dentist',
    'Gynecologist', 'Dermatologist', 'Orthopedic', 'Psychiatrist'
  ];
  final List<String> _councils = [
    'Gujarat Medical Council', 'Maharashtra Medical Council', 'Delhi Medical Council',
    'National Medical Commission (NMC)', 'Ayurvedic Medical Council'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Doctor Credential Registration", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Professional Verification",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            const Text(
              "To protect patient safety and app credibility, your Medical Degree Certificate and Council Registration Number will be verified before consultation features unlock.",
              style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            _buildField("Dr. Full Name", _nameController, Icons.person_outline),
            _buildField("Official Email", _emailController, Icons.email_outlined),
            _buildField("Password", _passwordController, Icons.lock_outline, obscureText: true),

            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDegree,
              decoration: const InputDecoration(labelText: "Medical Degree", border: OutlineInputBorder()),
              items: _degrees.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _selectedDegree = val!),
            ),

            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedSpecialty,
              decoration: const InputDecoration(labelText: "Clinical Specialty", border: OutlineInputBorder()),
              items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSpecialty = val!),
            ),

            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedCouncil,
              decoration: const InputDecoration(labelText: "Registering Medical Council", border: OutlineInputBorder()),
              items: _councils.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCouncil = val!),
            ),

            const SizedBox(height: 14),
            _buildField("State Council Registration No. (e.g. G-54812)", _councilNoController, Icons.badge_outlined),

            const SizedBox(height: 18),
            // Degree Certificate Upload Section
            const Text("Upload Medical Degree Certificate *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                setState(() => _certificateUploaded = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Degree Certificate Attached (mbbs_degree.pdf)"), backgroundColor: AppColors.primary),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: _certificateUploaded ? AppColors.accentMint : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _certificateUploaded ? AppColors.primary : AppColors.borderLight,
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _certificateUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                      size: 40,
                      color: _certificateUploaded ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _certificateUploaded ? "Certificate Attached: mbbs_degree.pdf" : "Tap to browse or photograph Certificate (PDF / JPG)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _certificateUploaded ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            _buildField("Clinic / Hospital Name", _clinicController, Icons.local_hospital_outlined),
            _buildField("Consultation Fee (₹)", _feeController, Icons.currency_rupee, keyboardType: TextInputType.number),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitDoctorRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Submit Credentials for Verification", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderLight)),
        ),
      ),
    );
  }

  void _submitDoctorRegistration() {
    if (_councilNoController.text.trim().isEmpty || !_certificateUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Council Registration Number and attach Certificate!"), backgroundColor: AppColors.alertRed),
      );
      return;
    }

    // Direct transition to Pending Verification Gate
    Navigator.pushReplacementNamed(context, AppRoutes.doctorPending);
  }
}
