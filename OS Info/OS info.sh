#!/bin/bash

echo "Hello, this is A-bot at your service!" 
echo " "

echo "Thank you for choosing me to assist you and I hope you have a pleasant day :)"
echo " "

echo "By running this script, you have requested for the following information:"
echo "1. Machine OS Version"
echo "2. Primary Network Addresses"
echo "3. Hard Disk Information"
echo "4. Top 5 Directories"
echo "5. Live Monitoring of CPU Usage"

echo " "
echo " "

# 1. Find and display the user's LINUX Version.

OS=$(cat /etc/os-release | grep -w NAME | awk -F= '{print $2}' | tr -d '"') 

VER=$(cat /etc/os-release | grep -w VERSION | awk -F= '{print $2}' | tr -d '"')

echo "Your current OS Version is: $OS $VER"
echo " "
echo " "

#2. Provide the user with their private IP address, public IP address, and default gateway.

IP_PRIVATE=$(ifconfig | grep broadcast | awk '{print $2}')
IP_PUBLIC=$(curl -s ifconfig.io)
DEFAULT_GATEWAY=$(route | grep UG | awk '{print $2}')

echo "Here are your primary network addresses:"
echo " "

echo "Private IP Address - $IP_PRIVATE"
echo "Public IP Address - $IP_PUBLIC"
echo "Default Gateway - $DEFAULT_GATEWAY"
echo " "
echo " "

#3. Let the user know their hard disk size and its free and used space.

TOTAL_SIZE=$(df -H / | grep /dev/sda | awk '{print $2}')
USED_SPACE=$(df -H / | grep /dev/sda | awk '{print $3}')
FREE_SPACE=$(df -H / | grep /dev/sda | awk '{print $4}')

echo "Your hard disk size is $TOTAL_SIZE, with $USED_SPACE used and $FREE_SPACE remaining."
echo " "
echo " "

#4. Inform the user of their machine's top 5 directories and display their size.

DIR_SIZE=$(sudo du -hx / | sort -hr | head -n 5)

echo "Your top 5 directories with their respective sizes in descending order are:"
echo " "

echo  "$DIR_SIZE"
echo " "
echo " "

#5. Inform the user of their CPU usage, refreshing at a rate of 10 seconds.

echo "Here is a live feed of your CPU usage refreshed at every 10s:"
echo "(To stop running, press 'Ctrl-C')"
echo " "

while true
do

	iostat -ct | tail -n +3 | head -n 4
	sleep 10

done

