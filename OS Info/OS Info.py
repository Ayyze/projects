#!/usr/bin/python3

# 1. Display the OS version.

import platform

print('[*] System Info')

print('OS:      ', platform.platform())			# Provides kernel version.
print('Version: ', platform.version())			# Provides the current updated version.
print('\n')


# 2. Display the following: a) private IP address, b) public IP address, & c) default gateway.

#Internal IP
import netifaces as ni

ipv4=ni.ifaddresses('eth0')[2][0]['addr']		# Obtain internal IP address by interacting with the eth0 interface


# External IP
import requests

ipx=requests.get("https://api.ipify.org").text		# Obtain external IP address by utilising an external resource with API


# Default Gateway
dg=ni.gateways()['default'][2][0]			# Obtain default gateway information and narrowing output to desired information.


print('[*] Network Info')
print('Private IP:	', ipv4)
print('Public IP:	', ipx)
print('Default Gateway:', dg)
print('\n')


# 3. Display the hard disk size; a) free and b) used space.

import shutil

t, u, f=shutil.disk_usage('/')					# Defines 3 variables according to the categories.
total, used, free=(t//10**9, u//10**9, f//10**9)		# Converts the unit from bytes to gigabytes and redefines them as new variables.

print('[*] Disk Usage')
print('Total: %dG' % total)					
print('Used:  %dG' % used)					
print('Free:  %dG' % free)
print('\n')


# 4. Display the top 5 directories with their size.

import os
import glob
from pathlib import Path							
root=Path('/')									# Specifies / as the argument and stores as variable for intuitive reading.
foldersize=[]									

# Function to scan directories and consolidate their sizes.
def scandir(var):							
	for subdir in Path(var).iterdir():				# Iterate through the specified directory and store the path name of each item within as subdir.
		if subdir.is_dir():					# Check if path is directory and not file to avoid errors.
			try:
				subdir_size = sum(file.stat().st_size for file in subdir.glob('**/*') if file.is_file() and not os.path.islink(file))		# Crawl through each directory recursively. If they are a file and not a symbolic link, calculate their size and sum them.
				size=round(subdir_size/10**9, 1)			# Convert unit from bytes to gigabytes, and round them to 1 decimal place.
				result=(size, subdir)					# Pair the directory path name with their size as a variable.
				foldersize.append(result)				# Append the result to list.
			except PermissionError:						# Exclude directories with permision restrictions and proceed without interrupting the process.
				continue

scandir('/')										# Scan size of directories in root folder.

# Scan size of subdirectories.
for eachitem in root.iterdir():						# Retrieve path name of each item in root directory.
	if eachitem.is_dir():							# Check if path is directory.
		try:
			scandir(eachitem)						# Scan size of subdirectories within directories in root folder.
		except PermissionError:
			continue

foldersize.sort()								# Sort the results according to numerical value since size is stored as first index.
foldersize.reverse()								# Rearrange items with the largest value as first item in list.

print('[*] Top Directory Sizes')
print('1| {0}G 	{1}'.format(foldersize[0][0], foldersize[0][1]))		# Show size value followed by directory path name.
print('2| {0}G 	{1}'.format(foldersize[1][0], foldersize[1][1]))
print('3| {0}G 	{1}'.format(foldersize[2][0], foldersize[2][1]))
print('4| {0}G 	{1}'.format(foldersize[3][0], foldersize[3][1]))
print('5| {0}G 	{1}'.format(foldersize[4][0], foldersize[4][1]))
print('\n')


# 5. Display and refresh the CPU usage every 10 seconds.

from tqdm import tqdm
from time import sleep
import psutil

ram=psutil.virtual_memory().percent						# Shows the percentage of RAM consumed.
cpu=psutil.cpu_percent()								# Shows the load on the CPU.

print('[*] Current CPU Usage')

with tqdm(total=100, desc='CPU%', position=1) as cpubar, tqdm(total=100, desc='RAM%', position=2) as rambar:		# Creates two visual progress bars, the first named CPU% and the second named RAM%, with both assigned max values of 100.
	while True:								# Loop infinitely.
		cpubar.n=cpu						# Assign cpu value to cpubar.
		rambar.n=ram
		cpubar.refresh()					# Refresh to reset bar value.
		rambar.refresh()
		sleep(10)							# Repeat loop in intervals of 10 seconds.
