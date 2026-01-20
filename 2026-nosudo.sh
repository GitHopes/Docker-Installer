echo "Este script eliminara todos los contenedores que hayan previamente"
read -p "¿Deseas continuar? (s/N): " confirm
[[ "$confirm" == "s" || "$confirm" == "S" ]] || exit 1

apt-get remove --purge docker docker-engine docker.io containerd runc docker-compose
rm -rf /var/lib/docker
rm -rf /var/lib/containerd

# Actualizar paquetes APT
apt-get update

# Instalar los paquetes necesarios para configurar el repositorio oficial de Docker
apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

# Agregar la clave GPG oficial de Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Añadir el repositorio de Docker a APT
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Activar el repositorio APT de Docker
apt-get update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

docker run hello-world

usermod -aG docker $USER

echo "Reincia el ordenador y ejecuta 'docker version' para ver la version"
