---
# 🤖 Machine-Readable Metadata (Frontmatter YAML)
adr: 601
title: "Nomenclature des scripts de test — test_<id>_<area>.sh"
status: "accepted"
date: 2026-06-17
superseded_by: null
replaces: "docs/adr/0002-test-naming.md (ancien format pré-bootstrap)"
related_adrs: [0, 700]
related_issues: [2]

# 🗂️ Taxonomie ADR
classification:
  lifecycle: "accepted"
  domain: "devops"
  impact: "medium"
  quality:
    - "maintainability"
    - "usability"
    - "reliability"
  reversibility: "easy"
  scope: "tactical"
  tech_areas:
    - "bash"
    - "shell-script"
    - "make"

tags: ["naming-convention", "tests", "conformance", "ordering"]
stakeholders: ["@architecture-team", "@dev-team"]
effort: "low"
---

# ADR 601: Nomenclature des scripts de test — `test_<id>_<area>.sh`

## 📊 Vue d'Ensemble

| Attribut | Valeur |
|----------|--------|
| **Statut** | ✅ Accepté |
| **Date Décision** | 2026-06-17 |
| **Stakeholders** | @architecture-team, @dev-team |
| **Impact** | 🟡 Moyen |
| **Effort Implémentation** | 🟢 Faible |
| **Risque Technique** | 🟢 Faible |

---

## 🎯 Contexte & Problème

Les contrôles de conformité du validator sont implémentés sous forme de fichiers Bash indépendants dans `tests/` (voir [ADR-700](./700-TEST-taxonomie-tests-par-chapitre-200.md)). Sans convention de nommage stricte :

- l'ordre d'exécution (énumération via `find ... | sort`) devient imprévisible ;
- l'intention d'un fichier (quelle exigence, quel chapitre Microsoft) n'est pas lisible au premier coup d'œil ;
- la corrélation entre un fichier de test et la clause de policy qu'il couvre se perd.

Cet ADR formalise une décision **déjà appliquée** dans le dépôt (ancien `0002-test-naming.md`), perdue lors de la migration vers le système ADR numéroté.

---

## ✅ Décision

### Approche Choisie

Tout script de test suit le motif :

```
test_<id>_<area>.sh
```

- **`<id>`** : identifiant numérique encodant le chapitre de la policy Microsoft (ex. `2003` → 200.3.3, `2004` → 200.4, `2005` → 200.5). Le tri lexicographique garantit un **ordre stable**.
- **`<area>`** : zone fonctionnelle courte en `snake_case` exprimant **l'intention** (ex. `walinuxagent`, `ssh_hardening`, `no_zipbomb`, `kernel_cmdline`).

**Exemples réels du dépôt** :

```
test_2003_walinuxagent.sh
test_2003_cloudinit.sh
test_2003_hyperv_drivers.sh
test_2004_kernel_cmdline.sh
test_2004_no_zipbomb.sh
test_2005_no_pending_security_updates.sh
```

### Comment Cette Solution Résout le Problème

1. **Ordre stable** → le préfixe numérique trié donne une séquence déterministe.
2. **Intention explicite** → `<area>` décrit le contrôle sans ouvrir le fichier.
3. **Traçabilité** → `<id>` relie le fichier au chapitre Microsoft.

### Principes Architecturaux Appliqués

- ✅ **Determinisme**: ordre d'exécution reproductible.
- ✅ **Self-documenting**: le nom porte le sens.
- ✅ **Cohérence**: aligné sur la taxonomie ADR-700.

---

## 📊 Matrice de Décision Quantifiée

| Critère | Poids | Nom libre | `<area>_test.sh` | `test_<id>_<area>.sh` (choisi) | Notes |
|---------|-------|-----------|------------------|-------------------------------|-------|
| **Ordre stable** | 35% | 🔴 Faible (2/10) | 🟡 Moyen (5/10) | 🟢 Élevé (10/10) | Préfixe numérique |
| **Intention lisible** | 30% | 🟡 Moyen (5/10) | 🟢 Élevé (8/10) | 🟢 Élevé (9/10) | `<area>` explicite |
| **Traçabilité policy** | 25% | 🔴 Faible (2/10) | 🔴 Faible (3/10) | 🟢 Élevé (10/10) | `<id>` = chapitre |
| **Simplicité** | 10% | 🟢 Élevé (9/10) | 🟢 Élevé (8/10) | 🟢 Élevé (8/10) | Motif unique |
| **Score Total Pondéré** | 100% | **3.55** | **5.65** | **9.45** ⭐ | Winner |

```
Nom libre        : (2*0.35)+(5*0.30)+(2*0.25)+(9*0.10) = 3.60
<area>_test.sh   : (5*0.35)+(8*0.30)+(3*0.25)+(8*0.10) = 5.70
test_<id>_<area> : (10*0.35)+(9*0.30)+(10*0.25)+(8*0.10) = 9.50 ✅
```

---

## ⚖️ Conséquences

### ✅ Positives (Bénéfices)

| Bénéfice | Métrique Cible | Valeur Attendue | Mesure |
|----------|----------------|-----------------|--------|
| Ordre déterministe | Runs identiques | 100% | Exécutions répétées |
| Lisibilité | Intention sans ouverture | Immédiate | Revue de code |
| Corrélation policy | Chapitre depuis le nom | 1:1 | `docs/policy-mapping.md` |

### ⚠️ Négatives (Risques & Limitations)

| Risque | Impact | Probabilité | Mitigation | Responsable |
|--------|--------|-------------|------------|-------------|
| Collision d'`<id>` entre deux contrôles du même chapitre | 🟢 Faible | 🟡 Moyen | Distinguer via `<area>` | @dev-team |
| Mapping `<id>` ↔ clause non documenté | 🟡 Moyen | 🟡 Moyen | Maintenir `docs/policy-mapping.md` | @dev-team |

---

## 🔄 Alternatives Considérées

### Alternative 1: Nom libre (`walinuxagent.sh`)

**Rejetée parce que**: aucun ordre garanti, aucune corrélation au chapitre Microsoft. **Score**: 3.60/10.

### Alternative 2: Suffixe `<area>_test.sh`

**Rejetée parce que**: le tri ne reflète pas les chapitres, et la convention diverge des frameworks où le préfixe `test_` est idiomatique. **Score**: 5.70/10.

---

## 🚀 Plan d'Implémentation

| Phase | Durée | Deliverables | Statut |
|-------|-------|--------------|--------|
| **Phase 1: Convention** | — | Motif appliqué à tous les fichiers `tests/` | ✅ Complété (bootstrap) |
| **Phase 2: Lint** | À planifier | Garde CI refusant un nom non conforme | 📋 Backlog |

---

## 🎯 Critères de Succès & Validation

| Métrique | Valeur Cible |
|----------|--------------|
| Fichiers conformes au motif | 100% |
| Ordre d'exécution reproductible | 100% |

---

## 🔗 Traçabilité & Liens

- [ADR-000](./000-META-processus-creation-adr.md) — Processus ADR
- [ADR-700](./700-TEST-taxonomie-tests-par-chapitre-200.md) — Taxonomie des tests
- `CONTRIBUTING.md` — procédure d'ajout d'un test
- Roadmap : [issue #2](https://github.com/michel-heon/azure-marketplace-vm-validator/issues/2)

---

## 📝 Notes & Historique

| Date | Auteur | Changement | Raison |
|------|--------|------------|--------|
| 2026-06-17 | @architecture-team | Migration de l'ancien `0002-test-naming.md` vers le format ADR numéroté AI-optimized | Préserver la décision perdue lors du bootstrap du système ADR |
