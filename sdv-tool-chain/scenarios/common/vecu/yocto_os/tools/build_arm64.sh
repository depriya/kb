#!/bin/bash

# -----------------------------------------------------
# Create custom linux distribution based on Yocto
#
# Reference: https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-generic
# Source: collaboration with ARM to build a reference image for azure based on EWAOL
# -----------------------------------------------------

# ----------------------
# Start of user defined settings
# ----------------------

set -e

cd "$(dirname "$0")"

BUILD=kirkstone
MACHINETYPE=azure-vm-arm64
TARGETDIR="${GITHUB_WORKSPACE}/meta-machine-azure"
BUILDIMAGE=core-image-sato

# ----------------------
# End of user defined settings
# ----------------------

# ----------------------
# Host setup, which requires sudo. The build process does not
# ----------------------
sudo apt update
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg gawk wget jq git diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python2 python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev xterm locales rng-tools-debian e2fsprogs parted sudo openssh-sftp-server zstd liblz4-tool

sudo mkdir -p $TARGETDIR/source
USERGROUP=`id -gn`
sudo chown -R $USER:$USERGROUP $TARGETDIR
sudo locale-gen en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# ----------------------
# End of host setup
# ----------------------

# ----------------------
# Actual work
# ----------------------
echo Building Yocto version: $BUILD

rm -r -f $TARGETDIR/yocto

cp -r ${GITHUB_WORKSPACE}/meta-machine-azure/meta-azure $TARGETDIR/source
cd $TARGETDIR/source
git clone -b $BUILD https://git.yoctoproject.org/git/poky
git clone -b $BUILD https://git.yoctoproject.org/git/meta-arm
git clone -b $BUILD git://git.yoctoproject.org/meta-security
git clone -b $BUILD git://git.openembedded.org/meta-openembedded
git clone -b $BUILD git://git.yoctoproject.org/meta-virtualization

cd $TARGETDIR
source source/poky/oe-init-build-env yocto

echo "BBLAYERS += \"${TARGETDIR}/source/meta-arm/meta-arm\" " >> $TARGETDIR/yocto/conf/bblayers.conf
echo "BBLAYERS += \"${TARGETDIR}/source/meta-arm/meta-arm-bsp\" " >> $TARGETDIR/yocto/conf/bblayers.conf
echo "BBLAYERS += \"${TARGETDIR}/source/meta-arm/meta-arm-toolchain\" " >> $TARGETDIR/yocto/conf/bblayers.conf
echo "BBLAYERS += \"${TARGETDIR}/source/meta-openembedded/meta-filesystems\" " >> $TARGETDIR/yocto/conf/bblayers.conf
echo "BBLAYERS += \"${TARGETDIR}/source/meta-openembedded/meta-networking\" " >> $TARGETDIR/yocto/conf/bblayers.conf
echo "BBLAYERS += \"${TARGETDIR}/source/meta-openembedded/meta-oe\" " >> $TARGETDIR/yocto/conf/bblayers.conf
echo "BBLAYERS += \"${TARGETDIR}/source/meta-openembedded/meta-python\" " >> $TARGETDIR/yocto/conf/bblayers.conf
echo "BBLAYERS += \"${TARGETDIR}/source/meta-virtualization\" " >> $TARGETDIR/yocto/conf/bblayers.conf
echo "BBLAYERS += \"${TARGETDIR}/source/meta-azure\" " >> $TARGETDIR/yocto/conf/bblayers.conf

echo "MACHINE = \"$MACHINETYPE\"" >> $TARGETDIR/yocto/conf/local.conf
echo 'DISTRO_FEATURES:append = " pam wayland systemd wifi virtualization"' >> $TARGETDIR/yocto/conf/local.conf
echo 'IMAGE_INSTALL:append = " docker-ce symphony-agent ca-certificates azure-provisioning git rng-tools jq e2fsprogs e2fsprogs-resize2fs e2fsprogs-tune2fs e2fsprogs-e2fsck e2fsprogs-mke2fs parted sudo sudo-sudo openssh-sftp-server wget"' >> $TARGETDIR/yocto/conf/local.conf
echo 'VIRTUAL-RUNTIME_init_manager = "systemd"' >> $TARGETDIR/yocto/conf/local.conf
echo 'DISTRO_FEATURES_BACKFILL_CONSIDERED = "sysvinit"' >> $TARGETDIR/yocto/conf/local.conf
echo 'VIRTUAL-RUNTIME_initscripts = ""' >> $TARGETDIR/yocto/conf/local.conf
echo 'PACKAGECONFIG:remove:pn-qemu-native = " sdl"' >> $TARGETDIR/yocto/conf/local.conf
echo 'PACKAGECONFIG:remove:pn-nativesdk-qemu = " sdl"' >> $TARGETDIR/yocto/conf/local.conf

# -----------------------------------------
# This will take about 90 minutes on a 32 core system and can consume ~130 GB of disk space.
# -----------------------------------------
# Need to reference the GITHUB_WORKSPACE environment variable in bitbake to be able to use it.
export BB_ENV_PASSTHROUGH_ADDITIONS="$BB_ENV_PASSTHROUGH_ADDITIONS GITHUB_WORKSPACE"
cd ${TARGETDIR}/yocto/conf
cat "local.conf"

cd $TARGETDIR
bitbake $BUILDIMAGE

# ----------------------
# End of actual work
# ----------------------

exit 0
