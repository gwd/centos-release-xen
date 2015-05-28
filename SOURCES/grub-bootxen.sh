#!/bin/bash
#
# (c) Simon Rowe, 2013
# (c) Karanbir Singh, 2013

#read in xen-kernel defaults
if [ -e /etc/sysconfig/xen-kernel ]; then
  . /etc/sysconfig/xen-kernel
else
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

if [ -e /etc/default/grub ] ; then
    config_add /etc/default/grub GRUB_CMDLINE_LINUX_XEN_REPLACE_DEFAULT "console=hvc0 earlyprintk=xen nomodeset"
    config_add /etc/default/grub GRUB_CMDLINE_XEN_DEFAULT "watchdog cpuinfo com1=115200,8n1 console=com1,tty loglvl=all guest_loglvl=all"
fi

#convert BOOT_XEN_AS_DEFAULT to lowercase
BOOT_XEN_AS_DEFAULT=${BOOT_XEN_AS_DEFAULT,,}

if [ "$BOOT_XEN_AS_DEFAULT" == "no" ]; then
  exit 0
fi

if [ -e /etc/grub.d/20_linux_xen ] ; then
    echo "Promoting xen above linux in grub2 boot order"
    mv /etc/grub.d/20_linux_xen /etc/grub.d/08_linux_xen
fi

#check for the xen.gz file
if [ ! -e /boot/xen.gz ]; then
  exit 0
fi 

if [ "$XEN_KERNEL_MBARGS" == "" ]; then
  XEN_KERNEL_MBARGS="--mbargs=dom0_mem=1024M,max:1024M loglvl=all guest_loglvl=all"
fi

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

if which grub2-set-default >& /dev/null ; then
    grub2-set-default 0
fi
exit $?
