---
# 🤖 Machine-Readable Metadata (Frontmatter YAML)
adr: 0
title: "Processus de Création et Gestion des ADR"
status: "accepted"
date: 2026-02-21
superseded_by: null
replaces: null
related_adrs: []
related_issues: []

# 🗂️ Taxonomie ADR
classification:
  lifecycle: "accepted"
  domain: "meta"
  impact: "critical"
  quality:
    - "maintainability"
    - "compliance"
  reversibility: "hard"
  scope: "strategic"
  tech_areas:
    - "documentation"
    - "git"

tags: ["process", "documentation", "meta-adr", "governance"]
stakeholders: ["@architecture-team", "@dev-team", "@azure-marketplace-vm-validator"]
effort: "low"
---

# ADR 000: Processus de Création et Gestion des ADR

## ⚠️ Documents Complémentaires Obligatoires

**Ce processus est documenté dans un système cohérent de 4 fichiers à consulter ensemble**:

1. **[ADR-000](./000-META-processus-creation-adr.md)** - Ce fichier (processus et règles)
2. **[TAXONOMY.md](./TAXONOMY.md)** - Classification détaillée (7 dimensions)
3. **[adr-template-ai-optimized.md](./adr-template-ai-optimized.md)** - Template pratique
4. **[README.md](./README.md)** - Index et guide rapide

**⚡ Cohérence**: Toute modification des plages de numérotation, domaines ou classification doit être reflétée dans les 4 fichiers.

---

## 📊 Vue d'Ensemble

| Attribut | Valeur |
|----------|--------|
| **Statut** | ✅ Accepté |
| **Date Décision** | 2026-02-21 |
| **Dernière Révision** | 2026-06-11 |
| **Stakeholders** | @architecture-team, @dev-team |
| **Impact** | 🔴 Critique (fondamental) |
| **Effort Implémentation** | 🟢 Faible |
| **Risque Technique** | 🟢 Faible |

## Statut

✅ Accepté

## Date

2026-02-21

## Contexte

Le projet **azure-marketplace-vm-validator** fournit une boîte à outils réutilisable, projet-agnostique, qui **valide la conformité des images VM Linux publiées sur Microsoft Azure Marketplace** vis-à-vis des politiques de certification Microsoft (chapitres 200.3.3 / 200.4 / 200.5 — *VM Offer Certification*). Les contrôles s'exécutent via `az vm run-command invoke` (aucune SSH entrante requise) afin de reproduire les contraintes des évaluateurs Partner Center.

Ce projet sert de **composant partagé** entre plusieurs offres VM Marketplace : chaque projet appelant (PeerTube, WordPress, GitLab, etc.) conserve ses propres tests applicatifs et délègue au validator la conformité d'infrastructure commune à toutes les offres VM Microsoft.

Dans ce contexte, les Architecture Decision Records (ADR) sont essentiels pour capturer le **pourquoi** derrière les décisions techniques, facilitant :

- La compréhension des choix architecturaux par les nouveaux contributeurs
- La traçabilité des décisions dans le temps
- L'évaluation des alternatives considérées
- La documentation des conséquences (positives et négatives)
- La justification des changements futurs
- L'alignement strict sur les politiques officielles Microsoft Marketplace

Sans processus formalisé, les décisions restent implicites, rendant difficile :

- La cohérence de la documentation
- La recherche de décisions passées
- La compréhension du contexte historique
- L'évaluation de la pertinence actuelle des décisions

## Décision

Adopter un processus formalisé de création et gestion des ADR basé sur le modèle Michael Nygard, adapté pour **azure-marketplace-vm-validator**.

### Structure des ADR

Chaque ADR suit le template **optimisé IA** : [`docs/adr/adr-template-ai-optimized.md`](./adr-template-ai-optimized.md)

Ce template inclut :

#### **Frontmatter YAML obligatoire** (machine-readable):
```yaml
---
adr: XXX
title: "Titre Descriptif"
status: "proposed"  # lifecycle state
date: YYYY-MM-DD
classification:
  lifecycle: "proposed"
  domain: "test"
  impact: "high"
  quality: ["compliance", "maintainability"]
  reversibility: "moderate"
  scope: "tactical"
  tech_areas: ["azure", "vm", "az-cli", "bash"]
tags: ["azure-marketplace", "vm-offer", "certification"]
stakeholders: ["@architecture-team", "@dev-team"]
effort: "medium"
---
```

