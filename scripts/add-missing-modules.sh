istentCasingInFileNames": false,
    "noFallthroughCasesInSwitch": false
  }
}
EOF

    # Buat Dockerfile untuk backend
    cat > Dockerfile << EOF
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000
CMD ["node", "dist/main"]
EOF

    echo "✅ Backend project initialized"
else
    echo "✅ Backend project sudah ada"
fi

echo ""
echo "8. BUAT FILE KONFIGURASI UTAMA"
echo "------------------------------"

# Buat .env.example
cat > "$BASE_DIR/.env.example" << EOF
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d

# App
APP_PORT=3000
APP_URL=http://localhost:3000
NODE_ENV=production

# Email (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-email-password

# WhatsApp (optional)
WHATSAPP_API_KEY=your-whatsapp-api-key
WHATSAPP_PHONE_NUMBER=+6281234567890
EOF

echo "✅ Environment configuration created"

echo ""
echo "9. BUAT SCRIPT START/STOP"
echo "-------------------------"

# Buat script management
cat > "$BASE_DIR/start.sh" << 'EOF'
#!/bin/bash

echo "🚀 Starting Pesantren System..."

# Start Docker services
docker-compose up -d

echo "✅ Services started:"
echo "   - PostgreSQL: localhost:5432"
echo "   - Backend API: localhost:3000"
echo "   - Nginx: localhost:80"
echo ""
echo "🌐 Access: http://localhost"
EOF

cat > "$BASE_DIR/stop.sh" << 'EOF'
#!/bin/bash

echo "🛑 Stopping Pesantren System..."

docker-compose down

echo "✅ Services stopped"
EOF

cat > "$BASE_DIR/restart.sh" << 'EOF'
#!/bin/bash

echo "🔄 Restarting Pesantren System..."

./stop.sh
sleep 2
./start.sh
EOF

chmod +x "$BASE_DIR/start.sh" "$BASE_DIR/stop.sh" "$BASE_DIR/restart.sh"

echo "✅ Management scripts created"

echo ""
echo "10. BUAT DOKUMENTASI"
echo "--------------------"

# Buat README
cat > "$BASE_DIR/README.md" << 'EOF'
# 🕌 Sistem Informasi Pondok Pesantren

Sistem informasi komprehensif untuk manajemen pondok pesantren dengan 40 modul.

## 📋 Fitur

### Modul Inti (1-20)
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

### Modul Tambahan (21-40)
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
31. Disaster Recovery
32. Data Warehouse & BI
33. Workflow Automation
34. Multi Cabang Pondok
35. Legal & Kepatuhan
36. Green / Smart Pesantren (IoT)
37. Integrasi Pendidikan Formal
38. Sistem Reward & Beasiswa
39. Digital Signature & Approval

## 🚀 Instalasi Cepat

```bash
# 1. Clone atau copy project
git clone <repository-url> /var/www/html/pesantren

# 2. Masuk ke direktori
cd /var/www/html/pesantren

# 3. Setup environment
cp .env.example .env
# Edit .env sesuai konfigurasi

# 4. Start services
./start.sh

# 5. Akses aplikasi
# Backend API: http://localhost:3000
# Web Interface: http://localhost
```

## 🐳 Docker Services

- **PostgreSQL**: Database utama
- **Backend**: NestJS API
- **Nginx**: Reverse proxy & web server

## 📊 Database

- **Name**: pesantren_db
- **User**: pesantren
- **Password**: Pesantren2026!

## 🔧 Management

```bash
# Start semua service
./start.sh

# Stop semua service  
./stop.sh

# Restart semua service
./restart.sh

# View logs
docker-compose logs -f
```

## 📞 Support

Untuk bantuan teknis, hubungi administrator sistem.
EOF

echo "✅ Documentation created"

echo ""
echo "=========================================="
echo "🎉 PENAMBAHAN MODUL SELESAI!"
echo "=========================================="
echo ""
echo "📊 SUMMARY:"
echo "   - Direktori utama: $BASE_DIR"
echo "   - Backend: $BACKEND_DIR"
echo "   - Database: $DB_NAME"
echo "   - Total modul: ${#MODULES_TO_ADD[@]} modul"
echo ""
echo "🚀 NEXT STEPS:"
echo "   1. Login ke server: ssh sisfo@192.168.55.4"
echo "   2. Copy script ke server"
echo "   3. Jalankan script: sudo ./add-missing-modules.sh"
echo "   4. Start services: cd $BASE_DIR && ./start.sh"
echo ""
echo "✅ Semua modul yang belum ada telah ditambahkan secara otomatis!"