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

if [ -e /etc/default/grub ] ; then
    config_add /etc/default/grub GRUB_CMDLINE_XEN_DEFAULT "$XEN_KERNEL_ARGS"
    config_add /etc/default/grub GRUB_CMDLINE_LINUX_XEN_REPLACE_DEFAULT "$LINUX_XEN_KERNEL_ARGS"
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
if ! [[ -e /boot/xen.gz || -e /boot/xen ]]; then
  echo "No /boot/xen.gz or /boot/xen, nothing more to do."
  exit 0
fi 

XEN_KERNEL_MBARGS="--mbargs=$XEN_KERNEL_ARGS"

grub1Config=$(readlink -f /etc/grub.conf)
grub2Config=$(readlink -f /etc/grub2.cfg)

if ! [[ -e "$grub2Config" ]] ; then
    grub2Config=$(readlink -f /etc/grub2-efi.cfg)
fi

if [[ -e "$grub2Config" ]] ; then
    echo "Regenerating grub2 config"
    grub2-mkconfig -o $grub2Config
    echo "Setting Xen as the default"
    grub2-set-default 0
elif [ -e "$grub1Config" ] ; then
    # We only need to add a stanza if:
    # 1. We're installing Xen and there is no xen.gz stanza
    # 2. We're installing a new kernel
    #
    # If called when installing xen, it will not have a kver; if
    # called from a new kernel, it will.
    # 
    # If called from xen, and xen is not installed, install a Xen
    # stanza with kernel which is currently default.
    #
    # If called from a new kernel, install a new Xen stanza with the
    # kernel version being installed (found in kver).
    if [[ -z "$kver" ]]; then
	# Called from xen-hypervisor install; get the kernel version
	default=$(grubby --default-kernel)
	kver=$(expr $default : '.*vmlinuz-\(.*\)')
	# If this expression doesn't find anything, xen is already
	# installed; nothing to do.
	if [[ -z "$kver" ]] ; then
	    echo "Xen already installed (default $default kver $kver), nothing to do"
	    exit 0
	fi
	initrd=$(grubby --info $default | sed -ne 's/^initrd=//p')
    else
	default="/boot/vmlinuz-$kver"
	initrd="/boot/initramfs-$kver.img"
    fi

    if [[ ! -e $default ]] ; then
	echo "$0: Strange, can't find kernel $default"
	exit 0
    fi

    if [[ ! -e $initrd ]] ; then
	echo "$0: Strange, can't find initrd $default"
	exit 0
    fi

    echo "Installing xen.gz stanza for kver $kver (kernel $default initrd $initrd)"
    new-kernel-pkg --install --package kernel --multiboot=/boot/xen.gz "$XEN_KERNEL_MBARGS" --initrdfile=$initrd $kver
else
    echo "Don't know how to update bootloader."
fi

exit $?
