
#!/bin/bash

# get list of VMs on the node
VMIDs=$(qm list| awk 'NR>1 {print $1}')

# ask them to shutdown
for VM in $VMIDs
do
    qm shutdown $VM
done


#wait until they're done (and down)
for VM in $VMIDs
do
    while [[ "$(qm status $VM)" =~ "running" ]] ; do
        sleep 1
    done
done

## do the reboot
shutdown -r now
