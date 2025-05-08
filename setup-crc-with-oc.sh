#!/bin/bash

# OpenShift Local (crc) installation script with oc CLI setup for Ubuntu

set -e

# Configuration
CRC_VERSION="2.39.0"
CRC_FILENAME="crc-linux-amd64.tar.xz"
CRC_DIR="crc-linux-${CRC_VERSION}-amd64"
DOWNLOAD_URL="https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/crc/${CRC_VERSION}/${CRC_FILENAME}"

echo "===== Installing dependencies ====="
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon libvirt-clients bridge-utils virt-manager curl tar

echo "===== Enabling libvirtd ====="
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER

echo "===== Downloading crc v$CRC_VERSION ====="
cd /tmp
curl -LO $DOWNLOAD_URL
tar -xf $CRC_FILENAME

echo "===== Installing crc ====="
sudo mv ${CRC_DIR}/crc /usr/local/bin/
rm -rf $CRC_FILENAME $CRC_DIR

echo "===== Running crc setup ====="
crc setup

# Run `crc start` to generate oc CLI
echo "===== Starting crc for the first time (this will take a few minutes) ====="
crc start

# Extract and export oc binary path
OC_PATH=$(crc oc-env | grep 'PATH=' | cut -d'"' -f2)
OC_DIR=$(dirname $(echo $OC_PATH | cut -d: -f1))

if [[ ":$PATH:" != *":$OC_DIR:"* ]]; then
  echo "export PATH=\$PATH:$OC_DIR" >> ~/.bashrc
  echo "===== oc CLI path added to ~/.bashrc ====="
fi

echo "===== Reloading shell to apply PATH changes ====="
source ~/.bashrc

echo "===== Installation complete! ====="
echo "Run 'oc login -u developer -p developer https://api.crc.testing:6443' to start using OpenShift CLI."