#### **Sections obligatoires** (human-readable):
```markdown
# ADR XXX: Titre Court et Descriptif

## 📊 Vue d'Ensemble (tableau récapitulatif)

## 🎯 Contexte & Problème
[Description du problème avec questions guidées]

## ✅ Décision
[Solution choisie + principes appliqués]

## 📊 Matrice de Décision Quantifiée
[Tableau comparatif avec scores sur 10]

## ⚖️ Conséquences
### ✅ Positives (avec métriques)
### ⚠️ Négatives & Mitigations (tableau)

## 🔄 Alternatives Considérées
[Options rejetées avec scores matrice]

## 🚀 Plan d'Implémentation (phases tabulaires)

## 🎯 Critères de Succès & Validation (métriques SMART)

## 🔗 Traçabilité & Liens (ADRs/Issues/PRs)
```

### Numérotation et Convention de Nommage

#### Format Hybride (Numéro + Catégorie + Titre)

**Format standard** : `XXX-CATÉGORIE-titre-kebab-case.md`

**Structure**:
- `XXX` : Numéro séquentiel sur 3 chiffres (000-999), **par plage de catégorie**
- `CATÉGORIE` : Préfixe optionnel domaine en UPPER-CASE (4-6 lettres)
- `titre-kebab-case` : Titre descriptif en minuscules avec tirets

**Exemples propres au projet**:
```
000-META-processus-creation-adr.md              # Méta-ADR
100-ARCH-modes-execution-ssh-vs-run-command.md  # Architecture du validator
200-INFRA-az-vm-run-command-invoke.md           # Cible d'exécution Azure
300-SEC-exigences-hardening-testees.md          # Contrôles de sécurité validés
400-DATA-format-rapport-pass-fail-warn.md       # Format de sortie des tests
500-API-reusable-github-workflow-call.md        # API d'intégration callers
600-DEVOPS-makefile-orchestrateur.md            # Makefile et scripts
700-TEST-mapping-policies-200-3-3.md            # Mapping tests ↔ policies Microsoft
800-BIZ-sources-officielles-marketplace.md      # Référentiel anti-hallucination
```

#### Préfixes Catégories Standards

**Plages de numérotation réservées par préfixe** :

| Préfixe | Plage | Domaine | Usage |
|---------|-------|---------|-------|
| `META` | 000-099 | Méta-processus | ADRs sur le processus ADR lui-même |
| `ARCH` | 100-199 | Architecture | Design du validator : modes d'exécution, adaptateurs distro, plugin model |
| `INFRA` | 200-299 | Infrastructure | Cible Azure : `az vm run-command`, identités managées, scopes RG |
| `SEC` | 300-399 | Sécurité | Contrôles validés côté VM testée (SSH, TLS, hardening) |
| `DATA` | 400-499 | Données | Format des rapports, archivage des preuves, structure JSON/Markdown |
| `API` | 500-599 | APIs | Surface d'intégration : reusable workflow, submodule, npm |
| `DEVOPS` | 600-699 | DevOps | Makefile, scripts, nomenclature, version bump, couleurs |
| `TEST` | 700-799 | Tests & QA | **Cœur du projet** : mapping policies, taxonomie, conventions PASS/FAIL/WARN |
| `BIZ` | 800-899 | Business | Sources officielles Microsoft, conformité licences, versionnage policies |

**Règle catégorie obligatoire** : Utiliser le préfixe correspondant à la plage de numérotation. Si multi-domaines, choisir le domaine principal et utiliser la classification YAML pour les domaines secondaires.

#### Séquence Numérotation

- **Plages** : Chaque catégorie a sa plage réservée de 100 numéros
- **ADR 000** : Ce document (méta-ADR sur le processus)
- **Séquence par plage** : 000-001-002... (META), 100-101-102... (ARCH), 600-601-602... (DEVOPS)
- **Ordre de création** : Chronologique **au sein de chaque catégorie**

### États Possibles (Lifecycle)

