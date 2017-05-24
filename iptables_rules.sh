#! /bin/bash 


# add header + color
echo "IPTABLES RULES"
echo

# There are three chains : INPUT, FORWARD, OUTPUT
#There are three main policies : ACCEPT, DROP, REJECT


echo "Menu:"
echo 
echo "[+] Start/Stop/Restart        ......................... 0 "
echo "[+] List all iptables rules   ........................  1 "
echo "[+] Lock down mode            ........................  2"
echo 


echo "Enter one of the options"

read user_input
echo 

if [ $user_input -eq 0 ]; then 

	echo "[-] Disabling the iptables ..."
	
	# by settig the policies to accept, that would diable the functionality of the firewall
	iptables -P INPUT   ACCEPT 
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT  ACCEPT 

	iptables -F #flush the rules
 
elif [ $user_input -eq 1 ]; then

	echo "Iptables Status: "
	echo  
	iptables -L

elif [ $user_input -eq 2 ]; then 

	echo "Locking Mode "
	
	# drop all packets 
	# disable IPv4 and IPv6
	iptables -P INPUT   DROP
	iptables -P OUTPUT  DROP
	iptables -P FORWARD DROP

	iptables -F 
	
fi 




# List all iptables rules:
#iptables -L 




