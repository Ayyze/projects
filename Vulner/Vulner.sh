#!/bin/bash

# Colour settings
red="\033[38;5;203m"
green="\033[38;5;121m"
blue="\033[38;5;117m"
beige="\033[38;5;223m"
colour="\033[0m"


function network_valid()
{
	# Use regex to validate IP address with its 4 octets and CIDR
	ipregex='^([0-9]{1,3}\.){3}[0-9]{1,3}(/([0-9]|[1-2][0-9]|3[0-2]))?$'
	if [[ $network =~ $ipregex ]]; then
		echo
	else
		echo -e "${red}[x] Invalid IP Address!${colour}"
		network_input
	fi
}

function network_input()
{
	# Get from the user a network to scan
	read -p "[?] Enter a network to scan: " network
	network_valid
}

function directory_name()
{
	# Request the user to name the output directory
	read -p "[?] Please name the output directory: " dirname
	mkdir $dirname
}

function scan_option()
{
	# Allow user to choose their preferred scan type
	echo -e "${blue}[*] Please choose from the following scan types:${colour}"
	echo "1. Basic"
	echo "2. Full"
	read -s choice
	echo
}

function get_ip()
{
	# Store IPs to exclude as variables
	internal_ip=$(ifconfig | grep broadcast | awk '{print $2}')
	default_gateway=$(route | grep default | awk '{print $2}')                                                
	# Create a list of IPs to scan through host discovery
	nmap -sn $network | grep "scan report" | tr -d '()' | awk '{print $(NF)}' | grep -Ev "$internal_ip|$default_gateway" >> $dirname/ip_list.txt
}

function tcp_exploits()
{
	# Identify available exploits with EBD-ID.
	grep EDB-ID "$dirname/$eachip"_tcp_scan.txt | awk -F: '{print $2}' | awk '{print $1}' | sort | uniq > "$dirname"/tcptemp.txt
	for eachline in $(cat "$dirname"/tcptemp.txt)
	do
		searchsploit $eachline --disable-colour >> "$dirname/$eachip"_tcp_exploits.txt
	done
	# Clean up temporary files
	rm -rf "$dirname"/tcptemp.txt
}

function udp_exploits()
{
	# Identify available exploits with EBD-ID.
	grep EDB-ID "$dirname/$eachip"_udp_scan.txt | awk -F: '{print $2}' | awk '{print $1}' | sort | uniq > "$dirname"/udptemp.txt
	for eachline in $(cat "$dirname"/udptemp.txt)
	do
		searchsploit $eachline --disable-colour >> "$dirname/$eachip"_udp_exploits.txt 2>/dev/null
	done
	# Clean up temporary files
	rm -rf "$dirname"/udptemp.txt
}

function tcp_basic_scan()
{
	# Perform port and service scan on targets
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		echo -e "${blue}[*] Performing TCP scan on $eachip...${colour}"
		sudo nmap -p- -sV -O $eachip -oN "$dirname/$eachip"_tcp_scan.txt > /dev/null 2>&1
		echo -e "${green}[>] Results saved as:${colour} ${eachip}_tcp_scan.txt"
	done
	echo
}

function udp_basic_scan()
{
	# Perform port and service scan on targets
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		echo -e "${blue}[*] Performing UDP scan on $eachip...${colour}"
		# Scan for open UDP ports with masscan
		sudo masscan -pU:1-65535 --rate 10000 $eachip 2>&1 | tee "$dirname"/udp_results.txt > /dev/null
		# Retrieve open udp port numbers for service scan
		ports=$(grep -o '[0-9]\+/' "$dirname"/udp_results.txt | awk -F/ '{print $1}' | paste -sd,)
		# Perform service version detection on open UDP ports
		sudo nmap -p $ports -sU -sV $eachip -oN "$dirname/$eachip"_udp_scan.txt > /dev/null 2>&1
		# Clean up temporary files
		rm -rf "$dirname"/udp_results.txt
		echo -e "${green}[>] Results saved as:${colour} ${eachip}_udp_scan.txt"
	done
	echo -e '\n'
}

function tcp_full_scan()
{
	# Perform vulnerability analysis on targets
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		echo -e "${blue}[*] Performing TCP scan on $eachip...${colour}"
		sudo nmap -p- -sV -O --script vulners $eachip -oN "$dirname/$eachip"_tcp_scan.txt > /dev/null 2>&1
		tcp_exploits
		echo -e "${green}[>] Results saved as:${colour} ${eachip}_tcp_scan.txt, ${eachip}_tcp_exploits.txt"
	done
	echo
}

