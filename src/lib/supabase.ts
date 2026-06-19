import { createClient } from '@supabase/supabase-js';

// We use import.meta.env for Astro environment variables.
// In a real scenario, the user will add these to their .env file.
const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL || 'https://gegvdbdhhgmdcojlommf.supabase.co';
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdlZ3ZkYmRoaGdtZGNvamxvbW1mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2MjMwOTMsImV4cCI6MjA5NzE5OTA5M30.D2tqqchzAtyEtyFLgMkbXeIa1gLDVzuMSYl06KvvVIc';

console.log(import.meta.env.PUBLIC_SUPABASE_URL);

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Types derived from schema
export type Service = {
  id: string;
  name: string;
  description: string | null;
  duration_minutes: number;
  price: number;
  active: boolean;
  created_at: string;
};

export type Staff = {
  id: string;
  name: string;
  specialization: string | null;
  photo: string | null;
  active: boolean;
  created_at: string;
};

export type Appointment = {
  id: string;
  customer_name: string;
  customer_email: string | null;
  customer_phone: string | null;
  service_id: string | null;
  staff_id: string | null;
  appointment_date: string | null;
  appointment_time: string | null;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  payment_status: 'unpaid' | 'pending_verification' | 'verified';
  payment_reference: string | null;
  created_at: string;

  // Joined fields for convenience in UI
  services?: Service;
  staff?: Staff;
};

export type Waitlist = {
  id: string;
  customer_name: string;
  email: string | null;
  phone: string | null;
  service_id: string | null;
  staff_id: string | null;
  desired_date: string | null;
  desired_time: string | null;
  created_at: string;

  // Joined fields
  services?: Service;
  staff?: Staff;
};
