-- Lanjutan schema_part4.sql

-- Tabel target ibadah harian
CREATE TABLE ibadah_target_harian (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    tanggal DATE NOT NULL,
    target_sholat INTEGER DEFAULT 5,
    target_tilawah INTEGER, -- dalam juz
    target_dzikir INTEGER, -- dalam menit
    target_qiyamul_lail BOOLEAN DEFAULT FALSE,
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, tanggal)
);

-- Tabel pencapaian ibadah harian
CREATE TABLE ibadah_pencapaian_harian (
    id SERIAL PRIMARY KEY,
    target_id INTEGER REFERENCES ibadah_target_harian(id) ON DELETE CASCADE,
    sholat_tercapai INTEGER DEFAULT 0,
    tilawah_tercapai DECIMAL(3,1), -- dalam juz
    dzikir_tercapai INTEGER, -- dalam menit
    qiyamul_lail_tercapai BOOLEAN DEFAULT FALSE,
    catatan TEXT,
    tanggal_lapor TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'draft', -- draft, submitted, verified
    verified_by INTEGER REFERENCES users(id),
    tanggal_verifikasi TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel qiyamul lail / sunnah
CREATE TABLE ibadah_qiyamul_lail (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    tanggal DATE NOT NULL,
    waktu_mulai TIME,
    waktu_selesai TIME,
    jumlah_rakaat INTEGER,
    jenis_ibadah VARCHAR(50), -- tahajud, witir, hajat, dll
    catatan TEXT,
    pencatat_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, tanggal)
);

