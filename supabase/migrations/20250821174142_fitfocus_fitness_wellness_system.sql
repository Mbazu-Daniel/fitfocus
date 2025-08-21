-- Location: supabase/migrations/20250821174142_fitfocus_fitness_wellness_system.sql
-- Schema Analysis: FRESH PROJECT - No existing schema detected
-- Integration Type: NEW MODULE - Complete fitness/wellness application
-- Dependencies: None - Creating complete new schema

-- 1. Extensions & Types (with public qualification)
CREATE TYPE public.user_role AS ENUM ('admin', 'trainer', 'member');
CREATE TYPE public.exercise_category AS ENUM ('strength', 'cardio', 'flexibility', 'balance', 'sports');
CREATE TYPE public.difficulty_level AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE public.workout_status AS ENUM ('planned', 'active', 'completed', 'skipped');
CREATE TYPE public.measurement_type AS ENUM ('weight', 'body_fat', 'muscle_mass', 'water_percentage');

-- 2. Core tables (no foreign keys)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'member'::public.user_role,
    date_of_birth DATE,
    height_cm INTEGER,
    fitness_level public.difficulty_level DEFAULT 'beginner'::public.difficulty_level,
    profile_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    category public.exercise_category NOT NULL,
    difficulty public.difficulty_level DEFAULT 'beginner'::public.difficulty_level,
    description TEXT,
    instructions TEXT,
    muscles_targeted TEXT[],
    equipment_needed TEXT,
    duration_minutes INTEGER,
    calories_per_minute DECIMAL(4,2),
    video_url TEXT,
    image_url TEXT,
    is_premium BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Dependent tables (with foreign keys to existing tables only)
CREATE TABLE public.workout_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    difficulty public.difficulty_level DEFAULT 'beginner'::public.difficulty_level,
    duration_weeks INTEGER DEFAULT 4,
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.workout_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    workout_plan_id UUID REFERENCES public.workout_plans(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    status public.workout_status DEFAULT 'planned'::public.workout_status,
    scheduled_for TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    calories_burned INTEGER,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.exercise_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_session_id UUID REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
    exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE,
    set_number INTEGER NOT NULL,
    reps INTEGER,
    weight_kg DECIMAL(5,2),
    duration_seconds INTEGER,
    rest_seconds INTEGER DEFAULT 60,
    completed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.body_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    measurement_type public.measurement_type NOT NULL,
    value DECIMAL(6,2) NOT NULL,
    unit TEXT NOT NULL,
    measured_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE TABLE public.user_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    goal_type TEXT NOT NULL, -- 'weight_loss', 'muscle_gain', 'endurance', etc.
    target_value DECIMAL(8,2),
    target_unit TEXT,
    target_date DATE,
    current_value DECIMAL(8,2),
    is_achieved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.nutrition_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    meal_type TEXT NOT NULL, -- 'breakfast', 'lunch', 'dinner', 'snack'
    food_name TEXT NOT NULL,
    calories INTEGER,
    protein_g DECIMAL(6,2),
    carbs_g DECIMAL(6,2),
    fat_g DECIMAL(6,2),
    portion_size TEXT,
    logged_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Junction tables
CREATE TABLE public.workout_plan_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_plan_id UUID REFERENCES public.workout_plans(id) ON DELETE CASCADE,
    exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    order_in_day INTEGER NOT NULL,
    target_sets INTEGER DEFAULT 3,
    target_reps INTEGER,
    target_duration_seconds INTEGER,
    rest_seconds INTEGER DEFAULT 60,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(workout_plan_id, day_number, order_in_day)
);

-- 5. Indexes (CREATE INDEX ON public.table_name(column))
CREATE INDEX idx_user_profiles_user_id ON public.user_profiles(id);
CREATE INDEX idx_workout_plans_user_id ON public.workout_plans(user_id);
CREATE INDEX idx_workout_sessions_user_id ON public.workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_plan_id ON public.workout_sessions(workout_plan_id);
CREATE INDEX idx_exercise_sets_session_id ON public.exercise_sets(workout_session_id);
CREATE INDEX idx_exercise_sets_exercise_id ON public.exercise_sets(exercise_id);
CREATE INDEX idx_body_measurements_user_id ON public.body_measurements(user_id);
CREATE INDEX idx_user_goals_user_id ON public.user_goals(user_id);
CREATE INDEX idx_nutrition_logs_user_id ON public.nutrition_logs(user_id);
CREATE INDEX idx_exercises_category ON public.exercises(category);
CREATE INDEX idx_exercises_difficulty ON public.exercises(difficulty);

-- 6. Functions (with proper schema qualification) - MUST BE BEFORE RLS POLICIES
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'member'::public.user_role)
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.calculate_workout_calories(session_id UUID)
RETURNS INTEGER
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT COALESCE(
  (SELECT SUM(
    CASE 
      WHEN es.duration_seconds IS NOT NULL AND e.calories_per_minute IS NOT NULL 
      THEN (es.duration_seconds / 60.0 * e.calories_per_minute)::INTEGER
      ELSE 0
    END
  )
  FROM public.exercise_sets es
  JOIN public.exercises e ON es.exercise_id = e.id
  WHERE es.workout_session_id = session_id AND es.completed = true), 0
);
$$;

-- 7. Enable RLS (ALTER TABLE public.table_name ENABLE ROW LEVEL SECURITY)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.body_measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nutrition_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_plan_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

