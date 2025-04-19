#!/bin/bash
set -euxo pipefail

# Attach this instance to the ECS cluster
echo "ECS_CLUSTER=ThingsBoard-Cluster" | sudo tee /etc/ecs/ecs.config

echo "=== Updating System and Installing Dependencies ==="
sudo yum update -y
sudo yum install -y wget
sudo dnf install postgresql15.x86_64 postgresql15-server -y

# Download the Amazon Corretto 17 repo
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-17-amazon-corretto-devel

# Simulate a 'java-17' provides by creating an rpm package name link
sudo ln -s /usr/bin/java /usr/bin/java-17

echo "=== Setting up PostgreSQL ==="
sudo postgresql-setup initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

echo "=== Setting password for 'postgres' user ==="
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

echo "=== Fixing pg_hba.conf to use md5 ==="
PG_HBA=/var/lib/pgsql/data/pg_hba.conf
sudo sed -i 's/^\(local\s\+all\s\+postgres\s\+\)ident/\1md5/' $PG_HBA
sudo sed -i 's/^\(host\s\+all\s\+all\s\+127\.0\.0\.1\/32\s\+\)ident/\1md5/' $PG_HBA
sudo sed -i 's/^\(host\s\+all\s\+all\s\+::1\/128\s\+\)ident/\1md5/' $PG_HBA

echo "=== Restarting PostgreSQL to apply auth changes ==="
sudo systemctl restart postgresql

# Create DB and user
sudo -u postgres psql <<EOF
CREATE DATABASE thingsboard;
ALTER USER postgres WITH PASSWORD 'postgres';
EOF

echo "=== Downloading and Installing ThingsBoard ==="
wget https://github.com/thingsboard/thingsboard/releases/download/v3.9.1/thingsboard-3.9.1.rpm
sudo rpm -Uvh --nodeps thingsboard-3.9.1.rpm

echo "=== Configuring ThingsBoard ==="
sudo tee /etc/thingsboard/conf/thingsboard.conf > /dev/null <<EOT
export DATABASE_TS_TYPE=sql
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/thingsboard
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=postgres
export SQL_POSTGRES_TS_KV_PARTITIONING=DAYS
EOT

echo "=== Installing ThingsBoard with Demo Data ==="
sudo /usr/share/thingsboard/bin/install/install.sh --loadDemo

echo "=== Enabling and Starting ThingsBoard ==="
sudo systemctl enable thingsboard
sudo systemctl start thingsboard

echo "=== Setup Completed ==="
