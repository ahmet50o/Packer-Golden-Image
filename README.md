# Meine Golden Image

Ein kleines Hobbyprojekt. Es baut ein gehaertetes Ubuntu-Basisimage
mit Packer, Ansible und cloud-init. Das fertige Image dient als
Grundlage fuer andere VMs in weiteren Projekten.

## Warum ein Golden Image?

Das Cloud-Image von Canonical ist schon recht schlank, aber es kommen
trotzdem Sachen mit die auf Servern nicht gebraucht werden, und es
fehlen Tools die man eigentlich immer braucht. Statt das jedes Mal von
Hand zu machen, baut dieses Projekt ein fertiges Basisimage. SSH wird
gehaertet, fail2ban schuetzt vor Brute-Force, und unnoetige Pakete
fliegen raus. Nebenbei ist es ein gutes Lernprojekt, um zu verstehen
wie man mit Packer und Ansible einen reproduzierbaren Image-Build
aufsetzt.

## Wie es funktioniert

Packer startet ueber QEMU eine temporaere VM aus dem Cloud-Image.
Cloud-init setzt dabei nur ein temporaeres Passwort, damit Packer sich
per SSH verbinden kann. Dann laeuft Ansible durch und macht den
eigentlichen Job: System aktualisieren, Pakete installieren und
entfernen, SSH haerten, fail2ban konfigurieren. Am Ende faehrt Packer
die VM sauber herunter und speichert das Ergebnis als qcow2-Image
unter output/golden-ubuntu.qcow2.

## Schnellstart

Voraussetzungen sind Packer (>= 1.9.0), Ansible und QEMU mit KVM.
Dann einfach das Ubuntu 24.04 Cloud-Image (z.B. [hier](https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img) downloaden) in den input-Ordner legen
und bauen:

    cp /pfad/zum/ubuntu-24.04-server-cloudimg-amd64.img input/
    make build

Das ist alles. Packer findet das Image automatisch und berechnet die
Checksum selbst.

Das Playbook nutzt apt und ist damit auf Ubuntu- und Debian-basierte
Cloud-Images beschraenkt. Das Image im input-Ordner muss eine .img-
oder .qcow2-Datei sein.

Wer die VM-Ressourcen anpassen will (CPUs, RAM, Disk), kopiert die
Beispieldatei und passt die Werte an. Packer laedt alle
*.auto.pkrvars.hcl Dateien automatisch:

    cp beispiel.pkrvars.hcl meine.auto.pkrvars.hcl

## Projektstruktur

    .
    ├── Makefile                  # Build-Kommandos
    ├── README.md
    ├── ansible/
    │   └── playbook.yml          # Haertung und Paketinstallation
    ├── beispiel.pkrvars.hcl      # Beispiel fuer optionale Variablen
    ├── cloud-init/
    │   └── user-data.yml         # Temporaerer SSH-Zugang fuer den Build
    ├── input/                    # Cloud-Image hier ablegen
    ├── main.pkr.hcl              # Packer-Konfiguration
    └── vars.pkr.hcl              # Variablen mit Defaults

## Designentscheidungen

**KVM als Accelerator:** Ohne KVM emuliert QEMU jeden CPU-Befehl in
Software — ein Build der mit KVM 3 Minuten dauert, kann ohne locker
30 Minuten brauchen. Da das Image sowieso fuer libvirt/KVM gebaut wird,
ist KVM ohnehin vorhanden.

**qcow2 statt raw:** qcow2 ist das Standardformat fuer libvirt/KVM und
unterstuetzt Thin Provisioning, also nur belegter Platz wird gespeichert.
Ein raw-Image waere ein 1:1-Abbild der vollen Disk-Groesse.

**Expliziter Shutdown:** Ohne shutdown_command killt Packer den
QEMU-Prozess direkt. Das kann das Dateisystem im
Image beschaedigen. Mit dem Befehl faehrt die VM vorher sauber herunter.

**Kein ntp:** Ubuntu 24.04 bringt systemd-timesyncd schon mit. Ein
zusaetzliches ntp-Paket wuerde damit konkurrieren. Deshalb wird ntp
sogar explizit entfernt, falls es doch vorinstalliert sein sollte.

**fail2ban mit Jail:** Eher zu Lernzwecken. Das SSH-Jail sperrt IPs nach 3
fehlgeschlagenen Logins fuer eine Stunde.

**SSH-Handler in Ansible:** Aenderungen an der sshd_config werden erst
aktiv wenn der Dienst neu startet. Ein Handler erledigt das automatisch,
aber nur wenn sich wirklich etwas geaendert hat.

## Was das Playbook macht

| Aktion | Was | Warum |
|--------|-----|-------|
| Aktualisieren | Paketquellen und alle Pakete | Sicherheitsupdates und aktuelle Versionen |
| Installieren | curl | HTTP-Anfragen und Debugging |
| Installieren | vim | Dateien auf dem Server bearbeiten |
| Installieren | htop | Prozesse, RAM und CPU ueberwachen |
| Installieren | net-tools | Netzwerk-Debugging mit ifconfig, netstat |
| Installieren | dnsutils | DNS-Probleme finden mit dig, nslookup |
| Installieren | iputils-ping | Erreichbarkeit von VMs pruefen |
| Installieren | traceroute | Routing-Probleme zwischen VMs finden |
| Installieren | fail2ban | SSH vor Brute-Force-Angriffen schuetzen |
| Installieren | ca-certificates | HTTPS-Verbindungen ermoeglichen |
| Konfigurieren | fail2ban SSH-Jail | Sperrt IPs nach 3 Fehlversuchen fuer 1h |
| Entfernen | snapd | Unnoetig auf Servern, spart Ressourcen |
| Entfernen | popularity-contest | Sendet Nutzungsdaten, nicht gewuenscht |
| Entfernen | telnet | Unsicheres Protokoll, Sicherheitsrisiko |
| Entfernen | ntp | Konkurriert mit systemd-timesyncd |
| Haerten | Root-Login per SSH | Verhindert direkten Root-Zugriff |
| Haerten | Passwort-Login per SSH | Erzwingt Key-basierte Authentifizierung |
| Aufraeumen | Paket-Cache | Haelt das Image klein |
