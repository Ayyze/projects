#!/bin/bash

# Step 1. Check if the prerequisite applications are installed, if not install them.

# Rsync installation
function RSYNC_INSTL()
{
	RSYNC_CHK=$(which rsync | wc -l)					
	if [ $RSYNC_CHK -eq 0 ]							# If no results, it is not installed.
	then
		echo 'Befriending wild rsync...'
		sudo apt install -y rsync
		echo 'Rsync successfully befriended!'
	else
		# Rsync is already installed.
		:								
	fi
}

# Tor Installation
function TOR_INSTL()
{
	TOR_CHK=$(which tor | wc -l)
	if [ $TOR_CHK -eq 0 ]
	then
		echo 'Befriending wild Tor...'
		sudo apt install -y tor torbrowser-launcher
		echo 'Tor successfully befriended!'
	else
		# Tor is already installed.
		:
	fi
}


# SSHPass Installation
function SSHP_INSTL()
{
	SSHP_CHK=$(which sshpass | wc -l)
	if [ $SSHP_CHK -eq 0 ]
	then
		echo 'Befriending wild SSHPass...'
		sudo apt-get install -y sshpass
		echo 'SSHPass successfully befriended!'
	else
		# SSHPass is already installed.
		:
	fi
}

# Geoiplookup Installation
function GEOIP_INSTL()
{
	GEOIP_CHK=$(which geoiplookup | wc -l)
	if [ $GEOIP_CHK -eq 0 ]
	then
		echo 'Befriending wild Geoiplookup...'
		sudo apt-get install -y geoip-bin
		echo 'Geoiplookup successfully befriended!'
	else
		# Geoiplookup is already installed.
		:
	fi
}

# Whois Installation
function WHOIS_INSTL()
{
	WHOIS_CHK=$(which whois | wc -l)
	if [ $WHOIS_CHK -eq 0 ]
	then
		echo 'Befriending wild whois...'
		sudo apt-get install -y whois
		echo 'Whois successfully befriended!'
	else
		# Whois is already installed.
		:
	fi
}

# Nmap installation
function NMAP_INSTL()
{
	NMAP_CHK=$(which nmap | wc -l)
	if [ $NMAP_CHK -eq 0 ]
	then
		echo 'Befriending wild Nmap...'
		sudo apt-get install -y nmap
		echo 'Nmap successfully befriended!'
	else
		# Nmap is already installed.
		:
	fi
}

# Nipe Installation
function NIPE_INSTL()
{
	NIPE_CHK=$(find -maxdepth 1 -type d -name nipe | wc -l)				# Nipe doesn't install on the system. Instead this checks to see if Nipe exists in the working directory.
	if [ $NIPE_CHK -eq 0 ]								# If Nipe is not found, then it needs to be cloned into working directory.
	then
		echo 'Befriending wild Nipe...'
		git clone https://github.com/htrgouvea/nipe && cd nipe
		sudo apt install -y cpanminus
		sudo cpan install Config::Simple					# Insurance to avoid any errors even after installing cpanminus.
		sudo perl nipe.pl install
		cd ..									# Exits Nipe folder to avoid importing unnecessary files as script progresses.
		echo 'Nipe successfully befriended!'
	else
		# Nipe is already installed.
		:
	fi
}

# Execute apt installation and checks.								
function CRITTERS()
{
echo '[*] Checking system for necessary critters...'					
	SSHP_INSTL
	RSYNC_INSTL
	GEOIP_INSTL
	WHOIS_INSTL
	NMAP_INSTL
	TOR_INSTL
	NIPE_INSTL
echo 'Check complete. All critters are present.'
echo -en '\n'
echo '[*] Ditto activating...'								# Inform user that script is testing anonymity.
}

CRITTERS

# Step 2. Check if the network connection is anonymous. 

