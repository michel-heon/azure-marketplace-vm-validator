---
# 🤖 Machine-Readable Metadata (Frontmatter YAML)
adr: 700
title: "Taxonomie des tests — un fichier par exigence, groupés par chapitre 200.x"
status: "accepted"
date: 2026-06-17
superseded_by: null
replaces: "docs/adr/0001-taxonomy.md (ancien format pré-bootstrap)"
related_adrs: [0, 601, 608]
related_issues: [2]

# 🗂️ Taxonomie ADR
classification:
  lifecycle: "accepted"
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

tags: ["azure-marketplace", "vm-offer", "certification", "taxonomy", "policy-mapping"]
stakeholders: ["@architecture-team", "@dev-team"]
effort: "low"
---

# ADR 700: Taxonomie des tests — un fichier par exigence, groupés par chapitre 200.x

## 📊 Vue d'Ensemble

| Attribut | Valeur |
|----------|--------|
| **Statut** | ✅ Accepté |
| **Date Décision** | 2026-06-17 |
| **Stakeholders** | @architecture-team, @dev-team |
| **Impact** | 🔴 Élevé |
| **Effort Implémentation** | 🟢 Faible |
| **Risque Technique** | 🟢 Faible |

---

## 🎯 Contexte & Problème

Le projet **azure-marketplace-vm-validator** doit prouver, de manière vérifiable et auditable, la conformité d'une image VM Linux aux [politiques de certification Azure Marketplace — section 200](https://learn.microsoft.com/en-us/legal/marketplace/certification-policies#200-virtual-machines). Ces politiques sont structurées en chapitres normatifs (200.2, 200.3.3, 200.4, 200.5, 200.6).

Sans organisation explicite des tests :

- la traçabilité test ↔ exigence Microsoft devient floue (un évaluateur Partner Center ne peut pas relier un échec à une clause) ;
- un seul gros script monolithique est difficile à maintenir et à exécuter sélectivement ;
- l'ajout d'un nouveau contrôle ou la couverture d'une nouvelle clause n'a pas de point d'ancrage évident.

Cet ADR formalise une décision **déjà appliquée** dans le dépôt depuis son bootstrap (ancien `0001-taxonomy.md`), perdue lors de la migration vers le système ADR numéroté, et la réintègre au format AI-optimized.

---

## ✅ Décision

### Approche Choisie

Nous adoptons le principe **« une exigence = un fichier de test »**, les fichiers étant **groupés par chapitre de certification** Microsoft (200.2, 200.3.3, 200.4, 200.5, 200.6).

Chaque test :

- réside dans `tests/` sous la forme `test_<id>_<area>.sh` (voir [ADR-601](./601-DEVOPS-nomenclature-scripts-de-test.md)) où `<id>` encode le chapitre (ex. `2003`, `2004`, `2005`) ;
- couvre **une seule** clause / exigence (single responsibility) ;
- source `lib/_common.sh` et s'appuie sur les helpers `ctt_remote_*` ;
- s'exécute exclusivement via `az vm run-command invoke` ;
- retourne `0` pour PASS/WARN, non-zéro pour FAIL.

### Comment Cette Solution Résout le Problème

1. **Traçabilité Microsoft** → l'`<id>` du fichier renvoie directement au chapitre de la policy.
2. **Maintenabilité** → ajouter une exigence = ajouter un fichier, sans toucher aux autres.
3. **Exécution sélective** → `ctt.sh test <name>` rejoue un contrôle isolé.

### Principes Architecturaux Appliqués

- ✅ **Single responsibility**: un fichier ne valide qu'une exigence.
- ✅ **Compliance-driven**: la structure reflète la table des matières de la policy 200.
- ✅ **Project-agnostic**: aucun test ne dépend d'une pile applicative (voir [ADR-608](./608-DEVOPS-frontiere-non-duplication-workload-agnostic.md)).
- ✅ **Découvrabilité**: `ctt.sh` énumère automatiquement `tests/test_*.sh`.

---

## 📊 Matrice de Décision Quantifiée

