_Copyright (C) Microsoft Corporation_

# Microsoft Dev Box Configuration

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Create a Dev Box for SDV Toolchain](#create-a-dev-box-for-sdv-toolchain)

## Introduction

Microsoft Dev Box provides developers with cloud workstations. Pre-configured VM images are made available through dev box definitions. A dev box pool is configured with a dev box definition as the base image. A developer can then create a dev box in the dev pool. For more information, see [Dev Box documentation](https://learn.microsoft.com/en-us/azure/dev-box/overview-what-is-microsoft-dev-box).

The steps below describe how to create a dev box that is configured with everything needed to develop and test the components of SDV Toolchain.

## Prerequisites

An Azure dev center. Use an existing dev center or create a new one.
- Navigate to your dev center in Azure Portal. In "Manage > Projects", create a new project in this dev center.
- Navigate to your dev center project in Azure Portal. In "Access control (IAM)", assign yourself the `DevCenter Dev Box User` role.

## Create a Dev Box for SDV Toolchain

1. Navigate to your dev center in Azure Portal. In "Dev box configuration > Dev box definitions", create a dev box definition. Our recommended configuration (may work with other configurations as well):
    - Image: Windows 11 Enterprise
        > The Toolchain itself does not require Windows - it can run on a Linux VM. We are using Windows for the dev box for a user-friendly GUI. The steps below assume you chose a Windows image.
    - Image version: Latest
    - Compute: 8 vCPU, 32 GB RAM
    - Storage: 256 GB SSD

1. Navigate to your dev center project in Azure Portal. In "Manage > Dev box pools", create a new dev box pool with the dev box definition you just created.
    > You will be prompted to confirm that your organization has Azure Hybrid Benefit licenses. Ensure that this is true before proceeding.

1. Go to <https://devbox.microsoft.com>. **Note** You will hit an access error if you did not assign yourself the `DevCenter Dev Box User` role in the prerequisite steps.

1. Create a new dev box. This will take a while.

1. Connect to your dev box with the Remote Desktop client or in the browser.

1. Follow the setup instructions below to enable development in a dev container on Windows Subsystem for Linux (WSL):
    - Enable WSL2 and install Ubuntu:
      ```shell
      wsl --install -d Ubuntu-22.04
      ```
    - Install VSCode
    - Launch VSCode and install the Dev Containers and WSL extensions
    - Install Docker on WSL2 - either just the Docker engine or Docker Desktop if you prefer a GUI

1. Copy the zip archive of this repo to the dev box. Unpack the zip.

1. Open the toolchain directory in VSCode to launch the dev container.