-- Tabel hafalan Al-Quran
CREATE TABLE ibadah_hafalan (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    tanggal DATE NOT NULL,
    surat VARCHAR(100) NOT NULL,
    ayat_awal INTEGER NOT NULL,
    ayat_akhir INTEGER NOT NULL,
    status_hafalan VARCHAR(20), -- baru, murojaah, lancar
    metode_hafalan VARCHAR(50),
    penguji_id INTEGER REFERENCES users(id),
    nilai DECIMAL(5,2),
    catatan_penguji TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel murojaah hafalan
CREATE TABLE ibadah_murojaah (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    tanggal DATE NOT NULL,
    jenis_murojaah VARCHAR(50), -- harian, mingguan, bulanan
    surat_dan_ayat TEXT, -- JSON array of surat:ayat
    durasi INTEGER, -- dalam menit
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel statistik ibadah
CREATE TABLE ibadah_statistik (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    periode VARCHAR(50) NOT NULL, -- harian, mingguan, bulanan
    tanggal_periode DATE NOT NULL,
    total_sholat INTEGER DEFAULT 0,
    total_tilawah DECIMAL(5,2) DEFAULT 0, -- dalam juz
    total_dzikir INTEGER DEFAULT 0, -- dalam menit
    total_qiyamul_lail INTEGER DEFAULT 0,
    konsistensi_sholat DECIMAL(5,2), -- persentase
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, periode, tanggal_periode)
);

-- ============================================
-- 29. MANAJEMEN BAHASA (ARAB/INGGRIS)
-- ============================================

-- Tabel program language area
CREATE TABLE bahasa_program (
    id SERIAL PRIMARY KEY,
    nama_program VARCHAR(255) NOT NULL,
    bahasa_target VARCHAR(50) NOT NULL, -- arab, inggris
    deskripsi TEXT,
    level_program VARCHAR(50), -- dasar, menengah, lanjut
    durasi_program INTEGER, -- dalam minggu
    target_kompetensi TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel peserta program bahasa
CREATE TABLE bahasa_peserta (
    id SERIAL PRIMARY KEY,
    program_id INTEGER REFERENCES bahasa_program(id) ON DELETE CASCADE,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    level_awal VARCHAR(50),
    level_sekarang VARCHAR(50),
    mentor_id INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'active', -- active, completed, dropped
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(program_id, santri_id)
);

-- Tabel tracking penggunaan bahasa
CREATE TABLE bahasa_tracking (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    tanggal DATE NOT NULL,
    bahasa VARCHAR(50) NOT NULL, -- arab, inggris
    konteks_penggunaan VARCHAR(100), -- kelas, asrama, makan, umum
    durasi_penggunaan INTEGER, -- dalam menit
    kualitas_penggunaan INTEGER CHECK (kualitas_penggunaan >= 1 AND kualitas_penggunaan <= 5),
    pencatat_id INTEGER REFERENCES users(id),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel pelanggaran bahasa
CREATE TABLE bahasa_pelanggaran (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    tanggal TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    bahasa_yang_seharusnya VARCHAR(50),
    bahasa_yang_digunakan VARCHAR(50),
    konteks VARCHAR(100),
    pelanggaran_ke INTEGER DEFAULT 1,
    sanksi VARCHAR(255),
    pencatat_id INTEGER REFERENCES users(id),
    status_sanksi VARCHAR(20) DEFAULT 'pending', -- pending, executed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel vocabulary santri
CREATE TABLE bahasa_vocabulary (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    bahasa VARCHAR(50) NOT NULL,
    kata VARCHAR(255) NOT NULL,
    arti TEXT,
    contoh_penggunaan TEXT,
    level_kesulitan VARCHAR(20),
    tanggal_learn TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_mastery VARCHAR(20) DEFAULT 'learning', -- learning, reviewing, mastered
    last_reviewed TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel conversation practice
CREATE TABLE bahasa_conversation (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    partner_id INTEGER REFERENCES santri(id) ON DELETE SET NULL,
    bahasa VARCHAR(50) NOT NULL,
    topik VARCHAR(255),
    tanggal TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    durasi INTEGER, -- dalam menit
    evaluator_id INTEGER REFERENCES users(id),
    fluency_score INTEGER CHECK (fluency_score >= 1 AND fluency_score <= 5),
    accuracy_score INTEGER CHECK (accuracy_score >= 1 AND accuracy_score <= 5),
    vocabulary_score INTEGER CHECK (vocabulary_score >= 1 AND vocabulary_score <= 5),
    catatan_evaluator TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel assessment bahasa
CREATE TABLE bahasa_assessment (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    bahasa VARCHAR(50) NOT NULL,
    jenis_assessment VARCHAR(100), -- listening, speaking, reading, writing
    tanggal_assessment DATE NOT NULL,
    assessor_id INTEGER REFERENCES users(id),
    skor DECIMAL(5,2),
    level_hasil VARCHAR(50),
    rekomendasi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 30. MARKETPLACE INTERNAL PONDOK
-- ============================================

-- Tabel kategori produk
CREATE TABLE marketplace_kategori (
    id SERIAL PRIMARY KEY,
    nama_kategori VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    icon VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel produk
CREATE TABLE marketplace_produk (
    id SERIAL PRIMARY KEY,
    kode_produk VARCHAR(50) UNIQUE NOT NULL,
    nama_produk VARCHAR(255) NOT NULL,
    deskripsi TEXT,
    kategori_id INTEGER REFERENCES marketplace_kategori(id),
    penjual_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    harga DECIMAL(15,2) NOT NULL,
    stok INTEGER NOT NULL,
    kondisi VARCHAR(50), -- baru, bekas
    gambar_paths TEXT[], -- Array of image paths
    berat DECIMAL(8,2), -- dalam gram
    dimensi VARCHAR(100), -- panjang x lebar x tinggi (cm)
    status VARCHAR(20) DEFAULT 'draft', -- draft, published, sold_out, archived
    views INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel produk karya santri
CREATE TABLE marketplace_produk_karya (
    id SERIAL PRIMARY KEY,
    produk_id INTEGER REFERENCES marketplace_produk(id) ON DELETE CASCADE,
    jenis_karya VARCHAR(100), -- kerajinan, makanan, tulisan, digital
    bahan_utama TEXT,
    proses_pembuatan TEXT,
    waktu_pembuatan INTEGER, -- dalam jam
    sertifikasi BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel keranjang belanja
CREATE TABLE marketplace_keranjang (
    id SERIAL PRIMARY KEY,
    pembeli_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    produk_id INTEGER REFERENCES marketplace_produk(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(pembeli_id, produk_id)
);

-- Tabel pesanan
CREATE TABLE marketplace_pesanan (
    id SERIAL PRIMARY KEY,
    nomor_pesanan VARCHAR(50) UNIQUE NOT NULL,
    pembeli_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    tanggal_pesanan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_harga DECIMAL(15,2) NOT NULL,
    biaya_pengiriman DECIMAL(10,2) DEFAULT 0,
    total_bayar DECIMAL(15,2) NOT NULL,
    metode_pembayaran VARCHAR(50),
    status_pembayaran VARCHAR(20) DEFAULT 'pending', -- pending, paid, failed, refunded
    status_pesanan VARCHAR(20) DEFAULT 'pending', -- pending, processing, shipped, delivered, cancelled
    alamat_pengiriman TEXT,
    kurir VARCHAR(100),
    nomor_resi VARCHAR(100),
    tanggal_kirim TIMESTAMP,
    tanggal_terima TIMESTAMP,
    catatan_pembeli TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel detail pesanan
CREATE TABLE marketplace_pesanan_detail (
    id SERIAL PRIMARY KEY,
    pesanan_id INTEGER REFERENCES marketplace_pesanan(id) ON DELETE CASCADE,
    produk_id INTEGER REFERENCES marketplace_produk(id),
    quantity INTEGER NOT NULL,
    harga_satuan DECIMAL(15,2) NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel transaksi pembayaran
CREATE TABLE marketplace_pembayaran (
    id SERIAL PRIMARY KEY,
    pesanan_id INTEGER REFERENCES marketplace_pesanan(id) ON DELETE CASCADE,
    metode_pembayaran VARCHAR(50) NOT NULL,
    jumlah_bayar DECIMAL(15,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    bukti_bayar VARCHAR(500),
    tanggal_bayar TIMESTAMP,
    verified_by INTEGER REFERENCES users(id),
    tanggal_verifikasi TIMESTAMP,
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel review produk
CREATE TABLE marketplace_review (
    id SERIAL PRIMARY KEY,
    pesanan_detail_id INTEGER REFERENCES marketplace_pesanan_detail(id) ON DELETE CASCADE,
    pembeli_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    komentar TEXT,
    gambar_review TEXT[],
    status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel unit usaha digital
CREATE TABLE marketplace_unit_usaha (
    id SERIAL PRIMARY KEY,
    nama_unit VARCHAR(255) NOT NULL,
    deskripsi TEXT,
    penanggung_jawab INTEGER REFERENCES santri(id) ON DELETE SET NULL,
    jenis_usaha VARCHAR(100),
    modal_awal DECIMAL(15,2),
    tanggal_berdiri DATE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel laporan keuangan unit usaha
CREATE TABLE marketplace_laporan_keuangan (
    id SERIAL PRIMARY KEY,
    unit_usaha_id INTEGER REFERENCES marketplace_unit_usaha(id) ON DELETE CASCADE,
    periode VARCHAR(50) NOT NULL, -- bulanan, triwulan, semester, tahunan
    tanggal_laporan DATE NOT NULL,
    pendapatan DECIMAL(15,2) DEFAULT 0,
    pengeluaran DECIMAL(15,2) DEFAULT 0,
    laba_bersih DECIMAL(15,2),
    aset DECIMAL(15,2),
    hutang DECIMAL(15,2),
    modal DECIMAL(15,2),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(unit_usaha_id, periode, tanggal_laporan)
);

-- ============================================
-- 31. SISTEM TRANSPORTASI
-- ============================================

-- Tabel kendaraan
CREATE TABLE transportasi_kendaraan (
    id SERIAL PRIMARY KEY,
    nomor_polisi VARCHAR(20) UNIQUE NOT NULL,
    jenis_kendaraan VARCHAR(50) NOT NULL, -- bus, minibus, mobil, motor
    merk VARCHAR(100),
    tahun_pembuatan INTEGER,
    kapasitas_penumpang INTEGER,
    supir_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'active', -- active, maintenance, retired
    tanggal_service_terakhir DATE,
    tanggal_service_berikutnya DATE,
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel rute transportasi
CREATE TABLE transportasi_rute (
    id SERIAL PRIMARY KEY,
    kode_rute VARCHAR(50) UNIQUE NOT NULL,
    nama_rute VARCHAR(255) NOT NULL,
    titik_awal VARCHAR(255) NOT NULL,
    titik_akhir VARCHAR(255) NOT NULL,
    jarak_km DECIMAL(8,2),
    estimasi_waktu INTEGER, -- dalam menit
    biaya_per_penumpang DECIMAL(10,2),
    aktif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel jadwal perjalanan
CREATE TABLE transportasi_jadwal (
    id SERIAL PRIMARY KEY,
    rute_id INTEGER REFERENCES transportasi_rute(id) ON DELETE CASCADE,
    kendaraan_id INTEGER REFERENCES transportasi_kendaraan(id) ON DELETE SET NULL,
    hari VARCHAR(10) NOT NULL, -- Senin, Selasa, etc
    waktu_berangkat TIME NOT NULL,
    waktu_tiba TIME,
    supir_id INTEGER REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'scheduled', -- scheduled, on_time, delayed, cancelled, completed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel booking transportasi
CREATE TABLE transportasi_booking (
    id SERIAL PRIMARY KEY,
    jadwal_id INTEGER REFERENCES transportasi_jadwal(id) ON DELETE CASCADE,
    santri_id INTEGER REFERENCES santri(id) ON DELETE CASCADE,
    wali_id INTEGER REFERENCES wali_santri(id) ON DELETE SET NULL,
    tanggal_booking DATE NOT NULL,
    titik_naik VARCHAR(255),
    titik_turun VARCHAR(255),
    jumlah_penumpang INTEGER DEFAULT 1,
    status_booking VARCHAR(20) DEFAULT 'pending', -- pending, confirmed, cancelled, completed
    pembayaran_status VARCHAR(20) DEFAULT 'pending',
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel tracking kendaraan
CREATE TABLE transportasi_tracking (
    id SERIAL PRIMARY KEY,
    kendaraan_id INTEGER REFERENCES transportasi_kendaraan(id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    speed DECIMAL(5,2), -- km/h
    heading DECIMAL(5,2), -- derajat
    altitude DECIMAL(8,2), -- meter
    accuracy DECIMAL(5,2), -- meter
    battery_level INTEGER, -- persen
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel maintenance kendaraan
CREATE TABLE transportasi_maintenance (
    id SERIAL PRIMARY KEY,
    kendaraan_id INTEGER REFERENCES transportasi_kendaraan(id) ON DELETE CASCADE,
    tanggal_maintenance DATE NOT NULL,
    jenis_maintenance VARCHAR(