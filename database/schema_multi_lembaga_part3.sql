-- ============================================
-- 16. TABEL SERTIFIKASI & IJAZAH (Lanjutan)
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE syahadah_tahfidz (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    total_juz INTEGER NOT NULL CHECK (total_juz BETWEEN 1 AND 30),
    tanggal_ujian DATE,
    penguji_id INTEGER REFERENCES ustadz_tahfidz(id),
    nilai_akhir DECIMAL(5,2),
    predikat VARCHAR(20),
    nomor_syahadah VARCHAR(100) UNIQUE,
    file_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'DICETAK',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sertifikat_pondok (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    jenis_sertifikat VARCHAR(100) NOT NULL, -- PRESTASI, KEGIATAN, KEAHLIAN
    nama_sertifikat VARCHAR(200) NOT NULL,
    tanggal_terbit DATE,
    penerbit VARCHAR(100),
    file_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 17. TABEL ALUMNI TERINTEGRASI
-- ============================================

CREATE TABLE alumni (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) UNIQUE,
    tahun_kelulusan INTEGER NOT NULL,
    status_alumni VARCHAR(50), -- KULIAH, BEKERJA, WIRAUSAHA, LAINNYA
    institusi_lanjutan VARCHAR(200),
    jurusan VARCHAR(100),
    pekerjaan VARCHAR(100),
    perusahaan VARCHAR(200),
    alamat_kantor TEXT,
    telepon_kantor VARCHAR(20),
    email_kantor VARCHAR(255),
    is_active_member BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE alumni_lembaga (
    alumni_id INTEGER REFERENCES alumni(id) ON DELETE CASCADE,
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_lulus INTEGER,
    PRIMARY KEY (alumni_id, lembaga_id)
);

CREATE TABLE alumni_tahfidz (
    alumni_id INTEGER REFERENCES alumni(id) ON DELETE CASCADE,
    total_juz INTEGER NOT NULL CHECK (total_juz BETWEEN 1 AND 30),
    tanggal_selesai DATE,
    penguji_terakhir INTEGER REFERENCES ustadz_tahfidz(id),
    PRIMARY KEY (alumni_id)
);

CREATE TABLE tracking_lulusan (
    id SERIAL PRIMARY KEY,
    alumni_id INTEGER REFERENCES alumni(id),
    tahun INTEGER NOT NULL,
    bulan INTEGER NOT NULL CHECK (bulan BETWEEN 1 AND 12),
    status VARCHAR(50),
    pencapaian TEXT,
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (alumni_id, tahun, bulan)
);

-- ============================================
-- 18. TABEL KURIKULUM HYBRID
-- ============================================

CREATE TABLE kurikulum_hybrid (
    id SERIAL PRIMARY KEY,
    lembaga_id INTEGER REFERENCES lembaga(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    nama_kurikulum VARCHAR(100) NOT NULL,
    persentase_formal INTEGER DEFAULT 60 CHECK (persentase_formal BETWEEN 0 AND 100),
    persentase_diniyah INTEGER DEFAULT 25 CHECK (persentase_diniyah BETWEEN 0 AND 100),
    persentase_tahfidz INTEGER DEFAULT 15 CHECK (persentase_tahfidz BETWEEN 0 AND 100),
    total_jam_perminggu INTEGER DEFAULT 40,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (lembaga_id, tahun_ajaran_id)
);

CREATE TABLE mapping_waktu_belajar (
    id SERIAL PRIMARY KEY,
    kurikulum_id INTEGER REFERENCES kurikulum_hybrid(id),
    hari VARCHAR(10) CHECK (hari IN ('SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'AHAD')),
    jam_mulai TIME NOT NULL,
    jam_selesai TIME NOT NULL,
    jenis_aktivitas VARCHAR(20) CHECK (jenis_aktivitas IN ('FORMAL', 'DINIAH', 'TAHFIDZ', 'ISTIRAHAT', 'IBADAH', 'OLAHRAGA')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE beban_belajar_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    total_jam_formal INTEGER DEFAULT 0,
    total_jam_diniyah INTEGER DEFAULT 0,
    total_jam_tahfidz INTEGER DEFAULT 0,
    total_jam_istirahat INTEGER DEFAULT 0,
    stress_level VARCHAR(20) CHECK (stress_level IN ('RENDAH', 'SEDANG', 'TINGGI', 'KRITIS')),
    rekomendasi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, tahun_ajaran_id)
);

-- ============================================
-- 19. TABEL SISTEM PRESTASI SANTRI
-- ============================================

CREATE TABLE jenis_prestasi (
    id SERIAL PRIMARY KEY,
    kategori VARCHAR(20) CHECK (kategori IN ('AKADEMIK_FORMAL', 'DINIAH', 'TAHFIDZ', 'NON_AKADEMIK')),
    nama_prestasi VARCHAR(100) NOT NULL,
    tingkat VARCHAR(20) CHECK (tingkat IN ('LOKAL', 'KOTA', 'PROVINSI', 'NASIONAL', 'INTERNASIONAL')),
    bobot_nilai INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE prestasi_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    jenis_prestasi_id INTEGER REFERENCES jenis_prestasi(id),
    tanggal_prestasi DATE NOT NULL,
    deskripsi TEXT,
    penyelenggara VARCHAR(200),
    file_bukti_url VARCHAR(500),
    verified_by INTEGER REFERENCES users(id),
    verified_at TIMESTAMP,
    poin_prestasi INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ranking_prestasi (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    total_poin INTEGER DEFAULT 0,
    ranking_akademik INTEGER,
    ranking_diniyah INTEGER,
    ranking_tahfidz INTEGER,
    ranking_non_akademik INTEGER,
    ranking_total INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, tahun_ajaran_id)
);

-- ============================================
-- 20. TABEL INFRASTRUKTUR MULTI UNIT
-- ============================================

CREATE TABLE tenant (
    id SERIAL PRIMARY KEY,
    kode_tenant VARCHAR(50) UNIQUE NOT NULL,
    nama_tenant VARCHAR(100) NOT NULL,
    domain_custom VARCHAR(100) UNIQUE,
    lembaga_id INTEGER REFERENCES lembaga(id),
    database_name VARCHAR(100),
    database_host VARCHAR(100),
    database_user VARCHAR(100),
    database_password VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tenant_config (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER REFERENCES tenant(id) ON DELETE CASCADE,
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT,
    config_type VARCHAR(20) DEFAULT 'STRING' CHECK (config_type IN ('STRING', 'NUMBER', 'BOOLEAN', 'JSON')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (tenant_id, config_key)
);

CREATE TABLE data_isolation_log (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER REFERENCES tenant(id),
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(10) CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT')),
    record_id INTEGER,
    user_id INTEGER REFERENCES users(id),
    ip_address VARCHAR(45),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 21. TABEL SISTEM PSIKOLOGI & KARAKTER SANTRI
-- ============================================

CREATE TABLE assessment_psikologi (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal_assessment DATE NOT NULL,
    assessor_id INTEGER REFERENCES users(id),
    tipe_assessment VARCHAR(50), -- KEPRIBADIAN, MINAT BAKAT, KECERDASAN
    hasil_json JSONB NOT NULL,
    rekomendasi TEXT,
    follow_up_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tracking_akhlak (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal DATE NOT NULL,
    aspek_akhlak VARCHAR(100) NOT NULL, -- JUJUR, DISIPLIN, SOPAN, DLL
    nilai INTEGER CHECK (nilai BETWEEN 1 AND 5),
    penilai_id INTEGER REFERENCES users(id),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pembinaan_karakter (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE,
    program_pembinaan VARCHAR(200),
    tujuan_pembinaan TEXT,
    metode_pembinaan TEXT,
    hasil_evaluasi TEXT,
    status VARCHAR(20) DEFAULT 'BERJALAN' CHECK (status IN ('BERJALAN', 'SELESAI', 'DIBATALKAN')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE deteksi_masalah (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal_deteksi DATE NOT NULL,
    jenis_masalah VARCHAR(100), -- AKADEMIK, SOSIAL, EMOSIONAL, PERILAKU
    tingkat_keparahan VARCHAR(20) CHECK (tingkat_keparahan IN ('RINGAN', 'SEDANG', 'BERAT')),
    gejala TEXT,
    tindakan_awal TEXT,
    referred_to VARCHAR(100), -- PSIKOLOG, ORANG TUA, DOKTER
    status VARCHAR(20) DEFAULT 'TERDETEKSI' CHECK (status IN ('TERDETEKSI', 'DITANGANI', 'SELESAI')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 22. TABEL EARLY WARNING SYSTEM (EWS)
-- ============================================

CREATE TABLE ews_parameter (
    id SERIAL PRIMARY KEY,
    nama_parameter VARCHAR(100) UNIQUE NOT NULL,
    deskripsi TEXT,
    threshold_min DECIMAL(5,2),
    threshold_max DECIMAL(5,2),
    bobot INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE ews_monitoring (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    parameter_id INTEGER REFERENCES ews_parameter(id),
    tanggal DATE NOT NULL,
    nilai DECIMAL(5,2),
    status VARCHAR(20) CHECK (status IN ('NORMAL', 'WARNING', 'CRITICAL')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, parameter_id, tanggal)
);

CREATE TABLE ews_alert (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal_alert DATE NOT NULL,
    jenis_alert VARCHAR(100) NOT NULL,
    pesan_alert TEXT NOT NULL,
    severity VARCHAR(20) CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    channel_notifikasi VARCHAR(50), -- WHATSAPP, SMS, EMAIL, APP
    status_notifikasi VARCHAR(20) DEFAULT 'PENDING' CHECK (status_notifikasi IN ('PENDING', 'SENT', 'READ', 'ACKNOWLEDGED')),
    acknowledged_by INTEGER REFERENCES users(id),
    acknowledged_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE risk_scoring (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal_scoring DATE NOT NULL,
    total_score DECIMAL(5,2),
    risk_level VARCHAR(20) CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    faktor_risiko JSONB,
    rekomendasi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (santri_id, tanggal_scoring)
);

-- ============================================
-- 23. TABEL KNOWLEDGE BASE PONDOK
-- ============================================

CREATE TABLE kategori_knowledge (
    id SERIAL PRIMARY KEY,
    nama_kategori VARCHAR(100) UNIQUE NOT NULL,
    deskripsi TEXT,
    parent_id INTEGER REFERENCES kategori_knowledge(id),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE knowledge_base (
    id SERIAL PRIMARY KEY,
    kategori_id INTEGER REFERENCES kategori_knowledge(id),
    judul VARCHAR(200) NOT NULL,
    konten TEXT NOT NULL,
    tipe_konten VARCHAR(20) CHECK (tipe_konten IN ('ARTICLE', 'FAQ', 'GUIDE', 'SOP', 'DOCUMENT')),
    tags TEXT[],
    view_count INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT true,
    published_by INTEGER REFERENCES users(id),
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dokumentasi_digital (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(200) NOT NULL,
    deskripsi TEXT,
    tipe_dokumen VARCHAR(50), -- PDF, DOC, IMAGE, VIDEO
    file_url VARCHAR(500) NOT NULL,
    file_size INTEGER,
    kategori VARCHAR(100),
    uploaded_by INTEGER REFERENCES users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    download_count INTEGER DEFAULT 0
);

-- ============================================
-- 24. TABEL SISTEM FATWA / KONSULTASI SYARIAH
-- ============================================

CREATE TABLE topik_fiqh (
    id SERIAL PRIMARY KEY,
    nama_topik VARCHAR(100) UNIQUE NOT NULL,
    deskripsi TEXT,
    parent_id INTEGER REFERENCES topik_fiqh(id),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE konsultasi_syariah (
    id SERIAL PRIMARY KEY,
    pengirim_id INTEGER REFERENCES users(id),
    santri_id INTEGER REFERENCES santri(id),
    topik_id INTEGER REFERENCES topik_fiqh(id),
    pertanyaan TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'MENUNGGU' CHECK (status IN ('MENUNGGU', 'DIPROSES', 'DIJAWAB', 'DITUTUP')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE jawaban_konsultasi (
    id SERIAL PRIMARY KEY,
    konsultasi_id INTEGER REFERENCES konsultasi_syariah(id),
    ustadz_id INTEGER REFERENCES ustadz_diniyah(id),
    jawaban TEXT NOT NULL,
    referensi_kitab TEXT,
    fatwa_terkait TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE database_fatwa (
    id SERIAL PRIMARY KEY,
    topik_id INTEGER REFERENCES topik_fiqh(id),
    pertanyaan TEXT NOT NULL,
    jawaban TEXT NOT NULL,
    referensi TEXT,
    ustadz_pemberi_fatwa VARCHAR(100),
    tanggal_fatwa DATE,
    view_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    verified_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 25. TABEL SOCIAL NETWORK INTERNAL
-- ============================================

CREATE TABLE timeline_post (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    konten TEXT NOT NULL,
    tipe_konten VARCHAR(20) CHECK (tipe_konten IN ('TEXT', 'IMAGE', 'VIDEO', 'LINK')),
    media_urls TEXT[],
    visibility VARCHAR(20) DEFAULT 'PUBLIC' CHECK (visibility IN ('PUBLIC', 'FRIENDS', 'PRIVATE')),
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    is_pinned BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE post_like (
    post_id INTEGER REFERENCES timeline_post(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, user_id)
);

CREATE TABLE post_comment (
    id SERIAL PRIMARY KEY,
    post_id INTEGER REFERENCES timeline_post(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id),
    komentar TEXT NOT NULL,
    parent_comment_id INTEGER REFERENCES post_comment(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sharing_prestasi (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    prestasi_id INTEGER REFERENCES prestasi_santri(id),
    pesan TEXT,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    created_at