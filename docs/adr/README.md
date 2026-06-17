# 📚 Architecture Decision Records (ADR) — azure-marketplace-vm-validator

**Index central** des décisions architecturales du projet **azure-marketplace-vm-validator**.

> Le projet fournit une **boîte à outils Bash réutilisable et project-agnostic** validant la conformité des images VM Linux publiées sur **Microsoft Azure Marketplace** vis-à-vis des [politiques de certification VM Offer (section 200)](https://learn.microsoft.com/en-us/legal/marketplace/certification-policies). Les contrôles s'exécutent à distance via `az vm run-command invoke` (aucune SSH entrante requise) afin de reproduire les contraintes des évaluateurs Partner Center.

---

## 🗂️ Documents du Système ADR

| Document | Description |
|----------|-------------|
| **[ADR-000](./000-META-processus-creation-adr.md)** | Processus et règles de création des ADRs |
| **[TAXONOMY.md](./TAXONOMY.md)** | Classification détaillée (7 dimensions) |
| **[adr-template-ai-optimized.md](./adr-template-ai-optimized.md)** | Template à copier pour un nouvel ADR |
| **[README.md](./README.md)** | Ce fichier (index et guide rapide) |

---

## ⚡ Créer un Nouvel ADR Rapidement

```bash
# 1. Identifier la catégorie de la décision (voir tableau Numérotation plus bas)
# 2. Trouver le prochain numéro disponible dans la plage
ls -1 docs/adr/7*.md | tail -1   # Exemple: bloc TEST (700-799)

# 3. Créer le fichier depuis le template
cp docs/adr/adr-template-ai-optimized.md docs/adr/701-TEST-nouvelle-decision.md

# 4. Rédiger, committer et mettre à jour ce README
git add docs/adr/701-TEST-nouvelle-decision.md docs/adr/README.md
git commit -m "docs(adr): ADR-701 [TEST] Nouvelle décision"
```

---

## 📋 Index des ADRs par Catégorie

### 🔧 META — Méta-processus (000-099)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [000](./000-META-processus-creation-adr.md) | Processus de Création et Gestion des ADR | ✅ Accepté | 2026-02-21 | Gouvernance |

---

### 🏗️ ARCH — Architecture (100-199)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [100](./100-ARCH-contrat-adapter-distro.md) | Contrat d'interface des adapters distro | ✅ Accepté | 2026-06-17 | Architecture |

---

### ☁️ INFRA — Infrastructure Azure (200-299)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| *(aucun ADR pour l'instant)* | | | | |

---

### 🔒 SEC — Sécurité (300-399)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| *(aucun ADR pour l'instant)* | | | | |

---

### 🗄️ DATA — Données & Rapports (400-499)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| *(aucun ADR pour l'instant)* | | | | |

---

### 🔌 API — Intégrations & Interfaces (500-599)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| *(aucun ADR pour l'instant)* | | | | |

---

### ⚙️ DEVOPS — DevOps & CI/CD (600-699)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [601](./601-DEVOPS-nomenclature-scripts-de-test.md) | Nomenclature des scripts de test — `test_<id>_<area>.sh` | ✅ Accepté | 2026-06-17 | DevOps |
| [608](./608-DEVOPS-frontiere-non-duplication-workload-agnostic.md) | Frontière de non-duplication — uniquement des contrôles workload-agnostic | ✅ Accepté | 2026-06-17 | DevOps |
| [611](./611-DEVOPS-conventions-couleurs-pass-fail-warn.md) | Conventions de couleurs de sortie — PASS/WARN/FAIL/INFO via `printf` + ANSI | ✅ Accepté | 2026-06-17 | DevOps |

---

### 🧪 TEST — Tests & Validation (700-799)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| [700](./700-TEST-taxonomie-tests-par-chapitre-200.md) | Taxonomie des tests — un fichier par exigence, groupés par chapitre 200.x | ✅ Accepté | 2026-06-17 | Tests & validation |

---

### 💼 BIZ — Sources officielles & Conformité (800-899)

| ADR | Titre | Statut | Date | Domaine |
|-----|-------|--------|------|---------|
| *(aucun ADR pour l'instant)* | | | | |

---

## 📊 Statistiques

| Indicateur | Valeur |
|-----------|--------|
| **Total ADRs** | 6 |
| **Acceptés** | 5 |
| **Dépréciés** | 0 |
| **Proposés** | 0 |
| **Brouillons** | 0 |
| **Par Domaine** | META: 1, DEVOPS: 3, TEST: 1 |

---

## 🔍 Numérotation par Catégorie

| Préfixe | Plage | Domaine | Prochains disponibles |
|---------|-------|---------|----------------------|
| `META` | 000-099 | Méta-processus | 001 |
| `ARCH` | 100-199 | Architecture du validator (modes d'exécution, adapter distro, plugin model) | 100 |
| `INFRA` | 200-299 | Cible Azure (`az vm run-command`, identités managées, scopes RG) | 200 |
| `SEC` | 300-399 | Contrôles SSH/TLS/hardening testés sur la VM cible | 300 |
| `DATA` | 400-499 | Format des rapports (PASS/FAIL/WARN, JSON, JUnit XML) | 400 |
| `API` | 500-599 | Surface d'intégration (reusable workflow, submodule, sparse-checkout) | 500 |
| `DEVOPS` | 600-699 | Makefile, scripts, nomenclature, version bump, couleurs | 602 |
| `TEST` | 700-799 | **Cœur du projet** — mapping policies 200.x, taxonomie, PASS/FAIL/WARN | 701 |
| `BIZ` | 800-899 | Sources officielles Microsoft, anti-hallucination, versionnage policies | 800 |

---

## 🏷️ Statuts

| Emoji | Statut | Description |
|-------|--------|-------------|
| 🔄 | Brouillon / Proposé | En cours de rédaction ou en attente de validation |
| ✅ | Accepté | Décision approuvée et implémentée |
| ❌ | Rejeté | Proposition refusée (archivée pour référence) |
| ⚠️ | Déprécié | Obsolète, non remplacé |
| ➡️ | Supersédé | Remplacé par un ADR plus récent |

---

## 🔗 Ressources Projet

- [Microsoft Azure Marketplace VM Offer](https://learn.microsoft.com/en-us/azure/marketplace/azure-vm-offer-setup)
- [Microsoft Marketplace Certification Policies — section 200](https://learn.microsoft.com/en-us/legal/marketplace/certification-policies#200-virtual-machines)
- [Azure VM Certification FAQ](https://learn.microsoft.com/en-us/partner-center/marketplace-offers/azure-vm-certification-faq)
- [`az vm run-command invoke` reference](https://learn.microsoft.com/en-us/cli/azure/vm/run-command#az-vm-run-command-invoke)
- [User Story — RU-CTT (FR)](../../user-stories/RU-CTT-fr.md) / [(EN)](../../user-stories/RU-CTT-en.md)

---

_Mise à jour : 2026-06-17_
