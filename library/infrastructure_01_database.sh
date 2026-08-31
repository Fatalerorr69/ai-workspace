#!/bin/bash

install_mariadb() {
    info "Instalace MariaDB..."
    apt-get install -y -qq mariadb-server >/dev/null
    systemctl enable mariadb --now
}

install_redis() {
    info "Instalace Redis..."
    apt-get install -y -qq redis-server >/dev/null
    sed -i 's/^supervised no/supervised systemd/' /etc/redis/redis.conf
    systemctl restart redis-server
}

configure_databases() {
    info "Konfigurace databáze a uživatele..."
    
    # Vytvoření DB a uživatele SQL příkazem
    mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;" 2>/dev/null
    mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';" 2>/dev/null
    mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';" 2>/dev/null
    mysql -e "FLUSH PRIVILEGES;" 2>/dev/null
    
    # Uložení přihlašovacích údajů
    echo "DB_HOST=localhost" > "$CONFIG_DIR/db.env"
    echo "DB_NAME=$DB_NAME" >> "$CONFIG_DIR/db.env"
    echo "DB_USER=$DB_USER" >> "$CONFIG_DIR/db.env"
    echo "DB_PASS=$DB_PASS" >> "$CONFIG_DIR/db.env"
    echo "JWT_SECRET=$JWT_SECRET" >> "$CONFIG_DIR/db.env"
    
    chmod 600 "$CONFIG_DIR/db.env"
    chown "$GH_USER:$GH_USER" "$CONFIG_DIR/db.env"
}
