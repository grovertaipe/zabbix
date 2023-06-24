#!/bin/bash

# Verificar privilegios de SUDO
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse con privilegios de superusuario." 
   exit 1
fi

# Mostrar información del sistema operativo
echo -e "Información del sistema operativo:"
cat /etc/*release

# Variables de ubicación de archivo de configuración y scripts
plugins="/etc/zabbix/zabbix_agentd.d/plugins.d"
plugins2="/etc/zabbix/zabbix_agent2.d/plugins.d"
filezabbix="/etc/zabbix"


# Variables de URL de descarga
sles12_url="https://repo.zabbix.com/zabbix/6.5/sles/12/x86_64/zabbix-agent2-7.0.0-alpha1.release1.sles12.x86_64.rpm"
sles15_url="https://repo.zabbix.com/zabbix/6.5/sles/15/x86_64/zabbix-agent2-7.0.0-alpha1.release1.sles15.x86_64.rpm"
debian9_url="https://repo.zabbix.com/zabbix/6.5/debian/pool/main/z/zabbix/zabbix-agent2_7.0.0~alpha1-1%2Bdebian9_amd64.deb"
debian10_url="https://repo.zabbix.com/zabbix/6.5/debian/pool/main/z/zabbix/zabbix-agent2_7.0.0~alpha1-1%2Bdebian10_amd64.deb"
debian11_url="https://repo.zabbix.com/zabbix/6.5/ubuntu/pool/main/z/zabbix/zabbix-agent_7.0.0~alpha1-1%2Bubuntu22.04_amd64.deb"
rhel7_url="https://repo.zabbix.com/zabbix/6.5/rhel/7/x86_64/zabbix-agent2-7.0.0-alpha1.release1.el7.x86_64.rpm"
rhel8_url="https://repo.zabbix.com/zabbix/6.5/rhel/8/x86_64/zabbix-agent2-7.0.0-alpha1.release1.el8.x86_64.rpm"
rhel9_url="https://repo.zabbix.com/zabbix/6.5/rhel/9/x86_64/zabbix-agent2-7.0.0-alpha1.release1.el9.x86_64.rpm"

# Mostrar opciones disponibles
echo "---------------------------------------"
echo "Recuerde tener privilegios SUDO"
echo "---------------------------------------"
echo "Eligir una opción:"
echo "1 --> SLES 12/ OpenSUSE (.RPM)"
echo "2 --> SLES 15/ OpenSUSE (.RPM)"
echo "3 --> Debian 9 / Ubuntu 18.04 (.DEB)"
echo "4 --> Debian 10 / Ubuntu 20.04 (.DEB)"
echo "5 --> Debian 11 / Ubuntu 22.04 (.DEB)"
echo "6 --> RHEL 7 / CentOS / Fedora (.RPM)"
echo "7 --> RHEL 8 / CentOS / Fedora (.RPM)"
echo "8 --> RHEL 9 / CentOS / Fedora (.RPM)"
echo -n "Opción: "
read systemOperative
echo -e "\nOpción elegida: $systemOperative\n"

# Mostrar opciones de plantillas
echo "Eligir una plantilla:"
echo "1 --> template_cliente_aceros_agent2.conf"
echo "2 --> template_cliente_aceros_agentd.conf"
echo "3 --> template_cliente_cliente1_agent2.conf"
echo "4 --> template_cliente_cliente2_agentd.conf"
echo -n "Opción: "
read template

# Configurar la URL de descarga y el nombre del archivo según la opción seleccionada
case $systemOperative in
    1)
        url=$sles12_url
        filename="zabbix-agent2-7.0.0-alpha1.release1.sles12.x86_64.rpm"
        ;;
    2)
        url=$sles15_url
        filename="zabbix-agent2-7.0.0-alpha1.release1.sles15.x86_64.rpm"
        ;;
    3)
        url=$debian9_url
        filename="zabbix-agent2_7.0.0~alpha1-1+debian9_amd64.deb"
        ;;
    4)
        url=$debian10_url
        filename="zabbix-agent2_7.0.0~alpha1-1+debian10_amd64.deb"
        ;;
    5)
        url=$debian11_url
        filename="zabbix-agent_7.0.0~alpha1-1+ubuntu22.04_amd64.deb"
        ;;
    6)
        url=$rhel7_url
        filename="zabbix-agent2-7.0.0-alpha1.release1.el7.x86_64.rpm"
        ;;
    7)
        url=$rhel8_url
        filename="zabbix-agent2-7.0.0-alpha1.release1.el8.x86_64.rpm"
        ;;
    8)
        url=$rhel9_url
        filename="zabbix-agent2-7.0.0-alpha1.release1.el9.x86_64.rpm"
        ;;
    *)
        echo -e "Opción inválida. Saliendo del script."
        exit 1
        ;;
esac

# Mostrar opción y plantilla seleccionadas
echo "Descargando Zabbix Agent para la opción $systemOperative y la plantilla $template..."

# Descargar el archivo de instalación
wget $url -O $filename

# Verificar si la descarga fue exitosa
if [[ $? -eq 0 ]]; then
    echo "Descarga exitosa."
else
    echo "Error al descargar el archivo. Saliendo del script."
    exit 1
fi

# Instalar Zabbix Agent
case $systemOperative in
    1 | 2 | 6 | 7 | 8)
        rpm -ivh $filename
        ;;
    3 | 4)
        dpkg -i $filename
        ;;
    5)
        # Comprueba si libmodbus5 está instalado
             echo "Comprobando si el paquete libmodbus5 está instalado en el sistema..."
        if ! dpkg -s libmodbus5 >/dev/null 2>&1; then
            echo "El paquete libmodbus5 no está instalado. Instalando..."
            apt-get install -y libmodbus5
        else
            echo "El paquete libmodbus5 ya está instalado."
        fi
        dpkg -i $filename        
        ;;
    *)
        echo "Opción inválida. Saliendo del script."
        exit 1
        ;;
esac

# Verificar si la instalación fue exitosa
if [[ $? -eq 0 ]]; then
    echo "Instalación exitosa."
else
    echo "Error al instalar el paquete. Saliendo del script."
    exit 1
fi

# Configurar plantilla
case $systemOperative in
    1 | 2 | 3 | 4 | 6 | 7 | 8)
        template_file="$(dirname "$0")/template_cliente_aceros_agent2.conf"
        echo "\n--------------Copiando los archivos de configuración-------------------\n"
        cp -f "$template_file" $filezabbix/zabbix_agent2.conf
        cp top_* $plugins2
        chmod +x $plugins2/top_*
        echo "\n-------------------Habilitando el inicio automático-------------------\n"
        systemctl enable zabbix-agent2
        echo "\n-------------------Iniciando zabbix-agent2-------------------\n"
        systemctl start zabbix-agent2
        echo "\n---------------Verificando status del servicio----------------\n"
        systemctl status zabbix-agent2
        ;;
    5)
        case $template in
            1)
                template_file="$(dirname "$0")/template_cliente_aceros_agent2.conf"
                ;;
            2)
                template_file="$(dirname "$0")/template_cliente_aceros_agentd.conf"
                ;;
            3)
                template_file="$(dirname "$0")/template_cliente_cliente1_agent2.conf"
                ;;
            4)
                template_file="$(dirname "$0")/template_cliente_cliente2_agentd.conf"
                ;;
            *)
                echo -e "Plantilla inválida. Utilizando la plantilla por defecto."
                ;;
        esac

        if [[ -n $template_file ]]; then
            echo "\n--------------Copiando los archivos de configuración-------------------\n"
            mkdir -p $plugins
            cp -f "$template_file" $filezabbix/zabbix_agentd.conf
            cp top_* $plugins
            chmod +x $plugins/top_*
            echo "\n-------------------Habilitando el inicio automático-------------------\n"
            systemctl enable zabbix-agent
            echo "\n-------------------Iniciando zabbix-agent-------------------\n"
            systemctl start zabbix-agent
            echo "\n---------------Verificando status del servicio----------------\n"
            systemctl status zabbix-agent
        fi
        ;;
    *)
        echo "Opción inválida. Saliendo del script."
        exit 1
        ;;
esac

# Eliminar el archivo descargado
echo "\n---------------------Eliminando el instalador---------------------\n"
rm $filename

echo "El script ha finalizado correctamente."
