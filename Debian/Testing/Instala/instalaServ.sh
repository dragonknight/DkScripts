#!/bin/bash
#
# Script para la instalación de las utilidades en los sistemas administrados por  DK
# este código instala automaticamente las aplicaciones.

clear
salir=0
echo ''
        log="/var/log/UtilsLog"
	echo '********************************************************************************************'
        echo '*                                       Bienvenido...                                      *'
        echo '*      Esta utilidad instalará automaticamente un conjunto de aplicaciones en su sistema   *'
        echo '*      Este script ha sido licenciado bajo la GNU GPL                                      *'
        echo '*      Copyright (c) 2011 Carlos J. Castillo N.                                            *'
        echo '*      Se desarrrolla esperando que sea util y funcional, pero sin ningun tipo de garantia *'
        echo '********************************************************************************************'

        if [ -a $log ]
          then
		echo 'Incializando el registro en LOG, espere un momento'
		echo 'accesadon al script de instalacion de utilidades '$fecha >> $log
		sleep 10

          else
                echo 'El archivo de Log no se encuentra creado, espero un momento mientras se crea'
        	touch $log
		echo 'archivo de log creado ' $date ; 
		sleep 10
        fi

        fecha=$(date)


until [ $salir -eq 1 ]
  do
	clear
	echo ''
	echo '====================================================================================='
	echo '               Selecióne el paquete de aplicaciones que desea instalar:'
	echo '====================================================================================='
	echo ''
	echo '      1  .- Servidores de Desarrollo'
	echo '      2  .- Servidores de red'
	echo '      3  .- Servidores para Datos'
	echo '      4  .- Utilidades de Administrativas (Conexiones, redes, monitoreo)'
	echo ''
	echo '-------------------------------------------------------------------------------------'
	echo '      0  .- Salir'
	echo '====================================================================================='
	echo ''
	echo 'Ingrese su opcion: '; read opt

	echo ''

	case $opt in

	  1)
		echo 'Instalando Servidores en el equipo ' >> $log;
		echo 'Actualizando la lista de paquetes.... Por favor espere...' 
		aptitude update
		echo 'Se ha actualizado la lista de paquetes, continuando con el proceso'
		echo 'Se procedera a instalar los paquetes para servidores,'
		echo 'Instalando mercurial y etckeeper para el control de versiones de archivos de configuración'
		sleep 5
		aptitude install mercurial etckeeper
		echo 'Mercurial y etckeeper se han instalado con éxito, continuando con el proceso'
		sleep 5
		aptitude install apache php5 mysql-server phpmyadmin
		echo 'El servidor apache, php, MySQL y phpMyAdmind se han sido instalados con éxito en el sistema'
		echo 'Recuerde antes de continuar, ejecutar la configuración de etckeeper (/etc/etckeeper/etckeeper.conf)'
		echo 'Recuerde igualmente configurar mercurial (/etc/mercurial/hgrc)'
		echo 'Realizada la Configuración limpie etckeeper (etckeeper uninit) e inicialice luego (etckeeper init)'
		echo 'Por ultimo realize el primer commit (etckeeper commit "Mensaje de commit")'
		sleep 25
		;;
	  2)
		echo 'Se procedera a instalar los servicios de Red ' >> $log;
		echo 'Instalando DHCP, DNS, Proxy'
		sleep 5
		aptitude update
		aptitude install  squid squidview bind9 dhcp3-server
		echo 'Se han instalado los Servicios, es necesario ahora que implemente la Configuración de estos'
		echo 'Recuerde realizar durante este proceso lo commit hg,'
		echo 'asi mismo, para el correcto control de versiones, modifique la configuración un servicio a la ves'
		sleep 15
		;;
	  3)
		echo 'Se procedera a instalar los servidores de datos'
		echo 'Se instalará Ftp, Ssh'
		sleep 5
		aptitude update
		aptitude install proftpd ssh
		echo 'Se han instalado los servicios con exito...'
		echo 'Disfrute'
		sleep 10
		;; 
	  4)
		echo 'Se procedera a instalar las Utilidades de Administración en el equipo ' >> $log;
		echo 'Se instalará software Kvm y de Monitoreo de equipos y protocolos, utilidades para modem'
		sleep 5
		aptitude update
		aptitude install quicksynergy nagios3 wireshark nmap zenmap nast iptraf network-manager network-manager-gnome wvdial
		echo 'Recuerde que es necesario configurar nagios para que funcione correctamente, '
		echo 'al finalizar de aplicar cualquier configuracion recuerde ejecutar un commit para mantener el control de versiones de los servicios'
		sleep 10
		;;
	  0)
		salir=1
		;;
	  *)	echo 'Su Selección es invalida.... Intente de nuevo :/'
		;;
	esac
  done
