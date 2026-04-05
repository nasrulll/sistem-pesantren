// ============================================
// CONTINUATION OF PESANTREN SYSTEM API
// ============================================

// MODULE 8: KEUANGAN TERINTEGRASI (continued)
if (end_date) {
  query += ` AND tp.tanggal_transaksi <= $${paramCount}`;
  params.push(end_date);
  paramCount++;
}

query += ' ORDER BY tp.tanggal_transaksi DESC LIMIT 100';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 9: ASRAMA & KEHIDUPAN SANTRI
// ============================================

app.get('/api/asrama/kamar', authenticateToken, async (req, res, next) => {
try {
const { gedung_id, status } = req.query;
let query = `
  SELECT k.*, g.nama as gedung_nama, 
         COUNT(pk.id) as terisi,
         k.kapasitas - COUNT(pk.id) as tersedia
  FROM kamar k
  LEFT JOIN gedung_asrama g ON k.gedung_id = g.id
  LEFT JOIN penempatan_kamar pk ON k.id = pk.kamar_id AND pk.status = 'aktif'
  WHERE 1=1
`;
const params = [];
let paramCount = 1;

if (gedung_id) {
  query += ` AND k.gedung_id = $${paramCount}`;
  params.push(gedung_id);
  paramCount++;
}

if (status) {
  query += ` AND k.status = $${paramCount}`;
  params.push(status);
  paramCount++;
}

query += ' GROUP BY k.id, g.nama ORDER BY k.gedung_id, k.nomor_kamar';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 10: SDM TERPISAH & TERINTEGRASI
// ============================================

app.get('/api/sdm/ustadz', authenticateToken, async (req, res, next) => {
try {
const { status, lembaga } = req.query;
let query = `
  SELECT u.*, l.nama as lembaga_nama 
  FROM ustadz u 
  LEFT JOIN lembaga l ON u.lembaga_id = l.id 
  WHERE 1=1
`;
const params = [];
let paramCount = 1;

if (status) {
  query += ` AND u.status = $${paramCount}`;
  params.push(status);
  paramCount++;
}

if (lembaga) {
  query += ` AND u.lembaga_id = $${paramCount}`;
  params.push(lembaga);
  paramCount++;
}

query += ' ORDER BY u.nama_lengkap';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 11: RAPORT TERPADU
// ============================================

app.get('/api/raport', authenticateToken, async (req, res, next) => {
try {
const { santri_id, semester, tahun_ajaran } = req.query;
let query = `
  SELECT r.*, s.nama_lengkap, s.nis, l.nama as lembaga_nama
  FROM raport r
  LEFT JOIN santri s ON r.santri_id = s.id
  LEFT JOIN lembaga l ON s.lembaga_id = l.id
  WHERE 1=1
`;
const params = [];
let paramCount = 1;

if (santri_id) {
  query += ` AND r.santri_id = $${paramCount}`;
  params.push(santri_id);
  paramCount++;
}

if (semester) {
  query += ` AND r.semester = $${paramCount}`;
  params.push(semester);
  paramCount++;
}

if (tahun_ajaran) {
  query += ` AND r.tahun_ajaran = $${paramCount}`;
  params.push(tahun_ajaran);
  paramCount++;
}

query += ' ORDER BY r.tahun_ajaran DESC, r.semester DESC';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 12: INTEGRASI PEMERINTAH
// ============================================

app.get('/api/government/dapodik', authenticateToken, authorize('admin'), async (req, res, next) => {
try {
const { nisn } = req.query;
if (!nisn) {
  return res.status(400).json({ error: 'NISN required' });
}

// Simulasi integrasi dengan Dapodik
const dapodikData = {
  nisn: nisn,
  nama: 'Data dari Dapodik',
  sekolah_asal: 'SMP Negeri 1 Contoh',
  alamat: 'Jl. Contoh No. 123',
  // ... data lainnya
};

res.json(dapodikData);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 13: MONITORING ORANG TUA
// ============================================

app.get('/api/orangtua/notifikasi', authenticateToken, async (req, res, next) => {
try {
const { santri_id } = req.query;
if (!santri_id) {
  return res.status(400).json({ error: 'Santri ID required' });
}

const query = `
  SELECT 
    'presensi' as jenis,
    p.tanggal,
    p.status,
    mp.nama as mata_pelajaran
  FROM presensi p
  LEFT JOIN jadwal_pelajaran jp ON p.jadwal_id = jp.id
  LEFT JOIN mata_pelajaran mp ON jp.mata_pelajaran_id = mp.id
  WHERE p.santri_id = $1 AND p.tanggal >= CURRENT_DATE - INTERVAL '7 days'
  
  UNION ALL
  
  SELECT 
    'pembayaran' as jenis,
    tp.tanggal_transaksi as tanggal,
    tp.status,
    jp.nama as keterangan
  FROM transaksi_pembayaran tp
  LEFT JOIN jenis_pembayaran jp ON tp.jenis_pembayaran_id = jp.id
  WHERE tp.santri_id = $1 AND tp.tanggal_transaksi >= CURRENT_DATE - INTERVAL '30 days'
  
  UNION ALL
  
  SELECT 
    'nilai' as jenis,
    na.created_at::date as tanggal,
    'update' as status,
    mp.nama as keterangan
  FROM nilai_akademik na
  LEFT JOIN mata_pelajaran mp ON na.mata_pelajaran_id = mp.id
  WHERE na.santri_id = $1 AND na.created_at >= CURRENT_DATE - INTERVAL '30 days'
  
  ORDER BY tanggal DESC
`;

const result = await executeQuery(query, [santri_id]);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 14: DASHBOARD PIMPINAN PONDOK
// ============================================

app.get('/api/dashboard/summary', authenticateToken, async (req, res, next) => {
try {
// Get counts from database
const santriCount = await executeQuery('SELECT COUNT(*) as total FROM santri WHERE status = $1', ['aktif']);
const ustadzCount = await executeQuery('SELECT COUNT(*) as total FROM ustadz WHERE status = $1', ['aktif']);
const kamarCount = await executeQuery('SELECT COUNT(*) as total FROM kamar WHERE status = $1', ['tersedia']);
const transaksiCount = await executeQuery(
  "SELECT COUNT(*) as total FROM transaksi_pembayaran WHERE status = $1 AND tanggal_transaksi >= CURRENT_DATE - INTERVAL '30 days'", 
  ['paid']
);

// Get financial summary
const financialResult = await executeQuery(`
  SELECT 
    SUM(CASE WHEN status = 'paid' THEN jumlah ELSE 0 END) as total_paid,
    SUM(CASE WHEN status = 'pending' THEN jumlah ELSE 0 END) as total_pending,
    COUNT(*) as total_transactions
  FROM transaksi_pembayaran
  WHERE tanggal_transaksi >= CURRENT_DATE - INTERVAL '30 days'
`);

// Get academic summary
const academicResult = await executeQuery(`
  SELECT 
    AVG(nilai_akhir) as rata_rata_nilai,
    COUNT(DISTINCT santri_id) as total_santri_terlibat,
    COUNT(*) as total_nilai
  FROM nilai_akademik
  WHERE created_at >= CURRENT_DATE - INTERVAL '90 days'
`);

res.json({
  summary: {
    santri_aktif: parseInt(santriCount.rows[0].total),
    ustadz_aktif: parseInt(ustadzCount.rows[0].total),
    kamar_tersedia: parseInt(kamarCount.rows[0].total),
    transaksi_30hari: parseInt(transaksiCount.rows[0].total)
  },
  financial: financialResult.rows[0],
  academic: academicResult.rows[0],
  timestamp: new Date().toISOString()
});
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 15: MANAJEMEN KENAIKAN & KELULUSAN
// ============================================

app.post('/api/kelulusan/proses', authenticateToken, authorize('admin'), async (req, res, next) => {
try {
const { tahun_ajaran, lembaga_id } = req.body;

// Proses kenaikan kelas
const kenaikanQuery = `
  UPDATE santri 
  SET kelas = 
    CASE 
      WHEN kelas LIKE '7%' THEN REPLACE(kelas, '7', '8')
      WHEN kelas LIKE '8%' THEN REPLACE(kelas, '8', '9')
      WHEN kelas LIKE '9%' THEN REPLACE(kelas, '9', '10')
      ELSE kelas
    END,
    updated_at = CURRENT_TIMESTAMP
  WHERE status = 'aktif' 
    AND lembaga_id = $1
    AND kelas NOT LIKE '12%'
`;

await executeQuery(kenaikanQuery, [lembaga_id]);

// Proses kelulusan
const kelulusanQuery = `
  UPDATE santri 
  SET status = 'alumni', 
      updated_at = CURRENT_TIMESTAMP
  WHERE status = 'aktif' 
    AND lembaga_id = $1
    AND (kelas LIKE '12%' OR kelas LIKE 'III%')
`;

await executeQuery(kelulusanQuery, [lembaga_id]);

res.json({ 
  message: 'Proses kenaikan dan kelulusan berhasil',
  tahun_ajaran,
  lembaga_id
});
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 16: SERTIFIKASI & IJAZAH
// ============================================

app.get('/api/ijazah', authenticateToken, async (req, res, next) => {
try {
const { santri_id, jenis } = req.query;
let query = `
  SELECT i.*, s.nama_lengkap, s.nis, l.nama as lembaga_nama
  FROM ijazah i
  LEFT JOIN santri s ON i.santri_id = s.id
  LEFT JOIN lembaga l ON s.lembaga_id = l.id
  WHERE 1=1
`;
const params = [];
let paramCount = 1;

if (santri_id) {
  query += ` AND i.santri_id = $${paramCount}`;
  params.push(santri_id);
  paramCount++;
}

if (jenis) {
  query += ` AND i.jenis = $${paramCount}`;
  params.push(jenis);
  paramCount++;
}

query += ' ORDER BY i.tanggal_terbit DESC';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 17: ALUMNI TERINTEGRASI
// ============================================

app.get('/api/alumni', authenticateToken, async (req, res, next) => {
try {
const { tahun_lulus, pekerjaan } = req.query;
let query = `
  SELECT a.*, s.nama_lengkap, s.nis, s.tanggal_lahir, l.nama as lembaga_nama
  FROM alumni a
  LEFT JOIN santri s ON a.santri_id = s.id
  LEFT JOIN lembaga l ON s.lembaga_id = l.id
  WHERE 1=1
`;
const params = [];
let paramCount = 1;

if (tahun_lulus) {
  query += ` AND a.tahun_lulus = $${paramCount}`;
  params.push(tahun_lulus);
  paramCount++;
}

if (pekerjaan) {
  query += ` AND a.pekerjaan ILIKE $${paramCount}`;
  params.push(`%${pekerjaan}%`);
  paramCount++;
}

query += ' ORDER BY a.tahun_lulus DESC';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 18: KURIKULUM HYBRID
// ============================================

app.get('/api/kurikulum', authenticateToken, async (req, res, next) => {
try {
const { lembaga_id, is_active } = req.query;
let query = 'SELECT * FROM kurikulum WHERE 1=1';
const params = [];
let paramCount = 1;

if (lembaga_id) {
  query += ` AND lembaga_id = $${paramCount}`;
  params.push(lembaga_id);
  paramCount++;
}

if (is_active !== undefined) {
  query += ` AND is_active = $${paramCount}`;
  params.push(is_active === 'true');
  paramCount++;
}

query += ' ORDER BY tahun_ajaran DESC, semester DESC';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 19: SISTEM PRESTASI SANTRI
// ============================================

app.get('/api/prestasi', authenticateToken, async (req, res, next) => {
try {
const { santri_id, tahun, tingkat } = req.query;
let query = `
  SELECT p.*, s.nama_lengkap, s.nis, l.nama as lembaga_nama
  FROM prestasi p
  LEFT JOIN santri s ON p.santri_id = s.id
  LEFT JOIN lembaga l ON s.lembaga_id = l.id
  WHERE 1=1
`;
const params = [];
let paramCount = 1;

if (santri_id) {
  query += ` AND p.santri_id = $${paramCount}`;
  params.push(santri_id);
  paramCount++;
}

if (tahun) {
  query += ` AND EXTRACT(YEAR FROM p.tanggal_prestasi) = $${paramCount}`;
  params.push(tahun);
  paramCount++;
}

if (tingkat) {
  query += ` AND p.tingkat = $${paramCount}`;
  params.push(tingkat);
  paramCount++;
}

query += ' ORDER BY p.tanggal_prestasi DESC';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 20: INFRASTRUKTUR MULTI UNIT
// ============================================

app.get('/api/infrastruktur/fasilitas', authenticateToken, async (req, res, next) => {
try {
const { jenis, status } = req.query;
let query = 'SELECT * FROM fasilitas WHERE 1=1';
const params = [];
let paramCount = 1;

if (jenis) {
  query += ` AND jenis = $${paramCount}`;
  params.push(jenis);
  paramCount++;
}

if (status) {
  query += ` AND status = $${paramCount}`;
  params.push(status);
  paramCount++;
}

query += ' ORDER BY nama';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE 21: SISTEM PSIKOLOGI & KARAKTER SANTRI
// ============================================

app.get('/api/psikologi/assessment', authenticateToken, authorize('admin', 'kesehatan'), async (req, res, next) => {
try {
const { santri_id, start_date, end_date } = req.query;
let query = `
  SELECT a.*, s.nama_lengkap, s.nis, u.nama_lengkap as psikolog_nama
  FROM assessment_psikologi a
  LEFT JOIN santri s ON a.santri_id = s.id
  LEFT JOIN ustadz u ON a.psikolog_id = u.id
  WHERE 1=1
`;
const params = [];
let paramCount = 1;

if (santri_id) {
  query += ` AND a.santri_id = $${paramCount}`;
  params.push(santri_id);
  paramCount++;
}

if (start_date) {
  query += ` AND a.tanggal_assessment >= $${paramCount}`;
  params.push(start_date);
  paramCount++;
}

if (end_date) {
  query += ` AND a.tanggal_assessment <= $${paramCount}`;
  params.push(end_date);
  paramCount++;
}

query += ' ORDER BY a.tanggal_assessment DESC';
const result = await executeQuery(query, params);
res.json(result.rows);
} catch (error) {
next(error);
}
});

// ============================================
// MODULE