# Discuss Phoenix App - VPS Deployment Package 📦

This package contains everything you need to deploy the Discuss Phoenix application to your VPS with the domain **rediscusstopic.com**.

## 🚀 Quick Start

### 1. Upload to VPS
```bash
scp discuss-deployment-*.tar.gz user@your-vps-ip:/home/user/
```

### 2. Extract and Setup
```bash
# On your VPS
tar -xzf discuss-deployment-*.tar.gz
sudo mv discuss-deployment-* /opt/discuss
sudo chown -R $USER:$USER /opt/discuss
cd /opt/discuss
```

### 3. Install Dependencies
```bash
# Install Docker and Docker Compose
sudo apt update
sudo apt install -y docker.io docker-compose certbot python3-certbot-nginx
sudo usermod -aG docker $USER
# Log out and back in, or run: newgrp docker
```

### 4. Setup Nginx
```bash
sudo apt install -y nginx
sudo cp nginx/discuss.conf /etc/nginx/sites-available/discuss
sudo ln -s /etc/nginx/sites-available/discuss /etc/nginx/sites-enabled/
sudo nginx -t
```

### 5. Setup SSL Certificate
```bash
sudo certbot --nginx -d rediscusstopic.com -d www.rediscusstopic.com
```

### 6. Deploy Application
```bash
./deploy.sh deploy
```

## 🌐 Access Your Application

- **Primary**: `https://rediscusstopic.com`
- **WWW**: `https://www.rediscusstopic.com`
- **Direct** (fallback): `https://rediscusstopic.com:4000`

## 📁 What's Included

- **Source Code**: Complete Phoenix application
- **Docker Configuration**: 
  - `docker-compose.prod.yml` - Production setup
  - `Dockerfile.prod` - Optimized production build
- **Database Setup**: PostgreSQL with configured password
- **Environment**: `.env.prod` with production settings
- **Nginx Configs**: 
  - `nginx/discuss.conf` - Full config with SSL support
  - `nginx/discuss-simple.conf` - Simple HTTP-only config
- **Deployment Script**: `deploy.sh` for easy management
- **Documentation**: `DEPLOY_INSTRUCTIONS.txt` with detailed steps

## 🔧 Management Commands

```bash
./deploy.sh deploy     # Deploy/redeploy application
./deploy.sh logs       # View application logs
./deploy.sh status     # Check container status
./deploy.sh restart    # Restart application
./deploy.sh stop       # Stop application
./deploy.sh backup-db  # Backup database
./deploy.sh restore-db # Restore database
```

## 🔒 Security Notes

- Database password: `SecureDBPassword123!` (change in `.env.prod`)
- Application runs on port 4000 internally
- Nginx provides security headers and rate limiting
- For production, consider setting up SSL with Let's Encrypt

## 🛠️ Customization

### Change Database Password
1. Edit `.env.prod`: `POSTGRES_PASSWORD=your-new-password`
2. Redeploy: `./deploy.sh deploy`

### Add SSL Certificate
1. Use `nginx/discuss.conf` instead of simple config
2. Get certificate: `sudo certbot --nginx -d yourdomain.com`
3. Update server_name in nginx config

### Scale Application
Edit `docker-compose.prod.yml` to add more app replicas:
```yaml
services:
  discuss-app:
    scale: 3  # Run 3 instances
```

## 📞 Support

If you encounter issues:

1. Check logs: `./deploy.sh logs`
2. Verify containers: `docker ps`
3. Test nginx: `sudo nginx -t`
4. Check connectivity: `curl http://localhost:4000`

## 🎯 Current Configuration

- **Domain**: rediscusstopic.com (with www subdomain)
- **SSL**: Let's Encrypt certificates via Certbot
- **Port**: 443 (HTTPS), 80 (HTTP redirect)
- **Database**: PostgreSQL 16 with password protection
- **Environment**: Production-ready with security headers
- **WebSocket**: Enabled for Phoenix LiveView

Ready to deploy! 🚀
