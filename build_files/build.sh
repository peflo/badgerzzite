#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

# --- Install Solaar ---
dnf5 install -y solaar

# --- Build Katana USB Audio Driver ---
echo "Building Katana USB Audio Driver..."

# 1. Install build dependencies (kernel-devel must match the base image kernel)
# The base image already has the kernel installed, so we just need devel + tools
dnf5 install -y kernel-devel-$(uname -r) gcc make git

# 2. Clone and Compile
cd /tmp
git clone https://github.com/mrworf/katana-usb-audio.git
cd katana-usb-audio
make
make install

# 3. Cleanup build dependencies to reduce image size
dnf5 remove -y kernel-devel-$(uname -r) gcc make git
rm -rf /tmp/katana-usb-audio

echo "Katana Driver build complete."
# --- End Katana Build ---
