# 🗂️ Taxonomie ADR - Guide de Classification

**Version**: 2.0  
**Date**: 2026-06-17  
**Projet**: azure-marketplace-vm-validator  
**Basée sur**: Bonnes pratiques industrie (AWS, Azure, GitHub ADR Organization)

---

## ⚠️ Documents Complémentaires

**Ce document fait partie d'un système cohérent de 4 fichiers**:

1. **[ADR-000](./000-META-processus-creation-adr.md)** - Processus et numérotation
2. **[TAXONOMY.md](./TAXONOMY.md)** - Ce fichier (classification détaillée)
3. **[adr-template-ai-optimized.md](./adr-template-ai-optimized.md)** - Template pratique
4. **[README.md](./README.md)** - Index et vue d'ensemble

**⚡ IMPORTANT**: Toute modification de classification ici doit être reflétée dans le template et ADR-000.

---

## 📋 Vue d'Ensemble

Cette taxonomie permet de **classifier chaque ADR selon 7 dimensions** pour:
- ✅ Faciliter la recherche et le filtrage
- ✅ Permettre le parsing automatique par agents IA
- ✅ Construire des graphes de dépendances
- ✅ Générer des dashboards automatiques

**Format**: Frontmatter YAML dans chaque ADR (voir template)

---

## 🔍 Les 7 Dimensions de Classification

### 1️⃣ Lifecycle (Cycle de Vie)

**État actuel de l'ADR dans son cycle de vie**

| Valeur | Description | Emoji | Usage |
|--------|-------------|-------|-------|
| `draft` | Rédaction en cours, peut contenir TODOs | 🔄 | ADR incomplet |
| `proposed` | Prêt pour review équipe | 🔄 | En attente validation |
| `accepted` | Décision approuvée et en vigueur | ✅ | Implémenté |
| `rejected` | Proposition refusée (archivée) | ❌ | Non retenu |
| `deprecated` | Obsolète mais pas remplacé | ⚠️ | À retirer |
| `superseded` | Remplacé par nouvel ADR | ➡️ | Référencer nouveau |

**Exemple**:
```yaml
classification:
  lifecycle: "accepted"
```

---

### 2️⃣ Domain (Domaine Architectural)

**Domaine architectural principal concerné**

**Plages de numérotation réservées par domaine** :

| Préfixe | Plage | Domaine | Exemples ADR azure-marketplace-vm-validator |
|---------|-------|---------|----------------------------------------------|
| `META` | 000-099 | Méta-processus | ADR-000: Processus ADR |
| `ARCH` | 100-199 | Architecture | ADR-100: Modes d'exécution SSH vs run-command |
| `INFRA` | 200-299 | Infrastructure | ADR-200: Cible `az vm run-command invoke` |
| `SEC` | 300-399 | Sécurité | ADR-300: Contrôles hardening testés (SSH/TLS) |
| `DATA` | 400-499 | Données | ADR-400: Format de rapport PASS/FAIL/WARN |
| `API` | 500-599 | API/Intégrations | ADR-500: Reusable GitHub workflow_call |
| `DEVOPS` | 600-699 | DevOps | ADR-600: Makefile orchestrateur |
| `TEST` | 700-799 | Tests & QA | ADR-700: Mapping tests ↔ policies 200.x |
| `BIZ` | 800-899 | Business | ADR-800: Sources officielles Marketplace |

**Descriptions par domaine** :

| Valeur | Description | Exemples contexte azure-marketplace-vm-validator |
|--------|-------------|---------------------------------------------------|
| `meta` | Gouvernance et documentation du processus | Processus ADR, règles de contribution IA, conventions documentaires |
| `architecture` | Design du validator | Modes d'exécution (SSH vs `run-command`), adapters distro, modèle d'extension |
| `infrastructure` | Cible Azure d'exécution | `az vm run-command`, identités managées, scopes RG, subscription |
| `security` | Contrôles validés côté VM testée | Hardening SSH, TLS, host keys, généralisation vérifiés sur la cible |
| `data` | Format des rapports et preuves | Sortie PASS/FAIL/WARN, JSON machine-readable, JUnit XML, archivage |
| `api` | Surface d'intégration callers | Reusable workflow, submodule Git, sparse-checkout, variables `CTT_*` |
| `devops` | Outillage, automatisation | Makefile, scripts, nomenclature, version bump, conventions couleurs |
| `test` | **Cœur du projet** — conformité | Mapping policies 200.x, taxonomie des tests, conventions PASS/FAIL/WARN |
| `business` | Référentiel officiel et conformité | Sources Microsoft, anti-hallucination, versionnage des policies |

**Exemple**:
```yaml
classification:
  domain: "infrastructure"
```

**Règle**: Choisir **UN seul domaine principal** (le plus impacté).

---

### 3️⃣ Impact (Niveau d'Impact)

**Ampleur de l'impact sur le système**

