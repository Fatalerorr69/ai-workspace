# Vytvoření dokumentace
mkdir -p ~/Documentation/{setup,emulators,games}
cat > ~/Documentation/setup/README.md << 'EOF'
# Ubuntu Gaming Server Documentation

## Quick Start
1. Access via: https://server-ip:9090 (Cockpit)
2. Remote desktop: xrdp://server-ip
3. Web dashboard: http://server-ip:8080

## Module Management
Use ~/bin/module-updater.sh to update specific modules

## Backup
Automated backups daily at 4 AM
Manual: ~/bin/backup-saves.sh
EOF

# Setup completion script
cat > ~/bin/first-boot-checklist.sh << 'EOF'
#!/bin/bash
echo "=== Gaming Server Setup Checklist ==="
echo "1. Update SSH keys in GitHub and SourceForge"
echo "2. Configure MangoHud for desired games"
echo "3. Set up game library paths"
echo "4. Configure backup schedule"
echo "5. Test remote access methods"
echo "====================================="
EOF
chmod +x ~/bin/first-boot-checklist.sh