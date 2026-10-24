import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class DoctorPendingScreen extends StatelessWidget {
  const DoctorPendingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.warningAmber,
                  size: 64,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Credential Verification in Progress",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              const Text(
                "Thank you for submitting your Degree Certificate and Medical Council Registration details. To ensure credibility, our administration verifies every physician with the state register before granting clinical access.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: const [
                    _StatusItem(label: "Council Registration No", status: "Submitted (G-54812)"),
                    Divider(height: 16),
                    _StatusItem(label: "Degree Certificate", status: "Attached for Review"),
                    Divider(height: 16),
                    _StatusItem(label: "Verification Status", status: "Pending Admin Approval ⏳", isPending: true),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // Simulation button for Testing / Academic Defense
              ElevatedButton.icon(
                onPressed: () {
                  // Simulate Admin Approval
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Admin Approved Your Credentials! Welcome to Doctor Portal."), backgroundColor: AppColors.successGreen),
                  );
                  Navigator.pushReplacementNamed(context, AppRoutes.doctorDashboard);
                },
                icon: const Icon(Icons.verified_user_rounded),
                label: const Text("Simulate Admin Approval (Demo)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.splash),
                child: const Text("Sign Out / Return to Home", style: TextStyle(color: AppColors.textSecondary)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String status;
  final bool isPending;

  const _StatusItem({required this.label, required this.status, this.isPending = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        Text(
          status,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isPending ? AppColors.warningAmber : AppColors.primary,
          ),
        ),
      ],
    );
  }
}
