-- ============================================
-- DATABASE INITIALIZATION SCRIPT
-- Sistem Informasi Pondok Pesantren
-- Created: $(date)
-- ============================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- CORE TABLES
-- ============================================

-- Users table (all system users)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('super_admin', 'admin', 'ustadz', 'santri', 'orangtua', 'staff')),
    phone VARCHAR(20),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Santri table (students)
CREATE TABLE IF NOT EXISTS santri (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nis VARCHAR(20) UNIQUE NOT NULL,
    nisn VARCHAR(20) UNIQUE,
    nama_lengkap VARCHAR(100) NOT NULL,
    nama_panggilan VARCHAR(50),
    tempat_lahir VARCHAR(50),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(10) CHECK (jenis_kelamin IN ('Laki-laki', 'Perempuan')),
    alamat TEXT,
    provinsi VARCHAR(50),
    kabupaten VARCHAR(50),
    kecamatan VARCHAR(50),
    desa VARCHAR(50),
    nama_ayah VARCHAR(100),
    nama_ibu VARCHAR(100),
    pekerjaan_ayah VARCHAR(50),
    pekerjaan_ibu VARCHAR(50),
    phone_ortu VARCHAR(20),
    tanggal_masuk DATE,
    status VARCHAR(20) DEFAULT 'aktif' CHECK (status IN ('aktif', 'alumni', 'dropout', 'pindah')),
    lembaga VARCHAR(50) CHECK (lembaga IN ('MTs', 'SMP', 'MA', 'Tahfidz', 'TPA')),
    kelas VARCHAR(20),
    asrama VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ustadz/Teachers table
CREATE TABLE IF NOT EXISTS ustadz (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nip VARCHAR(20) UNIQUE,
    nama_lengkap VARCHAR(100) NOT NULL,
    gelar VARCHAR(50),
    bidang_keahlian VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    alamat TEXT,
    status VARCHAR(20) DEFAULT 'aktif',
    tanggal_bergabung DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- ACADEMIC TABLES
-- ============================================

-- Mata Pelajaran (Subjects)
CREATE TABLE IF NOT EXISTS mata_pelajaran (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(20) CHECK (jenis IN ('agama', 'umum', 'keterampilan', 'bahasa')),
    bobot_sks INTEGER DEFAULT 2,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Jadwal Pelajaran (Schedule)
CREATE TABLE IF NOT EXISTS jadwal_pelajaran (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hari VARCHAR(10) CHECK (hari IN ('Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu')),
    jam_mulai TIME NOT NULL,
    jam_selesai TIME NOT NULL,
    mata_pelajaran_id UUID REFERENCES mata_pelajaran(id),
    ustadz_id UUID REFERENCES ustadz(id),
    kelas VARCHAR(20),
    ruangan VARCHAR(50),
    semester VARCHAR(10),
    tahun_ajaran VARCHAR(9),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Presensi (Attendance)
CREATE TABLE IF NOT EXISTS presensi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id),
    jadwal_id UUID REFERENCES jadwal_pelajaran(id),
    tanggal DATE NOT NULL,
    status VARCHAR(10) CHECK (status IN ('hadir', 'izin', 'sakit', 'alpha')),
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, jadwal_id, tanggal)
);

-- ============================================
-- FINANCIAL TABLES
-- ============================================

-- Jenis Pembayaran (Payment Types)
CREATE TABLE IF NOT EXISTS jenis_pembayaran (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    kategori VARCHAR(20) CHECK (kategori IN ('spp', 'daftar_ulang', 'ujian', 'lainnya')),
    nominal DECIMAL(12,2) NOT NULL,
    periode VARCHAR(20),
    deskripsi TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transaksi Pembayaran (Payment Transactions)
CREATE TABLE IF NOT EXISTS transaksi_pembayaran (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    santri_id UUID REFERENCES santri(id),
    jenis_pembayaran_id UUID REFERENCES jenis_pembayaran(id),
    tanggal_transaksi DATE NOT NULL,
    jumlah DECIMAL(12,2) NOT NULL,
    metode_bayar VARCHAR(20) CHECK (metode_bayar IN ('cash', 'transfer', 'qris', 'ewallet')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'canceled', 'expired')),
    keterangan TEXT,
    bukti_bayar_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- DORMITORY TABLES
-- ============================================

-- Asrama/Kamar (Dormitory Rooms)
CREATE TABLE IF NOT EXISTS kamar (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nomor_kamar VARCHAR(10) UNIQUE NOT NULL,
    gedung VARCHAR(50),
    lantai INTEGER,
    kapasitas INTEGER DEFAULT 4,
    terisi INTEGER DEFAULT 0,
    fasilitas TEXT,
    status VARCHAR(20) DEFAULT 'tersedia' CHECK (status IN ('tersedia', 'penuh', 'perbaikan')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Penempatan Kamar (Room Assignment)
CREATE TABLE IF NOT EXISTS penempatan_kamar (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id),
    kamar_id UUID REFERENCES kamar(id),
    tanggal_masuk DATE NOT NULL,
    tanggal_keluar DATE,
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id) WHERE status = 'aktif'
);

-- ============================================
-- INSERT INITIAL DATA
-- ============================================

-- Insert admin user (password: AdminPesantren2026!)
INSERT INTO users (username, email, password_hash, full_name, role, is_active) 
VALUES (
    'admin', 
    'admin@pesantren.local', 
    crypt('AdminPesantren2026!', gen_salt('bf', 12)), 
    'Administrator System', 
    'super_admin', 
    true
) ON CONFLICT (username) DO NOTHING;

-- Insert sample santri
INSERT INTO santri (nis, nama_lengkap, tempat_lahir, tanggal_lahir, jenis_kelamin, alamat, status, lembaga, kelas)
VALUES 
    ('2024001', 'Ahmad Santoso', 'Jakarta', '2010-05-15', 'Laki-laki', 'Jl. Merdeka No. 123', 'aktif', 'MTs', '7A'),
    ('2024002', 'Siti Rahma', 'Bandung', '2011-03-20', 'Perempuan', 'Jl. Asia Afrika No. 45', 'aktif', 'SMP', '8B'),
    ('2024003', 'Budi Setiawan', 'Surabaya', '2010-11-10', 'Laki-laki', 'Jl. Diponegoro No. 67', 'aktif', 'MA', '10IPA')
ON CONFLICT (nis) DO NOTHING;

-- Insert sample ustadz
INSERT INTO ustadz (nip, nama_lengkap, bidang_keahlian, status)
VALUES 
    ('1980010120001', 'Ustadz Ahmad Fauzi, M.Pd.I', 'Al-Quran dan Tafsir', 'aktif'),
    ('1981020220002', 'Ustadzah Siti Aminah, M.Pd', 'Matematika dan Sains', 'aktif'),
    ('1982030320003', 'Ustadz Muhammad Rizki, S.Pd', 'Bahasa Arab dan Inggris', 'aktif')
ON CONFLICT (nip) DO NOTHING;

-- Insert sample mata pelajaran
INSERT INTO mata_pelajaran (kode, nama, jenis, bobot_sks)
VALUES 
    ('AGM001', 'Al-Quran', 'agama', 2),
    ('AGM002', 'Hadits', 'agama', 2),
    ('AGM003', 'Fiqih', 'agama', 2),
    ('UMU001', 'Matematika', 'umum', 3),
    ('UMU002', 'Bahasa Indonesia', 'umum', 2),
    ('UMU003', 'IPA', 'umum', 3),
    ('UMU004', 'IPS', 'umum', 2),
    ('BHS001', 'Bahasa Arab', 'bahasa', 2),
    ('BHS002', 'Bahasa Inggris', 'bahasa', 2)
ON CONFLICT (kode) DO NOTHING;

-- Insert sample kamar
INSERT INTO kamar (nomor_kamar, gedung, lantai, kapasitas, terisi, status)
VALUES 
    ('A101', 'Gedung A', 1, 4, 2, 'tersedia'),
    ('A102', 'Gedung A', 1, 4, 4, 'penuh'),
    ('B201', 'Gedung B', 2, 6, 3, 'tersedia'),
    ('B202', 'Gedung B', 2, 6, 2, 'tersedia')
ON CONFLICT (nomor_kamar) DO NOTHING;

-- Insert sample jenis pembayaran
INSERT INTO jenis_pembayaran (kode, nama, kategori, nominal, periode)
VALUES 
    ('SPP001', 'SPP Bulanan', 'spp', 500000.00, 'bulanan'),
    ('DU001', 'Daftar Ulang', 'daftar_ulang', 1500000.00, 'tahunan'),
    ('UJN001', 'Ujian Semester', 'ujian', 200000.00, 'semester'),
    ('ASR001', 'Biaya Asrama', 'lainnya', 300000.00, 'bulanan')
ON CONFLICT (kode) DO NOTHING;

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(is_active);

-- Santri indexes
CREATE INDEX IF NOT EXISTS idx_santri_nis ON santri(nis);
CREATE INDEX IF NOT EXISTS idx_santri_status ON santri(status);
CREATE INDEX IF NOT EXISTS idx_santri_lembaga ON santri(lembaga);
CREATE INDEX IF NOT EXISTS idx_santri_kelas ON santri(kelas);

-- Transaction indexes
CREATE INDEX IF NOT EXISTS idx_transaksi_santri ON transaksi_pembayaran(santri_id);
CREATE INDEX IF NOT EXISTS idx_transaksi_status ON transaksi_pembayaran(status);
CREATE INDEX IF NOT EXISTS idx_transaksi_tanggal ON transaksi_pembayaran(tanggal_transaksi);

-- Attendance indexes
CREATE INDEX IF NOT EXISTS idx_presensi_santri ON presensi(santri_id);
CREATE INDEX IF NOT EXISTS idx_presensi_tanggal ON presensi(tanggal);

-- ============================================
-- CREATE VIEWS FOR REPORTING
-- ============================================

-- View for student summary
CREATE OR REPLACE VIEW v_santri_summary AS
SELECT 
    s.id,
    s.nis,
    s.nama_lengkap,
    s.lembaga,
    s.kelas,
    s.status,
    k.nomor_kamar,
    k.gedung,
    COUNT(DISTINCT tp.id) as total_transaksi,
    COALESCE(SUM(CASE WHEN tp.status = 'paid' THEN tp.jumlah ELSE 0 END), 0) as total_paid
FROM santri s
LEFT JOIN penempatan_kamar pk ON s.id = pk.santri_id AND pk.status = 'aktif'
LEFT JOIN kamar k ON pk.kamar_id = k.id
LEFT JOIN transaksi_pembayaran tp ON s.id = tp.santri_id
GROUP BY s.id, s.nis, s.nama_lengkap, s.lembaga, s.kelas, s.status, k.nomor_kamar, k.gedung;

-- View for financial summary
CREATE OR REPLACE VIEW v_financial_summary AS
SELECT 
    DATE_TRUNC('month', tanggal_transaksi) as bulan,
    COUNT(*) as total_transaksi,
    SUM(jumlah) as total_nominal,
    AVG(jumlah) as rata_rata,
    COUNT(CASE WHEN status = 'paid' THEN 1 END) as lunas,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending
FROM transaksi_pembayaran
GROUP BY DATE_TRUNC('month', tanggal_transaksi)
ORDER BY bulan DESC;

-- ============================================
-- FINAL MESSAGE
-- ============================================

SELECT 'Database initialized successfully at ' || now() AS message;
SELECT 'Total tables created: ' || COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';
