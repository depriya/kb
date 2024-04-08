# Copyright (C) Microsoft Corporation.

LICENSE = "CLOSED"
SUMMARY = "Installs and starts the Symphony Agent"

inherit systemd

INHIBIT_PACKAGE_STRIP = "1"
REQUIRED_DISTRO_FEATURES = "systemd"
RDEPENDS:${PN} = "bash"

# Source the necessary files
# The symphony-agent.out binary is not checked into this directory.
# The Build Yocto workflow will download the symphony-agent binary from your Storage Blob Container to this directory.
SRC_URI = "file://symphony-agent.service \
           file://symphony-agent.out \
           file://symphony-agent.json \
           file://get_status_download_software.sh \
           file://apply_download_software.sh \
           "

S = "${WORKDIR}"

# Enable this service automatically when the image is installed.
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_SERVICE:${PN} = "symphony-agent.service"

do_install() {
  # Create the /usr/local/symphony-agent directory
  install -d ${D}/usr/local/symphony-agent

  # Move the symphony-agent files to /usr/local/symphony-agent where the owner can read, write, and execute the file.
  install -m 0755 ${WORKDIR}/symphony-agent.out ${D}/usr/local/symphony-agent
  install -m 0755 ${WORKDIR}/symphony-agent.json ${D}/usr/local/symphony-agent
  install -m 0755 ${WORKDIR}/get_status_download_software.sh ${D}/usr/local/symphony-agent
  install -m 0755 ${WORKDIR}/apply_download_software.sh ${D}/usr/local/symphony-agent

  # Move the systemd symphony-agent.service to the directory that systemd reads from.
  install -d ${D}${systemd_system_unitdir}
  # Owner has read and write permissions, and the group and others have only read permissions.
  install -m 0644 ${WORKDIR}/symphony-agent.service ${D}${systemd_system_unitdir}/
}

# Include these files to ensure that they are installed to the correct location on the target system when the package is installed.
FILES:${PN} += "/usr/local/symphony-agent/* ${systemd_system_unitdir}/symphony-agent.service"
