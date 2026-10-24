-- ==============================================================================
-- E-Medical Mobile Application: Master Supabase PostgreSQL Schema
-- Version: 1.0 (Production Core)
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. ENUMS
CREATE TYPE user_role AS ENUM ('patient', 'doctor', 'admin');
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE dose_status AS ENUM ('taken', 'missed', 'skipped');
CREATE TYPE appointment_status AS ENUM ('requested', 'confirmed', 'completed', 'cancelled');

-- 3. PROFILES TABLE (Tied to Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    role user_role NOT NULL DEFAULT 'patient',
    full_name TEXT NOT NULL,
    language TEXT NOT NULL DEFAULT 'en' CHECK (language IN ('en', 'hi', 'gu')),
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 4. PATIENTS TABLE
CREATE TABLE IF NOT EXISTS public.patients (
    profile_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    dob DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    height_cm NUMERIC(5, 2) CHECK (height_cm > 0),
    weight_kg NUMERIC(5, 2) CHECK (weight_kg > 0),
    blood_group TEXT CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    allergies JSONB DEFAULT '[]'::jsonb, -- Array of allergy objects with plain descriptions
    pre_existing_conditions JSONB DEFAULT '[]'::jsonb,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 5. DOCTORS TABLE
CREATE TABLE IF NOT EXISTS public.doctors (
    profile_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    specialty TEXT NOT NULL,
    council_registration_no TEXT NOT NULL UNIQUE,
    state_medical_council TEXT NOT NULL,
    degree_title TEXT NOT NULL, -- e.g. MBBS, MD, BAMS, BHMS
    degree_certificate_url TEXT, -- Private bucket storage path
    clinic_hospital_name TEXT,
    clinic_address TEXT,
    city TEXT NOT NULL DEFAULT 'Bharuch',
    consultation_fee NUMERIC(8, 2) DEFAULT 0.00,
    experience_years INT DEFAULT 0,
    verification_status verification_status NOT NULL DEFAULT 'pending',
    rejection_reason TEXT,
    verified_by UUID REFERENCES public.profiles(id),
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 6. VITALS TABLE (Time-Series)
CREATE TABLE IF NOT EXISTS public.vitals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id) ON DELETE CASCADE,
    systolic_bp INT CHECK (systolic_bp BETWEEN 50 AND 300),
    diastolic_bp INT CHECK (diastolic_bp BETWEEN 30 AND 200),
    pulse_rate INT CHECK (pulse_rate BETWEEN 30 AND 250),
    oxygen_spo2 INT CHECK (oxygen_spo2 BETWEEN 50 AND 100),
    body_temperature_f NUMERIC(4, 1) CHECK (body_temperature_f BETWEEN 85.0 AND 115.0),
    blood_glucose_mg_dl NUMERIC(5, 1),
    glucose_timing TEXT CHECK (glucose_timing IN ('fasting', 'post_prandial', 'random')),
    source TEXT NOT NULL DEFAULT 'manual' CHECK (source IN ('manual', 'wearable_sync', 'clinic_visit')),
    measured_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 7. DAILY LOGS TABLE (Steps, Sleep, Water)
CREATE TABLE IF NOT EXISTS public.daily_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    steps_count INT DEFAULT 0 CHECK (steps_count >= 0),
    sleep_hours NUMERIC(3, 1) DEFAULT 0.0 CHECK (sleep_hours BETWEEN 0.0 AND 24.0),
    water_intake_ml INT DEFAULT 0 CHECK (water_intake_ml >= 0),
    steps_source TEXT DEFAULT 'phone_pedometer' CHECK (steps_source IN ('phone_pedometer', 'wearable', 'manual')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(patient_id, log_date)
);

-- 8. MEDICINES TABLE
CREATE TABLE IF NOT EXISTS public.medicines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id) ON DELETE CASCADE,
    medicine_name TEXT NOT NULL,
    dosage TEXT NOT NULL, -- e.g. "1 Tablet", "5 ml"
    schedule_times JSONB NOT NULL DEFAULT '["08:00", "20:00"]'::jsonb, -- Array of HH:MM
    food_instruction TEXT CHECK (food_instruction IN ('before_meal', 'after_meal', 'with_meal', 'empty_stomach')),
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    end_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    prescribed_by_doctor_id UUID REFERENCES public.doctors(profile_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 9. MEDICINE DOSES LOG TABLE
CREATE TABLE IF NOT EXISTS public.medicine_doses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    medicine_id UUID NOT NULL REFERENCES public.medicines(id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id) ON DELETE CASCADE,
    scheduled_at TIMESTAMPTZ NOT NULL,
    taken_at TIMESTAMPTZ,
    status dose_status NOT NULL DEFAULT 'missed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 10. SCORE RULES VERSIONING TABLE
CREATE TABLE IF NOT EXISTS public.score_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    version_tag TEXT NOT NULL UNIQUE, -- e.g. 'v1.0'
    rules_config JSONB NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 11. HEALTH SCORES TABLE
CREATE TABLE IF NOT EXISTS public.health_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id) ON DELETE CASCADE,
    score_date DATE NOT NULL,
    total_score INT NOT NULL CHECK (total_score BETWEEN 0 AND 100),
    available_points INT NOT NULL DEFAULT 100,
    component_breakdown JSONB NOT NULL,
    rules_version TEXT NOT NULL REFERENCES public.score_rules(version_tag),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(patient_id, score_date)
);