function udp_full_scan()
{
	# Perform vulnerability analysis on targets
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		echo -e "${blue}[*] Performing UDP scan on $eachip...${colour}"
		# Scan for open UDP ports with masscan
		sudo masscan -pU:1-65535 --rate 10000 $eachip 2>&1 | tee "$dirname"/udp_results.txt > /dev/null
		# Retrieve open udp port numbers for service scan
		ports=$(grep -o '[0-9]\+/' "$dirname"/udp_results.txt | awk -F/ '{print $1}' | paste -sd,)
		# Perform service version detection on open UDP ports
		sudo nmap -p $ports -sU -sV --script vulners $eachip -oN "$dirname/$eachip"_udp_scan.txt > /dev/null 2>&1
		# Clean up temporary files
		rm -rf "$dirname"/udp_results.txt
		udp_exploits
		echo -e "${green}[>] Results saved as:${colour} ${eachip}_udp_scan.txt, ${eachip}_udp_exploits.txt"
	done
	echo -e '\n'
}

function get_users()
{
	# Enumerate users for bruteforcing
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		# Create list of users enumerated for each host
		enum4linux -U $eachip | grep Account | awk '{print $8}' >> "$dirname/$eachip"_userlist.txt
		# Consolidate all users into a single file
		cat "$dirname/$eachip"_userlist.txt >> "$dirname"/user_temp.txt
	done
	# Remove duplicate occurrences
	sort "$dirname"/user_temp.txt | uniq >> "$dirname"/total_user.txt
	# Feedback the number of users identified and display list of users
	user_count=$(cat $dirname/total_user.txt | wc -l)
	echo -e "${green}[>] $user_count unique user(s) found on the network: ${colour}"
	paste -sd, "$dirname"/total_user.txt
	echo ""
	# Clear temporary files
	rm -rf "$dirname"/user_temp.txt "$dirname"/total_user.txt
}

function create_userlist()
{
	# Take each user input and add into a newly created username list
	echo -e "${blue}[*] Please input user to add to list${colour} (type ${red}'exit'${colour} to complete). "
	while true
	do	
		read -p "[?] Add user: " input
		if [[ "$input" == "exit" ]]; then
			echo -e "${green}[>] List created as:${colour} selected_userlist.txt."
			break
		fi
		echo $input >> "$dirname"/selected_userlist.txt
	done
}

function user_valid()
{
	# Validate user input and proceed accordingly
	if [ "$custom_user" == "y" ]; then
		create_userlist
		username="$dirname"/selected_userlist.txt
		echo
	elif [ "$custom_user" == "n" ]; then
		echo -e "${blue}[*] Default mode selected.${colour}"
		username=username.txt
		echo
	else
		read -p "$(echo -e ${red}"[x] Invalid option! Please enter either y/n: "${colour})" custom_user
		user_valid
	fi
}

function username_option()
{
	# Allow choice of username list
	if [ "$user_count" -gt 0 ]; then
		read -p "[?] Create custom user list? (y/n): " custom_user
		user_valid
	else
		echo -e "${blue}[*] Since no users were obtained, the default mode will be used. ${colour}"
	fi
}

function password_valid()
{
	# Validate user input and store password list as variable according to user choice
	if [ "$pass_choice" == "y" ]; then
		read -p "[?] Enter filename to use as password list: " password
	elif [ "$pass_choice" == "n" ]; then
		echo -e "${blue}[*] Using default password list.${colour}"
		password=password.txt
	else
		read -p "$(echo -e ${red}"[x] Invalid option! Please enter either y/n: "${colour})" pass_choice
		password_valid
	fi
}

function get_password()
{
	# Allow user to choose their password list
	echo -e "${blue}[*] A password list is required for this process.${colour}"
	read -p "[?] Would you like to use a custom password list? (y/n): " pass_choice
	password_valid
	echo
}

function hydra_ssh()
{
	# Store hydra command as function to enable suppression of outputs while allowing other stdouts to appear
	timeout 10m hydra -L $username -P $password $eachip -I ssh >> "$dirname"/ssh.txt
}

