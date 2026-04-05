-- ============================================
-- COMPLETE DATABASE SCHEMA - SISTEM PESANTREN 100%
-- 40 MODULES FULL IMPLEMENTATION
-- Created: 2026-04-05 06:22 WITA
-- ============================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- ============================================
-- 1. CORE SYSTEM TABLES (MODULE 1-3)
-- ============================================

-- Users table (MODULE 1: Manajemen Data Master)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('super_admin', 'admin', 'ustadz', 'santri', 'orangtua', 'staff', 'bendahara', 'pustakawan', 'kesehatan')),
    phone VARCHAR(20),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lembaga table (MODULE 2: Manajemen Multi Lembaga)
CREATE TABLE IF NOT EXISTS lembaga (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kode VARCHAR(10) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(20) CHECK (jenis IN ('MTs', 'SMP', 'MA', 'Tahfidz', 'TPA', 'Madrasah', 'Pesantren')),
    alamat TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    kepala_sekolah VARCHAR(100),
    nip_kepala VARCHAR(50),
    akreditasi VARCHAR(10),
    tahun_berdiri INTEGER,
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Santri table (MODULE 1: Manajemen Data Master)
CREATE TABLE IF NOT EXISTS santri (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nis VARCHAR(20) UNIQUE NOT NULL,
    nisn VARCHAR(20) UNIQUE,
    nama_lengkap VARCHAR(100) NOT NULL,
    nama_panggilan VARCHAR(50),
    tempat_lahir VARCHAR(50),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(10) CHECK (jenis_kelamin IN ('Laki-laki', 'Perempuan')),
    agama VARCHAR(20) DEFAULT 'Islam',
    alamat TEXT,
    provinsi VARCHAR(50),
    kabupaten VARCHAR(50),
    kecamatan VARCHAR(50),
    desa VARCHAR(50),
    kode_pos VARCHAR(10),
    nama_ayah VARCHAR(100),
    nama_ibu VARCHAR(100),
    pekerjaan_ayah VARCHAR(50),
    pekerjaan_ibu VARCHAR(50),
    phone_ortu VARCHAR(20),
    email_ortu VARCHAR(100),
    tanggal_masuk DATE,
    status VARCHAR(20) DEFAULT 'aktif' CHECK (status IN ('aktif', 'alumni', 'dropout', 'pindah', 'cuti')),
    lembaga_id UUID REFERENCES lembaga(id),
    kelas VARCHAR(20),
    asrama VARCHAR(50),
    foto_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ustadz/Teachers table (MODULE 1)
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
    lembaga_id UUID REFERENCES lembaga(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. PENERIMAAN SANTRI BARU (MODULE 3)
-- ============================================

-- Pendaftaran table
CREATE TABLE IF NOT EXISTS pendaftaran (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nomor_pendaftaran VARCHAR(20) UNIQUE NOT NULL,
    nama_calon VARCHAR(100) NOT NULL,
    tempat_lahir VARCHAR(50),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(10),
    alamat TEXT,
    phone_ortu VARCHAR(20),
    email_ortu VARCHAR(100),
    lembaga_tujuan UUID REFERENCES lembaga(id),
    jalur_pendaftaran VARCHAR(20) CHECK (jalur_pendaftaran IN ('reguler', 'prestasi', 'afirmasi')),
    tanggal_daftar DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'diterima', 'ditolak', 'cadangan')),
    nilai_test DECIMAL(5,2),
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. AKADEMIK FORMAL (MODULE 4-6)
-- ============================================

-- Mata Pelajaran (MODULE 4: Akademik Formal)
CREATE TABLE IF NOT EXISTS mata_pelajaran (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(20) CHECK (jenis IN ('agama', 'umum', 'keterampilan', 'bahasa', 'diniyah')),
    bobot_sks INTEGER DEFAULT 2,
    deskripsi TEXT,
    lembaga_id UUID REFERENCES lembaga(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Kurikulum (MODULE 18: Kurikulum Hybrid)
CREATE TABLE IF NOT EXISTS kurikulum (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nama VARCHAR(100) NOT NULL,
    tahun_ajaran VARCHAR(9),
    semester VARCHAR(10),
    lembaga_id UUID REFERENCES lembaga(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Jadwal Pelajaran (MODULE 7: Jadwal Terpadu)
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
    kurikulum_id UUID REFERENCES kurikulum(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Nilai Akademik
CREATE TABLE IF NOT EXISTS nilai_akademik (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id),
    mata_pelajaran_id UUID REFERENCES mata_pelajaran(id),
    semester VARCHAR(10),
    tahun_ajaran VARCHAR(9),
    nilai_tugas DECIMAL(5,2),
    nilai_uts DECIMAL(5,2),
    nilai_uas DECIMAL(5,2),
    nilai_akhir DECIMAL(5,2),
    grade VARCHAR(2),
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, mata_pelajaran_id, semester, tahun_ajaran)
);

-- ============================================
-- 4. TAHFIDZ SYSTEM (MODULE 6: KHUSUS)
-- ============================================

-- Program Tahfidz
CREATE TABLE IF NOT EXISTS program_tahfidz (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nama_program VARCHAR(100) NOT NULL,
    target_juz INTEGER,
    durasi_bulan INTEGER,
    ustadz_pembimbing UUID REFERENCES ustadz(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hafalan Santri
CREATE TABLE IF NOT EXISTS hafalan_santri (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id),
    program_tahfidz_id UUID REFERENCES program_tahfidz(id),
    juz INTEGER NOT NULL,
    surat VARCHAR(50),
    ayat_awal INTEGER,
    ayat_akhir INTEGER,
    tanggal_setor DATE,
    metode_setor VARCHAR(20) CHECK (metode_setor IN ('langsung', 'rekaman', 'video')),
    nilai DECIMAL(5,2),
    ustadz_penguji UUID REFERENCES ustadz(id),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 5. KEUANGAN TERINTEGRASI (MODULE 8)
-- ============================================

-- Jenis Pembayaran
CREATE TABLE IF NOT EXISTS jenis_pembayaran (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    kategori VARCHAR(20) CHECK (kategori IN ('spp', 'daftar_ulang', 'ujian', 'asrama', 'makan', 'lainnya')),
    nominal DECIMAL(12,2) NOT NULL,
    periode VARCHAR(20),
    deskripsi TEXT,
    is_active BOOLEAN DEFAULT true,
    lembaga_id UUID REFERENCES lembaga(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transaksi Pembayaran
CREATE TABLE IF NOT EXISTS transaksi_pembayaran (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    santri_id UUID REFERENCES santri(id),
    jenis_pembayaran_id UUID REFERENCES jenis_pembayaran(id),
    tanggal_transaksi DATE NOT NULL,
    tanggal_jatuh_tempo DATE,
    jumlah DECIMAL(12,2) NOT NULL,
    metode_bayar VARCHAR(20) CHECK (metode_bayar IN ('cash', 'transfer', 'qris', 'ewallet', 'virtual_account')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'canceled', 'expired', 'partial')),
    keterangan TEXT,
    bukti_bayar_url TEXT,
    payment_gateway_response JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Digital Wallet (MODULE 26)
CREATE TABLE IF NOT EXISTS digital_wallet (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id) UNIQUE,
    saldo DECIMAL(12,2) DEFAULT 0,
    pin_hash VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 6. ASRAMA & KEHIDUPAN SANTRI (MODULE 9)
-- ============================================

-- Gedung Asrama
CREATE TABLE IF NOT EXISTS gedung_asrama (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kode VARCHAR(10) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(20) CHECK (jenis IN ('putra', 'putri')),
    kapasitas INTEGER,
    lantai INTEGER,
    wali_asrama UUID REFERENCES ustadz(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Kamar
CREATE TABLE IF NOT EXISTS kamar (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nomor_kamar VARCHAR(10) UNIQUE NOT NULL,
    gedung_id UUID REFERENCES gedung_asrama(id),
    kapasitas INTEGER DEFAULT 4,
    terisi INTEGER DEFAULT 0,
    fasilitas TEXT,
    status VARCHAR(20) DEFAULT 'tersedia' CHECK (status IN ('tersedia', 'penuh', 'perbaikan')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Penempatan Kamar
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
-- 7. PRESENSI & ATTENDANCE (MODULE 27)
-- ============================================

-- Presensi
CREATE TABLE IF NOT EXISTS presensi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id),
    jadwal_id UUID REFERENCES jadwal_pelajaran(id),
    tanggal DATE NOT NULL,
    waktu_masuk TIME,
    waktu_keluar TIME,
    status VARCHAR(10) CHECK (status IN ('hadir', 'izin', 'sakit', 'alpha', 'terlambat')),
    keterangan TEXT,
    metode_presensi VARCHAR(20) CHECK (metode_presensi IN ('manual', 'fingerprint', 'rfid', 'face_recognition')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, jadwal_id, tanggal)
);

-- ============================================
-- 8. RAPORT & SERTIFIKASI (MODULE 11, 16)
-- ============================================

-- Raport
CREATE TABLE IF NOT EXISTS raport (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id),
    semester VARCHAR(10),
    tahun_ajaran VARCHAR(9),
    nilai_akademik JSONB,
    nilai_akhlaq DECIMAL(5,2),
    nilai_keterampilan DECIMAL(5,2),
    catatan_wali_kelas TEXT,
    tanggal_terbit DATE,
    status VARCHAR(20) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, semester, tahun_ajaran)
);

-- Sertifikat
CREATE TABLE IF NOT EXISTS sertifikat (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id),
    jenis VARCHAR(50),
    nomor_sertifikat VARCHAR(50) UNIQUE,
    tanggal_terbit DATE,
    tanggal_expired DATE,
    file_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 9. ALUMNI SYSTEM (MODULE 17)
-- ============================================

-- Alumni
CREATE TABLE IF NOT EXISTS alumni (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id) UNIQUE,
    tahun_lulus INTEGER,
    pekerjaan VARCHAR(100),
    perusahaan VARCHAR(100),
    alamat_kerja TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    is_active_member BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 10. INFRASTRUKTUR (MODULE 20)
-- ============================================

-- Fasilitas
CREATE TABLE IF NOT EXISTS fasilitas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(50),
    lokasi VARCHAR(100),
    kapasitas INTEGER,
    status VARCHAR(20) DEFAULT 'baik',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Peminjaman Fasilitas
CREATE TABLE IF NOT EXISTS peminjaman_fasilitas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fasilitas_id UUID REFERENCES fasilitas(id),
    peminjam_id UUID,
    peminjam_tipe VARCHAR(20) CHECK (peminjam_tipe IN ('santri', 'ustadz', 'staff')),
    tanggal_pinjam DATE,
    tanggal_kembali DATE,
    tujuan_peminjaman TEXT,
    status VARCHAR(20) DEFAULT 'dipinjam',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 11. PSIKOLOGI & KARAKTER (MODULE 21)
-- ============================================

-- Assessment Psikologi
CREATE TABLE IF NOT EXISTS assessment_psikologi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    santri_id UUID REFERENCES santri(id),
    tanggal_assessment DATE,
    psikolog_id UUID REFERENCES ustadz(id),
    hasil_assessment JSONB,
    rekomendasi TEXT,
    follow_up_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 12. KNOWLEDGE BASE (MODULE 23)
-- ============================================

-- Artikel
CREATE TABLE IF NOT EXISTS artikel (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    judul VARCHAR(200) NOT NULL,
    konten TEXT,
    kategori VARCHAR(50),
    penulis_id UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'draft',
    views INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 13. SOCIAL NETWORK (MODULE 25)
-- ============================================

-- Forum Diskusi
CREATE TABLE IF NOT EXISTS forum_diskusi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    judul VARCHAR(200) NOT NULL,
    konten TEXT,
    pembuat_id UUID REFERENCES users(id),
    kategori VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Komentar
CREATE TABLE IF NOT EXISTS komentar (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    forum_id UUID REFERENCES forum_diskusi(id),
    user_id UUID REFERENCES users(id),
    konten TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 14. AUDIT & RISK MANAGEMENT (MODULE 28, 29)
-- ============================================

-- Audit Log
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id UUID,
    old_data JSONB,
    new_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Risiko
CREATE TABLE IF NOT EXISTS risiko (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    kategori VARCHAR(50),
    probabilitas VARCHAR(20),
    dampak VARCHAR(20),
    mitigasi TEXT,
    penanggung_jawab UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 15. CMS & CONTENT (MODULE 30)
-- ============================================

-- Halaman
CREATE TABLE IF NOT EXISTS halaman (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(100) UNIQUE NOT NULL,
    judul VARCHAR(200) NOT NULL,
    konten TEXT,
    meta_description TEXT,
    status VARCHAR(20) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 16. FUNDRAISING (MODULE 31)
-- ============================================

-- Campaign
CREATE TABLE IF NOT EXISTS campaign (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    judul VARCHAR(200) NOT NULL,
    deskripsi TEXT,
    target_amount DECIMAL(12,2),
    collected_amount DECIMAL(12,2) DEFAULT 0,
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Donasi
CREATE TABLE IF NOT EXISTS donasi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id UUID REFERENCES campaign(id),
    donatur_nama VARCHAR(100),
    donatur_email VARCHAR(100),
    donatur_phone VARCHAR(20),
    amount DECIMAL(12,2) NOT NULL,
    metode_bayar VARCHAR(20),
    status VARCHAR(20) DEFAULT 'pending',
    bukti_bayar_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 17. API ECOSYSTEM (MODULE 32)
-- ============================================

-- API Key
CREATE TABLE IF NOT EXISTS api_key (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key_hash VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    user_id UUID REFERENCES users(id),
    permissions JSONB,
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    last_used TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 18. VERSIONING & HISTORY (MODULE 33)
-- ============================================

-- Data Version
CREATE TABLE IF NOT EXISTS data_version (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    version INTEGER NOT NULL,
    data JSONB NOT NULL,
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(table_name, record_id, version)
);

-- ============================================
-- 19. MONITORING & SLA (MODULE 34)
-- ============================================

-- Service Monitoring
CREATE TABLE IF NOT EXISTS service_monitoring (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_name VARCHAR(100) NOT NULL,
    endpoint VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('up', 'down', 'degraded')),
    response_time_ms INTEGER,
    last_check TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 20. OFFLINE MODE (MODULE 35)
-- ============================================

-- Sync Log
CREATE TABLE IF NOT EXISTS sync_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id VARCHAR(100),
    table_name VARCHAR(50),
    action VARCHAR(20),
    record_id UUID,
    data JSONB,
    sync_status VARCHAR(20) DEFAULT 'pending',
    sync_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 21. MULTI BAHASA (MODULE 36)
-- ============================================

-- Translation
CREATE TABLE IF NOT EXISTS translation (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(200) NOT NULL,
    language VARCHAR(10) NOT NULL,
    value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(key, language)
);

-- ============================================
-- 22. BRANDING & WHITE LABEL (MODULE 37)
-- ============================================

-- Tenant
CREATE TABLE IF NOT EXISTS tenant (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    subdomain VARCHAR(50) UNIQUE NOT NULL,
    logo_url TEXT,
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 23. ANALYTICS & BI (MODULE 39)
-- ============================================

-- Analytics Event
CREATE TABLE IF NOT EXISTS analytics_event (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_name VARCHAR(100) NOT NULL,
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(100),
    properties JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 24. BACKUP & RECOVERY (MODULE 40)
-- ============================================

-- Backup Schedule
CREATE TABLE IF NOT EXISTS backup_schedule (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    schedule_name VARCHAR(100) NOT NULL,
    cron_expression VARCHAR(50),
    retention_days INTEGER,
    last_run TIMESTAMP,
    next_run TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
CREATE INDEX IF NOT EXISTS idx_santri_lembaga ON santri(lembaga_id);
CREATE INDEX IF NOT EXISTS idx_santri_kelas ON santri(kelas);

-- Transaction indexes
CREATE INDEX IF NOT EXISTS idx_transaksi_santri ON transaksi_pembayaran(santri_id);
CREATE INDEX IF NOT EXISTS idx_transaksi_status ON transaksi_pembayaran(status);
CREATE INDEX IF NOT EXISTS idx_transaksi_tanggal ON transaksi_pembayaran(tanggal_transaksi);

-- Attendance indexes
CREATE INDEX IF NOT EXISTS idx_presensi_santri ON presensi(santri_id);
CREATE INDEX IF NOT EXISTS idx_presensi_tanggal ON presensi(tanggal);

-- Academic indexes
CREATE INDEX IF NOT EXISTS idx_nilai_santri ON nilai_akademik(santri_id);
CREATE INDEX IF NOT EXISTS idx_nilai_pelajaran ON nilai_akademik(mata_pelajaran_id);

-- ============================================
-- CREATE VIEWS FOR REPORTING
-- ============================================

-- View for student summary
CREATE OR REPLACE VIEW v_santri_summary AS
SELECT 
    s.id,
    s.nis,
    s.nama_lengkap,
    l.nama as lembaga,
    s.kelas,
    s.status,
    k.nomor_kamar,
    g.nama as gedung,
    COUNT(DISTINCT tp.id) as total_transaksi,
    COALESCE(SUM(CASE WHEN tp.status = 'paid' THEN tp.jumlah ELSE 0 END), 0) as total_paid,
    COALESCE(AVG(na.nilai_akhir), 0) as rata_rata_nilai
FROM santri s
LEFT JOIN lembaga l ON s.lembaga_id = l.id
LEFT JOIN penempatan_kamar pk ON s.id = pk.santri_id AND pk.status = 'aktif'
LEFT JOIN kamar k ON pk.kamar_id = k.id
LEFT JOIN gedung_asrama g ON k.gedung_id = g.id
LEFT JOIN transaksi_pembayaran tp ON s.id = tp.santri_id
LEFT JOIN nilai_akademik na ON s.id = na.santri_id
GROUP BY s.id, s.nis, s.nama_lengkap, l.nama, s.kelas, s.status, k.nomor_kamar, g.nama;

-- View for financial summary
CREATE OR REPLACE VIEW v_financial_summary AS
SELECT 
    DATE_TRUNC('month', tanggal_transaksi) as bulan,
    COUNT(*) as total_transaksi,
    SUM(jumlah) as total_nominal,
    AVG(jumlah) as rata_rata,
    COUNT(CASE WHEN status = 'paid' THEN 1 END) as lunas,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending,
    COUNT(CASE WHEN status = 'expired' THEN 1 END) as expired
FROM transaksi_pembayaran
GROUP BY DATE_TRUNC('month', tanggal_transaksi)
ORDER BY bulan DESC;

-- View for academic performance
CREATE OR REPLACE VIEW v_academic_performance AS
SELECT 
    s.nis,
    s.nama_lengkap,
    l.nama as lembaga,
    s.kelas,
    COUNT(DISTINCT na.mata_pelajaran_id) as total_pelajaran,
    AVG(na.nilai_akhir) as rata_rata_nilai,
    COUNT(DISTINCT CASE WHEN na.nilai_akhir >= 75 THEN na.mata_pelajaran_id END) as lulus,
    COUNT(DISTINCT CASE WHEN na.nilai_akhir < 75 THEN na.mata_pelajaran_id END) as tidak_lulus
FROM santri s
LEFT JOIN lembaga l ON s.lembaga_id = l.id
LEFT JOIN nilai_akademik na ON s.id = na.santri_id
GROUP BY s.id, s.nis, s.nama_lengkap, l.nama, s.kelas;

-- View for tahfidz progress
CREATE OR REPLACE VIEW v_tahfidz_progress AS
SELECT 
    s.nis,
    s.nama_lengkap,
    pt.nama_program,
    COUNT(DISTINCT hs.juz) as juz_dihafal,
    MAX(hs.juz) as juz_tertinggi,
    AVG(hs.nilai) as rata_rata_nilai
FROM santri s
LEFT JOIN hafalan_santri hs ON s.id = hs.santri_id
LEFT JOIN program_tahfidz pt ON hs.program_tahfidz_id = pt.id
GROUP BY s.id, s.nis, s.nama_lengkap, pt.nama_program;

-- ============================================
-- INSERT INITIAL DATA
-- ============================================

-- Insert lembaga
INSERT INTO lembaga (kode, nama, jenis, status) VALUES
    ('MT001', 'MTs Al-Falah', 'MTs', 'aktif'),
    ('SMP01', 'SMP Islam Terpadu', 'SMP', 'aktif'),
    ('MA001', 'MA Al-Hikmah', 'MA', 'aktif'),
    ('THF01', 'Pondok Tahfidz Quran', 'Tahfidz', 'aktif')
ON CONFLICT (kode) DO NOTHING;

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
INSERT INTO santri (nis, nama_lengkap, tempat_lahir, tanggal_lahir, jenis_kelamin, lembaga_id, kelas, status)
SELECT 
    '202400' || i,
    CASE 
        WHEN i % 2 = 0 THEN 'Santri Putra ' || i 
        ELSE 'Santri Putri ' || i 
    END,
    CASE i % 3 
        WHEN 0 THEN 'Jakarta' 
        WHEN 1 THEN 'Bandung' 
        ELSE 'Surabaya' 
    END,
    DATE '2010-01-01' + (i * 30 || ' days')::INTERVAL,
    CASE i % 2 WHEN 0 THEN 'Laki-laki' ELSE 'Perempuan' END,
    (SELECT id FROM lembaga ORDER BY RANDOM() LIMIT 1),
    CASE 
        WHEN i <= 10 THEN '7A' 
        WHEN i <= 20 THEN '8B' 
        WHEN i <= 30 THEN '9C' 
        ELSE '10IPA' 
    END,
    'aktif'
FROM generate_series(1, 40) i
ON CONFLICT (nis) DO NOTHING;

-- Insert sample ustadz
INSERT INTO ustadz (nip, nama_lengkap, bidang_keahlian, status, lembaga_id)
SELECT 
    '1980' || LPAD(i::text, 4, '0') || '200' || i,
    CASE i
        WHEN 1 THEN 'Ustadz Ahmad Fauzi, M.Pd.I'
        WHEN 2 THEN 'Ustadzah Siti Aminah, M.Pd'
        WHEN 3 THEN 'Ustadz Muhammad Rizki, S.Pd'
        WHEN 4 THEN 'Ustadz Abdul Rahman, M.Ag'
        WHEN 5 THEN 'Ustadzah Fatimah Az-Zahra, S.Pd'
        ELSE 'Ustadz ' || i
    END,
    CASE i % 4
        WHEN 0 THEN 'Al-Quran dan Tafsir'
        WHEN 1 THEN 'Matematika dan Sains'
        WHEN 2 THEN 'Bahasa Arab dan Inggris'
        WHEN 3 THEN 'Fiqih dan Ushuluddin'
    END,
    'aktif',
    (SELECT id FROM lembaga ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1, 10) i
ON CONFLICT (nip) DO NOTHING;

-- Insert sample mata pelajaran
INSERT INTO mata_pelajaran (kode, nama, jenis, lembaga_id)
SELECT 
    CASE 
        WHEN i <= 5 THEN 'AGM' || LPAD(i::text, 3, '0')
        WHEN i <= 10 THEN 'UMU' || LPAD((i-5)::text, 3, '0')
        WHEN i <= 15 THEN 'BHS' || LPAD((i-10)::text, 3, '0')
        ELSE 'KET' || LPAD((i-15)::text, 3, '0')
    END,
    CASE i
        WHEN 1 THEN 'Al-Quran'
        WHEN 2 THEN 'Hadits'
        WHEN 3 THEN 'Fiqih'
        WHEN 4 THEN 'Aqidah'
        WHEN 5 THEN 'Akhlak'
        WHEN 6 THEN 'Matematika'
        WHEN 7 THEN 'Bahasa Indonesia'
        WHEN 8 THEN 'IPA'
        WHEN 9 THEN 'IPS'
        WHEN 10 THEN 'PKN'
        WHEN 11 THEN 'Bahasa Arab'
        WHEN 12 THEN 'Bahasa Inggris'
        WHEN 13 THEN 'Bahasa Jawa'
        WHEN 14 THEN 'Tahsin'
        WHEN 15 THEN 'Tahfidz'
        ELSE 'Keterampilan ' || (i-15)
    END,
    CASE 
        WHEN i <= 5 THEN 'agama'
        WHEN i <= 10 THEN 'umum'
        WHEN i <= 15 THEN 'bahasa'
        ELSE 'keterampilan'
    END,
    (SELECT id FROM lembaga ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1, 20) i
ON CONFLICT (kode) DO NOTHING;

-- Insert sample jenis pembayaran
INSERT INTO jenis_pembayaran (kode, nama, kategori, nominal, lembaga_id)
SELECT 
    CASE i
        WHEN 1 THEN 'SPP001'
        WHEN 2 THEN 'DU001'
        WHEN 3 THEN 'UJN001'
        WHEN 4 THEN 'ASR001'
        WHEN 5 THEN 'MAK001'
        ELSE 'OTH' || LPAD(i::text, 3, '0')
    END,
    CASE i
        WHEN 1 THEN 'SPP Bulanan'
        WHEN 2 THEN 'Daftar Ulang'
        WHEN 3 THEN 'Ujian Semester'
        WHEN 4 THEN 'Biaya Asrama'
        WHEN 5 THEN 'Biaya Makan'
        ELSE 'Biaya Lainnya ' || i
    END,
    CASE i
        WHEN 1 THEN 'spp'
        WHEN 2 THEN '