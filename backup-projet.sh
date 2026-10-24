#!/bin/bash
# Sauvegarde du projet os-mobile vers D: (archive tar.gz datée, qui conserve les permissions Unix).
# Usage : ./backup-projet.sh
# Restauration : tar xzf /mnt/d/projets/os-mobile-backup/os-mobile-AAAAMMJJ-HHMMSS.tar.gz -C ~/projets
# Code retour : 0 = OK, 1 = erreur.
SRC="$HOME/projets/os-mobile"
DEST="/mnt/d/projets/os-mobile-backup"
KEEP=5

[ -d "$SRC" ] || { echo "ERREUR : dossier source introuvable : $SRC"; exit 1; }
[ -d /mnt/d ] || { echo "ERREUR : D: n'est pas accessible depuis WSL (/mnt/d absent)"; exit 1; }
mkdir -p "$DEST" || { echo "ERREUR : impossible de créer $DEST"; exit 1; }

FILE="$DEST/os-mobile-$(date +%Y%m%d-%H%M%S).tar.gz"
tar czf "$FILE" -C "$HOME/projets" os-mobile || { echo "ERREUR : la création de l'archive a échoué"; rm -f "$FILE"; exit 1; }

# Vérifie que l'archive est lisible
if ! tar tzf "$FILE" > /dev/null 2>&1; then
  echo "ERREUR : archive illisible, supprimée : $FILE"
  rm -f "$FILE"
  exit 1
fi

# Rotation : garde les $KEEP archives les plus récentes
ls -1t "$DEST"/os-mobile-*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)) | xargs -r rm --

echo "OK : $FILE ($(du -h "$FILE" | cut -f1))"
echo "Archives conservées :"
ls -1t "$DEST"/os-mobile-*.tar.gz
