#!/bin/bash
#
# (c) Simon Rowe, 2013
# (c) Karanbir Singh, 2013

#read in xen-kernel defaults
if [ -e /etc/sysconfig/xen-kernel ]; then
  . /etc/sysconfig/xen-kernel
else
  echo "No /etc/sysconfig/xen-kernel, nothing to do."
  exit 0
fi

function config_add
{
    local file="$1"
    local option="$2"
    local value="$3"

    if ! grep -q "^$option" $file ; then
	echo "Adding $option to $file"
	echo "$option=\"$value\"" >> $file
    else
	echo "$option already set in $file, not touching"
    fi
}

if [ "$XEN_KERNEL_ARGS" == "" ]; then
  XEN_KERNEL_ARGS="dom0_mem=1024M,max:1024M cpuinfo com1=115200,8n1 console=com1,tty loglvl=all guest_loglvl=all"
fi

if [ -e /etc/default/grub ] ; then
    config_add /etc/default/grub GRUB_CMDLINE_LINUX_XEN_REPLACE_DEFAULT "console=hvc0 earlyprintk=xen nomodeset"
    config_add /etc/default/grub GRUB_CMDLINE_XEN_DEFAULT "$XEN_KERNEL_ARGS"
fi

#convert BOOT_XEN_AS_DEFAULT to lowercase
BOOT_XEN_AS_DEFAULT=${BOOT_XEN_AS_DEFAULT,,}

if [ "$BOOT_XEN_AS_DEFAULT" == "no" ]; then
  echo "BOOT_XEN_AS_DEFAULT is 'no', nothing more to do."
  exit 0
fi

if [ -e /etc/grub.d/20_linux_xen ] ; then
    echo "Promoting xen above linux in grub2 boot order"
    mv /etc/grub.d/20_linux_xen /etc/grub.d/08_linux_xen
fi

#check for the xen.gz file
if [ ! -e /boot/xen.gz ]; then
  echo "No /boot/xen.gz, nothing more to do."
  exit 0
fi 

XEN_KERNEL_MBARGS="--mbargs=$XEN_KERNEL_ARGS"

grub1Config=$(readlink -f /etc/grub.conf)
grub2Config=$(readlink -f /etc/grub2.cfg)

if [ -e "$grub2Config" ] ; then
    echo "Regenerating grub2 config"
    grub2-mkconfig -o $grub2Config
    echo "Setting Xen as the default"
    grub2-set-default 0
elif [ -e "$grub1Config" ] ; then
    echo "Updating grub config"
    if [ "$kver" = "" ]; then 
	default=$(grubby --default-kernel)
	kver=$(expr $default : '.*vmlinuz-\(.*\)')
	initrd=$(grubby --info $default | sed -ne 's/^initrd=//p')
    else
	default="/boot/vmlinuz-$kver"
	initrd=$(grubby --info $default | sed -ne 's/^initrd=//p')
    fi

    [ -n "$kver" ] || exit 0

    new-kernel-pkg --install --package kernel --multiboot=/boot/xen.gz "$XEN_KERNEL_MBARGS" --initrdfile=$initrd $kver
else
    echo "Don't know how to update bootloader."
fi

exit $?