| Valeur | Description | Critères | Réversibilité Typique |
|--------|-------------|----------|----------------------|
| `low` | Impact local, facilement réversible | Single component, < 1 jour | Easy |
| `medium` | Plusieurs composants, effort modéré | Multi-component, 1-5 jours | Moderate |
| `high` | Système-wide, breaking change possible | Cross-system, > 1 semaine | Hard |
| `critical` | Fondamental, irréversible | Core architecture, migration coûteuse | Irreversible |

**Aide décision (contexte azure-marketplace-vm-validator)**:
- **Low**: Ajustement d'un message de log ou d'un seuil dans un test existant
- **Medium**: Ajout d'un nouveau test de conformité ou d'un helper dans `lib/`
- **High**: Changement du mode d'exécution distant, ajout d'un adapter distro
- **Critical**: Changement de la cible d'exécution (`run-command` → autre) ou du contrat d'API `CTT_*`

---

### 4️⃣ Quality Attributes (Attributs Qualité - ASR)

**Qualités système affectées (basé sur ISO 25010)**

| Valeur | Description | Métriques Typiques | Pertinence azure-marketplace-vm-validator |
|--------|-------------|-------------------|--------------------------------------------|
| `performance` | Latence, débit, scalabilité | Temps total d'une passe, parallélisation | Durée d'une validation complète via `run-command` |
| `security` | Auth, autorisation, encryption | CVE count, TLS grade | Robustesse du runner (pas d'injection, pas de leak de secrets) |
| `reliability` | Disponibilité, tolérance pannes | Uptime %, MTBF | Idempotence et déterminisme des tests PASS/FAIL/WARN |
| `maintainability` | Modularité, testabilité | Temps d'ajout d'un test, lisibilité | Ajout d'un test, support multi-distros, plugin model |
| `cost` | Infrastructure, licensing | $/month Azure | Coût d'une passe (`run-command` minutes, RG de test) |
| `usability` | Developer/operator experience | Time to integrate | Intégration simple côté projet appelant |
| `compliance` | Légal, réglementaire | Marketplace policies | Alignement strict sur les politiques Microsoft Marketplace |
| `portability` | Multi-cloud, vendor independence | Migration effort | Réutilisabilité par toute offre VM Linux (Ubuntu, RHEL, Alma…) |

**Exemple**:
```yaml
classification:
  quality:
    - "security"
    - "reliability"
    - "compliance"
```

---

### 5️⃣ Reversibility (Facilité de Changement)

**Effort requis pour changer cette décision**

| Valeur | Effort | Durée Typique | Dépendances |
|--------|--------|---------------|-------------|
| `easy` | Très faible | < 1 jour | Aucune ou locale |
| `moderate` | Moyen | 1-5 jours | Quelques composants |
| `hard` | Élevé | > 1 semaine | Multiples systèmes |
| `irreversible` | Impossible/Prohibitif | Migration complète | Critique, données |

**Aide décision (contexte azure-marketplace-vm-validator)**:
- **Easy**: Ajustement d'un test Bash ou d'un message de sortie
- **Moderate**: Ajout d'un adapter distro ou d'un format de rapport
- **Hard**: Refonte du modèle d'exécution distant ou du dispatch des tests
- **Irreversible**: Changement du contrat public `CTT_*` ou de la cible `run-command`

---

### 6️⃣ Scope (Portée)

**Niveau stratégique de la décision**

| Valeur | Description | Horizon Temporel | Niveau |
|--------|-------------|------------------|--------|
| `strategic` | Vision long terme, organisation-wide | 3-5 ans | C-level, CTO |
| `tactical` | Implémentation spécifique, projet-wide | 6-18 mois | Team lead, Architect |
| `operational` | Choix techniques locaux, component-level | 1-6 mois | Developer |

**Aide décision (contexte azure-marketplace-vm-validator)**:
- **Strategic**: Choix de la cible d'exécution (`run-command`) ou du modèle de distribution du toolkit
- **Tactical**: Architecture des adapters distro, format des rapports, surface d'intégration
- **Operational**: Ajout d'un test, ajustement d'un seuil, message de log

---

### 7️⃣ Tech Areas (Domaines Technologiques)

**Technologies/frameworks/plateformes concernés** (liste libre)

#### Languages & Runtimes
- `bash`, `shellcheck`, `bats`, `jq`

#### Cloud & Infrastructure
- `azure`, `az-cli`, `vm`, `vm-offer`, `partner-center`, `marketplace`, `run-command`, `managed-identity`

#### Conformité VM Linux testée
- `walinuxagent`, `cloud-init`, `hyper-v`, `systemd`, `tls`, `ssh`, `openssl`

#### Rapports & Données
- `json`, `junit-xml`, `markdown`, `pass-fail-warn`

#### DevOps & CI/CD
- `github-actions`, `workflow-call`, `make`, `shell-script`

#### Distros supportées
- `ubuntu`, `debian`, `rhel`, `centos`, `almalinux`, `rocky`, `suse`

**Exemple**:
```yaml
classification:
  tech_areas:
    - "azure"
    - "az-cli"
    - "vm"
    - "run-command"
    - "bash"
```

---

## 📊 Exemple Complet

### ADR-700: Mapping des tests ↔ politiques Marketplace 200.x

```yaml
---
adr: 700
title: "Mapping des tests ↔ politiques Marketplace 200.x"
status: "proposed"
date: 2026-06-17

classification:
  lifecycle: "proposed"
  domain: "test"
  impact: "high"
  quality:
    - "compliance"
    - "maintainability"
    - "reliability"
  reversibility: "moderate"
  scope: "tactical"
  tech_areas:
    - "azure"
    - "az-cli"
    - "vm"
    - "run-command"
    - "bash"

tags: ["azure-marketplace", "vm-offer", "certification", "policy-mapping"]
stakeholders: ["@architecture-team", "@dev-team"]
---
```

---

## 🔎 Cas d'Usage

### Recherche par Domain
```bash
# Tous les ADRs infrastructure
grep -l 'domain: "infrastructure"' docs/adr/*.md
```

### Filtrage par Impact
```bash
# ADRs critiques seulement
grep -l 'impact: "critical"' docs/adr/*.md
```

### ADRs concernant la conformité Marketplace
```bash
grep -l '"compliance"' docs/adr/*.md
```

### Recherche par tech_area run-command
```bash
grep -l '"run-command"' docs/adr/*.md
```

---

## ✅ Checklist Validation Classification

Avant d'accepter un ADR, vérifier:

- [ ] **Lifecycle**: État cohérent avec contenu ADR
- [ ] **Domain**: UN seul domaine principal choisi
- [ ] **Impact**: Niveau justifié dans section Conséquences
- [ ] **Quality**: ≥ 1 attribut qualité listé
- [ ] **Reversibility**: Cohérent avec impact et scope
- [ ] **Scope**: Aligné avec stakeholders et horizon
- [ ] **Tech Areas**: ≥ 1 technologie listée

---

## 🏷️ Convention Nommage Fichiers (Format Hybride)

### Format Standard

**Pattern** : `XXX-CATÉGORIE-titre-kebab-case.md`

### Exemples azure-marketplace-vm-validator

```
000-META-processus-creation-adr.md                # META: 000-099
100-ARCH-modes-execution-ssh-vs-run-command.md    # ARCH: 100-199
200-INFRA-az-vm-run-command-invoke.md             # INFRA: 200-299
300-SEC-exigences-hardening-testees.md            # SEC: 300-399
400-DATA-format-rapport-pass-fail-warn.md         # DATA: 400-499
500-API-reusable-github-workflow-call.md          # API: 500-599
600-DEVOPS-makefile-orchestrateur.md              # DEVOPS: 600-699
700-TEST-mapping-policies-200.md                  # TEST: 700-799
800-BIZ-sources-officielles-marketplace.md        # BIZ: 800-899
```

### Commandes Recherche par Catégorie

```bash
# ADRs infrastructure
ls -1 docs/adr/*-INFRA-*.md

# ADRs sécurité ET data
ls -1 docs/adr/*-{SEC,DATA}-*.md

# Comptage par catégorie
ls -1 docs/adr/*.md | grep -oE "[A-Z]+" | sort | uniq -c
```

---

## 📚 Références

### Standards Industrie
- **ISO 25010**: System and software quality models
- **Azure Well-Architected**: 5 pillars (reliability, security, performance, cost, operational excellence)
- **Microsoft Azure Marketplace**: [VM Offer Requirements](https://learn.microsoft.com/en-us/azure/marketplace/azure-vm-offer-setup)

### Bonnes Pratiques ADR
- [Joel Parker Henderson - ADR GitHub](https://github.com/joelparkerhenderson/architecture-decision-record)
- [ADR.github.io](https://adr.github.io/)
- [AWS Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/)

---

## 📝 Notes

**Évolution**: Cette taxonomie peut évoluer avec le projet. Si changement majeur, créer nouvel ADR et superseder ADR-000.

**Contexte spécifique azure-marketplace-vm-validator**: La classification `compliance` est centrale car le projet existe pour aligner les images VM sur les politiques de certification Microsoft Azure Marketplace (section 200). La classification `portability` est également structurante : le toolkit doit rester project-agnostic et multi-distro (Ubuntu, Debian, RHEL…). Les `tech_areas` reflètent l'outillage du validator (`az-cli`, `run-command`, `bash`, `github-actions`) et non une pile applicative.

---

**Version**: 2.0  
**Maintenu par**: @architecture-team  
**Dernière mise à jour**: 2026-06-17  
**Projet**: azure-marketplace-vm-validator
