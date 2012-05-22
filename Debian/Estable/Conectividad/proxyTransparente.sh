#!/bin/bash

# Script para compartir internet entre un ban y la red cableada
#Carlos J. Castillo N
# castilloc185@gmail.com
# Dr4g0nkn1ght

# Se activa el reenvio de paquetes

clear
echo "Activando la comparticion de internet con BAM"
echo "Por favor espere"
echo "Activando el forward (renvio de paquetes)"
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "Renvio de paquetes activo"
# Borramos reglas anteriores de iptables

echo "Borrando las reglas de Iptables Anteriores"
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

echo "Reglas borradas, continuando con las iptables..."
echo "Activando el nat"
#Activando NAT en ppp0

iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE

# Alternativamente, es posible contar con un servidor DHCP esto nos permitiria dar Ip a los clientes
# convendria entonces aca iniciar o reiniciar el servicio

#/etc/init.d/servicio restart

echo "todo se ha configurado correctamente"
echo "Disfrute de su conexion Compartida...."
