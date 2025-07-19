#!/bin/bash

# Create deployment package for VPS
# This script creates a tar.gz file with everything needed for deployment

set -e

CURRENT_DIR=$(pwd)
PACKAGE_NAME="discuss-deployment-$(date +%Y%m%d_%H%M%S)"
PACKAGE_DIR="/tmp/$PACKAGE_NAME"

echo "📦 Creating deployment package: $PACKAGE_NAME"

# Create temporary directory
mkdir -p "$PACKAGE_DIR"

# Copy all necessary files
echo "📄 Copying application files..."
cp -r ./* "$PACKAGE_DIR/" 2>/dev/null || true

# Explicitly copy hidden/env files that might be missed
cp .env.prod "$PACKAGE_DIR/" 2>/dev/null || echo "Warning: .env.prod not found"

# Remove development files and directories we don't need
echo "🧹 Cleaning up unnecessary files..."
rm -rf "$PACKAGE_DIR/_build" 2>/dev/null || true
rm -rf "$PACKAGE_DIR/deps" 2>/dev/null || true
rm -rf "$PACKAGE_DIR/.git" 2>/dev/null || true
rm -rf "$PACKAGE_DIR/node_modules" 2>/dev/null || true
rm -f "$PACKAGE_DIR/.env" 2>/dev/null || true
rm -f "$PACKAGE_DIR/discuss-deployment-*.tar.gz" 2>/dev/null || true

# Make scripts executable
chmod +x "$PACKAGE_DIR/deploy.sh"
chmod +x "$PACKAGE_DIR/scripts/setup-vps.sh"

# Create deployment instructions
cat > "$PACKAGE_DIR/DEPLOY_INSTRUCTIONS.txt" << 'EOF'
=== DISCUSS PHOENIX APP DEPLOYMENT INSTRUCTIONS ===

STEP 1: SETUP VPS
1. Upload and extract this package to your VPS: /opt/discuss/
2. SSH into your VPS and navigate to: cd /opt/discuss/
3. Run VPS setup: ./scripts/setup-vps.sh
4. Update the domain in nginx config: sudo nano /etc/nginx/sites-available/discuss
5. Enable nginx site: sudo ln -s /etc/nginx/sites-available/discuss /etc/nginx/sites-enabled/
6. Test nginx config: sudo nginx -t
7. Reload nginx: sudo systemctl reload nginx

STEP 2: SSL CERTIFICATE (Optional, for custom domain)
If you have a domain pointed to your VPS:
sudo certbot --nginx -d yourdomain.com

For localhost/IP access, skip this step.

STEP 3: DEPLOY APPLICATION
./deploy.sh deploy

STEP 4: ACCESS YOUR APP
- If using domain: https://yourdomain.com
- If using IP: http://YOUR_VPS_IP:4000

MANAGEMENT COMMANDS:
./deploy.sh logs      # View logs
./deploy.sh status    # Check status  
./deploy.sh restart   # Restart app
./deploy.sh stop      # Stop app
./deploy.sh backup-db # Backup database

TROUBLESHOOTING:
- Check logs: ./deploy.sh logs
- Check container status: docker ps
- Check nginx: sudo nginx -t && sudo systemctl status nginx

Current configuration:
- Database: PostgreSQL with password 'SecureDBPassword123!'
- App Port: 4000
- Host: localhost (accessible via VPS IP)
EOF

# Create the package
echo "🗜️  Creating tar.gz package..."
cd /tmp
tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME"

# Move to current directory
mv "$PACKAGE_NAME.tar.gz" "$CURRENT_DIR/"

# Cleanup
rm -rf "$PACKAGE_DIR"
rm -rf "$PACKAGE_DIR"

echo "✅ Deployment package created: $PACKAGE_NAME.tar.gz"
echo ""
echo "📋 Next steps:"
echo "1. Upload $PACKAGE_NAME.tar.gz to your VPS"
echo "2. Extract: tar -xzf $PACKAGE_NAME.tar.gz"
echo "3. Move to /opt/: sudo mv $PACKAGE_NAME /opt/discuss"
echo "4. Change ownership: sudo chown -R \$USER:\$USER /opt/discuss"
echo "5. Navigate: cd /opt/discuss"
echo "6. Follow DEPLOY_INSTRUCTIONS.txt"
