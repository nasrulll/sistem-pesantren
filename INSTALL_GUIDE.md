# 📋 PANDUAN INSTALASI: TAMBAH MODUL YANG BELUM ADA

## 🎯 TUJUAN
Menambahkan semua modul yang belum ada pada sistem informasi pondok pesantren **tanpa menginstall ulang** sistem yang sudah ada.

## 🔍 LANGKAH 1: IDENTIFIKASI SISTEM YANG SUDAH ADA

### Login ke Server:
```bash
ssh sisfo@192.168.55.4
Password: 12Jagahati
```

### Periksa Sistem yang Sudah Ada:
```bash
# 1. Cek web server
sudo systemctl status nginx || sudo systemctl status apache2

# 2. Cek database  
sudo systemctl status postgresql || sudo systemctl status mysql

# 3. Cek direktori proyek
ls -la /var/www/html/
ls -la /home/sisfo/

# 4. Cek Docker containers
docker ps -a

# 5. Cek aplikasi yang berjalan
curl -I http://localhost 2>/dev/null || echo "No web app running"
```

### Catat Hasil:
- ✅ Modul apa yang sudah ada?
- ✅ Teknologi apa yang digunakan?
- ✅ Struktur direktori seperti apa?
- ❌ Modul apa yang belum ada?

## 🚀 LANGKAH 2: SETUP DASAR (Jika Belum)

