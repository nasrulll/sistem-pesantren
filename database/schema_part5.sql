-- Lanjutan schema_part5.sql

-- Tabel penerima beasiswa
CREATE TABLE reward_penerima_beasiswa (
    id SERIAL PRIMARY KEY,
    pendaftaran_id INTEGER REFERENCES reward_pendaftaran_beasiswa(id) ON DELETE CASCADE,
    tanggal_ditetapkan DATE NOT NULL,
    periode_mulai DATE NOT NULL,
    periode_selesai DATE,
    nilai_beasiswa_diterima DECIMAL(15,2),
    metode_pencairan VARCHAR(50),
    status_pencairan VARCHAR(20) DEFAULT 'pending', -- pending, processed, completed
    tanggal_pencairan DATE,
    bukti_pencairan VARCHAR(500),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel monitoring penerima beasiswa
CREATE TABLE reward_monitoring_penerima (
    id SERIAL PRIMARY KEY,
    penerima_id INTEGER REFERENCES reward_penerima_beasiswa(id) ON DELETE CASCADE,
    periode_monitoring VARCHAR(50), -- bulanan, semester
    tanggal_monitoring DATE NOT NULL,
    ipk_semester DECIMAL(5,2),
    kehadiran_persentase DECIMAL(5,2),
    aktivitas_organisasi TEXT,
    prestasi_tambahan TEXT,
    catatan_ustadz TEXT,
    status_kepuasan VARCHAR(20), -- sangat_puas, puas, cukup, kurang
    rekomendasi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(penerima_id, periode_monitoring, tanggal_monitoring)
);

-- Tabel reward point system
CREATE TABLE reward_point_system (
    id SERIAL PRIMARY KEY,
    nama_reward VARCHAR(255) NOT NULL,
    deskripsi TEXT,
    jenis_reward VARCHAR(50), -- fisik, digital, privilege
    poin_dibutuhkan INTEGER NOT NULL,
    stok INTEGER,
    gambar_path VARCHAR(500),
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel klaim reward point
CREATE TABLE reward_klaim_point (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    reward_id INTEGER REFERENCES reward_point_system(id) ON DELETE SET NULL,
    poin_dipakai INTEGER NOT NULL,
    tanggal_klaim TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_klaim VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected, delivered
    tanggal_approve TIMESTAMP,
    approved_by INTEGER REFERENCES users(id),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel seleksi otomatis
CREATE TABLE reward_seleksi_otomatis (
    id SERIAL PRIMARY KEY,
    beasiswa_id INTEGER REFERENCES reward_jenis_beasiswa(id) ON DELETE CASCADE,
    algoritma_seleksi VARCHAR(100),
    parameter_config JSONB,
    tanggal_jalankan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_pendaftar INTEGER,
    total_lolos INTEGER,
    threshold_nilai DECIMAL(5,2),
    hasil_seleksi JSONB, -- JSON array of selected santri_ids with scores
    status VARCHAR(20) DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel laporan beasiswa
CREATE TABLE reward_laporan_beasiswa (
    id SERIAL PRIMARY KEY,
    periode VARCHAR(50) NOT NULL,
    tanggal_laporan DATE NOT NULL,
    total_beasiswa_aktif INTEGER,
    total_dana_beasiswa DECIMAL(15,2),
    rata_ipk_penerima DECIMAL(5,2),
    tingkat_kepuasan DECIMAL(5,2),
    rekomendasi TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(periode, tanggal_laporan)
);

-- ============================================
-- 40. DIGITAL SIGNATURE & APPROVAL
-- ============================================

-- Tabel digital signature profile
CREATE TABLE signature_profile (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    public_key TEXT NOT NULL,
    private_key_encrypted TEXT, -- Encrypted private key
    certificate_path VARCHAR(500),
    algorithm VARCHAR(50) DEFAULT 'RSA-SHA256',
    key_size INTEGER DEFAULT 2048,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- active, expired, revoked
    revocation_reason TEXT,
    revocation_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- Tabel dokumen untuk tanda tangan
CREATE TABLE signature_dokumen (
    id SERIAL PRIMARY KEY,
    dokumen_type VARCHAR(100) NOT NULL, -- surat, kontrak, laporan, sertifikat
    dokumen_id INTEGER NOT NULL, -- ID dari dokumen asli
    nama_dokumen VARCHAR(255) NOT NULL,
    hash_dokumen VARCHAR(255) NOT NULL,
    file_path VARCHAR(500),
    metadata JSONB,
    status VARCHAR(20) DEFAULT 'draft', -- draft, pending_signature, signed, rejected
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel proses tanda tangan
CREATE TABLE signature_process (
    id SERIAL PRIMARY KEY,
    dokumen_id INTEGER REFERENCES signature_dokumen(id) ON DELETE CASCADE,
    workflow_config JSONB, -- Urutan dan persyaratan tanda tangan
    status VARCHAR(20) DEFAULT 'pending', -- pending, in_progress, completed, cancelled
    tanggal_mulai TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tanggal_selesai TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel tanda tangan
CREATE TABLE signature_record (
    id SERIAL PRIMARY KEY,
    process_id INTEGER REFERENCES signature_process(id) ON DELETE CASCADE,
    signer_id INTEGER REFERENCES users(id),
    urutan INTEGER NOT NULL,
    signature_data TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT,
    certificate_used TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- pending, signed, rejected
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(process_id, signer_id)
);

-- Tabel audit trail tanda tangan
CREATE TABLE signature_audit_trail (
    id SERIAL PRIMARY KEY,
    dokumen_id INTEGER REFERENCES signature_dokumen(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL, -- created, viewed, signed, rejected, revoked
    user_id INTEGER REFERENCES users(id),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel validasi dokumen
CREATE TABLE signature_validation (
    id SERIAL PRIMARY KEY,
    dokumen_id INTEGER REFERENCES signature_dokumen(id) ON DELETE CASCADE,
    validator_id INTEGER REFERENCES users(id),
    tanggal_validasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hash_validasi VARCHAR(255),
    signature_valid BOOLEAN,
    certificate_valid BOOLEAN,
    timestamp_valid BOOLEAN,
    overall_valid BOOLEAN,
    catatan_validasi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel template dokumen
CREATE TABLE signature_template (
    id SERIAL PRIMARY KEY,
    nama_template VARCHAR(255) NOT NULL,
    jenis_dokumen VARCHAR(100),
    template_content TEXT NOT NULL,
    signature_fields JSONB, -- Array of signature field positions and requirements
    required_approvers TEXT[], -- Array of role names or user ids
    status VARCHAR(20) DEFAULT 'active',
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel timestamp authority
CREATE TABLE signature_timestamp_authority (
    id SERIAL PRIMARY KEY,
    authority_name VARCHAR(255) NOT NULL,
    service_url VARCHAR(500),
    api_key VARCHAR(500),
    certificate_path VARCHAR(500),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel timestamp record
CREATE TABLE signature_timestamp_record (
    id SERIAL PRIMARY KEY,
    dokumen_id INTEGER REFERENCES signature_dokumen(id) ON DELETE CASCADE,
    authority_id INTEGER REFERENCES signature_timestamp_authority(id),
    timestamp_token TEXT NOT NULL,
    timestamp_response TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES UNTUK PERFORMANCE
-- ============================================

-- Indexes untuk tabel alumni
CREATE INDEX idx_alumni_santri_id ON alumni(santri_id);
CREATE INDEX idx_alumni_tahun_lulus ON alumni(tahun_lulus);
CREATE INDEX idx_alumni_status_karir ON alumni(status_karir);

-- Indexes untuk tabel CRM
CREATE INDEX idx_crm_komunikasi_wali_id ON crm_komunikasi(wali_id);
CREATE INDEX idx_crm_komunikasi_tanggal ON crm_komunikasi(tanggal_jadwal);
CREATE INDEX idx_crm_ticket_wali_id ON crm_ticket(wali_id);
CREATE INDEX idx_crm_ticket_status ON crm_ticket(status);

-- Indexes untuk tabel SPMI
CREATE INDEX idx_spmi_audit_status ON spmi_audit(status);
CREATE INDEX idx_spmi_temuan_audit_id ON spmi_temuan(audit_id);
CREATE INDEX idx_spmi_temuan_status ON spmi_temuan(status_perbaikan);

-- Indexes untuk tabel kurikulum
CREATE INDEX idx_kurikulum_pencapaian_santri ON kurikulum_pencapaian_santri(santri_id, kompetensi_id);
CREATE INDEX idx_kurikulum_learning_step_path ON kurikulum_learning_step(learning_path_id, urutan);

-- Indexes untuk tabel scheduling
CREATE INDEX idx_scheduling_result_periode ON scheduling_result(periode_jadwal);
CREATE INDEX idx_scheduling_result_status ON scheduling_result(status);

-- Indexes untuk tabel CBT
CREATE INDEX idx_cbt_ujian_tanggal ON cbt_ujian(tanggal_mulai, tanggal_selesai);
CREATE INDEX idx_cbt_peserta_ujian_status ON cbt_peserta_ujian(status_pengerjaan);
CREATE INDEX idx_cbt_jawaban_peserta_ujian ON cbt_jawaban_peserta(peserta_ujian_id);

-- Indexes untuk tabel gamifikasi
CREATE INDEX idx_gamifikasi_transaksi_santri ON gamifikasi_transaksi(santri_id);
CREATE INDEX idx_gamifikasi_ranking_periode ON gamifikasi_ranking(periode_ranking, tanggal_ranking);

-- Indexes untuk tabel ibadah
CREATE INDEX idx_ibadah_tracking_santri_tanggal ON ibadah_tracking_sholat(santri_id, tanggal);
CREATE INDEX idx_ibadah_hafalan_santri ON ibadah_hafalan(santri_id);

-- Indexes untuk tabel bahasa
CREATE INDEX idx_bahasa_peserta_program ON bahasa_peserta(program_id, status);
CREATE INDEX idx_bahasa_assessment_santri ON bahasa_assessment(santri_id, bahasa);

-- Indexes untuk tabel marketplace
CREATE INDEX idx_marketplace_produk_penjual ON marketplace_produk(penjual_id, status);
CREATE INDEX idx_marketplace_pesanan_pembeli ON marketplace_pesanan(pembeli_id, status_pesanan);

-- Indexes untuk tabel transportasi
CREATE INDEX idx_transportasi_jadwal_hari ON transportasi_jadwal(hari, status);
CREATE INDEX idx_transportasi_booking_jadwal ON transportasi_booking(jadwal_id, status_booking);

-- Indexes untuk tabel disaster recovery
CREATE INDEX idx_dr_backup_log_status ON dr_backup_log(status);
CREATE INDEX idx_dr_failover_log_timestamp ON dr_failover_log(timestamp);

-- Indexes untuk tabel data warehouse
CREATE INDEX idx_dw_fact_akademik_tanggal ON dw_fact_akademik(tanggal_id);
CREATE INDEX idx_dw_fact_keuangan_tanggal ON dw_fact_keuangan(tanggal_id);

-- Indexes untuk tabel workflow
CREATE INDEX idx_workflow_instance_status ON workflow_instance(status);
CREATE INDEX idx_workflow_step_instance ON workflow_step(instance_id, status);

-- Indexes untuk tabel cabang
CREATE INDEX idx_cabang_santri_status ON cabang_santri(status);
CREATE INDEX idx_cabang_laporan_periode ON cabang_laporan_konsolidasi(periode, tanggal_laporan);

-- Indexes untuk tabel legal
CREATE INDEX idx_legal_perizinan_status ON legal_perizinan(status);
CREATE INDEX idx_legal_perizinan_kadaluarsa ON legal_perizinan(tanggal_kadaluarsa);

-- Indexes untuk tabel IoT
CREATE INDEX idx_iot_device_status ON iot_device(status);
CREATE INDEX idx_iot_sensor_listrik_timestamp ON iot_sensor_listrik(timestamp);
CREATE INDEX idx_iot_ai_detection_camera ON iot_ai_detection(camera_id, timestamp);

-- Indexes untuk tabel integrasi
CREATE INDEX idx_integrasi_siswa_sekolah ON integrasi_siswa_formal(sekolah_id, status);
CREATE INDEX idx_integrasi_sinkronisasi_siswa ON integrasi_sinkronisasi_nilai(siswa_id);

-- Indexes untuk tabel reward
CREATE INDEX idx_reward_pendaftaran_status ON reward_pendaftaran_beasiswa(status_pendaftaran);
CREATE INDEX idx_reward_penerima_status ON reward_penerima_beasiswa(status_pencairan);

-- Indexes untuk tabel signature
CREATE INDEX idx_signature_dokumen_status ON signature_dokumen(status);
CREATE INDEX idx_signature_process_status ON signature_process(status);
CREATE INDEX idx_signature_record_process ON signature_record(process_id, status);

-- ============================================
-- VIEWS UNTUK REPORTING
-- ============================================

-- View untuk laporan alumni
CREATE VIEW vw_alumni_summary AS
SELECT 
    a.id,
    a.nama_lengkap,
    a.tahun_lulus,
    a.pekerjaan_sekarang,
    a.perusahaan,
    COUNT(ak.id) as jumlah_pengalaman,
    COUNT(ap.id) as jumlah_pendidikan_lanjut,
    COALESCE(SUM(ad.jumlah), 0) as total_donasi
FROM alumni a
LEFT JOIN alumni_karir ak ON a.id = ak.alumni_id
LEFT JOIN alumni_pendidikan ap ON a.id = ap.alumni_id
LEFT JOIN alumni_donasi ad ON a.id = ad.alumni_id AND ad.status = 'success'
GROUP BY a.id;

-- View untuk CRM dashboard
CREATE VIEW vw_crm_dashboard AS
SELECT 
    w.id as wali_id,
    w.nama_lengkap,
    COUNT(DISTINCT k.id) as total_komunikasi,
    COUNT(DISTINCT t.id) as total_ticket,
    AVG(f.rating) as avg_rating,
    MAX(k.tanggal_selesai) as last_communication
FROM wali_santri w
LEFT JOIN crm_komunikasi k ON w.id = k.wali_id
LEFT JOIN crm_ticket t ON w.id = t.wali_id
LEFT JOIN crm_feedback f ON w.id = f.wali_id
GROUP BY w.id;

-- View untuk SPMI compliance
CREATE VIEW vw_spmi_compliance AS
SELECT 
    s.kode_standar,
    s.nama_standar,
    COUNT(DISTINCT i.id) as total_indikator,
    COUNT(DISTINCT t.id) as total_temuan,
    COUNT(DISTINCT CASE WHEN t.status_perbaikan = 'completed' THEN t.id END) as temuan_selesai,
    ROUND(COUNT(DISTINCT CASE WHEN t.status_perbaikan = 'completed' THEN t.id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT t.id), 0), 2) as persentase_selesai
FROM spmi_standar s
LEFT JOIN spmi_indikator i ON s.id = i.standar_id
LEFT JOIN spmi_temuan t ON i.id = t.indikator_id
GROUP BY s.id;

-- View untuk academic performance
CREATE VIEW vw_academic_performance AS
SELECT 
    s.id as santri_id,
    s.nama_lengkap,
    k.nama_kelas,
    COUNT(DISTINCT p.id) as total_presensi,
    COUNT(DISTINCT CASE WHEN p.status = 'hadir' THEN p.id END) as presensi_hadir,
    AVG(n.nilai) as rata_nilai,
    ROUND(COUNT(DISTINCT CASE WHEN p.status = 'hadir' THEN p.id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT p.id), 0), 2) as persentase_kehadiran
FROM santri s
LEFT JOIN kelas k ON s.kelas_id = k.id
LEFT JOIN presensi p ON s.id = p.santri_id
LEFT JOIN nilai n ON s.id = n.santri_id
GROUP BY s.id, k.id;

-- View untuk financial summary
CREATE VIEW vw_financial_summary AS
SELECT 
    DATE_TRUNC('month', t.tanggal_transaksi) as bulan,
    COUNT(DISTINCT t.id) as total_transaksi,
    SUM(CASE WHEN t.jenis = 'pemasukan' THEN t.jumlah ELSE 0 END) as total_pemasukan,
    SUM(CASE WHEN t.jenis = 'pengeluaran' THEN t.jumlah ELSE 0 END) as total_pengeluaran,
    SUM(CASE WHEN t.jenis = 'pemasukan' THEN t.jumlah ELSE 0 END) - 
    SUM(CASE WHEN t.jenis = 'pengeluaran' THEN t.jumlah ELSE 0 END) as