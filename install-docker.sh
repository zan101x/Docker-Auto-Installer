#!/usr/bin/env bash
# Author: Zan101
# Version: v1
# Description: Docker Auto-Installer

# Salir inmediatamente si un comando falla
set -e

# ==========================================
# Variables Visuales (Colores e Iconos)
# ==========================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Iconos
ICON_DOCKER="🐳"
ICON_ROCKET="🚀"
ICON_PACKAGE="📦"
ICON_KEY="🔑"
ICON_SHIELD="🛡️"
ICON_CHECK="✅"
ICON_CROSS="❌"
ICON_INFO="ℹ️"

# ==========================================
# Funciones de Utilidad
# ==========================================
print_info() {
    echo -e "${BLUE}${ICON_INFO} $1${NC}"
}

print_success() {
    echo -e "${GREEN}${ICON_CHECK} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}${ICON_CROSS} $1${NC}"
}

print_step() {
    echo -e "\n${CYAN}>>> $1${NC}"
}

# Comprobar privilegios de root
if [ "$EUID" -ne 0 ]; then
  print_error "Este script debe ejecutarse como root. Por favor, usa: sudo $0"
  exit 1
fi

# Detectar el usuario real de forma robusta para los permisos
REAL_USER=$(who am i | awk '{print $1}')
TARGET_USER=${SUDO_USER:-${REAL_USER:-$(logname 2>/dev/null || echo $USER)}}

if [ "$TARGET_USER" = "root" ]; then
    print_warning "Ejecutando directamente como root. No se añadirán permisos de usuario normal."
fi

# ==========================================
# Detección del Sistema Operativo
# ==========================================
print_step "Detectando Sistema Operativo..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    print_error "No se pudo detectar el sistema operativo (/etc/os-release no encontrado)."
    exit 1
fi

# Detección simplificada de la familia del SO
if [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"ubuntu"* || "$ID" == "anduinos" || "$ID" == "soplos" ]]; then
    OS_FAMILY="ubuntu"
elif [[ "$ID" == "fedora" || "$ID_LIKE" == *"fedora"* ]]; then
    OS_FAMILY="fedora"
