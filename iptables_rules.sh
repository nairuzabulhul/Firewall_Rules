#! /bin/bash 


# add header + color
echo "IPTABLES RULES"
echo

# There are three chains : INPUT, FORWARD, OUTPUT
#There are three main policies : ACCEPT, DROP, REJECT


echo "Menu:"
echo 
echo "[+] Disable ALL the rules                  ......................  0 "
echo "[+] List all iptables rules                ......................  1 "
echo "[+] Allow localhost connections ONLY       ......................  2 "
echo "[+] Lock down mode                         ......................  3 "
echo "[+] Allow HTTP & HTTPS                     ......................  4 "
echo "[+] Route HTTP &HTTPS  through SSH         ......................  5 "
echo "[+] Open range of ports                    ......................  6 "
echo "[+] Block or Open cetrain ports            ......................  7 "
echo "[+] Protection Mode                        ......................  8 "
echo "[+] Privacy Mode                           ......................  9 " # using OpenVPNs and SSH
echo "[+] Delete specific Rules                  ......................  10 "
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
	iptables -L -n -v --line-numbers
	echo 
	echo 


elif [ $user_input -eq 2 ]; then 


	echo "Allow ONLY localhost connections"
	iptables -P INPUT   DROP
	iptables -P OUTPUT  DROP
	iptables -P FORWARD DROP
	
	iptables -A INPUT  -i lo -j ACCEPT # i for input traffic
	iptables -A OUTPUT -o lo -j ACCEPT # o for output traffic
 

elif [ $user_input -eq 3 ]; then 

	echo "Locking Mode "
	
	# Flush old rules 
	iptables -F

	# drop all packets 
	# disable IPv4 
	iptables -P INPUT   DROP
	iptables -P OUTPUT  DROP
	iptables -P FORWARD DROP

	
	# Disable IPv6	


elif [ $user_input -eq 4 ]; then 

	echo "Allow ONLY HTTP & HTTPS "
	echo 

	iptables -P INPUT   DROP
	iptables -P FORWARD DROP
	iptables -P OUTPUT  DROP


	# loop interface "esstential "
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A OUTPUT -o lo -j ACCEPT

	# Allow ONLY HTTP & HTTPS traffic 
	iptables -A INPUT  -m state --state RELATED,ESTABLISHED -j ACCEPT # accept  related or established connection packets 
	iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
	
	# Add 80, 433 , 53 ports for outgoing connection
	
	echo "Enter the type of the interface : (eth0/wlan)"
	read interface
	echo 

	iptables -A OUTPUT -o $interface  -p udp -m udp --dport 53  -j ACCEPT 
	iptables -A OUTPUT -o $interface  -p tcp -m tcp --dport 80  -j ACCEPT -m state --state NEW
	iptables -A OUTPUT -o $interface  -p tcp -m tcp --dport 443 -j ACCEPT -m state --state NEW
	echo 

#elif [ $user_input -eq 5 ];

	# Allow incoming or outcoming pings
#	echo "Route HTTP & HTTPS traffic through SSH [Good option for extra layer of traffic encryption]"
	
	# HTTP/ HTTPS ---> SSH
	


fi 





