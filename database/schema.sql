-- 🕌 Database Schema for Pondok Pesantren Management System
-- Version: 1.0.0
-- Created: 2026-04-04

-- ============================================
-- 1. MANAJEMEN DATA MASTER
-- ============================================

-- Tabel Tahun Ajaran
CREATE TABLE tahun_ajaran (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(10) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif', 'draft')) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Kurikulum
CREATE TABLE kurikulum (
    id SERIAL PRIMARY KEY,
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Mata Pelajaran
CREATE TABLE mata_pelajaran (
    id SERIAL PRIMARY KEY,
    kurikulum_id INTEGER REFERENCES kurikulum(id),
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(50) CHECK (jenis IN ('wajib', 'pilihan', 'ekstra', 'hafalan')),
    bobot_sks INTEGER DEFAULT 1,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Gedung
CREATE TABLE gedung (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(10) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    alamat TEXT,
    lantai INTEGER DEFAULT 1,
    kapasitas INTEGER,
    fasilitas TEXT,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif', 'renovasi')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Asrama
CREATE TABLE asrama (
    id SERIAL PRIMARY KEY,
    gedung_id INTEGER REFERENCES gedung(id),
    kode VARCHAR(10) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis VARCHAR(50) CHECK (jenis IN ('putra', 'putri', 'campur')),
    kapasitas INTEGER NOT NULL,
    terisi INTEGER DEFAULT 0,
    pengurus_id INTEGER, -- akan di-reference ke tabel ustadz
    status VARCHAR(20) CHECK (status IN ('aktif', 'penuh', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Kamar
CREATE TABLE kamar (
    id SERIAL PRIMARY KEY,
    asrama_id INTEGER REFERENCES asrama(id),
    nomor_kamar VARCHAR(10) NOT NULL,
    kapasitas INTEGER NOT NULL,
    terisi INTEGER DEFAULT 0,
    fasilitas TEXT,
    status VARCHAR(20) CHECK (status IN ('tersedia', 'penuh', 'maintenance')) DEFAULT 'tersedia',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(asrama_id, nomor_kamar)
);

-- ============================================
-- 2. DATA SANTRI, WALI, USTADZ, STAF
-- ============================================

-- Tabel Santri
CREATE TABLE santri (
    id SERIAL PRIMARY KEY,
    nis VARCHAR(20) UNIQUE NOT NULL,
    nisn VARCHAR(20),
    nik VARCHAR(20),
    nama_lengkap VARCHAR(200) NOT NULL,
    nama_panggilan VARCHAR(100),
    tempat_lahir VARCHAR(100),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(10) CHECK (jenis_kelamin IN ('L', 'P')),
    agama VARCHAR(20),
    alamat TEXT,
    provinsi VARCHAR(100),
    kabupaten VARCHAR(100),
    kecamatan VARCHAR(100),
    desa VARCHAR(100),
    rt VARCHAR(5),
    rw VARCHAR(5),
    kode_pos VARCHAR(10),
    no_hp VARCHAR(20),
    email VARCHAR(100),
    foto_path VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('aktif', 'alumni', 'pindah', 'keluar', 'nonaktif')) DEFAULT 'aktif',
    tanggal_masuk DATE,
    tanggal_keluar DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Wali Santri
CREATE TABLE wali_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    hubungan VARCHAR(50) CHECK (hubungan IN ('ayah', 'ibu', 'wali', 'saudara')),
    nama_lengkap VARCHAR(200) NOT NULL,
    nik VARCHAR(20),
    pekerjaan VARCHAR(100),
    pendidikan VARCHAR(100),
    penghasilan DECIMAL(15,2),
    no_hp VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    alamat TEXT,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Ustadz/Pengajar
CREATE TABLE ustadz (
    id SERIAL PRIMARY KEY,
    nip VARCHAR(20) UNIQUE,
    nik VARCHAR(20),
    nama_lengkap VARCHAR(200) NOT NULL,
    gelar_depan VARCHAR(50),
    gelar_belakang VARCHAR(50),
    tempat_lahir VARCHAR(100),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(10) CHECK (jenis_kelamin IN ('L', 'P')),
    agama VARCHAR(20),
    alamat TEXT,
    no_hp VARCHAR(20),
    email VARCHAR(100),
    pendidikan_terakhir VARCHAR(100),
    bidang_keahlian TEXT,
    tanggal_masuk DATE,
    status VARCHAR(20) CHECK (status IN ('aktif', 'pensiun', 'keluar', 'nonaktif')) DEFAULT 'aktif',
    foto_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Staf/Admin
CREATE TABLE staf (
    id SERIAL PRIMARY KEY,
    nip VARCHAR(20) UNIQUE,
    nik VARCHAR(20),
    nama_lengkap VARCHAR(200) NOT NULL,
    jabatan VARCHAR(100),
    divisi VARCHAR(100),
    no_hp VARCHAR(20),
    email VARCHAR(100),
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    foto_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. KELAS & HALAQAH
-- ============================================

-- Tabel Kelas
CREATE TABLE kelas (
    id SERIAL PRIMARY KEY,
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    kode VARCHAR(10) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    tingkat INTEGER,
    wali_kelas_id INTEGER REFERENCES ustadz(id),
    kapasitas INTEGER,
    terisi INTEGER DEFAULT 0,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Halaqah (Kelompok Tahfidz)
CREATE TABLE halaqah (
    id SERIAL PRIMARY KEY,
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    kode VARCHAR(10) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    pembimbing_id INTEGER REFERENCES ustadz(id),
    tingkat_hafalan VARCHAR(50),
    jadwal_hari VARCHAR(20),
    jadwal_waktu TIME,
    lokasi VARCHAR(100),
    kapasitas INTEGER,
    terisi INTEGER DEFAULT 0,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 4. PENDAFTARAN SANTRI BARU (PSB)
-- ============================================

-- Tabel Pendaftaran
CREATE TABLE pendaftaran (
    id SERIAL PRIMARY KEY,
    no_pendaftaran VARCHAR(20) UNIQUE NOT NULL,
    tanggal_daftar DATE DEFAULT CURRENT_DATE,
    nama_calon_santri VARCHAR(200) NOT NULL,
    tempat_lahir VARCHAR(100),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(10) CHECK (jenis_kelamin IN ('L', 'P')),
    alamat TEXT,
    asal_sekolah VARCHAR(100),
    no_hp VARCHAR(20),
    email VARCHAR(100),
    nama_wali VARCHAR(200),
    no_hp_wali VARCHAR(20),
    program_pilihan VARCHAR(100),
    status VARCHAR(20) CHECK (status IN ('baru', 'verifikasi', 'test', 'wawancara', 'diterima', 'ditolak', 'daftar_ulang')) DEFAULT 'baru',
    tanggal_test DATE,
    nilai_test DECIMAL(5,2),
    tanggal_wawancara DATE,
    hasil_wawancara TEXT,
    tanggal_pengumuman DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Dokumen Pendaftaran
CREATE TABLE dokumen_pendaftaran (
    id SERIAL PRIMARY KEY,
    pendaftaran_id INTEGER REFERENCES pendaftaran(id),
    jenis_dokumen VARCHAR(100),
    nama_file VARCHAR(255),
    path_file VARCHAR(500),
    status_verifikasi VARCHAR(20) CHECK (status_verifikasi IN ('belum', 'diverifikasi', 'ditolak')) DEFAULT 'belum',
    catatan TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP,
    verified_by INTEGER REFERENCES staf(id)
);

-- ============================================
-- 5. AKADEMIK & PEMBELAJARAN
-- ============================================

-- Tabel Jadwal Pelajaran
CREATE TABLE jadwal_pelajaran (
    id SERIAL PRIMARY KEY,
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    kelas_id INTEGER REFERENCES kelas(id),
    mata_pelajaran_id INTEGER REFERENCES mata_pelajaran(id),
    ustadz_id INTEGER REFERENCES ustadz(id),
    hari VARCHAR(10) CHECK (hari IN ('senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu')),
    jam_mulai TIME NOT NULL,
    jam_selesai TIME NOT NULL,
    ruangan VARCHAR(50),
    status VARCHAR(20) CHECK (status IN ('aktif', 'libur', 'ganti')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Presensi Santri
CREATE TABLE presensi_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    jadwal_pelajaran_id INTEGER REFERENCES jadwal_pelajaran(id),
    tanggal DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) CHECK (status IN ('hadir', 'izin', 'sakit', 'alpha', 'terlambat')),
    waktu_masuk TIME,
    waktu_keluar TIME,
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, jadwal_pelajaran_id, tanggal)
);

-- Tabel Presensi Ustadz
CREATE TABLE presensi_ustadz (
    id SERIAL PRIMARY KEY,
    ustadz_id INTEGER REFERENCES ustadz(id),
    jadwal_pelajaran_id INTEGER REFERENCES jadwal_pelajaran(id),
    tanggal DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) CHECK (status IN ('hadir', 'izin', 'sakit', 'alpha', 'terlambat')),
    waktu_masuk TIME,
    waktu_keluar TIME,
    pengganti_id INTEGER REFERENCES ustadz(id),
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Penilaian
CREATE TABLE penilaian (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    mata_pelajaran_id INTEGER REFERENCES mata_pelajaran(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    semester INTEGER CHECK (semester IN (1, 2)),
    jenis_nilai VARCHAR(50) CHECK (jenis_nilai IN ('harian', 'uts', 'uas', 'praktikum', 'proyek')),
    nilai DECIMAL(5,2),
    bobot DECIMAL(3,2) DEFAULT 1.0,
    created_by INTEGER REFERENCES ustadz(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Raport
CREATE TABLE raport (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    semester INTEGER CHECK (semester IN (1, 2)),
    rata_rata DECIMAL(5,2),
    ranking INTEGER,
    catatan_wali_kelas TEXT,
    status VARCHAR(20) CHECK (status IN ('draft', 'final', 'dicetak')) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, tahun_ajaran_id, semester)
);

-- Tabel Monitoring Hafalan
CREATE TABLE monitoring_hafalan (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    halaqah_id INTEGER REFERENCES halaqah(id),
    tanggal DATE DEFAULT CURRENT_DATE,
    surat_mulai VARCHAR(100),
    ayat_mulai INTEGER,
    surat_selesai VARCHAR(100),
    ayat_selesai INTEGER,
    metode VARCHAR(50) CHECK (metode IN ('setoran', 'murojaah', 'tasmi')),
    nilai INTEGER CHECK (nilai BETWEEN 1 AND 100),
    catatan TEXT,
    diperiksa_oleh INTEGER REFERENCES ustadz(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 6. KEUANGAN
-- ============================================

-- Tabel Jenis Pembayaran
CREATE TABLE jenis_pembayaran (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    kategori VARCHAR(50) CHECK (kategori IN ('spp', 'pendaftaran', 'uang_bangunan', 'seragam', 'buku', 'lainnya')),
    nominal DECIMAL(15,2) NOT NULL,
    periode VARCHAR(20) CHECK (periode IN ('bulanan', 'tahunan', 'sekali', 'custom')),
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Tagihan
CREATE TABLE tagihan (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    jenis_pembayaran_id INTEGER REFERENCES jenis_pembayaran(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    bulan INTEGER CHECK (bulan BETWEEN 1 AND 12),
    tahun INTEGER,
    nominal DECIMAL(15,2) NOT NULL,
    jatuh_tempo DATE,
    status VARCHAR(20) CHECK (status IN ('belum_bayar', 'lunas', 'sebagian', 'dibatalkan')) DEFAULT 'belum_bayar',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, jenis_pembayaran_id, tahun_ajaran_id, bulan, tahun)
);

-- Tabel Pembayaran
CREATE TABLE pembayaran (
    id SERIAL PRIMARY KEY,
    tagihan_id INTEGER REFERENCES tagihan(id),
    no_transaksi VARCHAR(50) UNIQUE NOT NULL,
    tanggal_bayar DATE DEFAULT CURRENT_DATE,
    metode_bayar VARCHAR(50) CHECK (metode_bayar IN ('tunai', 'transfer', 'qris', 'ewallet', 'va')),
    bank VARCHAR(100),
    no_referensi VARCHAR(100),
    nominal_bayar DECIMAL(15,2) NOT NULL,
    keterangan TEXT,
    verified_by INTEGER REFERENCES staf(id),
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Donasi
CREATE TABLE donasi (
    id SERIAL PRIMARY KEY,
    no_donasi VARCHAR(50) UNIQUE NOT NULL,
    donatur_nama VARCHAR(200),
    donatur_no_hp VARCHAR(20),
    donatur_email VARCHAR(100),
    jenis_donasi VARCHAR(100),
    nominal DECIMAL(15,2) NOT NULL,
    metode_bayar VARCHAR(50),
    status VARCHAR(20) CHECK (status IN ('pending', 'lunas', 'dibatalkan')) DEFAULT 'pending',
    doa TEXT,
    anonim BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 7. ASRAMA & DISIPLIN
-- ============================================

-- Tabel Penempatan Kamar
CREATE TABLE penempatan_kamar (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    kamar_id INTEGER REFERENCES kamar(id),
    tanggal_masuk DATE DEFAULT CURRENT_DATE,