elif [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
    OS_FAMILY="arch"
else
    OS_FAMILY="debian"
fi

print_success "Sistema detectado: $PRETTY_NAME (Base $OS_FAMILY)"

# ==========================================
# Desinstalación de versiones antiguas
# ==========================================
print_step "Limpiando versiones antiguas no oficiales..."

if [[ "$OS_FAMILY" == "ubuntu" || "$OS_FAMILY" == "debian" ]]; then
    # PRECAUCIÓN: Eliminar un posible sources.list roto de intentos previos ("questing")
    rm -f /etc/apt/sources.list.d/docker.list 2>/dev/null || true

    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
        apt-get remove -y $pkg > /dev/null 2>&1 || true
    done
    print_success "Limpieza completada."
elif [[ "$OS_FAMILY" == "fedora" ]]; then
    for pkg in docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine; do
        dnf remove -y $pkg > /dev/null 2>&1 || true
    done
    print_success "Limpieza completada."
elif [[ "$OS_FAMILY" == "arch" ]]; then
    for pkg in docker docker-compose; do
        pacman -Rns --noconfirm $pkg > /dev/null 2>&1 || true
    done
    print_success "Limpieza completada."
fi

# ==========================================
# Instalación Principal
# ==========================================

if [[ "$OS_FAMILY" == "ubuntu" || "$OS_FAMILY" == "debian" ]]; then
    print_step "${ICON_PACKAGE} Instalando dependencias de ${OS_FAMILY^}..."
    apt-get update -qq
    apt-get install -y ca-certificates curl gnupg
    
    print_step "${ICON_KEY} Configurando el Keyring oficial de Docker..."
    install -m 0755 -d /etc/apt/keyrings
    rm -f /etc/apt/keyrings/docker.asc
    curl -fsSL https://download.docker.com/linux/$OS_FAMILY/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    
    print_step "${ICON_SHIELD} Configurando repositorio oficial..."
    # Detección simplificada del Codename
    if [[ "$OS_FAMILY" == "ubuntu" ]]; then
        CODENAME=${UBUNTU_CODENAME:-$VERSION_CODENAME}
        # Si el codename es el nombre de la distro, usamos un fallback de Ubuntu estable
        if [[ "$CODENAME" == "anduinos" || "$CODENAME" == "soplos" ]]; then
            CODENAME="noble"
        fi
    else
        CODENAME=$VERSION_CODENAME
        # Si es Debian testing/unstable (forky/sid), usamos bookworm
        if [[ "$CODENAME" == "forky" || "$CODENAME" == "sid" ]]; then
            CODENAME="bookworm"
        fi
    fi

    print_info "Configurando repositorio Docker para $OS_FAMILY ($CODENAME)..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$OS_FAMILY \
      $CODENAME stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    print_success "Repositorio añadido correctamente ($CODENAME)."
    
    print_step "${ICON_DOCKER} Instalando paquetes de Docker y Docker Compose..."
    apt-get update -qq
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    print_success "Paquetes instalados."

elif [[ "$OS_FAMILY" == "fedora" ]]; then
    print_step "${ICON_PACKAGE} Instalando dependencias de Fedora..."
    dnf -y install dnf-plugins-core
    
    print_step "${ICON_SHIELD} Configurando repositorio oficial..."
    # Descargar y adaptar el archivo .repo directamente para evitar errores de metadata en derivadas
    curl -fsSL https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
    
    if [[ "$ID" != "fedora" ]]; then
        print_warning "Base Fedora detectada ($ID). Adaptando repositorio reemplazando \$releasever por $VERSION_ID..."
        sed -i "s/\$releasever/$VERSION_ID/g" /etc/yum.repos.d/docker-ce.repo
    fi
    print_success "Repositorio configurado correctamente."
    
    print_step "${ICON_DOCKER} Instalando paquetes de Docker y Docker Compose..."
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    print_success "Paquetes instalados."

elif [[ "$OS_FAMILY" == "arch" ]]; then
    print_step "${ICON_DOCKER} Instalando Docker desde repositorios oficiales de Arch..."
    # En Arch no hacen falta repos externos, Docker está en [extra]
    pacman -Sy --noconfirm docker docker-compose docker-buildx
    print_success "Paquetes instalados."
fi

# ==========================================
# Post-Instalación: Servicios y Permisos
# ==========================================
print_step "${ICON_ROCKET} Configurando servicios y permisos..."

systemctl enable --now docker
systemctl enable --now containerd
print_success "Servicios de Docker habilitados e iniciados."

if [ "$TARGET_USER" != "root" ]; then
    print_info "Añadiendo el usuario '$TARGET_USER' al grupo 'docker'..."
    # Asegurarnos de que el grupo existe
    groupadd -f docker
    
    # Intentar añadir al usuario con usermod y verificar
    usermod -aG docker "$TARGET_USER" || gpasswd -a "$TARGET_USER" docker
    
    if grep -q "^docker:.*$TARGET_USER" /etc/group; then
        print_success "Usuario '$TARGET_USER' añadido al grupo docker correctamente."
        print_info "${YELLOW}RECUERDA: Debes cerrar sesión completamente y volver a entrar para que los permisos surtan efecto.${NC}"
    else
        print_error "No se pudo verificar la adición de '$TARGET_USER' al grupo docker."
        print_info "Intenta ejecutar manualmente: sudo gpasswd -a $TARGET_USER docker"
    fi
fi

# ==========================================
# Verificación Final
# ==========================================
print_step "Verificando la instalación..."
DOCKER_VER=$(docker --version)
COMPOSE_VER=$(docker compose version)

print_success "Docker: ${CYAN}$DOCKER_VER${NC}"
print_success "Docker Compose: ${CYAN}$COMPOSE_VER${NC}"

echo -e "\n${GREEN}${ICON_ROCKET} ¡Instalación completada con éxito! ${ICON_ROCKET}${NC}"
echo -e "${YELLOW}Nota: Si el comando 'docker' sin sudo falla, por favor cierra sesión o reinicia el equipo.${NC}\n"
