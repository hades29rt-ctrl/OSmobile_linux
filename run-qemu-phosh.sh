#!/bin/bash
# Lance l'image pmbootstrap (qemu-aarch64, Phosh) dans une fenêtre sous WSL2.
# On n'utilise pas "pmbootstrap qemu --no-gl" : il génère virtio-gpu-gl avec gl=off
# et QEMU refuse de démarrer. virtio-gpu-pci n'a pas besoin d'OpenGL.
# Fermer la fenêtre QEMU (croix) arrête la VM.
PMB="$HOME/.local/var/pmbootstrap"
exec qemu-system-aarch64 -M virt -cpu cortex-a57 -smp 4 -m 2048 \
  -drive file="$PMB/chroot_native/home/pmos/rootfs/qemu-aarch64.img",format=raw,if=virtio \
  -drive if=pflash,format=raw,readonly=on,file="$PMB/chroot_buildroot_aarch64/usr/share/AAVMF/AAVMF_CODE.fd" \
  -device virtio-gpu-pci -device virtio-tablet-pci -device virtio-keyboard-pci \
  -netdev user,id=net,hostfwd=tcp:127.0.0.1:2222-:22 -device virtio-net-pci,netdev=net \
  -serial stdio -display gtk
