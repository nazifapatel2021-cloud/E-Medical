import 'dart:math';

class HealthScoreResult {
  final int totalScore;          // 0 to 100
  final int earnedPoints;
  final int availablePoints;
  final String statusLabel;       // Optimal, Good, Fair, Attention
  final Map<String, int> breakdown;
  final List<String> recommendations;

  HealthScoreResult({
    required this.totalScore,
    required this.earnedPoints,
    required this.availablePoints,
    required this.statusLabel,
    required this.breakdown,
    required this.recommendations,
  });
}

class HealthScoreCalculator {
  /// Calculates the clinical Wellness Score (0 to 100)
  /// Incorporates Age, Height, Weight, Blood Pressure, Heart Rate, SpO2, Steps, Sleep, and Medicine Adherence.
  static HealthScoreResult calculate({
    required int age,
    required double heightCm,
    required double weightKg,
    int? systolicBp,
    int? diastolicBp,
    int? pulseRate,
    int? oxygenSpo2,
    int? dailySteps,
    double? sleepHours,
    int? scheduledDoses,
    int? dosesTaken,
    int? waterIntakeMl,
  }) {
    int earned = 0;
    int available = 0;
    final Map<String, int> breakdown = {};
    final List<String> recs = [];

    // -------------------------------------------------------------
    // PILLAR 1: BODY COMPOSITION (25 Points) - Height, Weight & Age
    // -------------------------------------------------------------
    available += 25;
    final double heightM = heightCm / 100.0;
    final double bmi = weightKg / (heightM * heightM);
    int bodyScore = 0;

    if (age < 60) {
      if (bmi >= 18.5 && bmi <= 22.9) {
        bodyScore = 25;
      } else if (bmi >= 23.0 && bmi <= 24.9) {
        bodyScore = 18;
        recs.add("Your BMI ($bmi) is slightly elevated for your height. A 30-minute daily walk can help.");
      } else if (bmi >= 25.0 && bmi <= 29.9) {
        bodyScore = 12;
        recs.add("Your BMI indicates Class I Obesity. Consult a dietitian to balance nutrition.");
      } else {
        bodyScore = 8;
        recs.add("BMI is outside healthy limits ($bmi). Please seek personalized medical advice.");
      }
    } else {
      // Senior adjustment (Age 60+ benefits from slightly higher bone density cushion)
      if (bmi >= 21.0 && bmi <= 25.9) {
        bodyScore = 25;
      } else if ((bmi >= 26.0 && bmi <= 28.9) || (bmi >= 20.0 && bmi < 21.0)) {
        bodyScore = 18;
      } else {
        bodyScore = 10;
        recs.add("For seniors, maintaining muscle mass and steady weight is vital for bone strength.");
      }
    }
    earned += bodyScore;
    breakdown['body_composition'] = bodyScore;

    // -------------------------------------------------------------
    // PILLAR 2: DAILY VITALS (35 Points) - Blood Pressure, Pulse, Oxygen
    // -------------------------------------------------------------
    if (systolicBp != null && diastolicBp != null) {
      available += 15;
      int bpScore = 0;
      if (age < 60) {
        if (systolicBp <= 120 && diastolicBp <= 80) {
          bpScore = 15;
        } else if (systolicBp <= 130 || diastolicBp <= 85) {
          bpScore = 10;
        } else if (systolicBp <= 140 || diastolicBp <= 90) {
          bpScore = 5;
          recs.add("Blood pressure is elevated ($systolicBp/$diastolicBp). Limit sodium intake.");
        } else {
          bpScore = 0;
          recs.add("Urgent: High Blood Pressure detected ($systolicBp/$diastolicBp). Contact your doctor.");
        }
      } else {
        // Senior Blood Pressure allowances
        if (systolicBp <= 135 && diastolicBp <= 85) {
          bpScore = 15;
        } else if (systolicBp <= 145 || diastolicBp <= 90) {
          bpScore = 10;
        } else if (systolicBp <= 155 || diastolicBp <= 95) {
          bpScore = 5;
        } else {
          bpScore = 0;
        }
      }
      earned += bpScore;
      breakdown['blood_pressure'] = bpScore;
    }

    // Pulse Rate (10 Points)
    if (pulseRate != null) {
      available += 10;
      int pulseScore = 0;
      if (pulseRate >= 60 && pulseRate <= 80) {
        pulseScore = 10;
      } else if ((pulseRate >= 81 && pulseRate <= 90) || (pulseRate >= 50 && pulseRate <= 59)) {
        pulseScore = 7;
      } else if (pulseRate >= 91 && pulseRate <= 100) {
        pulseScore = 4;
      } else {
        pulseScore = 2;
        recs.add("Resting pulse is irregular ($pulseRate bpm). Consider resting and rechecking.");
      }
      earned += pulseScore;
      breakdown['pulse_rate'] = pulseScore;
    }

    // SpO2 Blood Oxygen (10 Points)
    if (oxygenSpo2 != null) {
      available += 10;
      int o2Score = 0;
      if (oxygenSpo2 >= 96) {
        o2Score = 10;
      } else if (oxygenSpo2 >= 94) {
        o2Score = 5;
      } else {
        o2Score = 0;
        recs.add("EMERGENCY: SpO2 is below 94%. Sit upright, recheck, and seek medical help.");
      }
      earned += o2Score;
      breakdown['oxygen_spo2'] = o2Score;
    }

    // -------------------------------------------------------------
    // PILLAR 3: ACTIVITY & SLEEP (20 Points)
    // -------------------------------------------------------------
    if (dailySteps != null) {
      available += 10;
      int stepScore = 0;
      if (age < 50) {
        if (dailySteps >= 8000) stepScore = 10;
        else if (dailySteps >= 5000) stepScore = 7;
        else stepScore = 3;
      } else {
        if (dailySteps >= 5000) stepScore = 10;
        else if (dailySteps >= 3000) stepScore = 7;
        else stepScore = 3;
      }
      earned += stepScore;
      breakdown['steps'] = stepScore;
    }

    if (sleepHours != null) {
      available += 10;
      int sleepScore = 0;
      if (sleepHours >= 7.0 && sleepHours <= 9.0) {
        sleepScore = 10;
      } else if ((sleepHours >= 6.0 && sleepHours < 7.0) || (sleepHours > 9.0 && sleepHours <= 10.0)) {
        sleepScore = 7;
      } else {
        sleepScore = 4;
        recs.add("Aim for 7 to 9 hours of uninterrupted sleep to enhance cellular recovery.");
      }
      earned += sleepScore;
      breakdown['sleep'] = sleepScore;
    }

    // -------------------------------------------------------------
    // PILLAR 4: MEDICATION ADHERENCE & HYDRATION (20 Points)
    // -------------------------------------------------------------
    // FAIRNESS RULE: If user has active medicines, score adherence. If none, leave out and rescale!
    if (scheduledDoses != null && scheduledDoses > 0) {
      available += 15;
      final int taken = dosesTaken ?? 0;
      final double compliance = (taken / scheduledDoses) * 100.0;
      int medScore = 0;
      if (compliance >= 100.0) medScore = 15;
      else if (compliance >= 75.0) medScore = 10;
      else if (compliance >= 50.0) medScore = 5;
      else medScore = 0;

      earned += medScore;
      breakdown['medication_adherence'] = medScore;
    }

    if (waterIntakeMl != null) {
      available += 5;
      final int waterScore = waterIntakeMl >= 2000 ? 5 : 0;
      earned += waterScore;
      breakdown['hydration'] = waterScore;
    }

    // Normalized Score calculation (Rescaled to 100)
    final int finalScore = available > 0 ? ((earned / available) * 100).round() : 0;

    String label;
    if (finalScore >= 90) {
      label = "Optimal";
    } else if (finalScore >= 75) {
      label = "Good";
    } else if (finalScore >= 60) {
      label = "Fair";
    } else {
      label = "Worth Discussing with Doctor";
    }

    return HealthScoreResult(
      totalScore: min(100, max(0, finalScore)),
      earnedPoints: earned,
      availablePoints: available,
      statusLabel: label,
      breakdown: breakdown,
      recommendations: recs,
    );
  }
}