-- 12. LAB REPORTS TABLE
CREATE TABLE IF NOT EXISTS public.lab_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id) ON DELETE CASCADE,
    test_name TEXT NOT NULL,
    test_category TEXT NOT NULL DEFAULT 'Blood Test',
    test_date DATE NOT NULL DEFAULT CURRENT_DATE,
    file_storage_path TEXT NOT NULL,
    extracted_biomarkers JSONB DEFAULT '[]'::jsonb,
    ai_summary JSONB, -- 4-quadrant structured output
    ai_model_version TEXT DEFAULT 'gemini-1.5-flash',
    language TEXT NOT NULL DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 13. APPOINTMENTS TABLE
CREATE TABLE IF NOT EXISTS public.appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES public.doctors(profile_id) ON DELETE CASCADE,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason_for_visit TEXT,
    status appointment_status NOT NULL DEFAULT 'requested',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 14. PRESCRIPTIONS TABLE
CREATE TABLE IF NOT EXISTS public.prescriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID REFERENCES public.appointments(id),
    doctor_id UUID NOT NULL REFERENCES public.doctors(profile_id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id) ON DELETE CASCADE,
    diagnosis TEXT,
    instructions TEXT,
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    is_accepted_by_patient BOOLEAN NOT NULL DEFAULT false,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 15. CONSENT GRANTS TABLE (Zero-Trust Record Sharing)
CREATE TABLE IF NOT EXISTS public.consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.doctors(profile_id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL,
    scope TEXT[] NOT NULL DEFAULT '{"vitals", "lab_reports", "allergies"}',
    failed_attempts INT NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 16. ACCESS AUDIT LOG (Immutable)
CREATE TABLE IF NOT EXISTS public.access_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES public.profiles(id),
    patient_id UUID NOT NULL REFERENCES public.patients(profile_id),
    resource_type TEXT NOT NULL, -- e.g. 'lab_reports', 'vitals'
    action_type TEXT NOT NULL DEFAULT 'READ',
    ip_address TEXT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 17. HEALTH TIPS TABLE (366 Days Catalog)
CREATE TABLE IF NOT EXISTS public.health_tips (
    day_of_year INT PRIMARY KEY CHECK (day_of_year BETWEEN 1 AND 366),
    author TEXT NOT NULL,
    source_citation TEXT NOT NULL,
    category TEXT NOT NULL,
    tip_en TEXT NOT NULL,
    tip_hi TEXT NOT NULL,
    tip_gu TEXT NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT true
);

-- ==============================================================================
-- ROW-LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medicines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medicine_doses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lab_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.access_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_tips ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can read/update their own profile
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Patients: Patient accesses own data
CREATE POLICY "Patient can access own data" ON public.patients FOR ALL USING (auth.uid() = profile_id);

-- Doctors: Public can view approved doctors; Doctors manage own profile
CREATE POLICY "Public can view approved doctors" ON public.doctors FOR SELECT USING (verification_status = 'approved');
CREATE POLICY "Doctors can manage own profile" ON public.doctors FOR ALL USING (auth.uid() = profile_id);

-- Vitals: Patient owns vitals; Doctor reads if active consent exists
CREATE POLICY "Patient can manage own vitals" ON public.vitals FOR ALL USING (auth.uid() = patient_id);
CREATE POLICY "Doctor reads vitals with active consent" ON public.vitals FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.consents c
        WHERE c.patient_id = vitals.patient_id
          AND c.doctor_id = auth.uid()
          AND c.expires_at > now()
          AND c.revoked_at IS NULL
    )
);

-- Lab Reports: Patient owns reports; Doctor reads with consent
CREATE POLICY "Patient can manage own lab reports" ON public.lab_reports FOR ALL USING (auth.uid() = patient_id);
CREATE POLICY "Doctor reads reports with active consent" ON public.lab_reports FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.consents c
        WHERE c.patient_id = lab_reports.patient_id
          AND c.doctor_id = auth.uid()
          AND c.expires_at > now()
          AND c.revoked_at IS NULL
    )
);

-- Health Tips: Publicly readable for all authenticated users
CREATE POLICY "Health tips are readable by all" ON public.health_tips FOR SELECT TO authenticated USING (true);
