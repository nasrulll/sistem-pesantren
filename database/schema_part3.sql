-- Lanjutan Schema Database Pondok Pesantren - Bagian 3
-- ============================================
-- 13. UNIT USAHA / KOPERASI (lanjutan)
-- ============================================

-- Tabel Detail Penjualan (lanjutan)
    harga DECIMAL(15,2) NOT NULL,
    subtotal DECIMAL(15,2) GENERATED ALWAYS AS (jumlah * harga) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Tabungan Santri
CREATE TABLE tabungan_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    saldo DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Transaksi Tabungan
CREATE TABLE transaksi_tabungan (
    id SERIAL PRIMARY KEY,
    tabungan_id INTEGER REFERENCES tabungan_santri(id),
    jenis VARCHAR(20) CHECK (jenis IN ('setor', 'tarik', 'belanja')),
    nominal DECIMAL(15,2) NOT NULL,
    saldo_sebelum DECIMAL(15,2),
    saldo_sesudah DECIMAL(15,2),
    keterangan TEXT,
    referensi_id INTEGER, -- ID transaksi terkait (penjualan, dll)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 14. KEAMANAN SISTEM (RBAC)
-- ============================================

-- Tabel Role
CREATE TABLE role (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(50) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    level INTEGER DEFAULT 1,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Permission
CREATE TABLE permission (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(100) UNIQUE NOT NULL,
    nama VARCHAR(200) NOT NULL,
    modul VARCHAR(100),
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Role Permission
CREATE TABLE role_permission (
    id SERIAL PRIMARY KEY,
    role_id INTEGER REFERENCES role(id),
    permission_id INTEGER REFERENCES permission(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(role_id, permission_id)
);

-- Tabel User Role
CREATE TABLE user_role (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    user_tipe VARCHAR(20) CHECK (user_tipe IN ('santri', 'wali', 'ustadz', 'staf')),
    role_id INTEGER REFERENCES role(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, user_tipe, role_id)
);

-- Tabel Log Aktivitas
CREATE TABLE log_aktivitas (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    user_tipe VARCHAR(20),
    aksi VARCHAR(100) NOT NULL,
    modul VARCHAR(100),
    data_sebelum JSONB,
    data_sesudah JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 15. DASHBOARD & ANALYTICS
-- ============================================

-- Tabel Dashboard Widget
CREATE TABLE dashboard_widget (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(50) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    tipe VARCHAR(50) CHECK (tipe IN ('statistik', 'grafik', 'tabel', 'kalender')),
    query_sql TEXT,
    refresh_interval INTEGER DEFAULT 300, -- dalam detik
    role_access JSONB, -- role yang bisa melihat widget ini
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Saved Report
CREATE TABLE saved_report (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(200) NOT NULL,
    tipe VARCHAR(50) CHECK (tipe IN ('keuangan', 'akademik', 'santri', 'inventaris', 'custom')),
    parameter JSONB,
    created_by INTEGER REFERENCES staf(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 16. INTEGRASI & API
-- ============================================

-- Tabel API Key
CREATE TABLE api_key (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    client_id VARCHAR(100),
    permissions JSONB,
    rate_limit INTEGER DEFAULT 100,
    expires_at TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif', 'expired')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Integrasi Payment Gateway
CREATE TABLE integrasi_payment (
    id SERIAL PRIMARY KEY,
    provider VARCHAR(100) NOT NULL,
    tipe VARCHAR(50) CHECK (tipe IN ('va', 'qris', 'ewallet', 'transfer')),
    api_key VARCHAR(255),
    api_secret VARCHAR(255),
    merchant_id VARCHAR(100),
    callback_url VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif', 'testing')) DEFAULT 'testing',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Integrasi WhatsApp/Telegram
CREATE TABLE integrasi_messaging (
    id SERIAL PRIMARY KEY,
    platform VARCHAR(50) CHECK (platform IN ('whatsapp', 'telegram', 'email')),
    api_key VARCHAR(255),
    webhook_url VARCHAR(255),
    sender_id VARCHAR(100),
    template_messages JSONB,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 17. DIGITAL IDENTITY
-- ============================================

-- Tabel Kartu Santri
CREATE TABLE kartu_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    no_kartu VARCHAR(50) UNIQUE NOT NULL,
    tipe_kartu VARCHAR(20) CHECK (tipe_kartu IN ('qr', 'rfid', 'nfc', 'barcode')),
    qr_code_path VARCHAR(255),
    rfid_uid VARCHAR(100),
    tanggal_terbit DATE DEFAULT CURRENT_DATE,
    tanggal_expired DATE,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif', 'hilang', 'rusak')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Transaksi Kartu
CREATE TABLE transaksi_kartu (
    id SERIAL PRIMARY KEY,
    kartu_id INTEGER REFERENCES kartu_santri(id),
    jenis_transaksi VARCHAR(50) CHECK (jenis_transaksi IN ('absensi', 'pembayaran', 'pintu', 'koperasi')),
    lokasi VARCHAR(100),
    device_id VARCHAR(100),
    nominal DECIMAL(15,2),
    status VARCHAR(20) CHECK (status IN ('sukses', 'gagal', 'pending')) DEFAULT 'sukses',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 18. KEGIATAN & EVENT
-- ============================================

-- Tabel Kegiatan
CREATE TABLE kegiatan (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(200) NOT NULL,
    jenis VARCHAR(50) CHECK (jenis IN ('akademik', 'ekstra', 'keagamaan', 'sosial', 'olahraga')),
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    waktu TIME,
    lokasi VARCHAR(100),
    penanggung_jawab_id INTEGER REFERENCES ustadz(id),
    deskripsi TEXT,
    peserta JSONB, -- berisi aturan peserta (kelas, asrama, semua, dll)
    status VARCHAR(20) CHECK (status IN ('draft', 'terjadwal', 'berlangsung', 'selesai', 'dibatalkan')) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Pendaftaran Kegiatan
CREATE TABLE pendaftaran_kegiatan (
    id SERIAL PRIMARY KEY,
    kegiatan_id INTEGER REFERENCES kegiatan(id),
    santri_id INTEGER REFERENCES santri(id),
    tanggal_daftar DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) CHECK (status IN ('terdaftar', 'hadir', 'tidak_hadir', 'batal')) DEFAULT 'terdaftar',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(kegiatan_id, santri_id)
);

-- Tabel Dokumentasi Kegiatan
CREATE TABLE dokumentasi_kegiatan (
    id SERIAL PRIMARY KEY,
    kegiatan_id INTEGER REFERENCES kegiatan(id),
    jenis_dokumen VARCHAR(50) CHECK (jenis_dokumen IN ('foto', 'video', 'dokumen')),
    path_file VARCHAR(500),
    deskripsi TEXT,
    uploaded_by INTEGER REFERENCES staf(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 19. ARSIP & DOKUMEN
-- ============================================

-- Tabel Kategori Dokumen
CREATE TABLE kategori_dokumen (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Dokumen
CREATE TABLE dokumen (
    id SERIAL PRIMARY KEY,
    kode_dokumen VARCHAR(50) UNIQUE NOT NULL,
    kategori_id INTEGER REFERENCES kategori_dokumen(id),
    judul VARCHAR(200) NOT NULL,
    deskripsi TEXT,
    tipe_file VARCHAR(50),
    path_file VARCHAR(500),
    size_bytes BIGINT,
    upload_by INTEGER REFERENCES staf(id),
    access_role JSONB, -- role yang bisa mengakses
    status VARCHAR(20) CHECK (status IN ('draft', 'publik', 'terbatas', 'arsip')) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Template Dokumen
CREATE TABLE template_dokumen (
    id SERIAL PRIMARY KEY,
    kode_template VARCHAR(50) UNIQUE NOT NULL,
    nama VARCHAR(200) NOT NULL,
    tipe VARCHAR(50) CHECK (tipe IN ('surat', 'laporan', 'sertifikat', 'raport')),
    konten_template TEXT,
    variables JSONB, -- variable yang bisa diisi
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Surat
CREATE TABLE surat (
    id SERIAL PRIMARY KEY,
    no_surat VARCHAR(100) UNIQUE NOT NULL,
    template_id INTEGER REFERENCES template_dokumen(id),
    perihal VARCHAR(200) NOT NULL,
    tujuan VARCHAR(200),
    konten TEXT,
    status VARCHAR(20) CHECK (status IN ('draft', 'terbit', 'arsip')) DEFAULT 'draft',
    ditandatangani_oleh INTEGER REFERENCES ustadz(id),
    tanggal_terbit DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 20. AI & ANALYTICS (OPSIONAL)
-- ============================================

-- Tabel Model AI
CREATE TABLE model_ai (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    tipe VARCHAR(50) CHECK (tipe IN ('prediksi', 'klasifikasi', 'rekomendasi', 'chatbot')),
    endpoint VARCHAR(255),
    api_key VARCHAR(255),
    parameters JSONB,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif', 'training')) DEFAULT 'nonaktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Prediksi Performa Santri
CREATE TABLE prediksi_performa (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    model_id INTEGER REFERENCES model_ai(id),
    aspek VARCHAR(100),
    nilai_prediksi DECIMAL(5,2),
    confidence DECIMAL(5,2),
    faktor_pengaruh JSONB,
    rekomendasi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Chatbot Conversation
CREATE TABLE chatbot_conversation (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    user_tipe VARCHAR(20),
    session_id VARCHAR(100),
    pertanyaan TEXT,
    jawaban TEXT,
    confidence DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 21. INFRASTRUKTUR & MULTI-TENANT
-- ============================================

-- Tabel Tenant (untuk multi-tenant)
CREATE TABLE tenant (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(50) UNIQUE NOT NULL,
    nama VARCHAR(200) NOT NULL,
    domain VARCHAR(100),
    database_name VARCHAR(100),
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif', 'suspended')) DEFAULT 'aktif',
    config JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Server Monitoring
CREATE TABLE server_monitoring (
    id SERIAL PRIMARY KEY,
    server_name VARCHAR(100),
    cpu_usage DECIMAL(5,2),
    memory_usage DECIMAL(5,2),
    disk_usage DECIMAL(5,2),
    uptime_seconds BIGINT,
    active_connections INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES UNTUK PERFORMANCE
-- ============================================

-- Index untuk tabel santri
CREATE INDEX idx_santri_status ON santri(status);
CREATE INDEX idx_santri_nis ON santri(nis);
CREATE INDEX idx_santri_nama ON santri(nama_lengkap);

-- Index untuk tabel presensi
CREATE INDEX idx_presensi_santri_tanggal ON presensi_santri(santri_id, tanggal);
CREATE INDEX idx_presensi_jadwal ON presensi_santri(jadwal_pelajaran_id, tanggal);

-- Index untuk tabel pembayaran
CREATE INDEX idx_tagihan_santri ON tagihan(santri_id, status);
CREATE INDEX idx_tagihan_jatuh_tempo ON tagihan(jatuh_tempo) WHERE status = 'belum_bayar';

-- Index untuk tabel notifikasi
CREATE INDEX idx_notifikasi_penerima ON notifikasi(penerima_id, penerima_tipe, status);
CREATE INDEX idx_notifikasi_channel ON notifikasi(channel, status);

-- Index untuk tabel log aktivitas
CREATE INDEX idx_log_user ON log_aktivitas(user_id, user_tipe);
CREATE INDEX idx_log_timestamp ON log_aktivitas(created_at);

-- Index untuk tabel transaksi kartu
CREATE INDEX idx_transaksi_kartu ON transaksi_kartu(kartu_id, jenis_transaksi, created_at);

-- ============================================
-- VIEWS UNTUK REPORTING
-- ============================================

-- View untuk dashboard admin
CREATE VIEW vw_dashboard_admin AS
SELECT 
    (SELECT COUNT(*) FROM santri WHERE status = 'aktif') as total_santri,
    (SELECT COUNT(*) FROM ustadz WHERE status = 'aktif') as total_ustadz,
    (SELECT COUNT(*) FROM tagihan WHERE status = 'belum_bayar' AND jatuh_tempo < CURRENT_DATE) as tagihan_terlambat,
    (SELECT SUM(nominal) FROM pembayaran WHERE DATE(tanggal_bayar) = CURRENT_DATE) as pemasukan_hari_ini;

-- View untuk statistik kehadiran
CREATE VIEW vw_statistik_kehadiran AS
SELECT 
    s.id as santri_id,
    s.nama_lengkap,
    k.nama as kelas,
    COUNT(CASE WHEN ps.status = 'hadir' THEN 1 END) as total_hadir,
    COUNT(CASE WHEN ps.status = 'izin' THEN 1 END) as total_izin,
    COUNT(CASE WHEN ps.status = 'sakit' THEN 1 END) as total_sakit,
    COUNT(CASE WHEN ps.status = 'alpha' THEN 1 END) as total_alpha
FROM santri s
LEFT JOIN kelas k ON s.id IN (SELECT santri_id FROM santri_kelas WHERE status = 'aktif')
LEFT JOIN presensi_santri ps ON s.id = ps.santri_id AND ps.tanggal >= DATE_TRUNC('month', CURRENT_DATE)
WHERE s.status = 'aktif'
GROUP BY s.id, s.nama_lengkap, k.nama;

-- View untuk laporan keuangan
CREATE VIEW vw_laporan_keuangan AS
SELECT 
    DATE_TRUNC('month', p.tanggal_bayar) as bulan,
    COUNT(DISTINCT p.id) as total_transaksi,
    SUM(p.nominal_bayar) as total_pemasukan,
    COUNT(DISTINCT t.santri_id) as total_santri_bayar
FROM pembayaran p
JOIN tagihan t ON p.tagihan_id = t.id
WHERE p.status = 'lunas'
GROUP BY DATE_TRUNC('month', p.tanggal_bayar);

