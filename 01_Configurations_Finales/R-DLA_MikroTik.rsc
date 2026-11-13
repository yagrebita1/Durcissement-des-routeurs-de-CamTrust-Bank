# ==============================================================================
# CONFIGURATION FINALE DURCIE : R-DLA (Routeur Agence Douala - MikroTik CHR 7.6)
# Politique CamTrust Bank (M1) & Référentiel NSA (Sections 3.1 & 3.3)
# NOTE : Tous les secrets et mots de passe sont remplacés par <masqué>
# ==============================================================================

# [M1-ID / NSA 3.1.1] Identification explicite de l'équipement
/system identity set name=R-DLA

# [M1-ACC-01 / NSA 3.1.2] Compte local de secours et désactivation du compte par défaut 'admin'
/user add name=secours group=full password="<masqué>"
/user disable admin

# [M1-AAA-01 / NSA 3.1.3] Centralisation de l'authentification via FreeRADIUS (SRV-ADMIN)
/radius add address=10.10.99.20 secret="<masqué>" service=login timeout=2s
/user aaa set use-radius=yes default-group=read

# [M1-SRV-01 / NSA 3.1.4] Désactivation des services non chiffrés/inutiles et restriction SSH/Winbox
/ip service disable telnet,ftp,www,api,api-ssl
/ip service set ssh address=10.10.99.0/24 port=22
/ip service set winbox address=10.10.99.0/24 port=8291
/ssh set strong-crypto=yes

# [M1-L2-01 / NSA 3.1.5] Désactivation de l'accès niveau 2 (MAC-Server) et découverte de voisins
/tool mac-server set allowed-interface-list=none
/tool mac-server mac-winbox set allowed-interface-list=none
/ip neighbor discovery-settings set discover-interface-list=none

# [M1-FW-01 / NSA 3.3.1] Filtrage strict du plan de contrôle (chaîne INPUT - Default Drop)
/ip firewall filter
add chain=input action=accept connection-state=established,related,untracked comment="Reponses"
add chain=input action=drop connection-state=invalid comment="Paquets invalides"
add chain=input action=accept protocol=icmp comment="ICMP"
add chain=input action=accept protocol=tcp src-address=10.10.99.0/24 dst-port=22,8291 comment="Administration"
add chain=input action=accept protocol=udp in-interface-list=LAN dst-port=67 comment="DHCP des postes"
add chain=input action=drop log=yes log-prefix="INPUT-REFUS" comment="Tout le reste"

# [M1-TIME-01 / NSA 3.3.3] Synchronisation horaire NTP et fuseau local WAT
/system clock set time-zone-name=Africa/Douala
/system ntp client set enabled=yes mode=unicast servers=10.10.99.20

# [M1-LOG-01 / NSA 3.3.4] Centralisation des journaux Syslog vers SRV-ADMIN
/system logging action add name=remote-syslog target=remote remote=10.10.99.20 remote-port=514
/system logging add topics=info,warning,error,critical,account action=remote-syslog
