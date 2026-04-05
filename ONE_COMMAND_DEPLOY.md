# 🚀 ONE COMMAND DEPLOY - TAMBAH SEMUA MODUL SEKALIGUS

## 📋 **INSTALASI 1 PERINTAH SAJA**

### **Step 1: Login ke Server**
```bash
ssh sisfo@192.168.55.4
Password: 12Jagahati
```

### **Step 2: Jalankan 1 Perintah Ini Saja**
```bash
# Copy semua file ke server (jalankan di komputer lokal)
scp -r pesantren-system/* sisfo@192.168.55.4:/home/sisfo/

# Kemudian di server, jalankan:
cd /home/sisfo/pesantren-system
sudo bash scripts/deploy-all-now.sh
```

## 🎯 **APA YANG AKAN DILAKUKAN SCRIPT:**

Script `deploy-all-now.sh` akan otomatis:
1. ✅ **Install semua dependency** (Docker, Node.js, PostgreSQL, Nginx)
2. ✅ **Buat struktur project** di `/var/www/html/pesantren`
3. ✅ **Setup database** dengan 150+ tabel
4. ✅ **Buat 40 modul backend** lengkap
5. ✅ **Buat frontend structure** (Next.js)
6. ✅ **Konfigurasi Docker** dengan semua service
7. ✅ **Buat environment files** dan konfigurasi
8. ✅ **Start semua service** otomatis
9. ✅ **Verifikasi instalasi** dan tampilkan status

## 📊 **MODUL YANG AKAN DITAMBAHKAN (40 MODUL):**

### **Manajemen Inti:**
1. Authentication & User Management
2. Santri Data Management  
3. Academic Management
4. Financial Management
5. Communication
6. Asrama & Disiplin
7. Perpustakaan
8. Inventaris & Aset
9. SDM & Kepegawaian
10. Unit Usaha

### **Fitur Tambahan:**
11. Keamanan Sistem
12. Dashboard & Analytics
13. Integrasi & API
14. Mobile App
15. Digital Identity
16. Kegiatan & Event
17. Arsip & Dokumen
18. AI (Opsional)
19. Infrastruktur
20. Manajemen Alumni

### **Fitur Inovatif:**
21. CRM Wali Santri
22. Sistem Penjaminan Mutu (SPMI)
23. Manajemen Kurikulum Lanjutan
24. Manajemen Jadwal Terpadu
25. Sistem Ujian Digital (CBT)
26. Gamifikasi Santri
27. Monitoring Ibadah
28. Manajemen Bahasa
29. Marketplace Internal Pondok
30. Sistem Transportasi

### **Enterprise Features:**
31. Disaster Recovery
32. Data Warehouse & BI
33. Workflow Automation
34. Multi Cabang Pondok
35. Legal & Kepatuhan
36. Green / Smart Pesantren (IoT)
37. Integrasi Pendidikan Formal
38. Sistem Reward & Beasiswa
39. Digital Signature & Approval

## 🐳 **SERVICE YANG AKAN DIBUAT:**

1. **PostgreSQL** - Database utama (port 5432)
2. **Backend API** - NestJS API (port 3000)
3. **Web Frontend** - Next.js (port 3001)
4. **Nginx** - Reverse proxy (port 80)
5. **Semua terhubung** dalam Docker network

## ✅ **SETELAH INSTALASI:**

### **Akses Aplikasi:**
```bash
# Backend API
http://localhost:3000/api

# Web Interface  
http://localhost

# Database
localhost:5432 (user: pesantren, pass: Pesantren2026!)
```

### **Management Commands:**
```bash
# Start semua service
cd /var/www/html/pesantren
./start-all.sh

# Stop semua service
./stop-all.sh

# Restart semua service
./restart-all.sh

# Backup database
./backup-db.sh

# Lihat logs
docker-compose logs -f
```

### **Testing:**
```bash
# Test API health
curl http://localhost:3000/api/health

# Test web interface
curl -I http://localhost

# Test database
docker-compose exec postgres pg_isready -U pesantren
```

## 🔧 **TROUBLESHOOTING CEPAT:**

### **Issue 1: Port Conflict**
```bash
# Cek port yang digunakan
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :3000

# Jika ada conflict, stop service yang conflict
sudo systemctl stop nginx  # atau service lain
```

### **Issue 2: Docker Error**
```bash
# Restart Docker
sudo systemctl restart docker

# Hapus container lama
docker-compose down
docker system prune -a

# Build ulang
docker-compose up -d --build
```

### **Issue 3: Permission Error**
```bash
# Fix permissions
sudo chown -R sisfo:sisfo /var/www/html/pesantren
sudo chmod -R 755 /var/www/html/pesantren
```

## 📞 **SUPPORT:**

### **Log Files:**
```bash
# Backend logs
docker-compose logs backend

# Database logs  
docker-compose logs postgres

# Nginx logs
docker-compose logs nginx
```

### **Backup & Restore:**
```bash
# Backup database
docker-compose exec postgres pg_dump -U pesantren pesantren_db > backup.sql

# Restore database
docker-compose exec -T postgres psql -U pesantren pesantren_db < backup.sql
```

## 🎉 **FINAL CHECKLIST:**

- [ ] Server bisa diakses via SSH
- [ ] Script `deploy-all-now.sh` dijalankan
- [ ] Semua service berjalan (docker-compose ps)
- [ ] API bisa diakses (curl http://localhost:3000/api/health)
- [ ] Web interface bisa diakses (http://localhost)
- [ ] Database connected
- [ ] Semua 40 modul ter-deploy

## ⚡ **INSTALASI EKSPRES (5 MENIT):**

```bash
# 1. Login
ssh sisfo@192.168.55.4

# 2. Buat direktori
sudo mkdir -p /var/www/html/pesantren
sudo chown -R sisfo:sisfo /var/www/html/pesantren

# 3. Copy file (dari komputer lokal)
scp -r pesantren-system/* sisfo@192.168.55.4:/var/www/html/pesantren/

# 4. Deploy
cd /var/www/html/pesantren
sudo bash scripts/deploy-all-now.sh

# 5. Verifikasi
curl http://localhost:3000/api/health
```

## 🚀 **READY TO GO!**

**Hanya 1 perintah:** `sudo bash scripts/deploy-all-now.sh`

**Hasil:** Sistem informasi pondok pesantren dengan 40 modul lengkap siap digunakan!

**Status:** 🟢 **SEMUA MODUL AKAN DITAMBAHKAN OTOMATIS**