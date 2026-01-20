#!/usr/bin/env bash
set -e

echo "⚠️  Este script eliminará Docker y TODOS los contenedores existentes"
read -p "¿Deseas continuar? (s/N): " confirm
[[ "$confirm" == "s" || "$confirm" == "S" ]] || exit 1

# Detectar sistema operativo
. /etc/os-release
echo "DEBUG: Sistema detectado: ID='$ID', VERSION_CODENAME='$VERSION_CODENAME'"

# Eliminar Docker previo (común)
apt-get remove --purge -y docker docker-engine docker.io containerd runc docker-compose || true
rm -rf /var/lib/docker
rm -rf /var/lib/containerd

apt-get update

# Paquetes base
apt-get install -y ca-certificates curl gnupg lsb-release

# =========================
# UBUNTU
# =========================
if [[ "$ID" == "ubuntu" ]]; then
  echo "Instalando Docker para Ubuntu..."

  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $VERSION_CODENAME stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# =========================
# DEBIAN / PROXMOX
# =========================
elif [[ "$ID" == "debian" ]]; then
  echo "Instalando Docker para Debian / Proxmox..."

  # Eliminar el repo docker de Ubuntu si existe
  rm -f /etc/apt/sources.list.d/docker.list
  rm -f /etc/apt/keyrings/docker.gpg

  # Docker desde repos oficiales de Debian (más seguro)
  apt-get install -y docker.io docker-compose-plugin

else
  echo "❌ Sistema no soportado: $ID"
  exit 1
fi

# =========================
# POST-INSTALACIÓN
# =========================
if command -v docker >/dev/null 2>&1; then
  echo "Docker instalado correctamente"
  docker --version

  # Crear grupo docker si no existe
  getent group docker >/dev/null || groupadd docker
  usermod -aG docker "$USER"

  docker run hello-world || true
else
  echo "❌ Docker no se instaló correctamente"
  exit 1
fi

echo "✅ Proceso terminado"
echo "🔁 Reinicia el sistema y ejecuta: docker version"