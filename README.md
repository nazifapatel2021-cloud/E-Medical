# E-Medical — Your Personal Health Companion

> A comprehensive, role-based digital health and wellness mobile application developed with **Flutter** and **Supabase (PostgreSQL)**.

---

## 🌟 Key Features

### 👤 Patient Module (Multilingual: English, Hindi, Gujarati)
* **Animated Brand Experience:** Heartbeat pulse animation and custom tagline reveal on startup.
* **366-Day Health Tip Modal:** Daily evidence-based medical wisdom from global health authorities (WHO, ICMR), auto-indexed by `((dayOfYear - 1) % 366) + 1`.
* **Clinical Health & Wellness Score (0–100):** Age, Height, and Weight (BMI)-factored score calculating cardiovascular vitals, sleep, activity, and medication adherence.
* **Smart Lab Report Manager & AI OCR Analyzer:** Upload lab reports (PDF/JPG) for automated 4-quadrant breakdown (*Plain-English Summary*, *What's Great ✅*, *What Requires Caution ⚠️*, and *Action Plan 🥗*).
* **Plain-Language Allergy Cards:** Medication, food, and environmental allergy cards with simple symptom descriptions.
* **Zero-Knowledge Record Sharing:** Generate secure 15-minute consent codes (`642-891`) for doctors to view records in-clinic.
* **Active Medicine Alarms:** Offline-capable timed reminder alerts with one-tap dose logging.

### 🩺 Doctor Module (English Only)
* **Official Credential Registration:** Requires Medical Degree Certificate upload + State Medical Council Registration Number (e.g. Gujarat Medical Council / NMC).
* **Admin Verification Gate:** Doctor accounts remain in pending status until credentials are verified against the public registry.
* **Clinical Consultation Queue:** View daily patient appointments and check-in statuses.
* **Decrypted Record Viewer:** Enter patient consent code to temporarily inspect medical history.
* **Digital E-Prescription Writer:** Issues electronic prescriptions that sync directly into the patient's Medicine Tracker.

---

## 🏗️ Architecture & Tech Stack

* **Frontend:** Flutter (Dart) — Cross-platform Android & iOS.
* **Backend:** Supabase (PostgreSQL with Row-Level Security).
* **Storage:** Supabase Storage (Private buckets with signed URLs for reports and certificates).
* **AI Analysis:** Google Gemini Flash API via server-side Supabase Edge Functions.
* **Local Caching:** `shared_preferences` / Drift.
* **Notifications:** `flutter_local_notifications` for offline alarms.

---

## 📁 Project Structure

```
├── assets/
│   ├── data/
│   │   └── health_tips_366.json       # 366 Daily evidence-based tips
│   └── translations/
│       ├── en.json                    # English strings & allergy cards
│       ├── hi.json                    # Hindi strings (हिंदी)
│       └── gu.json                    # Gujarati strings (ગુજરાતી)
├── lib/
│   ├── core/
│   │   ├── constants/                 # AppColors, AppRoutes
│   │   └── services/                  # HealthScoreCalculator
│   ├── views/
│   │   ├── splash/                    # Animated splash screen
│   │   ├── widgets/                   # DailyTipDialog
│   │   ├── auth/                      # RoleSelectionScreen
│   │   ├── onboarding/                # PatientOnboarding, DoctorRegistration
│   │   ├── patient/                   # PatientDashboardScreen
│   │   └── doctor/                    # DoctorDashboardScreen, DoctorPendingScreen
│   └── main.dart                      # App entry point
├── supabase/
│   └── migrations/
│       └── 01_initial_schema.sql      # 16 Relational tables & RLS policies
└── pubspec.yaml                       # Dependencies and asset configuration
```

---

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nazifapatel2021-cloud/E-Medical.git
   cd E-Medical
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the mobile application:**
   ```bash
   flutter run
   ```

---

## 📜 Medical & Legal Disclaimer

*The Health/Wellness Score and AI Lab Report summaries provided by this application are for general wellness and educational purposes only. They do not constitute formal medical diagnosis, treatment, or clinical consultation. Always consult a licensed medical practitioner for personalized healthcare decisions.*
