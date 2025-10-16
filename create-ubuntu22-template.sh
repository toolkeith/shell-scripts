#!/bin/bash

read -p "Enter Template VM ID: " TEMPLATE_ID
read -p "Enter Template Name: " TEMPLATE_NAME

qm create $TEMPLATE_ID \
	--name $TEMPLATE_NAME \
	--memory 2048 \
	--cores 2 \
	--sockets 1 \
	--cpu host \
	--ostype l26 \
	--net0 virtio,bridge=vmbr0,firewall=1 \

cd /var/lib/vz/template/iso/
cp jammy-server-cloudimg-amd64-disk-kvm.img ubuntu22-disk.qcow2
qemu-img resize ubuntu22-disk.qcow2 32G
qm importdisk $TEMPLATE_ID ubuntu22-disk.qcow2 local-lvm

qm set $TEMPLATE_ID \
	--scsihw virtio-scsi-pci \
	--scsi0 local-lvm:vm-$TEMPLATE_ID-disk-0,ssd=1,discard=on \
	--ide2 local-lvm:cloudinit \
	--boot order=scsi0 \
	--serial0 socket --vga serial0 \
	--onboot 1 \
	--ciuser ubuntu \
	--cipassword password \
	--sshkey ~/.ssh/id_rsa.pub \
	--ipconfig0 ip=dhcp \
	--agent enabled=1

qm template $TEMPLATE_ID