function ssh_brute()
{
	# If port is open, proceed to bruteforce, else inform the user and move on.
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		ssh_check=$(grep -w ssh "$dirname/$eachip"_tcp_scan.txt | awk '{print $2}')
		if [ "$ssh_check" = "open" ]; then
			hydra_ssh > /dev/null 2>&1
		else
			echo -e "${red}[x] SSH Port for $eachip is closed!${colour}"
		fi
	done
	echo -e "${green}[>] SSH check completed.${colour}"
}

function hydra_ftp()
{
	# Store hydra command as function to enable suppression of outputs while allowing other stdouts to appear
	timeout 10m hydra -L $username -P $password $eachip -I ftp >> "$dirname"/ftp.txt
}

function ftp_brute()
{
	# If port is open, proceed to bruteforce, else inform the user and move on.
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		ftp_check=$(grep -w ftp "$dirname/$eachip"_tcp_scan.txt | grep -w '21' | awk '{print $2}')
		if [ "$ftp_check" = "open" ]; then
			hydra_ftp > /dev/null 2>&1
		else
			echo -e "${red}[x] FTP Port for $eachip is closed!${colour}"
		fi
	done
	echo -e "${green}[>] FTP check completed.${colour}"
}

function hydra_rdp()
{
	# Store hydra command as function to enable suppression of outputs while allowing other stdouts to appear
	timeout 10m hydra -L $username -P $password $eachip -I rdp >> "$dirname"/rdp.txt
}

function rdp_brute()
{
	# If port is open, proceed to bruteforce, else inform the user and move on.
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		rdp_check=$(grep -w rdp "$dirname/$eachip"_tcp_scan.txt | awk '{print $2}')
		if [ "$rdp_check" = "open" ]; then
			hydra_rdp > /dev/null 2>&1
		else
			echo -e "${red}[x] RDP Port for $eachip is closed!${colour}"
		fi
	done
	echo -e "${green}[>] RDP check completed.${colour}"
}

function hydra_telnet()
{
	# Store hydra command as function to enable suppression of outputs while allowing other stdouts to appear
	timeout 10m hydra -L $username -P $password $eachip -I telnet >> "$dirname"/telnet.txt
}

function telnet_brute()
{
	# If port is open, proceed to bruteforce, else inform the user and move on.
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		telnet_check=$(grep -w telnet "$dirname/$eachip"_tcp_scan.txt | awk '{print $2}')
		if [ "$telnet_check" = "open" ]; then
			hydra_telnet > /dev/null 2>&1
		else
			echo -e "${red}[x] TELNET Port for $eachip is closed!${colour}"
		fi
	done
	echo -e "${green}[>] TELNET check completed.${colour}"
}

function bruteforce()
{
	# Execute chain of commands to check for weak passwords
	echo -e "${blue}[*] Proceeding to check for users with weak passwords.${colour}"
	get_users
	username_option
	get_password
	echo -e "${blue}[*] Initiating bruteforcing sequence.${colour}"
	ssh_brute
	rdp_brute
	ftp_brute
	telnet_brute
	echo -e '\n'
}

function run_scan()
{
	# Execute scan according to user preference
	case $choice in
		1|basic)
			echo -e "${blue}[*] Basic scan selected.${colour}"
			tcp_basic_scan
			udp_basic_scan
			bruteforce
			;;
		2|full)
			echo -e "${blue}[*] Full scan selected.${colour}"
			tcp_full_scan
			udp_full_scan
			bruteforce
			;;
		*)
			read -p "$(echo -e ${red}"[x] Invalid option! Please enter either 1 or 2: "${colour})" choice
			run_scan
			;;
	esac
}

