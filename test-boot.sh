#!/bin/bash
# Test de boot automatisé : lance l'image en mode headless et attend le prompt "login:".
# Usage : ./test-boot.sh [timeout_en_secondes]   (défaut : 300)
# Code retour : 0 = OK, 1 = échec du boot, 2 = fichier manquant.
PMB="$HOME/.local/var/pmbootstrap"
IMG="$PMB/chroot_native/home/pmos/rootfs/qemu-aarch64.img"
FW="$PMB/chroot_buildroot_aarch64/usr/share/AAVMF/AAVMF_CODE.fd"
TIMEOUT="${1:-300}"
DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$DIR/logs"
LOG="$DIR/logs/boot-$(date +%Y%m%d-%H%M%S).log"

for f in "$IMG" "$FW"; do
  [ -f "$f" ] || { echo "ECHEC : fichier introuvable : $f"; exit 2; }
done

# snapshot=on : l'image n'est jamais modifiée par le test
qemu-system-aarch64 -M virt -cpu cortex-a57 -smp 4 -m 2048 \
  -drive file="$IMG",format=raw,if=virtio,snapshot=on \
  -drive if=pflash,format=raw,readonly=on,file="$FW" \
  -device virtio-gpu-pci -netdev user,id=net -device virtio-net-pci,netdev=net \
  -display none -monitor none -serial file:"$LOG" </dev/null &
QPID=$!

START=$SECONDS
while (( SECONDS - START < TIMEOUT )); do
  if grep -q "login:" "$LOG" 2>/dev/null; then
    kill "$QPID" 2>/dev/null; wait "$QPID" 2>/dev/null
    echo "OK : login atteint en $((SECONDS - START)) s (log : $LOG)"
    exit 0
  fi
  if grep -q "Kernel panic" "$LOG" 2>/dev/null; then
    kill "$QPID" 2>/dev/null; wait "$QPID" 2>/dev/null
    echo "ECHEC : kernel panic (log : $LOG)"; exit 1
  fi
  kill -0 "$QPID" 2>/dev/null || { echo "ECHEC : QEMU s'est arrêté (log : $LOG)"; exit 1; }
  sleep 2
done
kill "$QPID" 2>/dev/null; wait "$QPID" 2>/dev/null
echo "ECHEC : timeout de ${TIMEOUT} s sans login (log : $LOG)"
exit 1
