import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'views/splash/splash_screen.dart';
import 'views/auth/role_selection_screen.dart';
import 'views/onboarding/patient_onboarding_screen.dart';
import 'views/onboarding/doctor_registration_screen.dart';
import 'views/doctor/doctor_pending_screen.dart';
import 'views/patient/patient_dashboard_screen.dart';
import 'views/doctor/doctor_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EMedicalApp());
}

class EMedicalApp extends StatelessWidget {
  const EMedicalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Medical',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primary),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.roleSelect: (context) => const RoleSelectionScreen(),
        AppRoutes.patientOnboarding: (context) => const PatientOnboardingScreen(),
        AppRoutes.doctorRegistration: (context) => const DoctorRegistrationScreen(),
        AppRoutes.doctorPending: (context) => const DoctorPendingScreen(),
        AppRoutes.patientDashboard: (context) => const PatientDashboardScreen(),
        AppRoutes.doctorDashboard: (context) => const DoctorDashboardScreen(),
      },
    );
  }
}
