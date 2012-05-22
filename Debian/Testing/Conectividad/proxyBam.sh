#!/bin/sh

# script para activar el proxy transparente con conexion por PPP (Modem USB).
# Carlos J. Castillo N.
# castilloc185[at]gmail[dot]com
#
# En este script se han realizado las siguientes consideraciones:
# em1 = red local
# ppp0 = Modem USB (Internet)

#----Limpiamos todas las reglas----
echo 'Limpiando Reglas de Iptables'
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

#----Damos inet a la LAN
echo 'Ejecutando inet a la red local'
iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o ppp0 -j MASQUERADE

#----Activando bit fordwarder----
echo 'Activando bit de redirección'
echo 1 > /proc/sys/net/ipv4/ip_forward

#----Politicas por defecto ACCEPT
echo 'Implementando Politicas por defecto'
iptables -P OUTPUT ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT

#Proxy transparente
echo 'aplicando regla para proxy transparente'
iptables -t nat -A PREROUTING -i em1 -p tcp --dport 80 -j REDIRECT --to-port 3128

echo 'procesos aplicados...'
echo 'Disfrute'
