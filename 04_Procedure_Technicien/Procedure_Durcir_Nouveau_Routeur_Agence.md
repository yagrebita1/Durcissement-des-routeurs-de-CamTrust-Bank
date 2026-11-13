# Procédure Opérationnelle Standard (SOP) : Durcir un nouveau routeur d'agence

**Destinataire :** Technicien Réseau & Sécurité (CamTrust Bank)  
**Équipements cibles :** Routeurs d'agence (MikroTik RouterOS / Cisco IOS / VyOS)  
**Durée estimée :** 15 minutes | **Prérequis :** Accès console local, IP d'administration dans le plan d'adressage agence, déclaration préalable de l'IP du routeur dans FreeRADIUS (`10.10.99.20`).

---

## 1. Étape 1 — Préparation et Filet de Sécurité (Avant toute modification)
1. **Sauvegarder la configuration initiale** avant toute intervention (`/system backup save name=avant-durcissement` sur MikroTik, `copy running-config startup-config` sur Cisco).
2. **Activer le retour arrière automatique (anti-coupure)** :
   - **Cisco IOS :** `reload in 10` (annuler à la fin par `reload cancel`).
   - **VyOS :** `commit-confirm 10` (valider à la fin par `confirm` puis `save`).
   - **MikroTik :** Activer **Safe Mode** (`Ctrl+X` dans le terminal) avant d'appliquer les règles pare-feu.

## 2. Étape 2 — Comptes, Accès AAA et Réduction de Surface
1. **Identité et bannière :** Configurer le nom d'hôte normalisé (`R-<CODE_AGENCE>`) et la bannière légale CamTrust Bank.
2. **Compte de secours et comptes par défaut :**
   - Créer un compte local d'urgence `secours` avec un mot de passe fort (`<masqué>`) conservé dans le coffre-fort d'équipe.
   - Tester la connexion avec `secours`, puis **désactiver/supprimer** le compte par défaut (`admin` / `vyos`).
3. **Authentification centralisée RADIUS :**
   - Configurer le serveur RADIUS **`10.10.99.20`** (UDP `1812`/`1813`) avec le secret partagé `<masqué>` et activer le repli local (`group radius local`) uniquement en cas de perte du serveur central.
4. **Fermeture des services non chiffrés :**
   - Désactiver **Telnet (23), FTP (21), HTTP (80), API, CDP/LLDP/MNDP et MAC-Server**.
   - Autoriser uniquement **SSHv2** (et Winbox chiffré sur MikroTik) depuis le seul réseau d'administration **`10.10.99.0/24`**.

## 3. Étape 3 — Filtrage Pare-feu, Temps (NTP) et Journaux (Syslog)
1. **Filtrage du plan de contrôle (INPUT / VTY) :**
   - Appliquer une politique **Default Drop** sur le trafic à destination du routeur : autoriser uniquement `established/related`, ICMP de diagnostic, DHCP LAN (si applicable) et SSH/Winbox depuis `10.10.99.0/24`.
   - Activer **uRPF strict** sur l'interface WAN d'interconnexion avec le siège.
2. **Synchronisation horaire NTP :**
   - Régler le fuseau horaire sur **`Africa/Douala` (WAT, UTC+1)** et synchroniser l'horloge sur **`10.10.99.20`**.
3. **Centralisation Syslog :**
   - Diriger tous les journaux système, pare-feu et authentification (`info` et supérieur) vers **`10.10.99.20` (UDP 514)**.

## 4. Étape 4 — Checklist de Validation avant Mise en Production (Go / No-Go)

| Contrôle obligatoire | Test à réaliser par le technicien | Critère de validation (GO) |
| :--- | :--- | :--- |
| **1. Accès RADIUS** | Connexion SSH depuis `SRV-ADMIN` (`10.10.99.20`) avec un compte nominatif (`prenom.admin`) | Connexion réussie + privilèges complets attribués |
| **2. Compte par défaut** | Tentative de connexion SSH avec `admin` ou `vyos` | Accès refusé (`Permission denied`) |
| **3. Cloisonnement réseau** | Tentative de connexion SSH depuis un poste client agence ou Internet | Connexion bloquée (`Connection refused` / `timed out`) |
| **4. Surface exposée** | Scan de ports depuis `SRV-ADMIN` (`nc -zv` ou `nmap`) | Aucun port en clair (`21`, `23`, `80`) ouvert |
| **5. Temps & Journaux** | Vérification de l'heure locale (`WAT`) et présence d'une ligne de log sur `10.10.99.20` | Horloge synchronisée et logs visibles dans `/var/log/reseau/` |
| **6. Persistance** | Désactivation du filet de sécurité (`reload cancel` / `confirm` / `Ctrl+X`) et sauvegarde | Configuration persistante après redémarrage |
