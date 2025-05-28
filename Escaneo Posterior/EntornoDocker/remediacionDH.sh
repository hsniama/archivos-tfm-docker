#!/bin/bash
set -e

# --- Variables ---
BACKUP_DIR="/tmp/docker_backup_$(date +%Y%m%d_%H%M%S)"
DAEMON_JSON="/etc/docker/daemon.json"

# --- 1. Validar entorno ---
[ "$(id -u)" -ne 0 ] && echo "Ejecutar como root" && exit 1

# --- 2. Backup completo ---
echo "[1/4] Creando backup en $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
systemctl stop docker || true
tar -czvf "$BACKUP_DIR/docker_var_lib.tar.gz" /var/lib/docker
cp -a /etc/docker "$BACKUP_DIR/etc_docker"
[ -f "$DAEMON_JSON" ] && cp "$DAEMON_JSON" "$BACKUP_DIR/daemon.json.bak"

# --- 3. Remediar WARNINGS ---
echo "[2/4] Aplicando hardening..."

# Auditoría - 1.5 a 1.11
apt update && apt install -y auditd
cat > /etc/audit/rules.d/docker.rules <<EOF
-w /var/lib/docker -p wa -k docker
-w /etc/docker -p wa -k docker
-w /var/run/docker.sock -p wa -k docker
-w /lib/systemd/system/docker.service -p wa -k docker
-w /lib/systemd/system/docker.socket -p wa -k docker
-w /etc/default/docker -p wa -k docker
-w /etc/docker/daemon.json -p wa -k docker
EOF
service auditd restart

# Configuración del daemon.json - solo opciones seguras y compatibles
echo "Configurando daemon.json..."
cat > "$DAEMON_JSON" <<EOF
{
  "icc": false,
  "userns-remap": "default",
  "no-new-privileges": true,
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Configurar subuid y subgid
if ! grep -q "default:" /etc/subuid; then
  echo "default:100000:65536" >> /etc/subuid
fi
if ! grep -q "default:" /etc/subgid; then
  echo "default:100000:65536" >> /etc/subgid
fi

# Content Trust (4.5)
echo "export DOCKER_CONTENT_TRUST=1" > /etc/profile.d/docker.sh

# --- 4. Permisos y reinicio ---
echo "[3/4] Ajustando permisos y reiniciando Docker..."
chmod 600 "$DAEMON_JSON"
chown root:root "$DAEMON_JSON"

echo "[4/4] Reiniciando Docker..."
systemctl daemon-reload
systemctl restart docker || {
    echo "Error al reiniciar Docker. Restaurando configuración original..."
    [ -f "$BACKUP_DIR/daemon.json.bak" ] && cp "$BACKUP_DIR/daemon.json.bak" "$DAEMON_JSON"
    systemctl restart docker || echo "No se pudo reiniciar Docker incluso después de restaurar. Revisa manualmente con: journalctl -xeu docker.service"
    exit 1
}

echo "Hardening completado sin errores."
echo "Ejecuta 'docker bench-security' para validar el resultado."
