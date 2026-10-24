import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/health_score_calculator.dart';

class PatientOnboardingScreen extends StatefulWidget {
  const PatientOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<PatientOnboardingScreen> createState() => _PatientOnboardingScreenState();
}

class _PatientOnboardingScreenState extends State<PatientOnboardingScreen> {
  int _currentStep = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _contactController = TextEditingController();

  DateTime? _selectedDob;
  String _selectedGender = 'female';
  String _selectedBloodGroup = 'B+';

  // Plain-Language Allergies State
  final Map<String, bool> _allergies = {
    "no_allergies": true,
    "penicillin": false,
    "painkillers": false,
    "sulfa": false,
    "nuts": false,
    "dairy": false,
    "gluten": false,
    "seafood": false,
    "dust": false,
    "latex": false,
  };

  // Chronic Conditions
  final Map<String, bool> _conditions = {
    "diabetes": false,
    "hypertension": false,
    "asthma": false,
    "thyroid": false,
    "heart_disease": false,
  };

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Patient Profile Setup", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        elevation: 0,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submitPatientProfile();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          Step(
            title: const Text("Vitals"),
            isActive: _currentStep >= 0,
            content: _buildVitalsStep(),
          ),
          Step(
            title: const Text("Allergies"),
            isActive: _currentStep >= 1,
            content: _buildAllergiesStep(),
          ),
          Step(
            title: const Text("Conditions"),
            isActive: _currentStep >= 2,
            content: _buildConditionsStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField("Full Name", _nameController, Icons.person_outline),
        _buildTextField("Email Address", _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        _buildTextField("Password", _passwordController, Icons.lock_outline, obscureText: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField("Height (cm)", _heightController, Icons.height, keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField("Weight (kg)", _weightController, Icons.monitor_weight_outlined, keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: "Blood Group", border: OutlineInputBorder()),
                items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                onChanged: (val) => setState(() => _selectedBloodGroup = val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'female', child: Text("Female")),
                  DropdownMenuItem(value: 'male', child: Text("Male")),
                  DropdownMenuItem(value: 'other', child: Text("Other")),
                ],
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllergiesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Do you have any known allergies?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          "These cards use everyday plain language so you and your doctor avoid dangerous drug or food interactions.",
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        _allergyCheckbox("No Known Allergies", "I have never had any severe allergy reaction.", "no_allergies"),
        const Divider(),
        _allergyCheckbox("Penicillin & Common Antibiotics", "Causes itching, hives, facial swelling, or breathing distress.", "penicillin"),
        _allergyCheckbox("Painkillers (Aspirin, Ibuprofen, Brufen)", "Can cause asthma attacks, severe stomach ache, or rashes.", "painkillers"),
        _allergyCheckbox("Sulfa Drugs", "Antibiotics found in some urinary tract infection medicines.", "sulfa"),
        _allergyCheckbox("Peanuts & Tree Nuts", "Causes immediate swelling of lips/throat, vomiting, or hives.", "nuts"),
        _allergyCheckbox("Milk & Dairy Protein", "Causes severe stomach cramps, bloating, nausea, or eczema.", "dairy"),
        _allergyCheckbox("Wheat & Gluten", "Causes chronic digestive distress, bloating, or skin rash.", "gluten"),
        _allergyCheckbox("Seafood & Shellfish (Fish, Prawns)", "Can cause swelling of throat, nausea, or dizziness.", "seafood"),
        _allergyCheckbox("Dust & Plant Pollen", "Causes seasonal sneezing, runny nose, and red itchy eyes.", "dust"),
        _allergyCheckbox("Latex & Rubber Gloves", "Causes skin redness, blisters, or itching from surgical tape.", "latex"),
      ],
    );
  }

  Widget _allergyCheckbox(String title, String description, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _allergies[key] == true ? AppColors.accentMint : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _allergies[key] == true ? AppColors.primary : AppColors.borderLight),
      ),
      child: CheckboxListTile(
        activeColor: AppColors.primary,
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
        subtitle: Text(description, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        value: _allergies[key] ?? false,
        onChanged: (val) {
          setState(() {
            if (key == "no_allergies" && val == true) {
              _allergies.updateAll((k, v) => false);
              _allergies["no_allergies"] = true;
            } else {
              _allergies["no_allergies"] = false;
              _allergies[key] = val ?? false;
            }
          });
        },
      ),
    );
  }

  Widget _buildConditionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pre-Existing Medical Conditions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._conditions.keys.map((key) {
          return CheckboxListTile(
            activeColor: AppColors.primary,
            title: Text(key.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            value: _conditions[key],
            onChanged: (val) => setState(() => _conditions[key] = val ?? false),
          );
        }).toList(),
        const SizedBox(height: 16),
        _buildTextField("Emergency Contact Phone", _contactController, Icons.phone_outlined, keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscureText = false, TextInputType? keyboardType}) {
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

  void _submitPatientProfile() {
    final double height = double.tryParse(_heightController.text) ?? 170.0;
    final double weight = double.tryParse(_weightController.text) ?? 65.0;

    // Direct calculation of initial Health Score
    final result = HealthScoreCalculator.calculate(
      age: 24,
      heightCm: height,
      weightKg: weight,
      systolicBp: 120,
      diastolicBp: 80,
      pulseRate: 72,
      oxygenSpo2: 98,
      dailySteps: 8500,
      sleepHours: 7.5,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile Created! Initial Health Score: ${result.totalScore} (${result.statusLabel})"),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pushReplacementNamed(context, AppRoutes.patientDashboard);
  }
}
