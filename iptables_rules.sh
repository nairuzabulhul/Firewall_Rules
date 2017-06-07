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
echo "[+] Allow SSH from specific IP and PORT    .....................   5 "
echo "[+] Route HTTP &HTTPS  through SSH         ......................  6 "
echo "[+] Open range of ports                    ......................  7 "
echo "[+] Block or Open cetrain ports            ......................  8 "
echo "[+] Protection Mode                        ......................  9 "
echo "[+] Privacy Mode                           ......................  10" # using OpenVPNs and SSH
echo "[+] Delete all rule for IPv4 and IPv6      ......................  11"
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

	#IPv6
	ip6tables -P INPUT ACCEPT
	ip6tables -P FORWARD ACCEPT
	ip6tables -P OUTPUT ACCEPT
 
	ip6tables -F
	echo

elif [ $user_input -eq 1 ]; then

	echo "Iptables Status: "
	echo  
	
	# IPv4
	echo "IPv4 Rules :"
	iptables -L -n  --line-numbers
	echo 
	echo 

	# IPv6 
	echo "IPv6 Rules: "
	ip6tables -L -n --line-numbers

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
        ip6tables -P INPUT DROP
	ip6tables -P FORWARD DROP
	ip6tables  -P OUTPUT DROP

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


	# IPV6 disables

	ip6tables -P INPUT DROP
	ip6tables -P FORWARD DROP
	ip6tables -P OUTPUT DROP

	echo 

elif [ $user_input -eq 5 ]; then

	# Allow incoming or outcoming pings
	echo "Allow Incoming SSH from speific IP and port number"

	echo "Enter the interface: "
	read  interface
	echo 

	echo "Enetr the specific IP:"
	read ip 
	echo 

	echo "Enter the port number of the ssh:"
	read port
	echo 


	iptables -A INPUT -i $interface -p tcp -m tcp -s $ip --dport $port -m state --state NEW,ESTABLISHED  -j ACCEPT
	
	# Output 
	iptables -A OUTPUT -o $interface -p tcp -m tcp  --sport $port -m state --state ESTABLISHED -j ACCEPT 

		
	# HTTP/ HTTPS ---> SSH

elif [ $user_input -eq 9 ]; then 

	# PROTECTION MODE : combination of 4 and 5 
	echo "Protection mode drops all packets incoming and outgoing and allows only HTTP,HTTPS and SSH "


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
	# for the SSH choose the port 
	
	echo "Enter the type of the interface : (eth0/wlan)"
	read interface
	echo

 	echo "Enetr the specific IP:"
	read ip 
	echo 

	echo "Enter the port number of the ssh:"
	read port
	echo 

	echo 
	
	# HTTP section

	iptables -A OUTPUT -o $interface  -p udp -m udp --dport 53  -j ACCEPT 
	iptables -A OUTPUT -o $interface  -p tcp -m tcp --dport 80  -j ACCEPT -m state --state NEW
	iptables -A OUTPUT -o $interface  -p tcp -m tcp --dport 443 -j ACCEPT -m state --state NEW

	# SSH section
	iptables -A INPUT -i $interface -p tcp -m tcp -s $ip --dport $port -m state --state NEW,ESTABLISHED  -j ACCEPT
	
	# Output 
	iptables -A OUTPUT -o $interface -p tcp -m tcp  --sport $port -m state --state ESTABLISHED -j ACCEPT 

	# Disable IPv6

	ip6tables -P INPUT DROP
	ip6tables -P FORWARD DROP
	ip6tables -P OUTPUT DROP

	echo "DONE ........................"		
	echo 


elif [ $user_input -eq 11 ]; then 

	# Flush all IPv4 rules 

	iptables -F

	# Flush all IPv6 rules

	ip6tables -F 

fi
