import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final _tokenController = TextEditingController();
  final _medicineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _timingController = TextEditingController();

  bool _patientRecordUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.medicalBlue.withOpacity(0.12),
              child: const Icon(Icons.medical_services_rounded, color: AppColors.medicalBlue),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Dr. Rajesh Shah (MBBS, MD)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text("Gujarat Medical Council Verified ✅", style: TextStyle(fontSize: 11, color: AppColors.successGreen)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.alertRed),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.roleSelect),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consent Token Entry Card
            _buildTokenEntryCard(),

            const SizedBox(height: 20),

            // If token entered, show decrypted records
            if (_patientRecordUnlocked) _buildPatientDecryptedRecords(),

            const SizedBox(height: 20),

            // Today's Patient Queue
            const Text("Today's Patient Queue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _buildQueueItem("Nazifa Patel", "24 Yrs • Routine Checkup", "10:30 AM", isCheckedIn: true),
            const SizedBox(height: 10),
            _buildQueueItem("Suresh Mehta", "68 Yrs • BP & Sugar Follow-up", "11:15 AM", isCheckedIn: false),

            const SizedBox(height: 24),

            // Digital E-Prescription Writer
            _buildPrescriptionWriter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenEntryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: AppColors.medicalBlue.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, color: AppColors.medicalBlue, size: 22),
              SizedBox(width: 8),
              Text("Patient Record Access (Consent Grant)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.medicalBlue)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter the 6-digit access code displayed on the patient's phone to view their past vitals and lab reports with zero-knowledge consent.",
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tokenController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter 6-digit code (e.g. 642891)",
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderLight)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_tokenController.text.trim().isNotEmpty) {
                    setState(() => _patientRecordUnlocked = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Consent Verified! Patient Record Decrypted for 15 minutes."), backgroundColor: AppColors.successGreen),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicalBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Unlock Record", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDecryptedRecords() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accentMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Decrypted Medical History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
              Text("Active Grant • 14m remaining ⏳", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("• Known Allergies: Penicillin (Severe Hives)", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.alertRed)),
          const SizedBox(height: 4),
          const Text("• Latest Vitals: BP 118/78 mmHg | Pulse 72 bpm | SpO2 98%", style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text("• Recent Lab Report: Lipid Profile (20-Oct-2026) -> Normal", style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildQueueItem(String name, String details, String time, {required bool isCheckedIn}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(details, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(isCheckedIn ? "Checked In" : "Waiting", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: isCheckedIn ? AppColors.successGreen : AppColors.textMuted)),
          ]),
        ],
      ),
    );
  }

  Widget _buildPrescriptionWriter() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Digital E-Prescription Writer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          const Text("Prescribed medicines directly sync into the patient's Medicine Tracker upon acceptance.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextField(controller: _medicineNameController, decoration: const InputDecoration(labelText: "Medicine Name (e.g. Paracetamol 500mg)", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: _dosageController, decoration: const InputDecoration(labelText: "Dosage (1 Tablet)", border: OutlineInputBorder()))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _timingController, decoration: const InputDecoration(labelText: "Timing (After Lunch)", border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("E-Prescription Issued & Synced to Patient Device!"), backgroundColor: AppColors.primary),
                );
                _medicineNameController.clear();
                _dosageController.clear();
                _timingController.clear();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("Issue & Sync E-Prescription", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
