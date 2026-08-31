#!/bin/bash

systemctl enable --now auditd

cat > /etc/audit/rules.d/platform.rules <<EOF
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/ssh/sshd_config -p wa -k ssh_config_changes
-w /opt/platform -p wa -k platform_changes
EOF

augenrules --load
