-- ============================================
-- 8. TABEL KEUANGAN TERINTEGRASI (Lanjutan)
-- ============================================

CREATE TABLE tagihan (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    jenis_pembayaran_id INTEGER REFERENCES jenis_pembayaran(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    periode VARCHAR(20), -- JANUARI 2025, SEMESTER GANJIL
    nominal DECIMAL(12,2) NOT NULL,
    tanggal_jatuh_tempo DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'BELUM_BAYAR' CHECK (status IN ('BELUM_BAYAR', 'LUNAS', 'TERLAMBAT', 'DIBATALKAN')),
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pembayaran (
    id SERIAL PRIMARY KEY,
    tagihan_id INTEGER REFERENCES tagihan(id),
    metode_bayar VARCHAR(20) NOT NULL CHECK (metode_bayar IN ('TUNAI', 'TRANSFER', 'QRIS', 'DEBIT')),
    nominal_bayar DECIMAL(12,2) NOT NULL,
    tanggal_bayar DATE NOT NULL,
    waktu_bayar TIME NOT NULL,
    bukti_bayar_url VARCHAR(500),
    verified_by INTEGER REFERENCES users(id),
    verified_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'MENUNGGU' CHECK (status IN ('MENUNGGU', 'VERIFIED', 'DITOLAK')),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE laporan_keuangan (
    id SERIAL PRIMARY KEY,
    lembaga_id INTEGER REFERENCES lembaga(id),
    bulan INTEGER NOT NULL CHECK (bulan BETWEEN 1 AND 12),
    tahun INTEGER NOT NULL,
    total_pendapatan DECIMAL(15,2) DEFAULT 0,
    total_pengeluaran DECIMAL(15,2) DEFAULT 0,
    saldo_akhir DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'FINAL', 'DIVERIFIKASI')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (lembaga_id, bulan, tahun)
);

-- ============================================
-- 9. TABEL ASRAMA & KEHIDUPAN SANTRI
-- ============================================

CREATE TABLE gedung_asrama (
    id SERIAL PRIMARY KEY,
    nama_gedung VARCHAR(100) NOT NULL,
    jenis VARCHAR(10) CHECK (jenis IN ('PUTRA', 'PUTRI')),
    jumlah_lantai INTEGER DEFAULT 1,
    kapasitas INTEGER NOT NULL,
    lokasi VARCHAR(200),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE kamar_asrama (
    id SERIAL PRIMARY KEY,
    gedung_id INTEGER REFERENCES gedung_asrama(id),
    nomor_kamar VARCHAR(10) NOT NULL,
    lantai INTEGER DEFAULT 1,
    kapasitas INTEGER DEFAULT 4,
    fasilitas TEXT,
    is_active BOOLEAN DEFAULT true,
    UNIQUE (gedung_id, nomor_kamar)
);

CREATE TABLE penempatan_asrama (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    kamar_id INTEGER REFERENCES kamar_asrama(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    tanggal_masuk DATE DEFAULT CURRENT_DATE,
    tanggal_keluar DATE,
    status VARCHAR(20) DEFAULT 'AKTIF' CHECK (status IN ('AKTIF', 'PINDAH', 'KELUAR')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, tahun_ajaran_id)
);

CREATE TABLE aktivitas_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal DATE NOT NULL,
    jenis_aktivitas VARCHAR(50) NOT NULL, -- SHALAT, MAKAN, BELAJAR, OLAHRAGA
    waktu_mulai TIME,
    waktu_selesai TIME,
    lokasi VARCHAR(100),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pelanggaran (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal DATE NOT NULL,
    jenis_pelanggaran VARCHAR(100) NOT NULL,
    tingkat VARCHAR(20) CHECK (tingkat IN ('RINGAN', 'SEDANG', 'BERAT')),
    sanksi TEXT,
    dilaporkan_oleh INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'TERCATAT' CHECK (status IN ('TERCATAT', 'PROSES', 'SELESAI')),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 10. TABEL SDM TERPISAH & TERINTEGRASI
-- ============================================

CREATE TABLE guru_formal_detail (
    id SERIAL PRIMARY KEY,
    guru_id INTEGER REFERENCES guru_formal(id) ON DELETE CASCADE,
    lembaga_id INTEGER REFERENCES lembaga(id),
    mata_pelajaran_id INTEGER REFERENCES mata_pelajaran_formal(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    status VARCHAR(20) DEFAULT 'AKTIF',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (guru_id, lembaga_id, mata_pelajaran_id, tahun_ajaran_id)
);

CREATE TABLE ustadz_diniyah_detail (
    id SERIAL PRIMARY KEY,
    ustadz_id INTEGER REFERENCES ustadz_diniyah(id) ON DELETE CASCADE,
    halaqah_id INTEGER REFERENCES halaqah(id),
    kitab_id INTEGER REFERENCES kitab(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    status VARCHAR(20) DEFAULT 'AKTIF',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ustadz_tahfidz (
    id SERIAL PRIMARY KEY,
    ustadz_id INTEGER REFERENCES ustadz_diniyah(id) ON DELETE CASCADE,
    sertifikasi_tahfidz VARCHAR(100),
    pengalaman_tahfidz INTEGER, -- dalam tahun
    kapasitas_murid INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true
);

-- ============================================
-- 11. TABEL RAPORT TERPADU
-- ============================================

CREATE TABLE raport_formal (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    semester VARCHAR(10) CHECK (semester IN ('GANJIL', 'GENAP')),
    rata_rata_nilai DECIMAL(5,2),
    ranking INTEGER,
    catatan_wali_kelas TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'FINAL', 'DICETAK')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, lembaga_id, tahun_ajaran_id, semester)
);

CREATE TABLE raport_diniyah (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    semester VARCHAR(10) CHECK (semester IN ('GANJIL', 'GENAP')),
    total_kitab INTEGER DEFAULT 0,
    kitab_selesai TEXT,
    nilai_rata_rata DECIMAL(5,2),
    predikat VARCHAR(20),
    catatan_mudir TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, tahun_ajaran_id, semester)
);

CREATE TABLE raport_tahfidz (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    semester VARCHAR(10) CHECK (semester IN ('GANJIL', 'GENAP')),
    total_juz_terhafal INTEGER DEFAULT 0,
    total_halaman_terhafal INTEGER DEFAULT 0,
    rata_rata_nilai DECIMAL(5,2),
    ranking INTEGER,
    sertifikasi_juz INTEGER, -- Juz terakhir yang disertifikasi
    catatan_murabbi TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, tahun_ajaran_id, semester)
);

CREATE TABLE dashboard_wali (
    id SERIAL PRIMARY KEY,
    wali_id INTEGER REFERENCES wali_santri(id),
    santri_id INTEGER REFERENCES santri(id),
    last_access TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notifications_unread INTEGER DEFAULT 0,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (wali_id, santri_id)
);

-- ============================================
-- 12. TABEL INTEGRASI PEMERINTAH
-- ============================================

CREATE TABLE emis_sync (
    id SERIAL PRIMARY KEY,
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    sync_type VARCHAR(20) CHECK (sync_type IN ('DATA_SISWA', 'DATA_GURU', 'NILAI', 'ALL')),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSING', 'SUCCESS', 'FAILED')),
    records_synced INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    error_message TEXT,
    sync_started_at TIMESTAMP,
    sync_completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dapodik_sync (
    id SERIAL PRIMARY KEY,
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    sync_type VARCHAR(20) CHECK (sync_type IN ('DATA_SISWA', 'DATA_GURU', 'NILAI', 'ALL')),
    status VARCHAR(20) DEFAULT 'PENDING',
    records_synced INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    error_message TEXT,
    sync_started_at TIMESTAMP,
    sync_completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE government_config (
    id SERIAL PRIMARY KEY,
    lembaga_id INTEGER REFERENCES lembaga(id),
    config_type VARCHAR(20) CHECK (config_type IN ('EMIS', 'DAPODIK')),
    api_url VARCHAR(500),
    api_key VARCHAR(255),
    username VARCHAR(100),
    password_hash VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    last_test TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 13. TABEL MONITORING ORANG TUA (SUPER APP)
-- ============================================

CREATE TABLE notifikasi_wali (
    id SERIAL PRIMARY KEY,
    wali_id INTEGER REFERENCES wali_santri(id),
    santri_id INTEGER REFERENCES santri(id),
    jenis_notifikasi VARCHAR(50) NOT NULL, -- NILAI, HAFALAN, KEHADIRAN, PEMBAYARAN, PELANGGARAN
    judul VARCHAR(200) NOT NULL,
    pesan TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    action_url VARCHAR(500),
    priority VARCHAR(10) DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kehadiran_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal DATE NOT NULL,
    jenis_kehadiran VARCHAR(20) CHECK (jenis_kehadiran IN ('FORMAL', 'DINIAH', 'TAHFIDZ')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('HADIR', 'SAKIT', 'IZIN', 'ALPHA', 'LIBUR')),
    waktu_masuk TIME,
    waktu_keluar TIME,
    catatan TEXT,
    verified_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, tanggal, jenis_kehadiran)
);

CREATE TABLE perizinan_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE NOT NULL,
    jenis_izin VARCHAR(50) NOT NULL, -- PULANG, SAKIT, KELUARGA, LAINNYA
    alasan TEXT NOT NULL,
    disetujui_oleh_wali BOOLEAN DEFAULT false,
    disetujui_oleh_pondok BOOLEAN DEFAULT false,
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'MENUNGGU' CHECK (status IN ('MENUNGGU', 'DISETUJUI', 'DITOLAK', 'SELESAI')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 14. TABEL DASHBOARD PIMPINAN PONDOK
-- ============================================

CREATE TABLE dashboard_pimpinan (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    widget_type VARCHAR(50) NOT NULL, -- STATISTIK_LEMBAGA, PROGRESS_TAHFIDZ, KEUANGAN, DLL
    widget_config JSONB NOT NULL,
    position_x INTEGER DEFAULT 0,
    position_y INTEGER DEFAULT 0,
    width INTEGER DEFAULT 4,
    height INTEGER DEFAULT 3,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE statistik_lembaga (
    id SERIAL PRIMARY KEY,
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    bulan INTEGER CHECK (bulan BETWEEN 1 AND 12),
    total_santri INTEGER DEFAULT 0,
    santri_baru INTEGER DEFAULT 0,
    santri_keluar INTEGER DEFAULT 0,
    rata_rata_nilai DECIMAL(5,2),
    persentase_kehadiran DECIMAL(5,2),
    total_pendapatan DECIMAL(15,2),
    total_pengeluaran DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (lembaga_id, tahun_ajaran_id, bulan)
);

CREATE TABLE statistik_tahfidz (
    id SERIAL PRIMARY KEY,
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    bulan INTEGER CHECK (bulan BETWEEN 1 AND 12),
    total_santri_tahfidz INTEGER DEFAULT 0,
    santri_selesai_30_juz INTEGER DEFAULT 0,
    santri_selesai_20_juz INTEGER DEFAULT 0,
    santri_selesai_10_juz INTEGER DEFAULT 0,
    rata_rata_progress DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (tahun_ajaran_id, bulan)
);

-- ============================================
-- 15. TABEL MANAJEMEN KENAIKAN & KELULUSAN
-- ============================================

CREATE TABLE kenaikan_kelas (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_ajaran_lama INTEGER REFERENCES tahun_ajaran(id),
    tahun_ajaran_baru INTEGER REFERENCES tahun_ajaran(id),
    kelas_lama VARCHAR(20),
    kelas_baru VARCHAR(20),
    status VARCHAR(20) DEFAULT 'DIPROSES' CHECK (status IN ('DIPROSES', 'DISETUJUI', 'DITOLAK', 'MUTASI')),
    syarat_nilai BOOLEAN DEFAULT false,
    syarat_kehadiran BOOLEAN DEFAULT false,
    syarat_spp BOOLEAN DEFAULT false,
    catatan TEXT,
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kenaikan_marhalah (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    marhalah_lama VARCHAR(50),
    marhalah_baru VARCHAR(50),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    syarat_kitab TEXT,
    syarat_hafalan INTEGER, -- minimal juz
    status VARCHAR(20) DEFAULT 'DIPROSES',
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kelulusan (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    tanggal_kelulusan DATE,
    nomor_ijazah VARCHAR(50),
    nilai_akhir DECIMAL(5,2),
    predikat_kelulusan VARCHAR(20),
    status VARCHAR(20) DEFAULT 'LULUS' CHECK (status IN ('LULUS', 'TIDAK_LULUS', 'MENGULANG')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, lembaga_id, tahun_ajaran_id)
);

-- ============================================
-- 16. TABEL SERTIFIKASI & IJAZAH
-- ============================================

CREATE TABLE ijazah_formal (
    id SERIAL PRIMARY KEY,
    kelulusan_id INTEGER REFERENCES kelulusan(id),
    nomor_seri VARCHAR(100) UNIQUE,
    tanggal_terbit DATE,
    file_url VARCHAR(500),
    verified_by INTEGER REFERENCES users(id),
    verified_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'DICETAK' CHECK (status IN ('DICETAK', 'DIVERIFIKASI', 'DISTEMPEL', 'DIAMBIL')),
    created_at TIM