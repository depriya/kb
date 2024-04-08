#!/bin/bash

# -------------------------------------
# Convert image to properly aligned VHD
#
# reference: https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-generic
# source: collaboration with ARM to build a reference image for azure based on EWAOL
# -------------------------------------
set -e

BUILDDIR="${GITHUB_WORKSPACE}/meta-machine-azure/yocto/tmp/deploy/images/azure-vm-arm64"

srcimg="core-image-sato-azure-vm-arm64.wic"
vhddisk="yocto-azure-vm-arm64.vhd"
vhdrawdisk="yocto-azure-vm-arm64.vhd.raw"

qemu-img convert -f raw -O vpc $BUILDDIR/$srcimg $BUILDDIR/$vhddisk
qemu-img convert -f vpc -O raw $BUILDDIR/$vhddisk $BUILDDIR/$vhdrawdisk

MB=$((1024*1024))
size=$(qemu-img info -f raw --output json "$BUILDDIR/$vhdrawdisk" | gawk 'match($0, /"virtual-size": ([0-9]+),/, val) {print val[1]}')
rounded_size=$(((($size+$MB-1)/$MB)*$MB))
qemu-img resize $BUILDDIR/$vhdrawdisk $rounded_size
qemu-img convert -f raw -o subformat=fixed,force_size -O vpc $BUILDDIR/$vhdrawdisk $BUILDDIR/$vhddisk

exit 0