| Emoji | État | Description | YAML Value |
|-------|------|-------------|------------|
| 🔄 | Brouillon | En cours de rédaction | `draft` |
| 🔄 | Proposé | Prêt pour revue/validation | `proposed` |
| ✅ | Accepté | Décision approuvée et appliquée | `accepted` |
| ❌ | Rejeté | Proposition refusée (archivée) | `rejected` |
| ⚠️ | Déprécié | Remplacé par un ADR plus récent | `deprecated` |
| ➡️ | Supersédé | Remplacé (référencer l'ADR qui remplace) | `superseded` |

### 🗂️ Taxonomie de Classification

Chaque ADR doit inclure une classification complète dans le frontmatter YAML:

#### 1. **Lifecycle** (Cycle de vie)
- `draft` → `proposed` → `accepted` / `rejected`
- `deprecated` / `superseded` (pour ADRs obsolètes)

#### 2. **Domain** (Domaine architectural)
- `meta`: Gouvernance ADR, conventions documentaires, règles de contribution
- `architecture`: Modes d'exécution (SSH vs `run-command`), modèle d'extension distro
- `infrastructure`: Cible Azure (`az vm run-command`, RG, identités managées, scopes)
- `security`: Contrôles SSH/TLS/hardening **testés** sur la VM cible
- `data`: Format des rapports (Markdown, JSON), archivage, preuves de soumission
- `api`: Surface d'intégration callers (reusable workflow, submodule, sparse-checkout)
- `devops`: Makefile, scripts, nomenclature, version bump, couleurs
- `test`: **Cœur du projet** — taxonomie, mapping policies, PASS/FAIL/WARN
- `business`: Sources officielles Microsoft, anti-hallucination, licences

#### 3. **Impact** (Niveau d'impact)
- `low`: Local, facilement réversible
- `medium`: Plusieurs composants, effort modéré
- `high`: Système-wide, breaking change possible
- `critical`: Fondamental, irréversible

#### 4. **Quality Attributes** (ASR - ISO 25010)
- `performance`: Temps total d'une passe de validation, parallélisation
- `security`: Robustesse du runner (pas d'injection, pas de leak de secrets)
- `reliability`: Idempotence des tests, déterminisme PASS/FAIL/WARN
- `maintainability`: Ajout d'un nouveau test, support multi-distros
- `cost`: Coût d'une passe Azure (`run-command` minutes, RG de test)
- `usability`: Developer/operator experience côté projet appelant
- `compliance`: Alignement strict sur les politiques Microsoft Marketplace
- `portability`: Réutilisabilité par toute offre VM Linux (Ubuntu, RHEL, AlmaLinux…)

#### 5. **Reversibility** (Facilité de changement)
- `easy`: < 1 jour, aucune dépendance
- `moderate`: 1-5 jours, dépendances locales
- `hard`: > 1 semaine, dépendances multiples
- `irreversible`: Migration impossible ou prohibitive

#### 6. **Scope** (Portée)
- `strategic`: Vision long terme, organisation-wide
- `tactical`: Implémentation spécifique, projet-wide
- `operational`: Choix techniques locaux, component-level

#### 7. **Tech Areas** (Domaines technologiques)
- Exemples pertinents : `azure`, `az-cli`, `vm`, `vm-offer`, `partner-center`, `marketplace`, `bash`, `shellcheck`, `make`, `github-actions`, `tls`, `ssh`, `systemd`, `walinuxagent`, `hyper-v`

### Processus de Création

#### 1. Identifier le Besoin

Un ADR est requis quand :

- ✅ Décision architecturale significative (mode d'exécution, format de rapport, surface API)
- ✅ Choix ayant des conséquences à long terme
- ✅ Alternatives multiples existantes nécessitant justification
- ✅ Décision affectant plusieurs composants ou projets appelants
- ✅ Choix non évident nécessitant explication
- ✅ Interprétation d'une politique Microsoft Marketplace ambiguë

Un ADR n'est **pas** requis pour :

- ❌ Décisions triviales ou de routine
- ❌ Choix sans alternative viable
- ❌ Décisions temporaires ou expérimentales
- ❌ Préférences de style de code (utiliser linter)

#### 2. Créer le Fichier

**Procédure création**:

```bash
cd docs/adr

# 1. Déterminer la catégorie dominante de la décision
# Exemple: Décision sur taxonomie de tests → TEST (bloc 700)

# 2. Trouver le prochain numéro disponible dans le bloc
ls -1 7*.md | tail -1  # Dernier TEST (ex: 700)

# 3. Créer avec numéro suivant + préfixe catégorie
cp adr-template-ai-optimized.md 701-TEST-nouvelle-decision.md

# 4. ⚠️ OBLIGATOIRE : Mettre à jour l'index des ADRs
#    Ajouter l'entrée dans la table de la catégorie appropriée
vi README.md
```

> **📋 Rappel** : La mise à jour de [`docs/adr/README.md`](./README.md) est **obligatoire** à chaque création d'ADR.
> Un ADR absent de l'index est invisible pour l'équipe et les agents IA. Voir [étape 5 — Référencement](#5-référencement) pour la procédure complète.

#### 3. Rédiger l'ADR

**Ordre de rédaction recommandé** :

1. **Frontmatter YAML** : Remplir métadonnées + classification complète
2. **Contexte** : Décrire le problème avec questions guidées
3. **Alternatives** : Lister options avec matrice décision quantifiée (scores/10)
4. **Décision** : Solution choisie + principes architecturaux
5. **Conséquences** : Impacts avec métriques quantifiées
6. **Plan implémentation** : Phases tabulaires avec dépendances
7. **Critères succès** : Métriques SMART + triggers review
8. **Traçabilité** : Liens bidirectionnels ADRs/Issues/PRs

**Conseils de rédaction** :

- ✍️ Écrire au **présent** : "Nous décidons" (pas "Nous avons décidé")
- 🎯 Être **spécifique** : Noms de technologies, versions, configurations
- 📊 **Quantifier** : Scores matrice décision, métriques succès
- 📈 **Tableaux structurés** : Facilite parsing automatique par agents IA
- 🔗 **Référencer** : Liens vers docs externes, autres ADRs, code annoté `@ADR`
- ⚖️ Rester **objectif** : Présenter les faits, pas les opinions
- 🗂️ **Classifier** : Remplir taxonomie complète (domain, impact, quality, etc.)

#### 4. Revue et Validation

**Lifecycle ADR** :
- **Brouillon** (`draft`) : Rédaction initiale, peut contenir TODOs
- **Proposé** (`proposed`) : Prêt pour discussion avec l'équipe
- **Accepté** (`accepted`) : Décision finale, implémentation peut commencer

**Critères de validation** :
- ✅ Frontmatter YAML complet et valide
- ✅ Classification taxonomie remplie (7 dimensions)
- ✅ Matrice décision quantifiée (si alternatives)
- ✅ Métriques succès SMART définies
- ✅ Aucun placeholder `[...]` restant
- ✅ Review par au moins 1 stakeholder (pour impact `high`/`critical`)

#### 5. Référencement

> **⚠️ Rappel Important**: Cette étape est **obligatoire** mais **fréquemment omise**.  
> Un ADR non référencé dans le README est **invisible** pour les nouveaux développeurs et l'IA.

##### 5.1. Mettre à jour `docs/adr/README.md`

Ajouter l'entrée dans la table de la catégorie appropriée et mettre à jour les statistiques.

##### 5.2. Checklist Référencement

Avant de commiter, vérifier :

- [ ] ✅ Entrée ajoutée dans `docs/adr/README.md` (table principale)
- [ ] ✅ **Statistiques** mises à jour (total, par domaine)
- [ ] ✅ `README.md` (racine) mis à jour si impact `high`/`critical`

#### 6. Commit Git

```bash
git add docs/adr/XXX-CATÉGORIE-*.md docs/adr/README.md
git commit -m "docs(adr): ADR-XXX [CATÉGORIE] Titre court

Classification:
- Domain: infrastructure
- Impact: high
- Scope: tactical

Référence: #issue (si applicable)"
```

### Modification des ADR Existants

**Ne JAMAIS modifier** un ADR accepté pour changer la décision :

1. Créer un **nouvel ADR** avec la nouvelle décision
2. Marquer l'ancien ADR comme **Supersédé** (➡️)
3. Ajouter référence croisée entre les deux ADRs

## Conséquences

### Positives ✅

- **Traçabilité** : Historique complet des décisions architecturales
- **Onboarding** : Nouveaux contributeurs comprennent rapidement les choix
- **Cohérence** : Format standard facilite la recherche et compréhension
- **Réutilisabilité** : Décisions explicites facilitent l'adoption par les projets appelants
- **Documentation vivante** : ADRs évoluent avec le code dans le même repo

### Négatives ⚠️

- **Overhead initial** : Temps requis pour rédiger un ADR (~30-60 minutes)
- **Discipline requise** : Nécessite rigueur pour maintenir la pratique

### Mitigations 🔧

- **Template pré-rempli** : `adr-template-ai-optimized.md` accélère la rédaction
- **Critères clairs** : Section "Identifier le Besoin" guide quand créer un ADR

## 🚀 Plan d'Implémentation

| Phase | Durée | Deliverables | Status |
|-------|-------|--------------|--------|
| **Phase 1: Fondation** | 1 jour | ADR-000, TAXONOMY, template | ✅ Complété |
| **Phase 2: ADRs Initiaux** | 1-2 semaines | ADRs architecture principale | 🔄 En cours |
| **Phase 3: Automation** | À planifier | Scripts validation + CI check | 📋 Backlog |

## 🎯 Critères de Succès

| Métrique | Valeur Cible |
|----------|--------------|
| ADRs avec frontmatter YAML | 100% |
| Conformité taxonomie | ≥ 90% |
| Temps création ADR | < 60 min |

---

## 📚 Références

- [Architecture Decision Records](https://adr.github.io/)
- [Michael Nygard - Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [Azure Well-Architected Framework - ADRs](https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record)
- [Microsoft Azure Marketplace VM Offer Requirements](https://learn.microsoft.com/en-us/azure/marketplace/azure-vm-offer-setup)
- [Microsoft Marketplace Certification Policies](https://learn.microsoft.com/en-us/legal/marketplace/certification-policies)

---

## 📝 Notes & Historique

| Date | Auteur | Changement | Raison |
|------|--------|------------|--------|
| 2026-02-21 | @architecture-team | Création initiale du cadre ADR | Formaliser la gouvernance documentaire et les règles de décision |
| 2026-06-17 | @architecture-team | Adaptation au projet azure-marketplace-vm-validator | Recentrage sur la validation de conformité Azure Marketplace VM Offer, retrait des références applicatives spécifiques |
