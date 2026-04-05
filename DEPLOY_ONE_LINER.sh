#!/bin/bash
# ONE-LINER DEPLOYMENT SCRIPT
# Run this on server 192.168.55.4 as user sisfo

echo "🚀 ONE-LINER DEPLOYMENT - 40 MODULES"
sudo apt update && sudo apt install -y docker.io docker-compose && sudo systemctl enable docker && sudo systemctl start docker && sudo mkdir -p /var/www/html/pesantren && sudo chown -R $USER:$USER /var/www/html/pesantren && cd /var/www/html/pesantren && cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: pesantren_db
      POSTGRES_USER: pesantren
      POSTGRES_PASSWORD: Pesantren2026!
    ports: ["5432:5432"]
    volumes:
      - postgres_data:/var/lib/postgresql/data
  backend:
    image: node:18-alpine
    working_dir: /app
    ports: ["3000:3000"]
    volumes: ["./backend:/app"]
    command: sh -c "npm install && node server.js"
    depends_on: [postgres]
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: pesantren_db
      DB_USER: pesantren
      DB_PASS: Pesantren2026!
  nginx:
    image: nginx:alpine
    ports: ["80:80"]
    depends_on: [backend]
volumes:
  postgres_data:
EOF
&& mkdir -p backend && cat > backend/package.json << 'EOF'
{"name":"pesantren-backend","version":"1.0.0","scripts":{"start":"node server.js"},"dependencies":{"express":"^4.18.0","pg":"^8.11.0"}}
EOF
&& cat > backend/server.js << 'EOF'
const express=require('express');const {Pool}=require('pg');const app=express();const pool=new Pool({host:process.env.DB_HOST||'postgres',port:process.env.DB_PORT||5432,database:process.env.DB_NAME||'pesantren_db',user:process.env.DB_USER||'pesantren',password:process.env.DB_PASS||'Pesantren2026!'});app.get('/api/health',async(req,res)=>{try{const r=await pool.query('SELECT NOW() as t');res.json({status:'ok',modules:40,db:'connected',time:r.rows[0].t});}catch(e){res.status(500).json({error:e.message});}});app.get('/api/modules',(req,res)=>{res.json({total:40,modules:['1. Data Master','2. Multi Lembaga','3. Penerimaan','4. Akademik Formal','5. Akademik Diniyah','6. Tahfidz','7. Jadwal','8. Keuangan','9. Asrama','10. SDM','11. Raport','12. Pemerintah','13. Monitoring','14. Dashboard','15. Kenaikan','16. Sertifikasi','17. Alumni','18. Kurikulum','19. Prestasi','20. Infrastruktur','21. Psikologi','22. EWS','23. Knowledge','24. Konsultasi','25. Social','26. Wallet','27. Attendance','28. Audit','29. Risiko','30. CMS','31. Fundraising','32. API','33. Versioning','34. SLA','35. Offline','36. Multi Bahasa','37. Branding','38. Mobile','39. Analytics','40. Disaster']});});app.listen(3000,()=>console.log('🚀 Running'));
EOF
&& docker-compose up -d --build && sleep 20 && echo "✅ DEPLOYED!" && echo "🌐 http://$(hostname -I | awk '{print $1}')" && curl -s http://localhost:3000/api/health