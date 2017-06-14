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
echo "[+] Block or Open cetrain ports            ......................  6 "
echo "[+] Protection Mode [HTTPS & SSH]          ......................  7 "
echo "[+] Privacy Mode [VPN kill switch]         ......................  8 " # using OpenVPNs and SSH
echo "[+] Delete all rule for IPv4 and IPv6      ......................  9 "
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

	# Allow SSH from speific IP & port
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

# Number 6 : BLock or open certain ports

  

elif [ $user_input -eq 7 ]; then 

	# PROTECTION MODE : combination of 4 and 5
	# HTTP -HTTPS & SSH 
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


elif [ $user_input -eq 8 ]; then 


	# Privacy Mode -- VPN killswitch # drop all the traffic if the VPN is disconnected 

	# 1- Connect to your VPN service  IP and Port
	# 2- Choose option 8 to activate the VPN kill switch 


	echo "VPN IP: "
	read vpn_ip
	echo 

	echo "VPN port: "
	read vpn_port
	echo 

	echo "Connection type [tcp OR udp] :"
	read conn_type
	echo 

	# Drop all traffic 
	
	iptables -P INPUT DROP
	iptables -P FORWARD   DROP 
	iptables -P OUTPUT DROP
	
	
	# Allow basic INPUT traffic 

	iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT -p icmp -m icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
	

	# Allow basic OUTPUT traffic
	iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
	iptables -A OUTPUT -o lo -j ACCEPT
	iptables -A OUTPUT -p icmp -j ACCEPT


	# Allow VPN traffic only 
	iptables -A OUTPUT -o tun+ -j ACCEPT
	iptables -A OUTPUT -d $vpn_ip  -p $conn_type -m $conn_type --dport $vpn_port -j ACCEPT
	

elif [ $user_input -eq 9 ]; then 

	# Flush all IPv4 rules 

	iptables -F

	# Flush all IPv6 rules

	ip6tables -F 

fi
