#!/bin/bash

# Script para compartir internet entre un ban y la red cableada con Squid Transparente
# Carlos J. Castillo N
# castilloc185[at]gmail[dot]com
# twitter Dr4g0nkn1ght

# Activamos el reenvio de paquetes:

clear
echo "Activando la comparticion de internet (BAM) + Squid"
echo "Por favor espere..."
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

echo "Todos los procesos han sido ejecutados"
echo "Disfrute de su conexion Compartida con proxy"
