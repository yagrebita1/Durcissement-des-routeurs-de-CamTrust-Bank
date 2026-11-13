# Durcissement des routeurs de CamTrust Bank

**Établissement :** SUP'PTIC Yaoundé — Filière ITT2B (Spécialité Informatique & Réseaux)  
**Auteur :** Yakawa Grégoire Bihina (`yagrebita1`) & Binôme  
**Infrastructure cible :** Maquette CamTrust Bank (`R-DLA` MikroTik RouterOS 7.6, `R-SIEGE` Cisco IOSv, `R-FAI` VyOS 2026.03, `SRV-ADMIN` Ubuntu / FreeRADIUS / Chrony / Rsyslog)

---

## Présentation du dépôt

Ce dépôt contient l'ensemble des livrables techniques réalisés dans le cadre du durcissement de l'infrastructure réseau de **CamTrust Bank**, conformément à la politique de sécurité interne (**M1**) et aux recommandations de durcissement de la **NSA** (sections 3.1 et 3.3).

### Contenu du dossier

1. **[`01_Configurations_Finales/`](./01_Configurations_Finales/)** : Configurations finales durcies des trois routeurs (`R-DLA`, `R-SIEGE`, `R-FAI`) avec tous les secrets remplacés par `<masqué>`, chaque bloc relié à une règle de la politique M1 et à une section NSA.
2. **[`02_Grille_Conformite_NSA/`](./02_Grille_Conformite_NSA/)** : Grille de conformité NSA Avant/Après avec preuves et calcul des taux de conformité.
3. **[`03_Chronologie_Intervention_TP3.4/`](./03_Chronologie_Intervention_TP3.4/)** : Chronologie de l'intervention du prestataire (TP3.4), démonstration AAA centralisé et révocation de compte.
4. **[`04_Procedure_Technicien/`](./04_Procedure_Technicien/)** : Procédure opérationnelle d'une page « Durcir un nouveau routeur d'agence », utilisable par un technicien.
5. **[`preuves_captures/`](./preuves_captures/)** : Captures d'écran horodatées et anonymisées (aucun secret en clair).

---

## Synthèse des taux de conformité NSA

| Équipement | Plateforme | IP d'administration | Conformité Avant | Conformité Après |
| :--- | :--- | :--- | :---: | :---: |
| **R-DLA** (Agence Douala) | MikroTik RouterOS 7.6 | `172.16.12.2` | 20 % (2/10) | **100 % (10/10)** |
| **R-SIEGE** (Siège Central) | Cisco IOSv | `10.10.99.1` | 10 % (1/10) | **100 % (10/10)** |
| **R-FAI** (Bordure Opérateur) | VyOS 2026.03 (`circinus`) | `198.51.100.1` | 20 % (2/10) | **100 % (10/10)** |
