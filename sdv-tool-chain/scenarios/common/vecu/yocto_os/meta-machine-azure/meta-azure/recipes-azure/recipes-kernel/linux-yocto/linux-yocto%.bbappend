FILESEXTRAPATHS:prepend:azure-vm-arm64 := "${THISDIR}/azure-vm:"
SRC_URI:append:azure-vm-arm64 = " file://azure-vm.cfg"

COMPATIBLE_MACHINE:azure-vm-arm64 = "azure-vm-arm64"
