#!/usr/bin/bash



function run_amd {
	
	echo -e "\n\u1b[32mEditing /etc/default/grub ...\u1b[0m"
	sed -i -e 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=\)\(.*\)/\1"quiet amd_iommu=on ipcie_acs_override=downstream,multifunction video=efifb:off"/1' /etc/default/grub
	echo -e "\u1b[32mUpdating grub...\u1b[0m"
	update-grub
	echo -e "\u1b[32mAdding vfio modules to /etc/modules\u1b[0m"
	echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd\n" >> /etc/modules
	echo "Checking for IOMMU Interrupt Remapping"
	if [ $(dmesg | grep 'remapping' | wc -l) -gt 0 ]
	then
		echo -e "\u1b[32mIOMMU Remapping enabled\u1b[0m\n"
	else
		echo "Adding interrupt remapping"
		echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" >> /etc/modprobe.d/iommu_unsafe_interrupts.conf
	fi
	echo "Verifying IOMMU Isolation..."
	if [ $(find /sys/kernel/iommu_groups/ -type l | wc -l) -lt 2 ]
	then
		echo -e "\u1b[31mNo IOMMU Isolation. Please check with your admin\u1b[0m\n"
		exit
	fi
	echo "Detecting gpu pci number..."
	#lspci -v
	#lspci -v | grep "VGA compatible controller" | awk '{print $1}' | sed -e 's/\..*//g' 
	pci_numbers=$(lspci -v | grep "VGA compatible controller" | awk '{print $1}' | sed -e 's/\..*//g')
	#pci_numbers="1:00 2:00 3:00"
	echo "PCI numbers detected: $pci_numbers"
	echo -e "\u1b[32mAdding gpu ids to vfio...\u1b[0m\n"
	gpu_ids=()
 	for pci_number in $pci_numbers
	do
		ids=$(lspci -n -s $pci_number | awk '{print $3}')
		for id in $ids
		do
			gpu_ids+="$id,"
		done
		#gpu_ids+="$pci_number,"
	done
	echo "options vfio-pci ids=$(echo $gpu_ids | sed -e 's/,$//g')" > /etc/modprobe.d/vfio.conf
	 #$(echo $gpu_ids | sed -e 's/,$//g')
	echo -e "\u1b[32mBlacklinsting GPU drivers...\u1b[0m\n"
	echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf
	echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf 
	echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf 

	echo -e "\u1b[33mPlease it is recomended to restart your server\u1b[0m\n"
	echo "Do you wish to restart: (y/n)"
	read -n 1 ch
	case $ch in
		[yY]* ) reboot;;
		* ) echo -e "\u1b[31mENJOY!!!\u1b[0m\n"; exit;;
	esac

	 
}

if [ $UID -ne 0 ]
then
	echo "For this script to run, you need root previleges"
	exit
fi

echo -e "\u1b[32mYou are about to configure gpu passthrough in proxmox using this script"
echo -en "\u1b[33mDo you with to continue (y/n):\u1b[0m"
read -n 1 key
echo -e "\n"
case $key in
	[Nn]* ) exit;;
	* ) echo -e "\u1b[32mRunning script...\u1b[0m";;
esac

echo "Which cpu maker is in your system:"
echo "1. AMD"
echo "2. Intel"
read -n 1 -p "Chose from above:" choice

case $choice in
	1 ) run_amd;;
	2 ) run_intel;;
	* ) echo -e "\u1b[31mNo choice selected. Exiting script...\u1b[0m"; exit;;
esac
