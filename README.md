# Meine Golden Image

Dies ist ein simples Projekt. Es baut ein gehaertetes Ubuntu-Basisimage
mit Packer, Ansible und cloud-init. Das fertige Image wird in meinen
anderen Projekten als Grundlage fuer andere VMs genutzt.

Packer startet ueber QEMU eine temporaere VM aus dem Ubuntu Cloud-Image.
Cloud-init richtet dabei den SSH-Zugang ein, damit Packer sich verbinden kann.
Dann laeuft Ansible durch, aktualisiert das System, installiert Grundpakete
wie curl, vim, htop, fail2ban und Netzwerk-Diagnosetools, entfernt unnoetige
Pakete wie snapd und haertet die SSH-Konfiguration. Am Ende faehrt Packer
die VM herunter und speichert das Ergebnis als Golden Image unter
output-ubuntu-vm/golden-ubuntu.qcow2.

Voraussetzungen: Packer (>= 1.9.0), Ansible, QEMU mit KVM-Unterstuetzung
und ein Ubuntu 24.04 Cloud-Image.

    packer init .
    packer validate .
    packer build .

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
| Installieren | ntp | Zeitsynchronisation fuer Cluster und DBs |
| Entfernen | snapd | Unnoetig auf Servern, spart Ressourcen |
| Entfernen | popularity-contest | Sendet Nutzungsdaten, nicht gewuenscht |
| Entfernen | telnet | Unsicheres Protokoll, Sicherheitsrisiko |
| Haerten | Root-Login per SSH | Verhindert direkten Root-Zugriff |
| Haerten | Passwort-Login per SSH | Erzwingt Key-basierte Authentifizierung |
| Aufraeumen | Paket-Cache | Haelt das Image klein |
