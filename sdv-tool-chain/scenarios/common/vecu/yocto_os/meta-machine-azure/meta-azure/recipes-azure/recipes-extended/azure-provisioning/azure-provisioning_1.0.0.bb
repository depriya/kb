LICENSE = "CLOSED"
SUMMARY = "Installs and starts this Azure Provisioning SystemD Service to ping Azure when the VM is finished its boot process"

inherit systemd

REQUIRED_DISTRO_FEATURES= "systemd"

# Source the necessary files
SRC_URI = "file://azure-provisioning.service \
           file://azure-provisioning.py"

S = "${WORKDIR}"

# Enable this service automatically when the image is installed.
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_SERVICE:${PN} = "azure-provisioning.service"

do_install() {
  # Create the /usr/local directory
  install -d ${D}/usr/local

  # Move the azure-provisioning.py file to /usr/local where the owner can read, write, and execute the file.
  install -m 0755 ${WORKDIR}/azure-provisioning.py ${D}/usr/local/

  # Move the systemd azure-provisioning.service to the directory that systemd reads from
  install -d ${D}${systemd_system_unitdir}
  # Owner has read and write permissions, and the group and others have only read permissions.
  install -m 0644 ${WORKDIR}/azure-provisioning.service ${D}${systemd_system_unitdir}/
}

# Include these files to ensure that they are installed to the correct location on the target system when the package is installed.
FILES:${PN} += "/usr/local/azure-provisioning.py ${systemd_system_unitdir}/azure-provisioning.service"