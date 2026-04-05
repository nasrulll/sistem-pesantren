-- Initial database schema for Sistem Pesantren
-- This file can be imported directly to Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (for authentication)
CREATE TABLE users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  role VARCHAR(50) DEFAULT 'user',
  phone VARCHAR(20),
  avatar_url TEXT,
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Santri (Students) table
CREATE TABLE santri (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  nis VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  birth_place VARCHAR(100),
  birth_date DATE,
  gender VARCHAR(10),
  address TEXT,
  parent_name VARCHAR(255),
  parent_phone VARCHAR(20),
  class VARCHAR(50),
  status VARCHAR(50) DEFAULT 'active',
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ustadz/Teachers table
CREATE TABLE ustadz (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  nik VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  specialization VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(255),
  address TEXT,
  join_date DATE,
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Classes table
CREATE TABLE classes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  level VARCHAR(50),
  ustadz_id UUID REFERENCES ustadz(id),
  capacity INTEGER,
  current_count INTEGER DEFAULT 0,
  academic_year VARCHAR(20),
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Attendance table
CREATE TABLE attendance (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  santri_id UUID REFERENCES santri(id),
  class_id UUID REFERENCES classes(id),
  date DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'present', -- present, absent, sick, permit
  check_in_time TIME,
  check_out_time TIME,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  santri_id UUID REFERENCES santri(id),
  payment_type VARCHAR(50), -- SPP, registration, etc
  amount DECIMAL(10,2) NOT NULL,
  payment_date DATE,
  due_date DATE,
  status VARCHAR(20) DEFAULT 'pending', -- pending, paid, overdue
  payment_method VARCHAR(50),
  receipt_number VARCHAR(100),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_santri_nis ON santri(nis);
CREATE INDEX idx_santri_status ON santri(status);
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_santri ON attendance(santri_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_santri ON payments(santri_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_santri_updated_at BEFORE UPDATE ON santri
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ustadz_updated_at BEFORE UPDATE ON ustadz
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_classes_updated_at BEFORE UPDATE ON classes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data (optional)
INSERT INTO users (email, username, password_hash, full_name, role) VALUES
('admin@pesantren.local', 'admin', '$2a$10$YourHashedPasswordHere', 'Administrator', 'admin'),
('ustadz@pesantren.local', 'ustadz', '$2a$10$YourHashedPasswordHere', 'Ustadz Sample', 'teacher'),
('santri@pesantren.local', 'santri', '$2a$10$YourHashedPasswordHere', 'Santri Sample', 'student');

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE santri ENABLE ROW LEVEL SECURITY;
ALTER TABLE ustadz ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (basic example)
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Public santri view" ON santri
  FOR SELECT USING (true);

CREATE POLICY "Admin full access" ON users
  FOR ALL USING (role = 'admin');

-- Create storage bucket for uploads
INSERT INTO storage.buckets (id, name, public) VALUES
('uploads', 'uploads', true);

-- Set up storage policies
CREATE POLICY "Public uploads" ON storage.objects
  FOR SELECT USING (bucket_id = 'uploads');

CREATE POLICY "Authenticated users can upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'uploads' AND
    auth.role() = 'authenticated'
  );