-- 8. RLS policies (can now reference functions created in step 6)

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for user-owned tables
CREATE POLICY "users_manage_own_workout_plans"
ON public.workout_plans
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_workout_sessions"
ON public.workout_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_body_measurements"
ON public.body_measurements
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_user_goals"
ON public.user_goals
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_nutrition_logs"
ON public.nutrition_logs
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: For exercise sets (owned through workout sessions)
CREATE POLICY "users_manage_own_exercise_sets"
ON public.exercise_sets
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.workout_sessions ws
    WHERE ws.id = exercise_sets.workout_session_id
    AND ws.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.workout_sessions ws
    WHERE ws.id = exercise_sets.workout_session_id
    AND ws.user_id = auth.uid()
  )
);

-- Pattern 2: For workout plan exercises (owned through workout plans)
CREATE POLICY "users_manage_own_workout_plan_exercises"
ON public.workout_plan_exercises
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.workout_plans wp
    WHERE wp.id = workout_plan_exercises.workout_plan_id
    AND wp.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.workout_plans wp
    WHERE wp.id = workout_plan_exercises.workout_plan_id
    AND wp.user_id = auth.uid()
  )
);

-- Pattern 4: Public read, private write for exercises (public content)
CREATE POLICY "public_can_read_exercises"
ON public.exercises
FOR SELECT
TO public
USING (true);

CREATE POLICY "admins_manage_exercises"
ON public.exercises
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
  )
);

-- 9. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 10. Complete Mock Data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    trainer_uuid UUID := gen_random_uuid();
    member_uuid UUID := gen_random_uuid();
    workout_plan_uuid UUID := gen_random_uuid();
    exercise1_uuid UUID := gen_random_uuid();
    exercise2_uuid UUID := gen_random_uuid();
    exercise3_uuid UUID := gen_random_uuid();
    session_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@fitfocus.com', crypt('FitFocus123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (trainer_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'trainer@fitfocus.com', crypt('FitFocus123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Personal Trainer", "role": "trainer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (member_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'member@fitfocus.com', crypt('FitFocus123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Fitness Member", "role": "member"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create sample exercises
    INSERT INTO public.exercises (id, name, category, difficulty, description, instructions, muscles_targeted, equipment_needed, duration_minutes, calories_per_minute) VALUES
        (exercise1_uuid, 'Push-ups', 'strength'::public.exercise_category, 'beginner'::public.difficulty_level, 
         'Classic upper body strength exercise', 'Start in plank position, lower body to ground, push back up',
         ARRAY['chest', 'shoulders', 'triceps'], 'None', 15, 8.5),
        (exercise2_uuid, 'Running', 'cardio'::public.exercise_category, 'intermediate'::public.difficulty_level,
         'Cardiovascular endurance exercise', 'Maintain steady pace, focus on breathing',
         ARRAY['legs', 'core'], 'Running shoes', 30, 12.0),
        (exercise3_uuid, 'Yoga Stretch', 'flexibility'::public.exercise_category, 'beginner'::public.difficulty_level,
         'Flexibility and mindfulness exercise', 'Hold poses for 30 seconds each, focus on breathing',
         ARRAY['full_body'], 'Yoga mat', 20, 3.5);

    -- Create sample workout plan
    INSERT INTO public.workout_plans (id, user_id, name, description, difficulty, duration_weeks, is_active) VALUES
        (workout_plan_uuid, member_uuid, 'Beginner Full Body', 'Complete beginner workout focusing on all muscle groups', 
         'beginner'::public.difficulty_level, 8, true);

    -- Add exercises to workout plan
    INSERT INTO public.workout_plan_exercises (workout_plan_id, exercise_id, day_number, order_in_day, target_sets, target_reps, rest_seconds) VALUES
        (workout_plan_uuid, exercise1_uuid, 1, 1, 3, 10, 60),
        (workout_plan_uuid, exercise2_uuid, 1, 2, 1, 0, 120),
        (workout_plan_uuid, exercise3_uuid, 1, 3, 1, 0, 30);

    -- Create sample workout session
    INSERT INTO public.workout_sessions (id, user_id, workout_plan_id, name, status, scheduled_for, duration_minutes) VALUES
        (session_uuid, member_uuid, workout_plan_uuid, 'Morning Workout', 'completed'::public.workout_status, 
         now() - interval '2 hours', 45);

    -- Create sample exercise sets
    INSERT INTO public.exercise_sets (workout_session_id, exercise_id, set_number, reps, duration_seconds, completed) VALUES
        (session_uuid, exercise1_uuid, 1, 10, null, true),
        (session_uuid, exercise1_uuid, 2, 10, null, true),
        (session_uuid, exercise1_uuid, 3, 8, null, true),
        (session_uuid, exercise2_uuid, 1, null, 1800, true),
        (session_uuid, exercise3_uuid, 1, null, 1200, true);

    -- Create sample body measurements
    INSERT INTO public.body_measurements (user_id, measurement_type, value, unit, measured_at) VALUES
        (member_uuid, 'weight'::public.measurement_type, 70.5, 'kg', now() - interval '1 day'),
        (member_uuid, 'body_fat'::public.measurement_type, 18.2, 'percent', now() - interval '1 day');

    -- Create sample goals
    INSERT INTO public.user_goals (user_id, goal_type, target_value, target_unit, target_date, current_value) VALUES
        (member_uuid, 'weight_loss', 65.0, 'kg', current_date + interval '3 months', 70.5),
        (member_uuid, 'muscle_gain', 2.0, 'kg', current_date + interval '6 months', 0.0);

    -- Create sample nutrition log
    INSERT INTO public.nutrition_logs (user_id, meal_type, food_name, calories, protein_g, carbs_g, fat_g, portion_size) VALUES
        (member_uuid, 'breakfast', 'Oatmeal with banana', 350, 12.5, 58.0, 8.2, '1 bowl'),
        (member_uuid, 'lunch', 'Grilled chicken salad', 420, 35.0, 15.0, 18.5, '1 large plate'),
        (member_uuid, 'dinner', 'Salmon with quinoa', 480, 32.0, 45.0, 16.8, '1 portion');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;