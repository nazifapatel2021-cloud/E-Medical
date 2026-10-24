import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _healthScore = 96;
  String _scoreLabel = "Optimal";

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
              backgroundColor: AppColors.accentMint,
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Hello, Nazifa!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text("E-Medical — Your Personal Health Companion", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
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
            // Dynamic Health Score Card
            _buildHealthScoreCard(),

            const SizedBox(height: 20),

            // Share Consent Token with Doctor Button
            _buildShareConsentBanner(),

            const SizedBox(height: 20),

            const Text("Today's Vitals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),

            // Vitals Grid
            Row(
              children: const [
                Expanded(child: _VitalCard(icon: Icons.favorite_outline, title: "Blood Pressure", value: "118/78", unit: "mmHg", status: "Optimal", color: AppColors.successGreen)),
                SizedBox(width: 12),
                Expanded(child: _VitalCard(icon: Icons.monitor_heart_outlined, title: "Resting Pulse", value: "72", unit: "bpm", status: "Normal", color: AppColors.medicalBlue)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: _VitalCard(icon: Icons.air_outlined, title: "Blood Oxygen", value: "98", unit: "% SpO2", status: "Healthy", color: AppColors.successGreen)),
                SizedBox(width: 12),
                Expanded(child: _VitalCard(icon: Icons.directions_walk_rounded, title: "Daily Steps", value: "8,500", unit: "steps", status: "Goal Met", color: AppColors.warningAmber)),
              ],
            ),

            const SizedBox(height: 24),

            // Active Medicines Card
            _buildActiveMedicinesSection(),

            const SizedBox(height: 24),

            // Quick Actions (Lab Report Upload & Smart Doctor Locator)
            const Text("Quick Healthcare Tools", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.document_scanner_outlined,
                    title: "Scan Lab Report",
                    subtitle: "4-Quadrant AI Breakdown",
                    color: AppColors.primary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("AI OCR Document Scanner Launched"), backgroundColor: AppColors.primary),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.medical_information_outlined,
                    title: "Doctor Locator",
                    subtitle: "Real Clinics & Verified Fees",
                    color: AppColors.medicalBlue,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D5F3F), Color(0xFF1E4029)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Wellness Indicator", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text("$_healthScore / 100", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Status: $_scoreLabel", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      value: _healthScore / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA8D5BA)),
                    ),
                  ),
                  const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 6),
          const Text(
            "General wellness estimate for information only. Not a medical diagnosis. Factored for age 24, height 170cm, and weight 65kg.",
            style: TextStyle(color: Colors.white60, fontSize: 10.5, height: 1.35),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShareConsentBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentMint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Consulting a Doctor?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                SizedBox(height: 2),
                Text("Generate a secure 15-minute token to share past vitals and lab reports.", style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showConsentTokenModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Share Code", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showConsentTokenModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Doctor Access Code", textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Show this one-time code to your doctor in the clinic:", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(color: AppColors.accentMint, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary)),
              child: const Text("642-891", style: TextStyle(fontSize: 28, letterSpacing: 4, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            const SizedBox(height: 12),
            const Text("Valid for 15 minutes • You can revoke anytime", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Revoked Immediately!"), backgroundColor: AppColors.alertRed));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed, foregroundColor: Colors.white),
            child: const Text("Revoke Access"),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveMedicinesSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Active Medicine Alarms", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              Text("2 Active", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          _MedicineRow(name: "Metformin 500mg", schedule: "After Lunch • 02:00 PM", status: "Upcoming Alarm ⏰"),
          const Divider(height: 16),
          _MedicineRow(name: "Vitamin D3 Capsule", schedule: "After Breakfast • 09:00 AM", status: "Taken Today ✅", isTaken: true),
        ],
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final String status;
  final Color color;

  const _VitalCard({required this.icon, required this.title, required this.value, required this.unit, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color))),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          RichText(text: TextSpan(text: value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary), children: [TextSpan(text: " $unit", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: AppColors.textMuted))])),
        ],
      ),
    );
  }
}

class _MedicineRow extends StatelessWidget {
  final String name;
  final String schedule;
  final String status;
  final bool isTaken;

  const _MedicineRow({required this.name, required this.schedule, required this.status, this.isTaken = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(schedule, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        ]),
        Text(status, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: isTaken ? AppColors.successGreen : AppColors.warningAmber)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
