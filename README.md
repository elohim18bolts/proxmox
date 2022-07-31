# GPU Passthrough in Proxmox.

## 1. Edit /etc/default/grub

```
        GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on ipcie_acs_override=downstream,multifunction video=efifb:off"
```

## 2. Add to /etc/modules

```
        vfio
        vfio_iommu_type1
        vfio_pci
        vfio_virqfd
```

## 3. Run the command to check IOMMU Interrupt Remapping is enabled

```
        dmesg | grep 'remapping'
```

If your system doesn't support interrupt remapping, you can allow unsafe interrupts with:

```
        echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
```

## 4. Determine your PCI card address, and configure your VM

The easiest way is to use the GUI to add a device of type "Host PCI" in the VM's hardware tab.

Alternatively, you can use the command line:

Locate your card using "lspci". The address should be in the form of: 01:00.0 Edit the <vmid>.conf file. It can be located at: `/etc/pve/qemu-server/vmid.conf`.

Add this line to the end of the file:

```
        hostpci0: 01:00.0
```

If you have a multi-function device (like a vga card with embedded audio chipset), you can pass all functions manually with:

```
        hostpci0: 01:00.0;01:00.1
```

## 5. PCI Express Passthrough

Check the "PCI-E" checkbox in the GUI when adding your device, or manually add the pcie=1 parameter to your VM config:

```
        machine: q35
        hostpci0: 01:00.0,pcie=1
```

## 6. GPU Passthrough

For starters, it's often helpful if the host doesn't try to use the GPU, which avoids issues with the host driver unbinding and re-binding to the device. Sometimes making sure the host BIOS POST messages are displayed on a different GPU is helpful too. This can sometimes be acomplished via BIOS settings, moving the card to a different slot or enabling/disabling legacy boot support.

First, find the device and vendor id of your vga card:

```
        $ lspci -n -s 01:00
        01:00.0 0300: 10de:1381 (rev a2)
        01:00.1 0403: 10de:0fbc (rev a1)
```

The Vendor:Device IDs for this GPU and it's audio functions are therefore 10de:1381, 10de:0fbc.

Then, create a file:

```
        echo "options vfio-pci ids=10de:1381,10de:0fbc" > /etc/modprobe.d/vfio.conf
```

blacklist the drivers; add the following in the `/etc/modprobe.d/pve-blacklist.conf` file:

```
        blacklist nvidia
        blacklist amd
        blacklist radeon
        blacklist nouveau
```

and reboot your machine.

For VM configuration, They are 4 configurations possible:

### 1. GPU OVMF PCI Passthrough (recommended)

Select "OVMF" as "BIOS" for your VM instead of the default "SeaBIOS". You need to install your guest OS with uefi support. (for Windows, try win >=8)

Using OVMF, you can also add disable_vga=1 to vfio-pci module, which try to to opt-out devices from vga arbitration if possible:

```
        echo "options vfio-pci ids=10de:1381,10de:0fbc disable_vga=1" > /etc/modprobe.d/vfio.conf
```

and you need to make sure your graphics card has an UEFI bootable rom: [vfio.blogpost.fr](http://vfio.blogspot.fr/2014/08/does-my-graphics-card-rom-support-efi.html)

```
        bios: ovmf
        scsihw: virtio-scsi-pci
        bootdisk: scsi0
        scsi0: .....
        hostpci0: 01:00,x-vga=on
```

### 2. GPU OVMF PCI Express Passthrough

Same as above, but set machine type to q35 and enable `pcie=1`:

```
        bios: ovmf
        scsihw: virtio-scsi-pci
        bootdisk: scsi0
        scsi0: .....
        machine: q35
        hostpci0: 01:00,pcie=1,x-vga=on
```

### 3. GPU Seabios PCI Passthrough

```
        hostpci0: 01:00,x-vga=on
```

### 4. GPU Seabios PCI Express Passthrough

```
        machine: q35
        hostpci0: 01:00,pcie=1,x-vga=on
```
