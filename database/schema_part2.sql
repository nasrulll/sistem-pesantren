-- Lanjutan Schema Database Pondok Pesantren
-- ============================================
-- 7. ASRAMA & DISIPLIN (lanjutan)
-- ============================================

-- Tabel Penempatan Kamar (lanjutan)
    tanggal_keluar DATE,
    status VARCHAR(20) CHECK (status IN ('aktif', 'pindah', 'keluar')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id) WHERE status = 'aktif'
);

-- Tabel Absensi Asrama
CREATE TABLE absensi_asrama (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal DATE DEFAULT CURRENT_DATE,
    waktu_masuk TIME,
    waktu_keluar TIME,
    status VARCHAR(20) CHECK (status IN ('hadir', 'izin', 'sakit', 'alpha', 'libur')),
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(santri_id, tanggal)
);

-- Tabel Jenis Pelanggaran
CREATE TABLE jenis_pelanggaran (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    kategori VARCHAR(50) CHECK (kategori IN ('ringan', 'sedang', 'berat')),
    point INTEGER DEFAULT 0,
    sanksi TEXT,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Pelanggaran Santri
CREATE TABLE pelanggaran_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    jenis_pelanggaran_id INTEGER REFERENCES jenis_pelanggaran(id),
    tanggal DATE DEFAULT CURRENT_DATE,
    lokasi VARCHAR(100),
    deskripsi TEXT,
    saksi TEXT,
    point_didapat INTEGER,
    ditangani_oleh INTEGER REFERENCES ustadz(id),
    tindakan TEXT,
    status VARCHAR(20) CHECK (status IN ('lapor', 'proses', 'selesai', 'dibatalkan')) DEFAULT 'lapor',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Perizinan Santri
CREATE TABLE perizinan_santri (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    jenis_izin VARCHAR(50) CHECK (jenis_izin IN ('pulang', 'kunjungan', 'kegiatan', 'sakit', 'lainnya')),
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE NOT NULL,
    alasan TEXT NOT NULL,
    tujuan VARCHAR(200),
    penjemput VARCHAR(100),
    hubungan_penjemput VARCHAR(50),
    no_hp_penjemput VARCHAR(20),
    disetujui_oleh INTEGER REFERENCES ustadz(id),
    status VARCHAR(20) CHECK (status IN ('pengajuan', 'disetujui', 'ditolak', 'selesai')) DEFAULT 'pengajuan',
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Konseling
CREATE TABLE konseling (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    konselor_id INTEGER REFERENCES ustadz(id),
    tanggal DATE DEFAULT CURRENT_DATE,
    waktu TIME,
    jenis_konseling VARCHAR(50),
    masalah TEXT,
    tindakan TEXT,
    rencana_tindak_lanjut TEXT,
    status VARCHAR(20) CHECK (status IN ('terjadwal', 'selesai', 'dibatalkan')) DEFAULT 'terjadwal',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 8. KESEHATAN
-- ============================================

-- Tabel Rekam Medis
CREATE TABLE rekam_medis (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    tanggal DATE DEFAULT CURRENT_DATE,
    keluhan TEXT,
    diagnosa TEXT,
    tindakan TEXT,
    obat TEXT,
    petugas_kesehatan VARCHAR(100),
    status VARCHAR(20) CHECK (status IN ('rawat', 'kontrol', 'selesai')) DEFAULT 'rawat',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Riwayat Penyakit
CREATE TABLE riwayat_penyakit (
    id SERIAL PRIMARY KEY,
    santri_id INTEGER REFERENCES santri(id),
    penyakit VARCHAR(100),
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    status VARCHAR(20) CHECK (status IN ('aktif', 'sembuh', 'kronis')),
    catatan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Stok Obat
CREATE TABLE stok_obat (
    id SERIAL PRIMARY KEY,
    kode_obat VARCHAR(20) UNIQUE NOT NULL,
    nama_obat VARCHAR(100) NOT NULL,
    jenis VARCHAR(50),
    satuan VARCHAR(20),
    stok_awal INTEGER DEFAULT 0,
    stok_sekarang INTEGER DEFAULT 0,
    tanggal_kadaluarsa DATE,
    harga_beli DECIMAL(15,2),
    harga_jual DECIMAL(15,2),
    supplier VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Penggunaan Obat
CREATE TABLE penggunaan_obat (
    id SERIAL PRIMARY KEY,
    rekam_medis_id INTEGER REFERENCES rekam_medis(id),
    obat_id INTEGER REFERENCES stok_obat(id),
    jumlah INTEGER NOT NULL,
    dosis TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 9. KOMUNIKASI
-- ============================================

-- Tabel Notifikasi
CREATE TABLE notifikasi (
    id SERIAL PRIMARY KEY,
    penerima_id INTEGER,
    penerima_tipe VARCHAR(20) CHECK (penerima_tipe IN ('santri', 'wali', 'ustadz', 'staf', 'semua')),
    judul VARCHAR(200) NOT NULL,
    pesan TEXT NOT NULL,
    jenis VARCHAR(50) CHECK (jenis IN ('info', 'pembayaran', 'akademik', 'kesehatan', 'disiplin', 'kegiatan')),
    channel VARCHAR(20) CHECK (channel IN ('whatsapp', 'telegram', 'email', 'sms', 'inapp')),
    status VARCHAR(20) CHECK (status IN ('draft', 'terkirim', 'gagal', 'dibaca')) DEFAULT 'draft',
    dikirim_pada TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Broadcast
CREATE TABLE broadcast (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(200) NOT NULL,
    konten TEXT NOT NULL,
    target VARCHAR(50) CHECK (target IN ('semua_santri', 'semua_wali', 'semua_ustadz', 'kelas', 'asrama', 'custom')),
    target_ids JSONB, -- berisi array ID target spesifik
    jadwal_kirim TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('draft', 'terjadwal', 'terkirim', 'dibatalkan')) DEFAULT 'draft',
    created_by INTEGER REFERENCES staf(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Chat Internal
CREATE TABLE chat_internal (
    id SERIAL PRIMARY KEY,
    pengirim_id INTEGER NOT NULL,
    pengirim_tipe VARCHAR(20) CHECK (pengirim_tipe IN ('santri', 'wali', 'ustadz', 'staf')),
    penerima_id INTEGER NOT NULL,
    penerima_tipe VARCHAR(20) CHECK (penerima_tipe IN ('santri', 'wali', 'ustadz', 'staf')),
    pesan TEXT NOT NULL,
    dibaca BOOLEAN DEFAULT FALSE,
    dibaca_pada TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 10. PERPUSTAKAAN
-- ============================================

-- Tabel Kategori Buku
CREATE TABLE kategori_buku (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Buku
CREATE TABLE buku (
    id SERIAL PRIMARY KEY,
    isbn VARCHAR(20),
    kode_buku VARCHAR(20) UNIQUE NOT NULL,
    judul VARCHAR(200) NOT NULL,
    kategori_id INTEGER REFERENCES kategori_buku(id),
    pengarang VARCHAR(100),
    penerbit VARCHAR(100),
    tahun_terbit INTEGER,
    bahasa VARCHAR(50),
    jumlah_halaman INTEGER,
    deskripsi TEXT,
    jumlah_total INTEGER DEFAULT 0,
    jumlah_tersedia INTEGER DEFAULT 0,
    lokasi_rak VARCHAR(50),
    cover_path VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('aktif', 'rusak', 'hilang', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Peminjaman Buku
CREATE TABLE peminjaman_buku (
    id SERIAL PRIMARY KEY,
    buku_id INTEGER REFERENCES buku(id),
    peminjam_id INTEGER,
    peminjam_tipe VARCHAR(20) CHECK (peminjam_tipe IN ('santri', 'ustadz', 'staf')),
    tanggal_pinjam DATE DEFAULT CURRENT_DATE,
    tanggal_kembali DATE,
    tanggal_dikembalikan DATE,
    denda DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) CHECK (status IN ('dipinjam', 'dikembalikan', 'terlambat', 'hilang')) DEFAULT 'dipinjam',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 11. SDM & KEPEGAWAIAN
-- ============================================

-- Tabel Absensi Pegawai
CREATE TABLE absensi_pegawai (
    id SERIAL PRIMARY KEY,
    pegawai_id INTEGER,
    pegawai_tipe VARCHAR(20) CHECK (pegawai_tipe IN ('ustadz', 'staf')),
    tanggal DATE DEFAULT CURRENT_DATE,
    jam_masuk TIME,
    jam_keluar TIME,
    status VARCHAR(20) CHECK (status IN ('hadir', 'izin', 'sakit', 'cuti', 'alpha', 'terlambat')),
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(pegawai_id, pegawai_tipe, tanggal)
);

-- Tabel Penggajian
CREATE TABLE penggajian (
    id SERIAL PRIMARY KEY,
    pegawai_id INTEGER,
    pegawai_tipe VARCHAR(20) CHECK (pegawai_tipe IN ('ustadz', 'staf')),
    periode_bulan INTEGER CHECK (periode_bulan BETWEEN 1 AND 12),
    periode_tahun INTEGER,
    gaji_pokok DECIMAL(15,2),
    tunjangan DECIMAL(15,2),
    potongan DECIMAL(15,2),
    total_gaji DECIMAL(15,2),
    status VARCHAR(20) CHECK (status IN ('draft', 'dibayar', 'dibatalkan')) DEFAULT 'draft',
    tanggal_bayar DATE,
    metode_bayar VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(pegawai_id, pegawai_tipe, periode_bulan, periode_tahun)
);

-- Tabel Penilaian Kinerja
CREATE TABLE penilaian_kinerja (
    id SERIAL PRIMARY KEY,
    pegawai_id INTEGER,
    pegawai_tipe VARCHAR(20) CHECK (pegawai_tipe IN ('ustadz', 'staf')),
    periode VARCHAR(50),
    penilai_id INTEGER REFERENCES staf(id),
    aspek_penilaian JSONB, -- berisi detail penilaian
    nilai_total DECIMAL(5,2),
    catatan TEXT,
    status VARCHAR(20) CHECK (status IN ('draft', 'final', 'dikirim')) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 12. INVENTARIS & ASET
-- ============================================

-- Tabel Kategori Inventaris
CREATE TABLE kategori_inventaris (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Inventaris
CREATE TABLE inventaris (
    id SERIAL PRIMARY KEY,
    kode_barang VARCHAR(50) UNIQUE NOT NULL,
    nama_barang VARCHAR(200) NOT NULL,
    kategori_id INTEGER REFERENCES kategori_inventaris(id),
    merk VARCHAR(100),
    tipe VARCHAR(100),
    serial_number VARCHAR(100),
    lokasi VARCHAR(100),
    kondisi VARCHAR(20) CHECK (kondisi IN ('baik', 'rusak_ringan', 'rusak_berat', 'hilang')),
    tanggal_pembelian DATE,
    harga_beli DECIMAL(15,2),
    masa_garansi DATE,
    foto_path VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('tersedia', 'dipinjam', 'maintenance', 'nonaktif')) DEFAULT 'tersedia',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Peminjaman Inventaris
CREATE TABLE peminjaman_inventaris (
    id SERIAL PRIMARY KEY,
    inventaris_id INTEGER REFERENCES inventaris(id),
    peminjam_id INTEGER,
    peminjam_tipe VARCHAR(20) CHECK (peminjam_tipe IN ('santri', 'ustadz', 'staf', 'kelas', 'asrama')),
    tanggal_pinjam DATE DEFAULT CURRENT_DATE,
    tanggal_kembali DATE,
    tanggal_dikembalikan DATE,
    tujuan_peminjaman TEXT,
    status VARCHAR(20) CHECK (status IN ('dipinjam', 'dikembalikan', 'terlambat', 'rusak', 'hilang')) DEFAULT 'dipinjam',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Maintenance
CREATE TABLE maintenance (
    id SERIAL PRIMARY KEY,
    inventaris_id INTEGER REFERENCES inventaris(id),
    tanggal DATE DEFAULT CURRENT_DATE,
    jenis_maintenance VARCHAR(50) CHECK (jenis_maintenance IN ('preventif', 'korektif', 'rutin')),
    deskripsi_kerusakan TEXT,
    tindakan TEXT,
    biaya DECIMAL(15,2),
    teknisi VARCHAR(100),
    status VARCHAR(20) CHECK (status IN ('dilaporkan', 'proses', 'selesai')) DEFAULT 'dilaporkan',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 13. UNIT USAHA / KOPERASI
-- ============================================

-- Tabel Supplier
CREATE TABLE supplier (
    id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    nama VARCHAR(200) NOT NULL,
    alamat TEXT,
    no_hp VARCHAR(20),
    email VARCHAR(100),
    jenis_supply TEXT,
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Produk Koperasi
CREATE TABLE produk_koperasi (
    id SERIAL PRIMARY KEY,
    kode_produk VARCHAR(20) UNIQUE NOT NULL,
    nama_produk VARCHAR(200) NOT NULL,
    kategori VARCHAR(100),
    satuan VARCHAR(20),
    stok INTEGER DEFAULT 0,
    harga_beli DECIMAL(15,2),
    harga_jual DECIMAL(15,2),
    supplier_id INTEGER REFERENCES supplier(id),
    foto_path VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('aktif', 'nonaktif', 'habis')) DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Penjualan
CREATE TABLE penjualan (
    id SERIAL PRIMARY KEY,
    no_transaksi VARCHAR(50) UNIQUE NOT NULL,
    tanggal DATE DEFAULT CURRENT_DATE,
    pembeli_id INTEGER,
    pembeli_tipe VARCHAR(20) CHECK (pembeli_tipe IN ('santri', 'ustadz', 'staf', 'umum')),
    total DECIMAL(15,2),
    diskon DECIMAL(15,2) DEFAULT 0,
    grand_total DECIMAL(15,2),
    metode_bayar VARCHAR(50) CHECK (metode_bayar IN ('tunai', 'cashless', 'tabungan')),
    status VARCHAR(20) CHECK (status IN ('draft', 'selesai', 'dibatalkan')) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Detail Penjualan
CREATE TABLE detail_penjualan (
    id SERIAL PRIMARY KEY,
    penjualan_id INTEGER REFERENCES penjualan(id),
    produk_id INTEGER REFERENCES produk_koperasi(id),
    jumlah INTEGER NOT NULL,
    harga DECIMAL(15