function temp_port_files()
{
	# Save the categories of 'port number, protocol, service, and version' as different files
	grep -i open "$dirname/$eachip"_tcp_scan.txt | grep -i '/tcp' | awk -F/ '{print $1}' >> "$dirname/$eachip"_port_num.txt
	grep -i open "$dirname/$eachip"_tcp_scan.txt | grep -i '/tcp' | awk -F/ '{print $2}' | awk '{print $1}' >> "$dirname/$eachip"_port_proto.txt
	grep -i open "$dirname/$eachip"_tcp_scan.txt | grep -i '/tcp' | awk '{print $3}' >> "$dirname/$eachip"_port_service.txt
	grep -i open "$dirname/$eachip"_tcp_scan.txt | grep -i '/tcp' | awk '{for (i=4; i<NF; i++) {printf ("%s ", $i)} print $NF}' >> "$dirname/$eachip"_port_version.txt
	grep -i open "$dirname/$eachip"_udp_scan.txt | grep -i '/udp' | awk -F/ '{print $1}' >> "$dirname/$eachip"_port_num.txt
	grep -i open "$dirname/$eachip"_udp_scan.txt | grep -i '/udp' | awk -F/ '{print $2}' | awk '{print $1}' >> "$dirname/$eachip"_port_proto.txt
	grep -i open "$dirname/$eachip"_udp_scan.txt | grep -i '/udp' | awk '{print $3}' >> "$dirname/$eachip"_port_service.txt
	grep -i open "$dirname/$eachip"_udp_scan.txt | grep -i '/udp' | awk '{for (i=4; i<NF; i++) {printf ("%s ", $i)} print $NF}' >> "$dirname/$eachip"_port_version.txt
	# Create a file with equal number of lines to aid with formatting
	for eachline in $(cat "$dirname/$eachip"_port_num.txt)
	do
		echo "" >> "$dirname"/blank.txt
	done
	# Merge each file's line output in a new file
	paste "$dirname/$eachip"_port_num.txt "$dirname"/blank.txt "$dirname/$eachip"_port_proto.txt "$dirname"/blank.txt "$dirname/$eachip"_port_service.txt "$dirname"/blank.txt "$dirname/$eachip"_port_version.txt | column -t -s$'\t' > "$dirname/$eachip"_port_temp.txt
	# clear temp files
	rm -rf "$dirname/$eachip"_port_num.txt "$dirname/$eachip"_port_proto.txt "$dirname/$eachip"_port_service.txt "$dirname/$eachip"_port_version.txt "$dirname"/blank.txt
}

function format_mapping()
{
	# Set the output format for network mapping results
	echo "$eachip"
	echo "==============="
	echo "OS:	       $os_info"
	echo "MAC Address:	$mac"
	echo "Domains:      $domains"
	echo "Users:		$users"
	echo
	echo "------- $tcpport_count OPEN PORTS -------"
	echo 
	echo "port	proto	service	       version"
	echo "----	-----	-------	       -------"
	cat "$dirname/$eachip"_port_temp.txt
	echo -e '\n'
	echo "----------- $tcpvuln_count MAPPED TCP VULNS -----------"
	echo "(Note: $tcpvuln_count including database overlaps)"
	grep -E 'cpe|https' "$dirname/$eachip"_tcp_scan.txt | grep \| | sed '/_/s/_//' | awk -F\| '{print $2}'| awk -F'https' '{print $1}' | column -t | sed '/cpe/s/^/\n/' | sed '/cpe/s/$/****/'
	echo
	echo "----------- $udpvuln_count MAPPED UDP VULNS -----------"
	echo "(Note: $udpvuln_count including database overlaps)"
	grep -E 'cpe|https' "$dirname/$eachip"_udp_scan.txt | grep \| | sed '/_/s/_//' | awk -F\| '{print $2}'| awk -F'https' '{print $1}' | column -t | sed '/cpe/s/^/\n/' | sed '/cpe/s/$/****/'
	echo -e '\n'
	echo "----------- $tcpexploit_count TCP EXPLOITS -----------"
	echo "(Note: Based on EDB database)"
	echo
	grep \/ "$dirname/$eachip"_tcp_exploits.txt
	echo
	echo "----------- $udpexploit_count UDP EXPLOITS -----------"
	echo "(Note: Based on EDB database)"
	echo
	grep \/ "$dirname/$eachip"_udp_exploits.txt
	echo -e '\n'
}

function format_brute()
{
	# Set the output format for bruteforce results
	weakpass_count=$(grep host "$dirname"/ssh.txt "$dirname"/rdp.txt "$dirname"/ftp.txt "$dirname"/telnet.txt | wc -l )
	echo "----------- $weakpass_count WEAK PASSWORDS FOUND -----------"
	echo
	cat "$dirname"/ftp.txt "$dirname"/ssh.txt "$dirname"/telnet.txt "$dirname"/rdp.txt | grep host | sed 's/\]/ /' | tr -d '[]' | column -t
	echo -e '\n'
}

