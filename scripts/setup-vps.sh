#!/bin/bash

# VPS Setup script for deploying Discuss Phoenix app
# Run this script on your VPS to set up the environment

set -e

echo "🚀 Setting up VPS for Discuss Phoenix app deployment..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed successfully"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose
echo "🔧 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed successfully"
else
    echo "✅ Docker Compose already installed"
fi

# Install Nginx
echo "🌐 Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    sudo apt install nginx -y
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo "✅ Nginx installed and started"
else
    echo "✅ Nginx already installed"
fi

# Install Certbot for SSL certificates
echo "🔒 Installing Certbot..."
if ! command -v certbot &> /dev/null; then
    sudo apt install snapd -y
    sudo snap install core; sudo snap refresh core
    sudo snap install --classic certbot
    sudo ln -sf /snap/bin/certbot /usr/bin/certbot
    echo "✅ Certbot installed successfully"
else
    echo "✅ Certbot already installed"
fi

# Install other useful tools
echo "🛠️  Installing additional tools..."
sudo apt install -y curl wget git htop ufw fail2ban

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p /opt/discuss
sudo chown $USER:$USER /opt/discuss

# Generate secret key base
echo "🔑 Generating secret key base..."
SECRET_KEY=$(openssl rand -hex 64)
echo "Your secret key base: $SECRET_KEY"
echo "Save this value for your .env.prod file!"

echo ""
echo "🎉 VPS setup complete!"
echo ""
echo "Next steps:"
echo "1. Clone your repository to /opt/discuss"
echo "2. Copy .env.prod.template to .env.prod and fill in values"
echo "3. Update nginx configuration with your domain"
echo "4. Get SSL certificate with: sudo certbot --nginx -d yourdomain.com"
echo "5. Run ./deploy.sh deploy"
echo ""
echo "Your secret key base: $SECRET_KEY"