# Extra rigour to ensure Tor is functional.
function TOR_FUNC()
{
	sudo service tor start								# Activate Tor
	TOR_STATUS=$(curl -x socks5h://localhost:9050 -s https://check.torproject.org/api/ip | grep -i true | wc -l)		
	if [ $TOR_STATUS -eq 0 ]
	then
		echo '[!] Warning: Tor is down.'					# Nipe seems to still be able to function even when Tor is stopped, hence not critical to exit.
	else										# Warning provided in case user wants to exit script to ensure all bases are covered.
		# Tor is functioning
		:
	fi
}

# Test for anonymity
function NIPE_TEST()
{
	cd nipe
	sudo perl nipe.pl start
	ANON_CHK=$(sudo perl nipe.pl status | grep -i true | wc -l)			# If Nipe is off, status will be 'false'. No results will be shown.
	if [ $ANON_CHK -eq 0 ]
	then
		echo '[!] Error: Ditto failed.'						# Inform user they are not anonymous.
		echo '[x] Please check network connection before trying again.'
		exit									
	else
		# Nipe is working, network connection is anonymous.
		:
	fi
}

TOR_FUNC
NIPE_TEST


# Step 3. Show spoof results (IP/Country).

IPS=$(sudo perl nipe.pl status | grep -i ip | awk -F: '{print $2}' | tr -d ' ')		# Extract spoofed IP from nipe status results.
COUNTRY=$(geoiplookup $IPS | awk -F, '{print $2}' | sed 's/^[ \t]//')			# Check spoofed IP's location.
RAN=$(echo {A..C} | tr ' ' '\n' | sort -R | head -n 1)					# Create a random result from [A-C].

function PROFILE()									# Just something fun to show identity is disguised.
{
	case $RAN in									# Show cases depending on randomised results.
	A)										# Set colour code to light green.
		echo -e "\e[0;32m												
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀				⠀
⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣶⣾⣀⠀⣴⡀⢠⣴⡀⠀⢀⢠⡖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣧⣾⣿⠀⣰⣿⣿⠁⠀⣠⣠⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣤⣾⣿⣿⡇⠀⠀⠀⠀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠉⠉⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠂⣠⣤⣾⡗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢿⡿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣾⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⣀⣀⣤⣤⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣗⣶⣃⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⢋⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⡧⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⡿⠉⠉⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠷⠶⠒⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⡟⠁⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣛⣠⣶⡶⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣥⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⣉⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣴⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢰⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⡏⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣥⣀⠀⠀⠀⠀⠀⠀⠀⠀
⢸⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀
⠈⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⠀⠀⣀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀
⠀⠘⢿⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⡟⠠⠾⠿⠿⠿⠿⠿⠿⠿⠿⠟⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡄⠀⠀⠀
⠀⠀⠀⠻⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀
⠀⠀⠀⠀⠙⢿⣿⣿⣷⣤⡀⠀⠀⠀⢀⣠⣤⣾⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄
⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣶⣄⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣿⣿⠿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢿⣿⣿⣿⣿⣿⣿⣷⣶⣦⣀⣀⡀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣶⣶⣿⣦⣄⣀⣦⣄⣄⣀⣠⣤⣤⣤⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⠟⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠙⠙⠛⠛⠛⠛⠛⠛⠛⠛⠛⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\e[0m"		# Reset colour. Credits: https://emojicombos.com/godzilla-text-art
		echo -en '\n'
		echo "[*] You are now a Godzilla in $COUNTRY, ID: $IPS!"		# Inform user of newly spoofed IP & location.
	;;
	B)										# Set colour to light orange/brown.
		echo -e "\e[0;33m
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣾⡄				
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣶⣾⣷⣾⣿⣃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⠟⢹⣧
⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⠋⠀⢸⣿
⠀⠀⠀⢀⣠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⡿⠁⠀⠀⢸⣿
⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣤⡀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⡿⠁⠀⠀⠀⣿⣿
⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣍⢤⣬⣥⣾⣿⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⠁⠀⠀⠀⢰⣿⡏
⣸⣿⣿⣿⣿⣿⣿⡟⠛⠻⠿⠿⠿⠿⣿⡿⠇⢨⣍⣙⣛⣠⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⡏⠀⠀⠀⢀⣾⣿⠁
⣿⣿⣿⣿⣿⣿⣿⣧⡘⢶⣶⣶⣶⣶⣶⣤⣤⣤⣤⣭⣉⣉⣉⣛⠛⠿⠿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⢀⣠⣴⣦⣤⣶⣶⣿⣿⣧⣤⣤⣄⠉⢻⡇⠀⠀⠀⣼⣿⡏⠀
⣿⣿⣿⣿⣿⣿⠿⣿⣿⣄⠙⢿⣿⣄⠀⠀⠀⠀⠈⠉⠙⠛⠻⠿⣿⣿⣶⣤⡉⠻⣿⣿⣿⡆⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣥⣤⣭⣁⣀⠀⣸⣿⡟⠀⠀
⢻⣿⣿⣿⣿⣿⡄⢬⣙⠻⢰⣤⡙⠻⣷⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣿⣷⣌⠻⢿⡇⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣍⡁⠿⠋⠀⠀⠀
⠸⣿⡏⣉⡻⢿⣿⡜⣿⣿⣿⣿⣿⣶⣄⡙⠻⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣷⣄⢁⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣛⣛⣛⠛⠂⠀⠀⠀⠀
⠀⢻⡇⣿⣿⣶⣬⣙⠈⢿⣿⣿⣿⣿⣿⣿⣶⣌⡙⠻⢿⣶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀
⠀⠈⠁⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣈⠙⠻⢿⣿⣶⣦⣄⣀⣀⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠗⢀⣀⣉⠙⠛⠛⠛⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣉⠻⣿⣿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⢉⣠⣾⣿⣿⠟⣁⣤⣴⣶⣶⢸⣿⣿⣿⣿⣿⣿⣿⢟⣛⠻⣿⣿⣿⣿⣿⣿⣿⣿⠁⣿⠇⠸⣿⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠿⢿⣿⣿⣿⣿⡿⠃⣴⣿⣿⣿⠟⣡⣾⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⢣⣿⣿⠀⠘⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⢀⣾⣿⣿⣿⠏⣼⡿⢟⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿⣿⣿⠘⠛⠋⠀⠀⢹⣿⣿⣿⣿⣿⣿⣇⠠⠤⢃⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣀⡅⣠⣿⣿⣿⣿⣿⣿⣇⢹⣿⣿⣿⣿⣿⠰⣷⣀⣠⡄⣸⣿⣿⣿⣿⣿⠿⢻⣷⣶⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⢡⣿⣿⣿⣿⣿⣿⣿⣿⡄⢻⣿⣿⣿⣿⣷⣬⣉⣉⣴⣿⣿⣿⣿⣿⣿⣿⠿⢟⣿⣿⠟⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⡇⢸⡇⣿⣿⣿⣿⣿⡿⢹⣿⣦⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣛⣋⣭⣶⣾⡿⢟⣡⣾⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣇⢈⣥⢸⣿⣿⣿⣿⡇⣾⣿⣿⣿⣶⣬⣙⠻⠿⣿⣿⣿⣿⣿⣿⠿⠿⢛⣉⣥⣶⣿⡿⠟⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⡿⠈⢿⣿⣿⣿⡀⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣤⣤⣤⣤⣴⣶⣾⣿⣿⢿⣿⣿⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⠡⣿⣌⢻⣿⣿⣧⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣿⠃⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⠇⠀⢿⣿⣷⡙⠛⣿⡇⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠛⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⠀⠀⠈⢿⣿⣿⣶⠈⣰⣷⣬⡻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠈⠉⠋⢠⣿⣿⣿⣿⣮⡛⢿⠏⠻⢿⣿⣿⣿⣿⢟⣴⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⢿⠆⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⢉⡛⠟⣱⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠁⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⠀⠀⠀⠀⠈⣿⣾⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⢹⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠉⠛⠋⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⣿⡟⢿⠟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\e[0m"		# Credits: https://emojicombos.com/eevee-ascii-art
		echo -en '\n'
		echo "[*] You are now an Eevee in $COUNTRY, ID: $IPS!"
	;;
	C)										# Set colour to white.
		echo -e "\e[1;37m
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠏⠹⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⠋⢉⣉⣭⣵⣶⣶⣾⣇⠐⢶⣶⣭⣉⡛⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣋⣴⡶⠃⠀⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⢻⣿⣿⣿⣿⣷⣦⣉⠻⢿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣱⣾⣿⡿⠃⢠⠀⣿⣿⣿⣿⣿⡿⣿⣿⡇⠀⡀⠹⣿⣿⣿⣿⣿⣿⠇⢀⡙⢿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⣡⣾⣿⣿⣿⡇⠀⢠⣠⠈⠛⠛⠋⠁⠀⠀⠹⣇⠀⠹⢆⠈⠻⢿⣿⡿⠟⠀⠀⢻⣦⡙⢿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠚⠛⠋⠉⠙⠛⠃⢀⡀⣠⠀⠀⠂⠀⠀⠀⠀⠀⠁⠀⠀⠀⢠⣀⣀⡀⠠⢶⣷⠃⠘⢿⣿⣆⠙⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣥⣤⣤⣤⣀⠁⠀⠀⠀⠀⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡟⣶⠀⠈⠃⠀⠘⠿⢿⣆⠘⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⡞⠻⣿⣿⠀⠀⠀⠀⠀⠙⠇⠀⠀⠀⣀⡉⠛⠯⣿⣷⠀⣿⡿⠷⠦⠀⠀⠀⠹
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢠⠈⠁⠀⠻⡿⠀⠀⠈⠳⡄⠀⠀⠀⠀⢾⣿⣿⣿⣶⣤⡈⢁⣤⣤⣶⣶⣾⣷⣶⣶
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣡⣴⣾⣿⣿⣷⣦⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⣀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⣴⣿⣿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⢰⠛⠋⣠⡾⠷⣆⠸⣿⡿⠛⠉⠭⠍⠙⠃⠸⣷⠀⢀⡤⣤⡀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣷⣬⣝⡛⠛⠋⢼⣿⣿⡇⠻⣧⣴⡿⠁⣀⣄⣀⡀⠀⠀⠀⠀⣶⣃⠀⢾⣇⣨⣿⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠿⠿⠿⠿⠋⢰⣦⣤⣈⡁⠀⣈⣁⣤⣾⣿⣿⣿⣿⣷⣤⣤⣴⣿⣿⠂⠈⠙⠛⠁⠀⠀⠀⠀⠀⠀⣭⣤⣤⣤⣾⣿⣿⣿
⣿⣿⣿⣿⣶⣶⣶⡖⢀⣤⣤⡭⠉⠁⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠨⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣉⣛⣛⠻⠿⣿⣿
⣿⣿⣿⣿⣿⣟⡉⢀⣬⣤⣤⣶⣶⣶⣶⣷⣿⣿⣿⣿⣿⡿⠿⠛⠻⠛⠁⠄⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢙⡻⠿⣿⣶⣿⣿
⣿⣿⣿⣿⣿⡿⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⣉⣩⣤⣶⣶⣶⣦⠄⠀⠀⠀⢸⣿⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣷⣾⣿⣿⣿
⣿⣿⣿⣿⡟⢁⣼⣿⣿⣿⣿⣿⠿⠛⣡⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣄⠉⢀⣄⠸⣿⡆⠀⠀⠀⠴⠄⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿
⣿⣿⣿⡟⠁⣼⡿⢿⣿⡿⠟⢈⣴⣾⠟⠉⠛⠻⢿⣿⣿⡿⠛⠉⠉⠙⢿⣿⣿⣧⡈⠿⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿
⣿⣿⡿⠁⣰⣿⠃⣼⣿⠃⣠⣿⣿⠏⠀⣠⣤⣤⣼⣿⣿⣄⣤⣶⣶⣄⠈⣿⣿⡟⢁⣀⠐⢀⠀⠀⠀⠖⠀⠀⠘⠀⠀⢻⣿⣿⣿⣿
⣿⡿⠁⣸⣿⡇⢸⡿⠃⣴⣿⣿⣿⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣈⠳⣄⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿
⣿⠇⣸⣿⡿⢀⡿⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠻⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣷⣌⠓⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿
⡏⠀⣿⣿⡇⢸⠀⣼⡿⠛⠁⠀⠉⢿⣿⣿⠏⠀⢀⣀⠈⠻⣿⣿⣿⠟⠉⠁⢀⠙⢿⣿⣿⣿⣿⠿⠗⠀⢀⠀⠀⠀⠀⠀⢸⣿⣿⣿
⠀⠀⣿⣿⡇⠀⢸⣿⣁⣠⣶⣶⣦⣀⣿⣿⣶⣶⣿⣿⣷⣾⣿⣿⣿⣶⣶⣶⣦⡀⢘⣿⣿⡋⠀⣀⡀⠀⢹⣷⣦⡀⠀⠀⢸⣿⣿⣿
⡄⢠⣿⣿⡇⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣼⣿⣿⡇⠀⠀⢸⣿⣿⣿
⣇⠠⡿⢿⠇⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣏⢰⣿⣿⣿⡇⠀⠀⢸⣿⣿⣿
⣿⣆⠀⢸⡇⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⣾⣿⣿⡟⠀⠀⠀⢸⣿⣿⣿
⣿⣿⡆⠀⠁⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⢠⣿⣿⣿⡇⠀⠀⠀⣼⣿⣿⣿
⣿⣿⠆⢀⢰⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣿⣿⣿⣿⠁⠀⠀⢸⣿⣿⣿⣿
⣿⣿⣶⣼⣸⠀⡀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⣼⣿⣿⣿⡏⠀⠀⠀⢸⣿⣿⣿⣿
⣿⣿⣿⣿⣿⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢡⣾⣿⣿⣿⠟⠀⠀⠀⠀⣾⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣇⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⣴⣿⣿⣿⡿⠋⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠨⣛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⣡⣾⣿⣿⣿⠋⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠓⢦⣙⠻⠿⣿⣿⣿⣿⣿⣿⣿⡿⠟⣫⣴⣾⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠈⠛⠶⣶⣮⣭⣭⣭⣉⣭⣴⣾⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⣀⣤⣄⣀⠀⠉⠻⠿⣿⣿⣿⣿⡿⠟⠉⠁⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠓⠀⠡⢌⣻⣿⣷⡄⠀⠀⠀⠉⠉⠉⠀⠀⠀⠀⠀⠀⢀⠀⣀⡀⠀⢀⣀⣀⣉⡉⠉⠛⠛⠻⠿⠿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣦⣤⣤⣬⣤⣤⣄⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠚⠛⠛⠋⠁⣀⣀⣀⣀⣀⣴
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿			\e[0m"		# Credits: https://emojicombos.com/totoro-ascii-art
		echo -en '\n'
		echo "[*] You are now a Totoro in $COUNTRY, ID: $IPS!"
	;;
esac
}

function SPOOF()
{
PROFILE
cd ..											# Still in nipe directory from tests, so return to original working directory.
echo -en '\n'
}

SPOOF	

# Step 4. Invite user to specify the address to scan.

function USER_INPUT()									
{
echo '[?] Please specify a target (Domain/IP Address) to find:'

read TARGET										
echo -en '\n'
}

function SSH_CRED()									
{
echo '[?] Please specify the remote IP address to access:'
read REMOTE_IP	

echo '[?] Please specify the username for SSH:'
read USER

echo '[?] Please specify the password for SSH:'
read PASSWORD	

echo -en '\n'
}

# Step 5. Connect to remote server via SSH

# Provide remote server info during SSH.
function SERVERINFO()									# Commands to execute in remote server.
{
				RUP=$(uptime)																	
				RIPX=$(curl -s ifconfig.io)				# Get remote server to check their IP.
				RLOCATION=$(curl -s ipwho.is/?fields=country | awk -F: '{print $2}' | tr -d [:punct:])	# Produce location of remote server without relying on geoiplookup which may not be installed.
				
				echo "Uptime: $RUP"
				echo "You have arrived in $RLOCATION, $RIPX!"
				cd s3 
echo -en '\n' 
}

# Execute connection into remote server and tell it to execute a list of commands.
function REMOTE()																													
{																										
echo '[*] Going on an adventure...'												
sshpass -p $PASSWORD ssh -q -o StrictHostKeyChecking=no $USER@$REMOTE_IP "$(typeset -f SERVERINFO); SERVERINFO && $SCRIPT"	
echo -en '\n'
}

# Step 6. Port the Whois and Nmap data files into the local computer.

# Make directory to organise where files are stored.
function MK_S3()
{
	FIND_S3=$(find -maxdepth 1 -type d -iname s3 | wc -l)				# Search for target folder only in working directory.
	if [ $FIND_S3 -eq 0 ]
	then
		mkdir s3
		mkdir s3/Log								# Directory to store log files.
	else
		# s3 folder exists.
		:
	fi
}

HERE=$(pwd)										# Store current filepath as variable.
TIME=$(date)										# Store date as variable.

# Customise whois log entry according to previously randomised profile.
function WHOIS_LOG()
{
if [ $RAN == "A" ]
		then
			echo "$TIME- [*] Godzilla collected whois data for: $TARGET" >> ./s3/Log/NR.log
		else
		if [ $RAN == "B" ]
			then
				echo "$TIME- [*] Eevee collected whois data for: $TARGET" >> ./s3/Log/NR.log
			else
				echo "$TIME- [*] Totoro collected whois data for: $TARGET" >> ./s3/Log/NR.log
			fi
fi
}

# Customise nmap log entry according to previously randomised profile.
function NMAP_LOG()
{
if [ $RAN == "A" ]
		then
			echo "$TIME- [*] Godzilla collected nmap data for: $TARGET" >> ./s3/Log/NR.log
		else
		if [ $RAN == "B" ]
			then
				echo "$TIME- [*] Eevee collected nmap data for: $TARGET" >> ./s3/Log/NR.log
			else
				echo "$TIME- [*] Totoro collected nmap data for: $TARGET" >> ./s3/Log/NR.log
			fi
fi
}

# Save files from remote server into local computer and create a log entry.
function SAVELOG()
{
sshpass -p $PASSWORD rsync $USER@:~/s3/whois_$TARGET ./s3			# Avoid password check while Obtaining whois file from remote server and save it in s3 folder.
WHOIS_LOG											# Create data log.

sshpass -p $PASSWORD rsync $USER@$REMOTE_IP:~/s3/nmap_$TARGET ./s3			# Obtain nmap file from remote server.
NMAP_LOG

echo "[@] The results of your adventure have been saved into $HERE/s3."
echo -en '\n'
}

# Step 7. Repeat or end the process.

	# Request user to make a choice and repeat request if invalid option is provided.
function OPTION()
{
	read USER_REPLY
	case $USER_REPLY in
		Y|y)											
			# Proceed to repeat process.
			echo -en '\n'
		;;
		N|n)
			echo -en '\n'
			echo '[*] Have a good rest!'
			exit										
		;;
		*)											
			echo '[!] Please enter (Y/N).'
			OPTION								# Call the function to repeat request.
		;;
	esac
}

# Provide user with the option to perform more scans without repeating installation and anonymity checks.
while true													
do
	USER_INPUT
 	SSH_CRED
	SCRIPT="
				echo '[*] Whois that pokemon?!' 
				whois $TARGET > whois_$TARGET 							
				echo 'It is a ... secret for now.' 
echo -en '\n' 
				echo '[*] Scanning for weaknesses...' 
				nmap $TARGET -oN nmap_$TARGET >/dev/null 
				echo 'Interesting.' 
echo -en '\n' 
				echo '[*] Heading home!'
				"							# Chain of commands to be run in remote server.
	REMOTE
	MK_S3
	SAVELOG
	echo '[?] Would you like to search for another target? (Y/N)'
	OPTION
done



