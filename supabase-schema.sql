-- Supabase Schema for Aura Luxe Salon Admin Dashboard

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. services table
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    price NUMERIC NOT NULL,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. staff table
CREATE TABLE IF NOT EXISTS public.staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    specialization TEXT,
    photo TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. appointments table
CREATE TABLE IF NOT EXISTS public.appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_name TEXT NOT NULL,
    customer_email TEXT,
    customer_phone TEXT,
    service_id UUID REFERENCES public.services(id) ON DELETE SET NULL,
    staff_id UUID REFERENCES public.staff(id) ON DELETE SET NULL,
    appointment_date DATE,
    appointment_time TIME,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    payment_status TEXT DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'pending_verification', 'verified')),
    payment_reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Migration for existing databases
ALTER TABLE public.appointments ALTER COLUMN appointment_date DROP NOT NULL;
ALTER TABLE public.appointments ALTER COLUMN appointment_time DROP NOT NULL;
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='appointments' AND column_name='payment_status') THEN
        ALTER TABLE public.appointments ADD COLUMN payment_status TEXT DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'pending_verification', 'verified'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='appointments' AND column_name='payment_reference') THEN
        ALTER TABLE public.appointments ADD COLUMN payment_reference TEXT;
    END IF;
END $$;

-- 4. waitlist table
CREATE TABLE IF NOT EXISTS public.waitlist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    service_id UUID REFERENCES public.services(id) ON DELETE CASCADE,
    staff_id UUID REFERENCES public.staff(id) ON DELETE CASCADE,
    desired_date DATE,
    desired_time TIME,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Disable Row Level Security temporarily for easy development out of the box
-- (In a real production environment with authenticated users, you would ENABLE RLS and write policies)
ALTER TABLE public.services DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.waitlist DISABLE ROW LEVEL SECURITY;

-- Optional: Create a storage bucket for staff photos if not exists
INSERT INTO storage.buckets (id, name, public) 
VALUES ('staff-photos', 'staff-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Disable RLS on the bucket for easy upload during dev
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- Migration to fix foreign key type mismatch (changing from bigint to UUID)
-- WARNING: The USING NULL clause will clear existing integer values in these columns to allow the type change.
ALTER TABLE public.appointments 
  ALTER COLUMN service_id TYPE UUID USING NULL,
  ALTER COLUMN staff_id TYPE UUID USING NULL;

ALTER TABLE public.waitlist 
  ALTER COLUMN service_id TYPE UUID USING NULL,
  ALTER COLUMN staff_id TYPE UUID USING NULL;
