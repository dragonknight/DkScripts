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
	echo '      1  .- Utilidades de Consola'
	echo '      2  .- Utilidades para Gnome'
	echo '      3  .- Utilidadesd de Diseño y Diagramación'
	echo '      4  .- Multimedia'
	echo '      5  .- Utilidades para Programación'
	echo '      6 .- Mensajeria y redes sociales'
	echo ''
	echo '-------------------------------------------------------------------------------------'
	echo '      0  .- Salir'
	echo '====================================================================================='
	echo ''
	echo 'Ingrese su opcion: '; read opt

	echo ''

	case $opt in

	  1)
		echo 'Se Procedera a instalar utilidades para la consola ' >> $log;
		echo 'Se instalara una terminar grafica alternativa (terminator), soporte para el ratón (gpm)'
		sleep 10
		aptitude update
		aptitude install terminator gpm rar unrar unrar-free
		echo 'Se aplicara ahora una nueva configuración que separará la salida de resultados en la terminal'
		echo 'Para el mejor uso de terminator se recomienda leer un manual de comandos'
		sleep 10
		;;
	  2)
		echo 'Se procederan a instalar las utilidades basicas en gnome'
		echo 'Se montará la suite ofimatica, software quemador, entre otras'
		aptitude update
		aptitude install brasero k3b
		aptitude -t squeeze-backports install libreoffice  libreoffice-l10n-es; aptitude install gdebi google-chrome-stable gnome-screenshot multiget okular okular-extra-backends fontforge fontmatrix fonttools
		echo 'Se han instalado las utilidades'
		sleep 5
		;;
	  3)
		echo 'Se procederan a instalar la utilidades de diagramacion y diseño'
		echo 'Software como Dia (Diagramacion, Scribus), y programas para diseño (Gimp, Inkscape, myPaint) serán instalados en el sistema'
		sleep 5
		aptitude update
		aptitude install dia gimp inkscape scribus mypaint
		echo 'Las utilidades han sido instaladas en su sistema, disfrute y ¡¡ Happy Desing !!'
		sleep 5
		;;
	  4)
		echo 'Se instalaran los Software Multimedia ' >> $log;
		echo 'Esta operación puede tomar cierto tiempo (Según su Conexión a Internet)'
		echo 'Se instalarán los paquetes Amarok, VLC, y Los codec Multimedia necesarios'
		aptitude update
		aptitude install amarok vlc dvdrip recordmydesktop gnome-codec-install gstreamer0.10-plugins-base gstreamer0.10-plugins-bad gstreamer0.10-plugins-cutter gstreamer0.10-plugins-ugly
		echo 'Utilidades Instaladas...'
		sleep 5
		;;
	  5)
		echo 'Se instalarán ahora las Utilidades de Programación en este Sistema ' >> $log;
		sleep 5
		aptitude update
		aptitude install bluefish bluefish-plugins git
		echo 'Se han instalado las utilidades de programación, XD ¡Happy Hacking!'
		sleep 5
		;;
	  6)
		echo 'Se instalaran las herramientas para Redes Sociales y Mensajeria'
		sleep 5
		aptitude update
		aptitude install amsn emesene empathy
		echo 'Herramientas instaladas, disfrute...'ç
		sleep 5
		;;
	  0)
		salir=1
		;;
	  *)	echo 'Su Selección es invalida.... Intente de nuevo :/'
		;;
	esac
  done
