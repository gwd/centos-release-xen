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

#convert BOOT_XEN_AS_DEFAULT to lowercase
BOOT_XEN_AS_DEFAULT=${BOOT_XEN_AS_DEFAULT,,}

if [ "$BOOT_XEN_AS_DEFAULT" == "no" ]; then
  exit 0
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
exit $?
