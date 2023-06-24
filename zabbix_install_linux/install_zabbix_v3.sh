#!/bin/bash

# Descripción del script y uso
echo -e "Este script descarga, instala y configura el agente de Zabbix en diferentes sistemas operativos."
echo -e "Debes ejecutar este script con privilegios de superusuario (sudo)."

# Verificar privilegios de SUDO
if [[ $EUID -ne 0 ]]; then
   echo -e "Este script debe ejecutarse con privilegios de superusuario." 
   exit 1
fi

# Mostrar información del sistema operativo
echo -e "Información del sistema operativo:"
echo "--------------------------------------"
cat /etc/*release | head -9
echo "---------------------------------------"
# Variables de ubicación de archivo de configuración y scripts
plugins="/etc/zabbix/zabbix_agentd.d/plugins.d"
plugins2="/etc/zabbix/zabbix_agent2.d/plugins.d"
filezabbix="/etc/zabbix"

# Función para validar la URL
validate_url() {
   if ! curl --output /dev/null --silent --head --fail "$1"; then
      echo "Error: No se puede acceder a la URL $1. Verifica la URL o tu conexión antes de continuar."
      exit 1
   fi
}
# Variables de URL de descarga
sles12_url="https://repo.zabbix.com/zabbix/6.5/sles/12/x86_64/zabbix-agent2-7.0.0-alpha2.release1.sles12.x86_64.rpm"
sles15_url="https://repo.zabbix.com/zabbix/6.5/sles/15/x86_64/zabbix-agent2-7.0.0-alpha2.release1.sles15.x86_64.rpm"
debian9_url="https://repo.zabbix.com/zabbix/6.5/debian/pool/main/z/zabbix/zabbix-agent2_7.0.0~alpha2-1%2Bdebian9_amd64.deb"
debian10_url="https://repo.zabbix.com/zabbix/6.5/debian/pool/main/z/zabbix/zabbix-agent2_7.0.0~alpha2-1%2Bdebian10_amd64.deb"
ubuntu22_url="https://repo.zabbix.com/zabbix/6.5/ubuntu/pool/main/z/zabbix/zabbix-agent2_7.0.0~alpha2-1%2Bubuntu22.04_amd64.deb"
debian11_url="https://repo.zabbix.com/zabbix/6.5/debian/pool/main/z/zabbix/zabbix-agent2_7.0.0~alpha2-1%2Bdebian11_amd64.deb"
rhel7_url="https://repo.zabbix.com/zabbix/6.5/rhel/7/x86_64/zabbix-agent2-7.0.0-alpha2.release1.el7.x86_64.rpm"
rhel8_url="https://repo.zabbix.com/zabbix/6.5/rhel/8/x86_64/zabbix-agent2-7.0.0-alpha2.release1.el8.x86_64.rpm"
rhel9_url="https://repo.zabbix.com/zabbix/6.5/rhel/9/x86_64/zabbix-agent2-7.0.0-alpha2.release1.el9.x86_64.rpm"

# Verificar la conectividad de red
echo  -e "\nComprobando la conectividad de red..."
if ! ping -c 1 google.com >/dev/null 2>&1; then
   echo  -e "Error: No hay conexión de red. Verifica tu conexión antes de continuar."
   exit 1
fi

# Mostrar opciones disponibles
echo -e "---------------------------------------"
echo -e "Recuerde tener privilegios SUDO"
echo -e "---------------------------------------"
echo -e "Eligir una opción:"
echo -e "1 --> SLES 12/ OpenSUSE (.RPM)"
echo -e "2 --> SLES 15/ OpenSUSE (.RPM)"
echo -e "3 --> Debian 9 (.DEB)"
echo -e "4 --> Debian 10 (.DEB)"
echo -e "5 --> Debian 11 (.DEB)"
echo -e "6 --> Ubuntu 22.04 (.DEB)"
echo -e "7 --> RHEL 7 / CentOS 7 (.RPM)"
echo -e "8 --> RHEL 8 / CentOS 8 / Oracle Linux 8 (.RPM)"
echo -e "9 --> RHEL 9 / CentOS Stream 9 / Oracle Linux 9 (.RPM)"
echo -e "---------------------------------------"

# Leer la opción seleccionada
read -p "Ingrese el número de opción: " option

case $option in
   1)
      # Descargar e instalar el agente Zabbix en SLES 12 / OpenSUSE
      echo -e "\nDescargando el agente de Zabbix para SLES 12 / OpenSUSE..."
      wget -O zabbix-agent2.rpm $sles12_url || { echo "Error al descargar el agente de Zabbix"; exit 1; }
      echo  -e "Instalando el agente de Zabbix..."
      zypper install -y zabbix-agent2.rpm || { echo "Error al instalar el agente de Zabbix"; exit 1; }
      ;;
   2)
      # Descargar e instalar el agente Zabbix en SLES 15 / OpenSUSE
      echo -e "\nDescargando el agente de Zabbix para SLES 15 / OpenSUSE..."
      wget -O zabbix-agent2.rpm $sles15_url || { echo "Error al descargar el agente de Zabbix"; exit 1; }
      echo -e "Instalando el agente de Zabbix..."
      zypper install -y zabbix-agent2.rpm || { echo "Error al instalar el agente de Zabbix"; exit 1; }
      ;;
   3)
      # Descargar e instalar el agente Zabbix en Debian 9 / Ubuntu 18.04
      echo -e "\nDescargando el agente de Zabbix para Debian 9 / Ubuntu 18.04..."
      wget -O zabbix-agent2.deb $debian9_url || { echo "Error al descargar el agente de Zabbix"; exit 1; }
      echo -e "Instalando el agente de Zabbix..."
      dpkg -i zabbix-agent2.deb || { echo "Error al instalar el agente de Zabbix"; exit 1; }
      ;;
   4)
      # Descargar e instalar el agente Zabbix en Debian 10 / Ubuntu 20.04
      echo -e "\nDescargando el agente de Zabbix para Debian 10 / Ubuntu 20.04..."
      wget -O zabbix-agent2.deb $debian10_url || { echo "Error al descargar el agente de Zabbix"; exit 1; }
      echo -e "Instalando el agente de Zabbix..."
      dpkg -i zabbix-agent2.deb || { echo "Error al instalar el agente de Zabbix"; exit 1; }
      ;;
   5)
      # Descargar e instalar el agente Zabbix en Ubuntu 22.04
      echo -e "\nDescargando el agente de Zabbix para Ubuntu 22.04..."
      wget -O zabbix-agent.deb $debian11_url || { echo "Error al descargar el agente de Zabbix"; exit 1; }    
      echo -e "Instalando el agente de Zabbix..."
      dpkg -i zabbix-agent.deb || { echo "Error al instalar el agente de Zabbix"; exit 1; }
      ;;
    6)
      # Descargar e instalar el agente Zabbix en Debian 11
      echo -e "\nDescargando el agente de Zabbix para Debian 11 ..."
      wget -O zabbix-agent.deb $ubuntu22_url || { echo "Error al descargar el agente de Zabbix"; exit 1; }     
      echo -e "Instalando el agente de Zabbix..."
      dpkg -i zabbix-agent.deb || { echo "Error al instalar el agente de Zabbix"; exit 1; }
      ;;
   7)
      # Descargar e instalar el agente Zabbix en RHEL 7 / CentOS 7
      echo -e "\nDescargando el agente de Zabbix para RHEL 7 / CentOS 7..."
      wget -O zabbix-agent2.rpm $rhel7_url || { echo "Error al descargar el agente de Zabbix"; exit 1; }
      echo -e "Instalando el agente de Zabbix..."
      yum localinstall -y zabbix-agent2.rpm || { echo "Error al instalar el agente de Zabbix"; exit 1; }
      ;;
   8)
      # Descargar e instalar el agente Zabbix en RHEL 8 / CentOS 8 / Oracle Linux 8
      echo -e "\nDescargando el agente de Zabbix para RHEL 8 / CentOS 8 / Oracle Linux 8..."
      wget -O zabbix-agent2.rpm $rhel8_url
      echo -e "Instalando el agente de Zabbix..."
      dnf localinstall -y zabbix-agent2.rpm
      ;;
   9)
   # Descargar e instalar el agente Zabbix en RHEL 9 / CentOS Stream 9 / Oracle Linux 9
   echo -e "\nDescargando el agente de Zabbix para RHEL 9 / CentOS Stream 9 / Oracle Linux 9..."
   wget -O zabbix-agent2.rpm $rhel9_url || { echo "Error al descargar el agente de Zabbix"; exit 1; }
   echo -e "Instalando el agente de Zabbix..."
   dnf localinstall -y zabbix-agent2.rpm || { echo "Error al instalar el agente de Zabbix"; exit 1; }
   ;;

   *)
      echo -e "Opción inválida. Saliendo..."
      exit 1
      ;;
esac

# Configurar el agente de Zabbix
echo -e "\nConfigurando el agente de Zabbix..."
# Mostrar opciones disponibles
echo -e "---------------------------------------"
echo -e "Seleccione el template de acuerdo al cliente"
echo -e "---------------------------------------"
echo -e "1 --> template_cliente_aceros_agent2.conf"
echo -e "2 --> template_cliente_aceros_agentd.conf"
echo -e "3 --> template_cliente_gsf_agent2.conf"
echo -e "4 --> template_cliente_gsf_agentd.conf"
echo -e "5 --> template_cliente_marathon_agent2.conf"
echo -e "6 --> template_cliente_marathon_agentd.conf"
echo -e "7 --> template_cliente_gse_agent2.conf"
echo -e "8 --> template_cliente_gse_agentd.conf"
echo -e "---------------------------------------"

# Leer la opción seleccionada
read -p "Ingrese el número de opción: " option
# Configurar plantilla

case $option in
    1)
        template_file="$(dirname "$0")/template_cliente_aceros_agent2.conf"
        ;;
    2)
        template_file="$(dirname "$0")/template_cliente_aceros_agentd.conf"
        ;;
    3)
        template_file="$(dirname "$0")/template_cliente_gsf_agent2.conf"
        ;;
    4)
        template_file="$(dirname "$0")/template_cliente_gsf_agentd.conf"
        ;;
    5)
        template_file="$(dirname "$0")/template_cliente_marathon_agent2.conf"
        ;;
    6)
        template_file="$(dirname "$0")/template_cliente_marathon_agentd.conf"
        ;;
    7)
        template_file="$(dirname "$0")/template_cliente_gse_agent2.conf"
        ;;
    8)
        template_file="$(dirname "$0")/template_cliente_gse_agentd.conf"
        ;;
    *)
        echo -e "Opción inválida. Saliendo del script. Vuelve a intentarlo"
        exit 1
        ;;
esac

# Verificar si el agente de Zabbix es zabbix-agent2 o zabbix-agent
if [[ -n $(command -v dpkg) ]]; then
    agente_instalado=$(dpkg -l | grep zabbix-agent2 | awk '{print $1}')
elif [[ -n $(command -v rpm) ]]; then
    agente_instalado=$(rpm -qa | grep zabbix-agent2)
fi

if [[ -n $agente_instalado ]]; then
    if [[ -n $template_file ]]; then
        echo -e "\n--------------Copiando los archivos de configuración-------------------\n"
        cp -f "$template_file" "$filezabbix/zabbix_agent2.conf"
        cp top_* "$plugins2"
        chmod +x "$plugins2"/top_*
        echo -e "\n-------------------Habilitando el inicio automático-------------------\n"
        if [[ -n $(command -v systemctl) ]]; then
            systemctl enable zabbix-agent2
            echo -e "\n-------------------Iniciando zabbix-agent2-------------------\n"
            systemctl start zabbix-agent2
            echo -e "\n---------------Verificando estado del servicio----------------\n"
            systemctl status zabbix-agent2
        fi
    fi
else
    if [[ -n $template_file ]]; then
        echo -e "\n--------------Copiando los archivos de configuración-------------------\n"
        mkdir -p "$plugins"
        cp -f "$template_file" "$filezabbix/zabbix_agentd.conf"
        cp top_* "$plugins"
        chmod +x "$plugins"/top_*
        echo -e "\n-------------------Habilitando el inicio automático-------------------\n"
        if [[ -n $(command -v systemctl) ]]; then
            systemctl enable zabbix-agent
            echo -e "\n-------------------Iniciando zabbix-agent-------------------\n"
            systemctl start zabbix-agent
            echo -e "\n---------------Verificando estado del servicio----------------\n"
            systemctl status zabbix-agent
        fi
    fi
fi
echo "-----------------------------------------------------------------------"
echo  -e "El agente de Zabbix se ha instalado y configurado correctamente. ¡¡¡Adios!!"
echo "-----------------------------------------------------------------------"