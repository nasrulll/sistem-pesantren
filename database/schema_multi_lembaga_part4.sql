-- ============================================
-- 25. TABEL SOCIAL NETWORK INTERNAL (Lanjutan)
-- ============================================

CREATE TABLE sharing_prestasi (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    prestasi_id INTEGER REFERENCES prestasi_santri(id),
    pesan TEXT,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE interaksi_wali (
    id SERIAL PRIMARY KEY,
    wali_id INTEGER REFERENCES wali_santri(id),
    santri_id INTEGER REFERENCES santri(id),
    jenis_interaksi VARCHAR(50), -- KOMENTAR, LIKE, SHARE
    konten_id INTEGER, -- ID post/komentar
    konten_tipe VARCHAR(20), -- POST, COMMENT, PRESTASI
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 26. TABEL DIGITAL WALLET SANTRI
-- ============================================

CREATE TABLE digital_wallet (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) UNIQUE,
    saldo DECIMAL(12,2) DEFAULT 0,
    limit_harian DECIMAL(12,2) DEFAULT 100000,
    status VARCHAR(20) DEFAULT 'AKTIF' CHECK (status IN ('AKTIF', 'NONAKTIF', 'DIBEKUKAN')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wallet_transaction (
    id SERIAL PRIMARY KEY,
    wallet_id INTEGER REFERENCES digital_wallet(id),
    jenis_transaksi VARCHAR(20) NOT NULL CHECK (jenis_transaksi IN ('TOPUP', 'PAYMENT', 'REFUND', 'TRANSFER')),
    nominal DECIMAL(12,2) NOT NULL,
    saldo_sebelum DECIMAL(12,2),
    saldo_sesudah DECIMAL(12,2),
    keterangan TEXT,
    merchant_id INTEGER, -- ID kantin/koperasi
    payment_method VARCHAR(20),
    status VARCHAR(20) DEFAULT 'SUCCESS' CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE topup_request (
    id SERIAL PRIMARY KEY,
    wallet_id INTEGER REFERENCES digital_wallet(id),
    wali_id INTEGER REFERENCES wali_santri(id),
    nominal DECIMAL(12,2) NOT NULL,
    metode_bayar VARCHAR(20) NOT NULL,
    bukti_bayar_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'VERIFIED', 'REJECTED', 'EXPIRED')),
    verified_by INTEGER REFERENCES users(id),
    verified_at TIMESTAMP,
    expired_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE merchant_internal (
    id SERIAL PRIMARY KEY,
    nama_merchant VARCHAR(100) NOT NULL,
    tipe VARCHAR(20) CHECK (tipe IN ('KANTIN', 'KOPERASI', 'LAUNDRY', 'LAINNYA')),
    lokasi VARCHAR(200),
    pemilik_id INTEGER REFERENCES users(id),
    saldo DECIMAL(12,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 27. TABEL SMART ATTENDANCE (ADVANCED)
-- ============================================

CREATE TABLE device_attendance (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100) UNIQUE NOT NULL,
    device_name VARCHAR(100),
    device_type VARCHAR(20) CHECK (device_type IN ('FACE_RECOGNITION', 'RFID', 'FINGERPRINT', 'MANUAL')),
    lokasi VARCHAR(200),
    ip_address VARCHAR(45),
    is_active BOOLEAN DEFAULT true,
    last_seen TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE face_biometric (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) UNIQUE,
    face_embedding BYTEA, -- Vector embedding untuk face recognition
    face_image_url VARCHAR(500),
    is_trained BOOLEAN DEFAULT false,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE attendance_log (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    device_id VARCHAR(100) REFERENCES device_attendance(device_id),
    tanggal DATE NOT NULL,
    waktu TIME NOT NULL,
    tipe_kehadiran VARCHAR(20) CHECK (tipe_kehadiran IN ('MASUK', 'KELUAR', 'IZIN')),
    metode_verifikasi VARCHAR(20) CHECK (metode_verifikasi IN ('FACE', 'RFID', 'FINGERPRINT', 'MANUAL')),
    confidence_score DECIMAL(5,2), -- Untuk face recognition
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    photo_url VARCHAR(500),
    is_suspected_titip BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE attendance_rule (
    id SERIAL PRIMARY KEY,
    lembaga_id INTEGER REFERENCES lembaga(id),
    hari VARCHAR(10) CHECK (hari IN ('SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'AHAD')),
    jam_masuk TIME NOT NULL,
    jam_keluar TIME NOT NULL,
    toleransi_keterlambatan INTEGER DEFAULT 15, -- dalam menit
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 28. TABEL SISTEM AUDIT INTERNAL
-- ============================================

CREATE TABLE audit_keuangan (
    id SERIAL PRIMARY KEY,
    auditor_id INTEGER REFERENCES users(id),
    periode_bulan INTEGER NOT NULL CHECK (periode_bulan BETWEEN 1 AND 12),
    periode_tahun INTEGER NOT NULL,
    lembaga_id INTEGER REFERENCES lembaga(id),
    temuan TEXT,
    rekomendasi TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'REVIEW', 'APPROVED', 'CLOSED')),
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_akademik (
    id SERIAL PRIMARY KEY,
    auditor_id INTEGER REFERENCES users(id),
    tahun_ajaran_id INTEGER REFERENCES tahun_ajaran(id),
    lembaga_id INTEGER REFERENCES lembaga(id),
    aspek_diaudit TEXT,
    temuan TEXT,
    rekomendasi TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT',
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_operasional (
    id SERIAL PRIMARY KEY,
    auditor_id INTEGER REFERENCES users(id),
    tanggal_audit DATE NOT NULL,
    area_audit VARCHAR(100),
    temuan TEXT,
    rekomendasi TEXT,
    status VARCHAR(20) DEFAULT 'DRAFT',
    follow_up_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_trail (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 29. TABEL MANAJEMEN RISIKO
-- ============================================

CREATE TABLE risiko_pondok (
    id SERIAL PRIMARY KEY,
    kode_risiko VARCHAR(20) UNIQUE NOT NULL,
    nama_risiko VARCHAR(200) NOT NULL,
    kategori VARCHAR(50), -- OPERASIONAL, KEUANGAN, AKADEMIK, HUKUM
    probabilitas VARCHAR(20) CHECK (probabilitas IN ('RENDAH', 'SEDANG', 'TINGGI')),
    dampak VARCHAR(20) CHECK (dampak IN ('RENDAH', 'SEDANG', 'TINGGI', 'KRITIS')),
    level_risiko VARCHAR(20) GENERATED ALWAYS AS (
        CASE 
            WHEN probabilitas = 'RENDAH' AND dampak = 'RENDAH' THEN 'RENDAH'
            WHEN probabilitas = 'TINGGI' AND dampak = 'KRITIS' THEN 'SANGAT_TINGGI'
            WHEN probabilitas = 'TINGGI' AND dampak = 'TINGGI' THEN 'TINGGI'
            WHEN probabilitas = 'SEDANG' AND dampak = 'TINGGI' THEN 'TINGGI'
            WHEN probabilitas = 'TINGGI' AND dampak = 'SEDANG' THEN 'TINGGI'
            WHEN probabilitas = 'SEDANG' AND dampak = 'SEDANG' THEN 'SEDANG'
            ELSE 'SEDANG'
        END
    ) STORED,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mitigasi_risiko (
    id SERIAL PRIMARY KEY,
    risiko_id INTEGER REFERENCES risiko_pondok(id),
    tindakan_mitigasi TEXT NOT NULL,
    penanggung_jawab INTEGER REFERENCES users(id),
    target_selesai DATE,
    status VARCHAR(20) DEFAULT 'PLANNED' CHECK (status IN ('PLANNED', 'ONGOING', 'COMPLETED', 'DELAYED')),
    progress INTEGER DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE monitoring_risiko (
    id SERIAL PRIMARY KEY,
    risiko_id INTEGER REFERENCES risiko_pondok(id),
    tanggal_monitoring DATE NOT NULL,
    status_risiko VARCHAR(20) CHECK (status_risiko IN ('TERKENDALI', 'WASPADA', 'KRITIS')),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE log_kejadian (
    id SERIAL PRIMARY KEY,
    tanggal_kejadian DATE NOT NULL,
    waktu_kejadian TIME NOT NULL,
    jenis_kejadian VARCHAR(100) NOT NULL,
    lokasi VARCHAR(200),
    deskripsi TEXT NOT NULL,
    dampak TEXT,
    tindakan TEXT,
    pelapor_id INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'DILAPORKAN' CHECK (status IN ('DILAPORKAN', 'DITINDAK', 'SELESAI')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 30. TABEL CONTENT MANAGEMENT SYSTEM (CMS)
-- ============================================

CREATE TABLE website_page (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(200) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    meta_description TEXT,
    meta_keywords TEXT,
    is_published BOOLEAN DEFAULT true,
    published_at TIMESTAMP,
    published_by INTEGER REFERENCES users(id),
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE news_article (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,
    excerpt TEXT,
    content TEXT NOT NULL,
    featured_image_url VARCHAR(500),
    category VARCHAR(100),
    tags TEXT[],
    is_published BOOLEAN DEFAULT true,
    published_at TIMESTAMP,
    published_by INTEGER REFERENCES users(id),
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE publication (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    event_date DATE,
    event_time TIME,
    location VARCHAR(200),
    cover_image_url VARCHAR(500),
    gallery_urls TEXT[],
    is_published BOOLEAN DEFAULT true,
    published_at TIMESTAMP,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE website_menu (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    url VARCHAR(500),
    parent_id INTEGER REFERENCES website_menu(id),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 31. TABEL FUNDRAISING & CROWDFUNDING
-- ============================================

CREATE TABLE fundraising_campaign (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    target_amount DECIMAL(15,2) NOT NULL,
    current_amount DECIMAL(15,2) DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    cover_image_url VARCHAR(500),
    gallery_urls TEXT[],
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE donation (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES fundraising_campaign(id),
    donor_name VARCHAR(200) NOT NULL,
    donor_email VARCHAR(255),
    donor_phone VARCHAR(20),
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(20),
    payment_status VARCHAR(20) DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED', 'EXPIRED')),
    is_anonymous BOOLEAN DEFAULT false,
    message TEXT,
    payment_proof_url VARCHAR(500),
    verified_by INTEGER REFERENCES users(id),
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fundraising_progress (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES fundraising_campaign(id),
    report_date DATE NOT NULL,
    total_donations DECIMAL(15,2) DEFAULT 0,
    donation_count INTEGER DEFAULT 0,
    average_donation DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (campaign_id, report_date)
);

CREATE TABLE transparency_report (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER REFERENCES fundraising_campaign(id),
    report_title VARCHAR(200) NOT NULL,
    report_content TEXT NOT NULL,
    expenditure_details JSONB,
    attachment_urls TEXT[],
    published_by INTEGER REFERENCES users(id),
    published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 32. TABEL API ECOSYSTEM (MARKETPLACE INTEGRASI)
-- ============================================

CREATE TABLE api_consumer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    api_key VARCHAR(255) UNIQUE NOT NULL,
    api_secret VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    rate_limit_per_minute INTEGER DEFAULT 60,
    allowed_ips CIDR[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE api_endpoint (
    id SERIAL PRIMARY KEY,
    endpoint_path VARCHAR(500) NOT NULL,
    method VARCHAR(10) CHECK (method IN ('GET', 'POST', 'PUT', 'DELETE', 'PATCH')),
    description TEXT,
    requires_auth BOOLEAN DEFAULT true,
    rate_limit INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE api_permission (
    consumer_id INTEGER REFERENCES api_consumer(id) ON DELETE CASCADE,
    endpoint_id INTEGER REFERENCES api_endpoint(id) ON DELETE CASCADE,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by INTEGER REFERENCES users(id),
    PRIMARY KEY (consumer_id, endpoint_id)
);

CREATE TABLE api_usage_log (
    id SERIAL PRIMARY KEY,
    consumer_id INTEGER REFERENCES api_consumer(id),
    endpoint_id INTEGER REFERENCES api_endpoint(id),
    request_method VARCHAR(10),
    request_path VARCHAR(500),
    request_ip VARCHAR(45),
    request_body TEXT,
    response_status INTEGER,
    response_time_ms INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE edutech_integration (
    id SERIAL PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    integration_type VARCHAR(50), -- LMS, ASSESSMENT, CONTENT, PAYMENT
    api_config JSONB NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_sync TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 33. TABEL VERSIONING & DATA HISTORY
-- ============================================

CREATE TABLE data_version (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER NOT NULL,
    version_number INTEGER NOT NULL,
    data_before JSONB,
    data_after JSONB,
    changed_by INTEGER REFERENCES users(id),
    change_type VARCHAR(10) CHECK (change_type IN ('INSERT', 'UPDATE', 'DELETE')),
    change_reason TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (table_name, record_id, version_number)
);

CREATE TABLE data_rollback_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER NOT NULL,
    from_version INTEGER NOT NULL,
    to_version INTEGER NOT NULL,
    rolled_back_by INTEGER REFERENCES users(id),
    rollback_reason TEXT,
    rolled_back_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_detail (
    id SERIAL PRIMARY KEY,
    audit_id INTEGER, -- Bisa merujuk ke berbagai tabel audit
    audit_type VARCHAR(50), -- KEUANGAN, AKADEMIK, OPERASIONAL
    field_name VARCHAR(100),
    old_value TEXT,
    new_value TEXT,
    change