| Critère | Poids | Script monolithique | Groupé par catégorie technique | Un fichier / exigence par chapitre (choisi) | Notes |
|---------|-------|---------------------|-------------------------------|---------------------------------------------|-------|
| **Traçabilité policy 200.x** | 35% | 🔴 Faible (3/10) | 🟡 Moyen (6/10) | 🟢 Élevé (10/10) | Lien direct clause↔fichier |
| **Maintenabilité** | 30% | 🔴 Faible (3/10) | 🟢 Élevé (8/10) | 🟢 Élevé (9/10) | Ajout sans régression |
| **Exécution sélective** | 20% | 🔴 Faible (2/10) | 🟡 Moyen (6/10) | 🟢 Élevé (10/10) | `test <name>` |
| **Lisibilité contributeur** | 15% | 🟡 Moyen (5/10) | 🟢 Élevé (8/10) | 🟢 Élevé (9/10) | Intention explicite |
| **Score Total Pondéré** | 100% | **3.05** | **7.10** | **9.55** ⭐ | Winner |

```
Monolithique : (3*0.35)+(3*0.30)+(2*0.20)+(5*0.15) = 3.05
Par technique : (6*0.35)+(8*0.30)+(6*0.20)+(8*0.15) = 7.10
Par exigence  : (10*0.35)+(9*0.30)+(10*0.20)+(9*0.15) = 9.55 ✅
```

---

## ⚖️ Conséquences

### ✅ Positives (Bénéfices)

| Bénéfice | Métrique Cible | Valeur Attendue | Mesure |
|----------|----------------|-----------------|--------|
| Traçabilité Microsoft | Clauses 200.x mappées | 1 fichier ↔ 1 clause | `docs/policy-mapping.md` (futur) |
| Maintenabilité | Couplage entre tests | Nul | Revue de code |
| Exécution ciblée | Re-run d'un contrôle | < 1 commande | `make test TEST=...` |

### ⚠️ Négatives (Risques & Limitations)

| Risque | Impact | Probabilité | Mitigation | Responsable |
|--------|--------|-------------|------------|-------------|
| Prolifération de petits fichiers | 🟢 Faible | 🟡 Moyen | Convention de nommage stricte (ADR-601) | @dev-team |
| Clause Microsoft couvrant plusieurs chapitres | 🟡 Moyen | 🟢 Faible | Choisir le chapitre dominant + commentaire de renvoi | @dev-team |

---

## 🔄 Alternatives Considérées

### Alternative 1: Script monolithique unique

**Description**: Un seul `ctt.sh` contenant tous les contrôles en séquence.

**Rejetée parce que**: aucune traçabilité fine, exécution sélective impossible, maintenance lourde. **Score**: 3.05/10.

### Alternative 2: Regroupement par catégorie technique (réseau, sécurité, services)

**Description**: Fichiers groupés par thème technique plutôt que par chapitre de policy.

**Rejetée parce que**: le découpage ne suit pas la structure officielle Microsoft, ce qui complique la preuve de conformité face à un évaluateur. **Score**: 7.10/10.

---

## 🚀 Plan d'Implémentation

| Phase | Durée | Deliverables | Statut |
|-------|-------|--------------|--------|
| **Phase 1: Convention** | — | Principe un-fichier-par-exigence appliqué dans `tests/` | ✅ Complété (bootstrap) |
| **Phase 2: Couverture 200.x** | 1 semaine | Tests manquants par chapitre + `docs/policy-mapping.md` | 📋 Backlog (issue #2) |

---

## 🎯 Critères de Succès & Validation

| Métrique | Valeur Cible |
|----------|--------------|
| Tests respectant `test_<id>_<area>.sh` | 100% |
| Clauses 200.x automatisables couvertes | ≥ 90% |
| Tests à responsabilité unique | 100% |

---

## 🔗 Traçabilité & Liens

- [ADR-000](./000-META-processus-creation-adr.md) — Processus ADR
- [ADR-601](./601-DEVOPS-nomenclature-scripts-de-test.md) — Nomenclature `test_<id>_<area>.sh`
- [ADR-608](./608-DEVOPS-frontiere-non-duplication-workload-agnostic.md) — Frontière de non-duplication
- [Microsoft Marketplace Certification Policies — 200](https://learn.microsoft.com/en-us/legal/marketplace/certification-policies#200-virtual-machines)
- Roadmap : [issue #2](https://github.com/michel-heon/azure-marketplace-vm-validator/issues/2)

---

## 📝 Notes & Historique

| Date | Auteur | Changement | Raison |
|------|--------|------------|--------|
| 2026-06-17 | @architecture-team | Migration de l'ancien `0001-taxonomy.md` vers le format ADR numéroté AI-optimized | Préserver la décision perdue lors du bootstrap du système ADR |