### Install Dependencies:
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io docker-compose

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs npm

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install Git
sudo apt install -y git
```

### Buat Direktori Project:
```bash
sudo mkdir -p /var/www/html/pesantren
sudo chown -R sisfo:sisfo /var/www/html/pesantren
cd /var/www/html/pesantren
```

## 📦 LANGKAH 3: COPY PROJECT FILE

### Dari Local Machine ke Server:
```bash
# Dari komputer lokal (jalankan di local):
scp -r pesantren-system/* sisfo@192.168.55.4:/var/www/html/pesantren/
```

### Atau Clone dari Repository:
```bash
cd /var/www/html/pesantren
git clone <repository-url> .
```

## 🛠️ LANGKAH 4: TAMBAH MODUL YANG BELUM ADA

### Jalankan Script Otomatis:
```bash
cd /var/www/html/pesantren

# Beri permission
chmod +x scripts/*.sh

# Jalankan script penambahan modul
sudo ./scripts/add-missing-modules.sh
```

### Script akan:
1. ✅ Cek dependency yang sudah ada
2. ✅ Buat struktur direktori
3. ✅ Setup database
4. ✅ Tambah 40 modul backend
5. ✅ Tambah tabel database
6. ✅ Buat konfigurasi deployment
7. ✅ Buat dokumentasi

## 🐳 LANGKAH 5: DEPLOY DENGAN DOCKER

### Konfigurasi Environment:
```bash
cd /var/www/html/pesantren
cp .env.example .env

# Edit .env file sesuai kebutuhan
nano .env
```

### Start Services:
```bash
# Build dan start semua service
docker-compose up -d --build

# Cek status
docker-compose ps

# Lihat logs
docker-compose logs -f
```

## ✅ LANGKAH 6: VERIFIKASI

### Cek Semua Service:
```bash
# 1. Cek backend API
curl http://localhost:3000/health

# 2. Cek database
docker exec pesantren-postgres pg_isready -U pesantren

# 3. Cek web server
curl -I http://localhost

# 4. Cek semua modul
curl http://localhost:3000/api/modules/list
```

### Test Modul:
```bash
# Test authentication
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Test santri module
curl http://localhost:3000/santri

# Test akademik module  
curl http://localhost:3000/akademik/jadwal
```

## 📊 MODUL YANG AKAN DITAMBAHKAN (40 MODUL)

### Kategori A: Manajemen Inti (1-20)
1. **Authentication & User Management**
2. **Santri Data Management**
3. **Academic Management**
4. **Financial Management**
5. **Communication**
6. **Asrama & Disiplin**
7. **Perpustakaan**
8. **Inventaris & Aset**
9. **SDM & Kepegawaian**
10. **Unit Usaha**
11. **Keamanan Sistem**
12. **Dashboard & Analytics**
13. **Integrasi & API**
14. **Mobile App**
15. **Digital Identity**
16. **Kegiatan & Event**
17. **Arsip & Dokumen**
18. **AI (Opsional)**
19. **Infrastruktur**
20. **Manajemen Alumni**

### Kategori B: Fitur Tambahan (21-40)
21. **CRM Wali Santri**
22. **Sistem Penjaminan Mutu (SPMI)**
23. **Manajemen Kurikulum Lanjutan**
24. **Manajemen Jadwal Terpadu**
25. **Sistem Ujian Digital (CBT)**
26. **Gamifikasi Santri**
27. **Monitoring Ibadah**
28. **Manajemen Bahasa**
29. **Marketplace Internal Pondok**
30. **Sistem Transportasi**
31. **Disaster Recovery**
32. **Data Warehouse & BI**
33. **Workflow Automation**
34. **Multi Cabang Pondok**
35. **Legal & Kepatuhan**
36. **Green / Smart Pesantren (IoT)**
37. **Integrasi Pendidikan Formal**
38. **Sistem Reward & Beasiswa**
39. **Digital Signature & Approval**

## 🔧 TROUBLESHOOTING

### Issue 1: Docker Error
```bash
# Restart Docker
sudo systemctl restart docker

# Remove old containers
docker-compose down
docker system prune -a

# Rebuild
docker-compose up -d --build
```

### Issue 2: Database Connection
```bash
# Check PostgreSQL
sudo systemctl status postgresql

# Reset database
docker-compose exec postgres psql -U pesantren -c "DROP DATABASE IF EXISTS pesantren_db; CREATE DATABASE pesantren_db;"
```

### Issue 3: Port Conflict
```bash
# Check used ports
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :3000
sudo netstat -tulpn | grep :5432

# Change ports in docker-compose.yml if needed
```

### Issue 4: Permission Denied
```bash
# Fix permissions
sudo chown -R sisfo:sisfo /var/www/html/pesantren
sudo chmod -R 755 /var/www/html/pesantren
```

## 📞 SUPPORT

### Log Files:
```bash
# Backend logs
docker-compose logs backend

# Database logs
docker-compose logs postgres

# Nginx logs
docker-compose logs nginx
```

### Backup & Restore:
```bash
# Backup database
docker-compose exec postgres pg_dump -U pesantren pesantren_db > backup.sql

# Restore database
docker-compose exec -T postgres psql -U pesantren pesantren_db < backup.sql
```

## 🎯 REKOMENDASI IMPLEMENTASI

### Fase 1 (Hari 1-3): Setup & Core Modules
1. Setup infrastructure
2. Deploy 5 modul inti
3. Basic testing

### Fase 2 (Hari 4-7): Additional Modules
1. Tambah 15 modul pendukung
2. Integration testing
3. User training

### Fase 3 (Hari 8-14): Advanced Modules
1. Tambah 20 modul lanjutan
2. Performance testing
3. Production deployment

## 📋 CHECKLIST AKHIR

- [ ] Server bisa diakses via SSH
- [ ] Dependencies terinstall
- [ ] Project files ter-copy
- [ ] Database berjalan
- [ ] Backend API berjalan
- [ ] Semua modul ter-deploy
- [ ] Testing berhasil
- [ ] Dokumentasi lengkap

## 🎉 SELESAI!

Sistem informasi pondok pesantren dengan **40 modul lengkap** telah siap digunakan. Semua modul yang belum ada telah ditambahkan secara otomatis tanpa mengganggu sistem yang sudah ada.

**Status:** 🟢 READY FOR PRODUCTION