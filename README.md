# 🐳 Docker Auto-Installer

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Bash](https://img.shields.io/badge/bash-%234EAA25.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

Un script de Bash robusto, inteligente y visual para automatizar la instalación de **Docker Engine** y **Docker Compose** en múltiples distribuciones Linux. Olvídate de seguir guías largas; un solo comando y listo.

## 🚀 Características

- **Detección Automática**: Identifica tu distribución y base (Ubuntu, Debian, Fedora, Arch).
- **Inteligencia Upstream**: En distribuciones derivadas (como Nobara, Linux Mint, Pop!_OS), detecta automáticamente la versión base correcta para evitar errores 404 en los repositorios.
- **Limpieza Total**: Elimina versiones antiguas o conflictivas antes de instalar la versión oficial.
- **Configuración Completa**: 
  - Configura GPG keys oficiales.
  - Añade repositorios estables.
  - Instala Docker Engine, CLI, Containerd y Docker Compose Plugin.
- **Gestión de Permisos**: Añade automáticamente a tu usuario al grupo `docker` para que no necesites usar `sudo` constantemente.
- **Interfaz Visual**: Feedback claro con iconos y colores en la terminal.

## 🐧 Distribuciones Soportadas

| Familia | Distribuciones Probadas |
| :--- | :--- |
| **Debian** | Debian 10/11/12, Kali Linux, MX Linux |
| **Ubuntu** | Ubuntu 20.04/22.04/24.04, Linux Mint, Pop!_OS, Zorin OS |
| **Fedora** | Fedora 38/39/40, Nobara Project, Ultramarine |
| **Arch** | Arch Linux, EndeavourOS, Manjaro |

---

## ⚡ Instalación Rápida (One-Liner)

¿No quieres descargar nada? Ejecuta este comando directamente en tu terminal:

**Usando `curl`:**
```bash
curl -fsSL https://raw.githubusercontent.com/zan101x/Docker-Auto-Installer/main/install-docker.sh | sudo bash
```

**Usando `wget`:**
```bash
wget -qO- https://raw.githubusercontent.com/zan101x/Docker-Auto-Installer/main/install-docker.sh | sudo bash
```

---

## 🛠️ Instalación Manual

Si prefieres descargar el script y revisarlo antes de ejecutarlo:

1. **Clona el repositorio o descarga el archivo:**
   ```bash
   git clone https://github.com/zan101x/Docker-Auto-Installer.git
   cd Docker-Auto-Installer
   ```

2. **Dale permisos de ejecución:**
   ```bash
   chmod +x install-docker.sh
   ```

3. **Ejecútalo con privilegios de root:**
   ```bash
   sudo ./install-docker.sh
   ```

---

## 🔑 Post-Instalación

Al finalizar la instalación, el script añadirá tu usuario al grupo `docker`. Para que estos cambios surtan efecto **sin reiniciar**, puedes ejecutar:

```bash
newgrp docker
```

O simplemente **cierra sesión y vuelve a entrar**. Una vez hecho esto, podrás ejecutar comandos de docker sin `sudo`:

```bash
docker run hello-world
```

---

## 👤 Autor

Desarrollado con ❤️ por **Zan101**.

---
*Si este script te ha ahorrado tiempo, no olvides darle una ⭐️ al repositorio.*
