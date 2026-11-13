# Grille de conformité NSA Avant / Après — CamTrust Bank

Ce document constitue la pièce centrale d'audit et de validation du durcissement des trois routeurs de l'infrastructure **CamTrust Bank** (`R-DLA`, `R-SIEGE`, `R-FAI`), conformément aux recommandations de la **NSA** (sections 3.1 et 3.3) et à la politique de sécurité interne (**M1**).

---

## 1. Grille d'audit détaillée par recommandation NSA

| Réf. NSA / M1 | Recommandation de durcissement | Équipement | Statut Avant | Statut Après | Preuve technique & Capture associée |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **NSA 3.1.1**<br>*(M1-ID)* | **Identification explicite et bannière légale** : Nom d'hôte normalisé et bannière d'avertissement dissuasive avant authentification. | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | Non conforme<br>Partiel<br>Non conforme | **Conforme**<br>**Conforme**<br>**Conforme** | `TP3.1_06_SRV-ADMIN_auth_RADIUS_RDLA.png`<br>`TP3.2_02_SRV-ADMIN_SSH_banniere_AAA.png`<br>`TP3.3_03_SRV-ADMIN_RADIUS_RFAI.png` |
| **NSA 3.1.2**<br>*(M1-ACC-01)* | **Suppression/désactivation des comptes par défaut et compte de secours** : Désactivation de `admin` / suppression de `vyos`, création du compte local `secours` chiffré. | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | Non conforme<br>Non conforme<br>Non conforme | **Conforme**<br>**Conforme**<br>**Conforme** | `TP3.1_02_RDLA_comptes_secours.png` (`/user disable admin`)<br>`TP3.2_04b_SRV-ADMIN_repli_local_secours.png`<br>`TP3.3_03_SRV-ADMIN_RADIUS_RFAI.png` (`vyos` refusé) |
| **NSA 3.1.3**<br>*(M1-AAA-01)* | **Authentification centralisée AAA (RADIUS)** : Délégation de l'authentification des administrateurs vers `SRV-ADMIN` (`10.10.99.20`) avec repli local. | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | Non conforme<br>Non conforme<br>Non conforme | **Conforme**<br>**Conforme**<br>**Conforme** | `TP3.1_06_SRV-ADMIN_auth_RADIUS_RDLA.png`<br>`TP3.2_04a_RSIEGE_AAA_RADIUS.png`<br>`TP3.3_03_SRV-ADMIN_RADIUS_RFAI.png` (`Access-Accept`) |
| **NSA 3.1.4**<br>*(M1-SRV-01)* | **Réduction de la surface réseau et SSHv2** : Fermeture de Telnet (23), FTP (21), HTTP (80), API ; administration chiffrée SSHv2 uniquement. | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | Non conforme<br>Partiel<br>Partiel | **Conforme**<br>**Conforme**<br>**Conforme** | `TP3.1_04_SRV-ADMIN_nmap_final_RDLA.png` (21, 23, 80 fermés)<br>`TP3.2_09a_RSIEGE_ports_ouverts.png` (`SSH version 2.0`)<br>`TP3.3_01_SRV-ADMIN_scan_initial_RFAI.png` (seul port 22 ouvert) |
| **NSA 3.1.5**<br>*(M1-L2-01)* | **Désactivation des protocoles de découverte et d'accès niveau 2** : Blocage de CDP/LLDP/MNDP et MAC-Server sur les interfaces exposées. | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | Non conforme<br>Non conforme<br>**Conforme** | **Conforme**<br>**Conforme**<br>**Conforme** | `TP3.1_08_RDLA_verifications_finales_et_backup.png` (`none`)<br>`TP3.2_08_RSIEGE_uRPF_WAN_Gi01.png` (`CDP is not enabled`)<br>Désactivé par défaut sur VyOS 2026.03 |
| **NSA 3.3.1**<br>*(M1-FW-01)* | **Filtrage strict du plan de contrôle (Control Plane)** : Politique *Default Drop* et restriction de l'accès SSH/Winbox au seul VLAN d'administration (`10.10.99.0/24`). | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | Non conforme<br>Non conforme<br>Non conforme | **Conforme**<br>**Conforme**<br>**Conforme** | `TP3.1_03_RDLA_firewall_input.png` (`INPUT-REFUS`)<br>`TP3.2_03a_CLIENT_refus_SSH.png` & `TP3.2_03b_RSIEGE_ACL_ADMIN_SOURCES.png`<br>`TP3.3_04_SRV-INTERNET_blocage_SSH.png` |
| **NSA 3.3.2**<br>*(M1-MON-01)* | **Supervision chiffrée SNMPv3** : Remplacement des communautés en clair par SNMPv3 `authPriv` (SHA + AES-128). | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | **Conforme**<br>Non conforme<br>**Conforme** | **Conforme**<br>**Conforme**<br>**Conforme** | SNMP désactivé sur `R-DLA` et `R-FAI` (`N/A - fermé`)<br>`TP3.2_05_SNMPv3_authPriv.png` (UDP 161 actif en v3) |
| **NSA 3.3.3**<br>*(M1-TIME-01)* | **Synchronisation horaire NTP et fuseau local** : Synchronisation de tous les équipements sur `SRV-ADMIN` (`10.10.99.20`) en fuseau `Africa/Douala` (WAT). | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | Non conforme<br>Non conforme<br>Non conforme | **Conforme**<br>**Conforme**<br>**Conforme** | `TP3.1_08_RDLA_verifications_finales_et_backup.png` (`synchronized`)<br>`TP3.2_07_RSIEGE_NTP_authentifie.png` (`WAT`)<br>`TP3.3_05_RFAI_uRPF_NTP.png` (`show ntp`) |
| **NSA 3.3.4**<br>*(M1-LOG-01)* | **Centralisation des journaux Syslog et audit des commandes** : Envoi des logs vers `SRV-ADMIN` (`UDP 514`) et journalisation des commandes de configuration. | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | Non conforme<br>Non conforme<br>Non conforme | **Conforme**<br>**Conforme**<br>**Conforme** | `P3.1_07_SRV-ADMIN_syslog_centralise_RDLA.png`<br>`TP3.2_06a_RSIEGE_archive_log.png` (`archive log config`)<br>`TP3.3_06_SRV-ADMIN_syslog_RFAI.png` |
| **NSA 3.3.5**<br>*(M1-EDGE-01)* | **Protection contre l'usurpation d'adresse IP (uRPF strict & anti-bogons)** : Activation de uRPF en mode strict sur les liens d'accès et filtrage des réseaux bogons. | `R-DLA`<br>`R-SIEGE`<br>`R-FAI` | **Conforme**<br>Non conforme<br>Non conforme | **Conforme**<br>**Conforme**<br>**Conforme** | `TP3.1_03_RDLA_firewall_input.png` (filtrage d'entrée)<br>`TP3.2_08_RSIEGE_uRPF_WAN_Gi01.png` (`reachable-via RX`)<br>`TP3.3_05_RFAI_uRPF_NTP.png` (`source-validation strict`) |

---

## 2. Calcul des taux de conformité Avant / Après

| Équipement | Critères conformes Avant | Taux Avant | Critères conformes Après | Taux Après | Gain de sécurité |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **R-DLA** (MikroTik) | 2 / 10 | **20 %** | 10 / 10 | **100 %** | **+80 %** |
| **R-SIEGE** (Cisco IOS) | 1 / 10 | **10 %** | 10 / 10 | **100 %** | **+90 %** |
| **R-FAI** (VyOS 2026.03) | 2 / 10 | **20 %** | 10 / 10 | **100 %** | **+80 %** |
| **Moyenne globale CamTrust Bank** | **5 / 30** | **16,7 %** | **30 / 30** | **100 %** | **+83,3 %** |