function save_output()
{
	hosts=$(paste -s "$dirname"/ip_list.txt)
	# Consolidate all results into single file according to desired format
	echo "************ RESULTS ************" >> "$dirname/$dirname"_Results.txt
	echo "" >> "$dirname/$dirname"_Results.txt
	echo "Hosts Discovered:  $hosts" >> "$dirname/$dirname"_Results.txt
	echo -e '\n' >> "$dirname/$dirname"_Results.txt
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		os_info=$(grep -i 'os details' "$dirname/$eachip"_tcp_scan.txt | awk -F: '{print $2}')
		mac=$(grep -i 'mac address' "$dirname/$eachip"_tcp_scan.txt | awk '{print $3}')
		domains=$(grep -i 'service info' "$dirname/$eachip"_tcp_scan.txt | awk -F\; '{print $1}' | awk -F: '{print $3}')
		users=$(paste -sd, "$dirname/$eachip"_userlist.txt)
		temp_port_files
		tcpport_count=$(cat "$dirname/$eachip"_port_temp.txt | wc -l)
		tcpvuln_count=$(grep -E 'cpe|https' "$dirname/$eachip"_tcp_scan.txt | grep \| | sed '/_/s/_//' | awk -F\| '{print $2}' | awk -F'https' '{print $1}' | grep -v cpe | wc -l)
		udpvuln_count=$(grep -E 'cpe|https' "$dirname/$eachip"_udp_scan.txt | grep \| | sed '/_/s/_//' | awk -F\| '{print $2}' | awk -F'https' '{print $1}' | grep -v cpe | wc -l)
		tcpexploit_count=$(grep \/ "$dirname/$eachip"_tcp_exploits.txt | wc -l)
		udpexploit_count=$(grep \/ "$dirname/$eachip"_udp_exploits.txt | wc -l)
		format_mapping >> "$dirname/$dirname"_Results.txt
	done
	format_brute >> "$dirname/$dirname"_Results.txt
}

function configure_results()
{
	# Output the results to user
	echo -e "${blue}[*] Consolidating results...${colour}"
	echo -e '\n'
	save_output 2>/dev/null
	cat "$dirname/$dirname"_Results.txt
	echo -e '\n'
	# Clear temp files now that everything has been included in the full results file
	for eachip in $(cat "$dirname"/ip_list.txt)
	do
		rm -rf "$dirname/$eachip"_port_temp.txt
	done
	rm -rf "$dirname"/ftp.txt "$dirname"/ssh.txt "$dirname"/telnet.txt "$dirname"/rdp.txt "$dirname"/ip_list.txt
}

function search_loop()
{
	# Request for user input to search for until commanded to stop
	while true
	do	
		read -p "$(echo -e "[?] Enter search term (type ${red}'exit'${colour} to end search):" )" searchinput
		if [[ "$searchinput" == "exit" ]]; then
			echo -e '\n'
			break
		fi
		echo
		grep -i $searchinput "$dirname/$dirname"_Results.txt 2>/dev/null
		echo -e "${beige}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${colour}"
		echo
	done
}

function search_valid()
{
	# Validate user input and proceed accordingly
	if [ "$search_choice" == "y" ]; then
		search_loop
	elif [ "$search_choice" == "n" ]; then
		echo -e '\n'
	else
		read -p "$(echo -e ${red}"[x] Invalid option. Please enter either y/n: "${colour})" search_choice
		search_valid
	fi
}

function allow_search()
{
	# Provide option for user to search for specific results
	read -p "[?] Search the results? (y/n): " search_choice
	search_valid
}

function zip_valid()
{
	# Validate user input and proceed accordingly
	if [ "$zip_choice" == "y" ]; then
		zip -r "$dirname".zip $dirname > /dev/null 2>&1
		echo -e "${blue}[*] Mission accomplished. Goodbye!${colour}"
	elif [ "$zip_choice" == "n" ]; then
		echo -e "${blue}[*] Mission accomplished. Goodbye!${colour}"
	else
		read -p "$(echo -e ${red}"[x] Invalid option. Please enter either y/n: "${colour})" zip_choice
		zip_valid
	fi
}

function allow_zip()
{
	# Provide option for user to save all results into a Zip file
	read -p "[?] Save all results into a Zip file? (y/n): " zip_choice
	zip_valid
}

function main()
{
	echo -e "${blue}[*] Greetings!${colour}"
	network_input
	directory_name
	get_ip
	scan_option
	run_scan
	configure_results
	allow_search
	allow_zip
}

main
