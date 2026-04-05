-- 🏫 DATABASE SCHEMA SISTEM PESANTREN MULTI-LEMBAGA
-- Versi: 2.0 (40 Modul Terupdate)
-- Tanggal: 4 April 2026

-- ============================================
-- 1. TABEL CORE & AUTHENTICATION
-- ============================================

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    user_type VARCHAR(20) NOT NULL, -- ADMIN, SANTRI, WALI, USTADZ, GURU, STAFF
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE user_roles (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    module VARCHAR(50), -- Modul sistem
    description TEXT
);

CREATE TABLE role_permissions (
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- ============================================
-- 2. TABEL LEMBAGA & STRUKTUR MULTI-LEMBAGA
-- ============================================

CREATE TABLE lembaga (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(10) UNIQUE NOT NULL, -- MTS, SMP, MA, TAHFIDZ
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(20) NOT NULL, -- FORMAL, DINIAH, TAHFIDZ
    kementerian VARCHAR(50), -- KEMENAG, KEMENDIKBUD, NULL
    alamat TEXT,
    telepon VARCHAR(20),
    email VARCHAR(255),
    kepala_lembaga_id INTEGER REFERENCES users(id),
    tahun_berdiri INTEGER,
    akreditasi VARCHAR(5), -- A, B, C
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tahun_ajaran (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(9) UNIQUE NOT NULL, -- 2024/2025
    nama VARCHAR(50) NOT NULL,
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE NOT NULL,
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE semester (
    id SERIAL PRIMARY KEY,
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    nama VARCHAR(20) NOT NULL, -- GANJIL, GENAP
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE NOT NULL,
    is_active BOOLEAN DEFAULT false
);

-- ============================================
-- 3. TABEL SANTRI & KELUARGA
-- ============================================

CREATE TABLE santri (
    id SERIAL PRIMARY KEY,
    nis VARCHAR(20) UNIQUE NOT NULL,
    nisn VARCHAR(10) UNIQUE, -- Untuk integrasi Dapodik
    nama_lengkap VARCHAR(200) NOT NULL,
    nama_panggilan VARCHAR(50),
    tempat_lahir VARCHAR(100),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(10) CHECK (jenis_kelamin IN ('LAKI-LAKI', 'PEREMPUAN')),
    agama VARCHAR(20) DEFAULT 'ISLAM',
    alamat TEXT,
    rt_rw VARCHAR(10),
    kelurahan VARCHAR(100),
    kecamatan VARCHAR(100),
    kota VARCHAR(100),
    provinsi VARCHAR(100),
    kode_pos VARCHAR(10),
    telepon VARCHAR(20),
    email VARCHAR(255),
    foto_url VARCHAR(500),
    golongan_darah VARCHAR(5),
    riwayat_penyakit TEXT,
    alergi TEXT,
    status VARCHAR(20) DEFAULT 'AKTIF' CHECK (status IN ('AKTIF', 'ALUMNI', 'KELUAR', 'MUTASI')),
    tanggal_masuk DATE,
    tanggal_keluar DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wali_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    nama VARCHAR(200) NOT NULL,
    hubungan VARCHAR(20) NOT NULL, -- AYAH, IBU, WALI
    pekerjaan VARCHAR(100),
    pendidikan VARCHAR(50),
    telepon VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    alamat TEXT,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE santri_lembaga (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    kelas VARCHAR(20), -- X, XI, XII atau 7, 8, 9
    rombel VARCHAR(10), -- A, B, C
    status VARCHAR(20) DEFAULT 'AKTIF' CHECK (status IN ('AKTIF', 'PINDAH', 'DO', 'LULUS')),
    tanggal_daftar DATE DEFAULT CURRENT_DATE,
    tanggal_selesai DATE,
    catatan TEXT,
    UNIQUE (santri_id, lembaga_id, tahun_ajaran_id)
);

-- ============================================
-- 4. TABEL AKADEMIK FORMAL (MTs/SMP/MA)
-- ============================================

CREATE TABLE mata_pelajaran_formal (
    id SERIAL PRIMARY KEY,
    lembaga_id INTEGER REFERENCES lembaga(id),
    kode_mapel VARCHAR(10) NOT NULL,
    nama_mapel VARCHAR(100) NOT NULL,
    kelompok VARCHAR(20), -- UMUM, KEAGAMAAN, PILIHAN
    kkm INTEGER DEFAULT 75,
    bobot INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    UNIQUE (lembaga_id, kode_mapel)
);

CREATE TABLE guru_formal (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    nip VARCHAR(20) UNIQUE,
    nuptk VARCHAR(20) UNIQUE,
    bidang_studi VARCHAR(100),
    status_kepegawaian VARCHAR(50), -- PNS, NON-PNS, HONORER
    tanggal_mulai DATE,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE kelas_formal (
    id SERIAL PRIMARY KEY,
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    tingkat VARCHAR(10) NOT NULL, -- 7, 8, 9 atau X, XI, XII
    rombel VARCHAR(10) NOT NULL, -- A, B, C
    wali_kelas_id INTEGER REFERENCES guru_formal(id),
    kapasitas INTEGER DEFAULT 30,
    is_active BOOLEAN DEFAULT true,
    UNIQUE (lembaga_id, tahun_ajaran_id, tingkat, rombel)
);

CREATE TABLE jadwal_pelajaran (
    id SERIAL PRIMARY KEY,
    kelas_formal_id INTEGER REFERENCES kelas_formal(id),
    mata_pelajaran_id INTEGER REFERENCES mata_pelajaran_formal(id),
    guru_id INTEGER REFERENCES guru_formal(id),
    hari VARCHAR(10) CHECK (hari IN ('SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU')),
    jam_mulai TIME NOT NULL,
    jam_selesai TIME NOT NULL,
    ruangan VARCHAR(50),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE nilai_formal (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    mata_pelajaran_id INTEGER REFERENCES mata_pelajaran_formal(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    semester VARCHAR(10) CHECK (semester IN ('GANJIL', 'GENAP')),
    nilai_uh1 DECIMAL(5,2),
    nilai_uh2 DECIMAL(5,2),
    nilai_uh3 DECIMAL(5,2),
    nilai_uts DECIMAL(5,2),
    nilai_uas DECIMAL(5,2),
    nilai_akhir DECIMAL(5,2),
    predikat VARCHAR(2), -- A, B, C, D
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, mata_pelajaran_id, tahun_ajaran_id, semester)
);

-- ============================================
-- 5. TABEL AKADEMIK DINIAH & PESANTREN
-- ============================================

CREATE TABLE kitab (
    id SERIAL PRIMARY KEY,
    kode_kitab VARCHAR(20) UNIQUE NOT NULL,
    nama_kitab VARCHAR(200) NOT NULL,
    pengarang VARCHAR(100),
    tingkat VARCHAR(20), -- DASAR, MENENGAH, LANJUT
    estimasi_waktu INTEGER, -- dalam jam
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE ustadz_diniyah (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    spesialisasi TEXT, -- FIQIH, AQIDAH, BAHASA ARAB, DLL
    pengalaman INTEGER, -- dalam tahun
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE halaqah (
    id SERIAL PRIMARY KEY,
    nama_halaqah VARCHAR(100) NOT NULL,
    ustadz_id INTEGER REFERENCES ustadz_diniyah(id),
    tingkat VARCHAR(20), -- DASAR, MENENGAH, LANJUT
    kapasitas INTEGER DEFAULT 20,
    lokasi VARCHAR(100),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE santri_halaqah (
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    halaqah_id INTEGER REFERENCES halaqah(id) ON DELETE CASCADE,
    tanggal_gabung DATE DEFAULT CURRENT_DATE,
    tanggal_keluar DATE,
    status VARCHAR(20) DEFAULT 'AKTIF',
    PRIMARY KEY (santri_id, halaqah_id)
);

CREATE TABLE jadwal_halaqah (
    id SERIAL PRIMARY KEY,
    halaqah_id INTEGER REFERENCES halaqah(id),
    kitab_id INTEGER REFERENCES kitab(id),
    hari VARCHAR(10) CHECK (hari IN ('SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'AHAD')),
    jam_mulai TIME NOT NULL,
    jam_selesai TIME NOT NULL,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE nilai_diniyah (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    kitab_id INTEGER REFERENCES kitab(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    semester VARCHAR(10) CHECK (semester IN ('GANJIL', 'GENAP')),
    nilai_hafalan DECIMAL(5,2),
    nilai_pemahaman DECIMAL(5,2),
    nilai_praktek DECIMAL(5,2),
    nilai_akhir DECIMAL(5,2),
    predikat VARCHAR(2),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, kitab_id, tahun_ajaran_id, semester)
);

-- ============================================
-- 6. TABEL MODUL TAHFIDZ KHUSUS (CORE SYSTEM)
-- ============================================

CREATE TABLE tahfidz_program (
    id SERIAL PRIMARY KEY,
    nama_program VARCHAR(100) NOT NULL, -- TAHFIDZ 1 TAHUN, 2 TAHUN, 3 TAHUN
    target_juz INTEGER NOT NULL, -- 30, 20, 10
    durasi_bulan INTEGER NOT NULL,
    biaya DECIMAL(12,2),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE santri_tahfidz (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    program_id INTEGER REFERENCES tahfidz_program(id),
    tanggal_mulai DATE NOT NULL,
    tanggal_target DATE NOT NULL,
    target_juz INTEGER NOT NULL CHECK (target_juz BETWEEN 1 AND 30),
    status VARCHAR(20) DEFAULT 'AKTIF' CHECK (status IN ('AKTIF', 'SELESAI', 'BERHENTI')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tahfidz_target_harian (
    id SERIAL PRIMARY KEY,
    santri_tahfidz_id INTEGER REFERENCES santri_tahfidz(id),
    tanggal DATE NOT NULL,
    target_halaman INTEGER NOT NULL CHECK (target_halaman BETWEEN 1 AND 604),
    target_juz INTEGER NOT NULL CHECK (target_juz BETWEEN 1 AND 30),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SELESAI', 'TERLEWAT')),
    UNIQUE (santri_tahfidz_id, tanggal)
);

CREATE TABLE tahfidz_setoran (
    id SERIAL PRIMARY KEY,
    santri_tahfidz_id INTEGER REFERENCES santri_tahfidz(id),
    tanggal DATE NOT NULL,
    waktu TIME NOT NULL,
    juz INTEGER NOT NULL CHECK (juz BETWEEN 1 AND 30),
    halaman_mulai INTEGER NOT NULL CHECK (halaman_mulai BETWEEN 1 AND 604),
    halaman_selesai INTEGER NOT NULL CHECK (halaman_selesai BETWEEN 1 AND 604),
    metode VARCHAR(20) NOT NULL CHECK (metode IN ('SETORAN', 'MUROJAAH', 'TES')),
    ustadz_id INTEGER REFERENCES ustadz_diniyah(id),
    nilai_tajwid INTEGER CHECK (nilai_tajwid BETWEEN 1 AND 100),
    nilai_kelancaran INTEGER CHECK (nilai_kelancaran BETWEEN 1 AND 100),
    nilai_makhraj INTEGER CHECK (nilai_makhraj BETWEEN 1 AND 100),
    catatan TEXT,
    status VARCHAR(20) DEFAULT 'SELESAI' CHECK (status IN ('SELESAI', 'BATAL', 'TUNDA')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tahfidz_progress (
    id SERIAL PRIMARY KEY,
    santri_tahfidz_id INTEGER REFERENCES santri_tahfidz(id),
    tanggal DATE NOT NULL,
    total_halaman_terhafal INTEGER DEFAULT 0,
    total_juz_terhafal INTEGER DEFAULT 0,
    halaman_terakhir INTEGER,
    juz_terakhir INTEGER,
    streak_hari INTEGER DEFAULT 0, -- hari berturut-turut setoran
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_tahfidz_id, tanggal)
);

CREATE TABLE tahfidz_murojaah (
    id SERIAL PRIMARY KEY,
    santri_tahfidz_id INTEGER REFERENCES santri_tahfidz(id),
    tanggal DATE NOT NULL,
    juz INTEGER NOT NULL CHECK (juz BETWEEN 1 AND 30),
    halaman_mulai INTEGER NOT NULL,
    halaman_selesai INTEGER NOT NULL,
    metode VARCHAR(20), -- DENGAR, BACA, TES
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 7. TABEL JADWAL TERPADU (FORMAL + DINIAH + TAHFIDZ)
-- ============================================

CREATE TABLE jadwal_terpadu (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal DATE NOT NULL,
    jenis_aktivitas VARCHAR(20) NOT NULL CHECK (jenis_aktivitas IN ('FORMAL', 'DINIAH', 'TAHFIDZ', 'ISTIRAHAT', 'IBADAH')),
    waktu_mulai TIME NOT NULL,
    waktu_selesai TIME NOT NULL,
    deskripsi TEXT,
    lokasi VARCHAR(100),
    is_bentrok BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE konflik_jadwal (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal DATE NOT NULL,
    waktu_mulai TIME NOT NULL,
    waktu_selesai TIME NOT NULL,
    aktivitas_1 VARCHAR(100),
    aktivitas_2 VARCHAR(100),
    severity VARCHAR(20) CHECK (severity IN ('RINGAN', 'SEDANG', 'BERAT')),
    status VARCHAR(20) DEFAULT 'TERDETEKSI' CHECK (status IN ('TERDETEKSI', 'TERSELESAIKAN', 'DIABAIKAN')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 8. TABEL KEUANGAN TERINTEGRASI
-- ============================================

CREATE TABLE jenis_pembayaran (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(20) CHECK (jenis IN ('SPP', 'SYAHRIYAH', 'TAHFIDZ', 'LAINNYA')),
    lembaga_id INTEGER REFERENCES lembaga(id), -- NULL jika untuk semua lembaga
    nominal DECIMAL(12,2) NOT NULL,
    periode VARCHAR(20), -- BULANAN, SEMESTER, TAHUNAN
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE tagihan (
    id SERIAL PRIMARY KEY,
