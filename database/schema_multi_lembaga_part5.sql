-- ============================================
-- 33. TABEL VERSIONING & DATA HISTORY (Lanjutan)
-- ============================================

CREATE TABLE audit_detail (
    id SERIAL PRIMARY KEY,
    audit_id INTEGER, -- Bisa merujuk ke berbagai tabel audit
    audit_type VARCHAR(50), -- KEUANGAN, AKADEMIK, OPERASIONAL
    field_name VARCHAR(100),
    old_value TEXT,
    new_value TEXT,
    change_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 34. TABEL SLA & MONITORING LAYANAN
-- ============================================

CREATE TABLE service_monitoring (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    service_type VARCHAR(50), -- API, DATABASE, CACHE, STORAGE
    endpoint_url VARCHAR(500),
    check_interval_seconds INTEGER DEFAULT 60,
    timeout_seconds INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE service_status_log (
    id SERIAL PRIMARY KEY,
    service_id INTEGER REFERENCES service_monitoring(id),
    check_time TIMESTAMP NOT NULL,
    response_time_ms INTEGER,
    status_code INTEGER,
    is_up BOOLEAN NOT NULL,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE service_alert (
    id SERIAL PRIMARY KEY,
    service_id INTEGER REFERENCES service_monitoring(id),
    alert_type VARCHAR(20) CHECK (alert_type IN ('DOWN', 'SLOW', 'ERROR_RATE')),
    alert_message TEXT NOT NULL,
    severity VARCHAR(20) CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    is_resolved BOOLEAN DEFAULT false,
    resolved_at TIMESTAMP,
    resolved_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sla_agreement (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    uptime_target DECIMAL(5,2) DEFAULT 99.9, -- Persentase
    response_time_target_ms INTEGER DEFAULT 1000,
    error_rate_target DECIMAL(5,2) DEFAULT 0.1, -- Persentase
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sla_performance (
    id SERIAL PRIMARY KEY,
    sla_id INTEGER REFERENCES sla_agreement(id),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    actual_uptime DECIMAL(5,2),
    avg_response_time_ms INTEGER,
    error_rate DECIMAL(5,2),
    is_met BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (sla_id, period_start, period_end)
);

-- ============================================
-- 35. TABEL OFFLINE MODE SYSTEM
-- ============================================

CREATE TABLE offline_sync_config (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    sync_priority INTEGER DEFAULT 1 CHECK (sync_priority BETWEEN 1 AND 10),
    sync_direction VARCHAR(10) CHECK (sync_direction IN ('UPLOAD', 'DOWNLOAD', 'BOTH')),
    conflict_resolution VARCHAR(20) DEFAULT 'SERVER_WINS' CHECK (conflict_resolution IN ('SERVER_WINS', 'CLIENT_WINS', 'MANUAL')),
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (table_name)
);

CREATE TABLE offline_data_queue (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(10) CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id INTEGER,
    data JSONB NOT NULL,
    sync_status VARCHAR(20) DEFAULT 'PENDING' CHECK (sync_status IN ('PENDING', 'SYNCING', 'SYNCED', 'FAILED')),
    retry_count INTEGER DEFAULT 0,
    last_retry TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    synced_at TIMESTAMP
);

CREATE TABLE device_sync_status (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100) UNIQUE NOT NULL,
    device_name VARCHAR(100),
    last_sync_time TIMESTAMP,
    sync_status VARCHAR(20) DEFAULT 'OFFLINE' CHECK (sync_status IN ('ONLINE', 'OFFLINE', 'SYNCING', 'ERROR')),
    pending_sync_count INTEGER DEFAULT 0,
    last_ip_address VARCHAR(45),
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sync_conflict (
    id SERIAL PRIMARY KEY,
    queue_id INTEGER REFERENCES offline_data_queue(id),
    server_data JSONB,
    client_data JSONB,
    conflict_type VARCHAR(50),
    resolution VARCHAR(20) DEFAULT 'PENDING' CHECK (resolution IN ('PENDING', 'RESOLVED', 'IGNORED')),
    resolved_by INTEGER REFERENCES users(id),
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 36. TABEL MULTI BAHASA SISTEM
-- ============================================

CREATE TABLE language (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) UNIQUE NOT NULL, -- id, ar, en
    name VARCHAR(100) NOT NULL, -- Indonesian, Arabic, English
    native_name VARCHAR(100),
    is_rtl BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0
);

CREATE TABLE translation_key (
    id SERIAL PRIMARY KEY,
    key_name VARCHAR(200) UNIQUE NOT NULL,
    module VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE translation (
    id SERIAL PRIMARY KEY,
    key_id INTEGER REFERENCES translation_key(id) ON DELETE CASCADE,
    language_id INTEGER REFERENCES language(id),
    translation_text TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT true,
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (key_id, language_id)
);

CREATE TABLE user_language_preference (
    user_id INTEGER REFERENCES users(id) PRIMARY KEY,
    language_id INTEGER REFERENCES language(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 37. TABEL BRANDING & WHITE LABEL
-- ============================================

CREATE TABLE white_label_config (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER REFERENCES tenant(id) UNIQUE,
    institution_name VARCHAR(200) NOT NULL,
    institution_logo_url VARCHAR(500),
    favicon_url VARCHAR(500),
    primary_color VARCHAR(7) DEFAULT '#3B82F6', -- Hex color
    secondary_color VARCHAR(7) DEFAULT '#10B981',
    accent_color VARCHAR(7) DEFAULT '#F59E0B',
    font_family VARCHAR(100) DEFAULT 'Inter, sans-serif',
    custom_css TEXT,
    custom_js TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE custom_domain (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER REFERENCES tenant(id),
    domain_name VARCHAR(100) UNIQUE NOT NULL,
    ssl_certificate TEXT,
    ssl_expiry_date DATE,
    is_active BOOLEAN DEFAULT true,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE branding_asset (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER REFERENCES tenant(id),
    asset_type VARCHAR(50), -- LOGO, FAVICON, BANNER, BACKGROUND
    asset_url VARCHAR(500) NOT NULL,
    asset_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE saas_pricing_plan (
    id SERIAL PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL,
    plan_code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    monthly_price DECIMAL(10,2),
    yearly_price DECIMAL(10,2),
    max_users INTEGER,
    max_students INTEGER,
    storage_gb INTEGER,
    features JSONB,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tenant_subscription (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER REFERENCES tenant(id) UNIQUE,
    plan_id INTEGER REFERENCES saas_pricing_plan(id),
    subscription_start DATE NOT NULL,
    subscription_end DATE NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (payment_status IN ('ACTIVE', 'PENDING', 'SUSPENDED', 'CANCELLED')),
    auto_renew BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 38. TABEL MOBILE APP SUITE
-- ============================================

CREATE TABLE mobile_app_version (
    id SERIAL PRIMARY KEY,
    platform VARCHAR(10) CHECK (platform IN ('IOS', 'ANDROID', 'BOTH')),
    version_code VARCHAR(20) NOT NULL,
    version_name VARCHAR(50) NOT NULL,
    minimum_os_version VARCHAR(20),
    download_url VARCHAR(500),
    release_notes TEXT,
    is_force_update BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    released_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mobile_device (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    device_id VARCHAR(255) UNIQUE NOT NULL,
    device_type VARCHAR(50), -- IOS, ANDROID
    device_model VARCHAR(100),
    os_version VARCHAR(20),
    app_version VARCHAR(20),
    push_token VARCHAR(500),
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mobile_notification (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    notification_type VARCHAR(50),
    is_read BOOLEAN DEFAULT false,
    is_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mobile_feature_flag (
    id SERIAL PRIMARY KEY,
    feature_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_enabled BOOLEAN DEFAULT true,
    enabled_for_ios BOOLEAN DEFAULT true,
    enabled_for_android BOOLEAN DEFAULT true,
    rollout_percentage INTEGER DEFAULT 100 CHECK (rollout_percentage BETWEEN 0 AND 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 39. TABEL ANALYTICS & BUSINESS INTELLIGENCE
-- ============================================

CREATE TABLE analytics_event (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    event_name VARCHAR(100) NOT NULL,
    event_category VARCHAR(100),
    event_label VARCHAR(200),
    event_value DECIMAL(10,2),
    session_id VARCHAR(100),
    page_url VARCHAR(500),
    referrer_url VARCHAR(500),
    user_agent TEXT,
    ip_address VARCHAR(45),
    device_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dashboard_widget (
    id SERIAL PRIMARY KEY,
    widget_name VARCHAR(100) NOT NULL,
    widget_type VARCHAR(50), -- CHART, TABLE, METRIC, LIST
    data_source VARCHAR(200),
    config JSONB NOT NULL,
    refresh_interval_seconds INTEGER DEFAULT 300,
    is_public BOOLEAN DEFAULT false,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_dashboard (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    dashboard_name VARCHAR(100) NOT NULL,
    layout_config JSONB NOT NULL,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, dashboard_name)
);

CREATE TABLE predictive_model (
    id SERIAL PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    model_type VARCHAR(50), -- CLASSIFICATION, REGRESSION, CLUSTERING
    target_variable VARCHAR(100),
    features JSONB,
    accuracy DECIMAL(5,4),
    last_trained TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE data_visualization (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    visualization_type VARCHAR(50), -- BAR, LINE, PIE, SCATTER, HEATMAP
    data_query TEXT,
    config JSONB NOT NULL,
    is_public BOOLEAN DEFAULT false,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 40. TABEL DISASTER RECOVERY & BACKUP
-- ============================================

CREATE TABLE backup_config (
    id SERIAL PRIMARY KEY,
    backup_type VARCHAR(20) CHECK (backup_type IN ('FULL', 'INCREMENTAL', 'DIFFERENTIAL')),
    schedule_cron VARCHAR(100) NOT NULL,
    retention_days INTEGER DEFAULT 30,
    storage_type VARCHAR(20) CHECK (storage_type IN ('LOCAL', 'S3', 'GCS', 'AZURE')),
    storage_config JSONB,
    is_active BOOLEAN DEFAULT true,
    last_run TIMESTAMP,
    next_run TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE backup_log (
    id SERIAL PRIMARY KEY,
    config_id INTEGER REFERENCES backup_config(id),
    backup_start TIMESTAMP NOT NULL,
    backup_end TIMESTAMP,
    backup_size_bytes BIGINT,
    backup_file_path VARCHAR(500),
    status VARCHAR(20) DEFAULT 'RUNNING' CHECK (status IN ('RUNNING', 'SUCCESS', 'FAILED', 'CANCELLED')),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE recovery_plan (
    id SERIAL PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL,
    description TEXT,
    rto_hours INTEGER DEFAULT 24, -- Recovery Time Objective
    rpo_hours INTEGER DEFAULT 1,  -- Recovery Point Objective
    steps JSONB NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_tested TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE disaster_recovery_drill (
    id SERIAL PRIMARY KEY,
    plan_id INTEGER REFERENCES recovery_plan(id),
    drill_date DATE NOT NULL,
    drill_scenario TEXT,
    participants TEXT[],
    success_criteria TEXT,
    actual_result TEXT,
    lessons_learned TEXT,
    status VARCHAR(20) DEFAULT 'PLANNED' CHECK (status IN ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE high_availability_config (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    primary_node VARCHAR(100),
    secondary_node VARCHAR(100),
    failover_mode VARCHAR(20) CHECK (failover_mode IN ('AUTOMATIC', 'MANUAL')),
    health_check_interval INTEGER DEFAULT 30,
    is_active BOOLEAN DEFAULT true,
    last_failover TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES UNTUK PERFORMANCE
-- ============================================

-- Indexes untuk tabel utama
CREATE INDEX idx_santri_nis ON santri(nis);
CREATE INDEX idx_santri_status ON santri(status);
CREATE INDEX idx_santri_tanggal_masuk ON santri(tanggal_masuk);

CREATE INDEX idx_santri_lembaga_santri ON santri_lembaga(santri_id);
CREATE INDEX idx_santri_lembaga_lembaga ON santri_lembaga(lembaga_id);
CREATE INDEX idx_santri_lembaga_tahun ON santri_lembaga(tahun_ajaran_id);

CREATE INDEX idx_tahfidz_setoran_santri ON tahfidz_setoran(santri_tahfidz_id);
CREATE INDEX idx_tahfidz_setoran_tanggal ON tahfidz_setoran(tanggal);
CREATE INDEX idx_tahfidz_setoran_juz ON tahfidz_setoran(juz);

CREATE INDEX idx_nilai_formal_santri ON nilai_formal(santri_id);
CREATE INDEX idx_nilai_formal_mapel ON nilai_formal(mata_pelajaran_id);
CREATE INDEX idx_nilai_formal_tahun ON nilai_formal(tahun_ajaran_id);

CREATE INDEX idx_tagihan_santri ON tagihan(santri_id);
CREATE INDEX idx_tagihan_status ON tagihan(status);
CREATE INDEX idx_tagihan_tanggal_tempo ON tagihan(tanggal_jatuh_tempo);

CREATE INDEX idx_kehadiran_santri_tanggal ON kehadiran_santri(santri_id, tanggal);
CREATE INDEX idx_kehadiran_status ON kehadiran_santri(status);

CREATE INDEX idx_notifikasi_wali_wali ON notifikasi_wali(wali_id);
CREATE INDEX idx_notifikasi_wali_read ON notifikasi_wali(is_read);
CREATE INDEX idx_notifikasi_wali_created ON notifikasi_wali(created_at);

-- Indexes untuk pencarian full-text
CREATE INDEX idx_santri_nama_fts ON santri USING gin(to_tsvector('indonesian', nama_lengkap));
CREATE