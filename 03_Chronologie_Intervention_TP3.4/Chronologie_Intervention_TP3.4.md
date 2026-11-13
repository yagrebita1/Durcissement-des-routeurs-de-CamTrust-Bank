# Chronologie de l'intervention du prestataire et gestion AAA (TP3.4)

Ce document démontre le fonctionnement de l'authentification centralisée **AAA (FreeRADIUS sur `SRV-ADMIN` `10.10.99.20`)**, la révocation immédiate des droits d'un compte lors du départ d'un intervenant, ainsi que la reconstitution chronologique exacte des actions grâce à la synchronisation **NTP** (`Africa/Douala` / WAT) et à la collecte **Syslog** (`UDP 514`)[cite: 1, 2].

---

## 1. Validation de l'authentification centralisée AAA

Tous les équipements réseau de **CamTrust Bank** (`R-DLA`, `R-SIEGE`, `R-FAI`) délèguent l'authentification des administrateurs au serveur **FreeRADIUS** hébergé sur **`SRV-ADMIN` (`10.10.99.20`)** :

- **Attribution des privilèges via attributs RADIUS (AVPairs) :**
  - `Cisco-AVPair = "shell:priv-lvl=15"` pour l'accès privilégié immédiat sur `R-SIEGE`[cite: 10].
  - `Mikrotik-Group = "full"` pour les droits d'administration complets sur `R-DLA`[cite: 10].
  - Authentification PAM/RADIUS directe sur `R-FAI` (VyOS 2026.03)[cite: 32].
- **Preuve technique :** `test_freeradius_2.png` (réception de `Access-Accept` avec les attributs de privilèges)[cite: 10], `TP3.1_06_SRV-ADMIN_auth_RADIUS_RDLA.png`[cite: 17], `TP3.2_04a_RSIEGE_AAA_RADIUS.png`[cite: 24] et `TP3.3_03_SRV-ADMIN_RADIUS_RFAI.png`[cite: 32].

---

## 2. Démonstration du départ d'un compte (Révocation centralisée)

Lorsqu'un prestataire ou un administrateur quitte **CamTrust Bank** (ou voit ses accès suspendus), l'architecture AAA centralisée permet de **révoquer instantanément son accès sur l'ensemble du parc réseau** par une seule opération sur `SRV-ADMIN` (`/etc/freeradius/3.0/mods-config/files/authorize`), **sans avoir à modifier la configuration des 3 routeurs** :

1. **Avant révocation :** L'utilisateur authentifié sur FreeRADIUS obtient un `Access-Accept` et ouvre une session SSH sur `R-DLA`, `R-SIEGE` et `R-FAI`[cite: 10, 17, 21, 32].
2. **Action de révocation sur `SRV-ADMIN` :** Commentaire ou suppression de l'entrée du compte dans `/etc/freeradius/3.0/mods-config/files/authorize` suivie du rechargement du service (`sudo systemctl reload freeradius`).
3. **Après révocation (Preuve de rejet) :**
   - Toute nouvelle tentative d'authentification (`radtest` ou connexion `ssh`) est immédiatement rejetée par FreeRADIUS (`Access-Reject` / absence de réponse valide) et refusée sur les routeurs (`Permission denied` / `login failure`)[cite: 3, 6].
   - **Preuve technique :** `preuve_depart_compte_rejet_freeradius.png`[cite: 6] et `P3.1_07_SRV-ADMIN_syslog_centralise_RDLA.png` (journalisation `system,error,critical login failure`)[cite: 3].

---

## 3. Reconstitution chronologique exacte de l'intervention (Corrélation NTP / Syslog)

Grâce au serveur **Chrony NTP** actif sur `SRV-ADMIN` (`10.10.99.20`, Stratum 3/8) et au démon **Rsyslog** écoutant sur `0.0.0.0:514`[cite: 4, 7, 18], tous les événements générés par les routeurs sont horodatés de manière cohérente et corrélés dans `/var/log/reseau/` :

| Horodatage (WAT) | Équipement source | Service / Événement journalisé | Analyse de sécurité et traçabilité |
| :--- | :--- | :--- | :--- |
| **10 Nov 2026 — 16:25** | `SRV-ADMIN` (`10.10.99.20`) | `chronyc tracking` (`Stratum 3`, `Leap status: Normal`)[cite: 4] | Mise en service de la référence horaire centrale pour tout le réseau[cite: 4]. |
| **10 Nov 2026 — 17:44** | `SRV-ADMIN` (`10.10.99.20`) | `freeradius -X` & `ss -ulnp \| grep 514`[cite: 7, 9] | Validation du serveur AAA (`Access-Accept`) et ouverture du puits Syslog UDP 514[cite: 7, 10]. |
| **12 Nov 2026 — 21:24** | `SRV-ADMIN` → `R-DLA` | Audit Nmap initial sur `172.16.12.2`[cite: 11] | Détection des ports vulnérables ouverts (`21/ftp`, `23/telnet`, `80/http`, `8728/api`)[cite: 11]. |
| **12 Nov 2026 — 21:42** | `R-DLA` (`172.16.12.2`) | `ntp change time` + désactivation `admin` + pare-feu `INPUT`[cite: 13, 14, 17] | Application du durcissement MikroTik et synchronisation horaire sur `10.10.99.20`[cite: 17, 18]. |
| **12 Nov 2026 — 21:51** | `SRV-ADMIN` → `R-DLA` | Audit Nmap final sur `172.16.12.2`[cite: 15] | Confirmation de la fermeture des ports non chiffrés (seuls `22/ssh` et `8291/winbox` filtrés subsistent)[cite: 15]. |
| **12 Nov 2026 — 22:07** | `R-DLA` (`172.16.12.2`) | `firewall,info INPUT-REFUS in:ether22 ... 10.20.10.10:137->10.20.10.1:137`[cite: 16] | Le pare-feu `INPUT` bloque et journalise en temps réel le trafic NetBIOS non autorisé vers le routeur[cite: 16]. |
| **12 Nov 2026 — 22:14** | `R-DLA` → `SRV-ADMIN` | `system,info,account user gregoire.admin logged in from 10.10.99.20 via ssh`[cite: 3] | Connexion légitime de l'administrateur via RADIUS tracée dans le journal centralisé[cite: 3]. |
| **12 Nov 2026 — 22:15** | `R-DLA` → `SRV-ADMIN` | `system,error,critical login failure for user admin from 10.10.99.20 via ssh`[cite: 3] | Détection immédiate d'une tentative d'accès avec le compte par défaut désactivé `admin`[cite: 3]. |
| **12 Nov 2026 — 22:27 – 23:48** | `R-SIEGE` (`10.10.99.1`) | Audit initial, déploiement SSHv2, AAA, SNMPv3, Archive, uRPF strict[cite: 19, 21, 24, 26, 27, 29] | Durcissement complet du routeur central Cisco et traçabilité commande par commande (`show archive log config all`)[cite: 27]. |
| **13 Nov 2026 — 05:30 – 05:50** | `R-FAI` (`198.51.100.1`) | Suppression `vyos`, activation RADIUS, pare-feu `input drop`, uRPF strict[cite: 32] | Durcissement complet du routeur de bordure VyOS 2026.03 et validation des journaux Syslog sur `SRV-ADMIN`[cite: 32]. |
