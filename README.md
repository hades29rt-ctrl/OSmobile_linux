# Config de référence — premier boot validé

Device: qemu-aarch64
Channel: v26.06
UI: console
Kernel: stable

Commande de lancement OBLIGATOIRE (sinon crash GTK/GL sous WSL2) :
    pmbootstrap qemu --no-gl --display none

Pour quitter la session QEMU proprement : fermer le terminal
(le raccourci Ctrl+A puis X n'a pas fonctionné dans cet environnement).
