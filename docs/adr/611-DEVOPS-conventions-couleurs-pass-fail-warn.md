---
# 🤖 Machine-Readable Metadata (Frontmatter YAML)
adr: 611
title: "Conventions de couleurs de sortie — PASS/WARN/FAIL/INFO via printf + ANSI"
status: "accepted"
date: 2026-06-17
superseded_by: null
replaces: "docs/adr/0004-color-conventions.md (ancien format pré-bootstrap)"
related_adrs: [0, 700, 601]
related_issues: []

# 🗂️ Taxonomie ADR
classification:
  lifecycle: "accepted"
  domain: "devops"
  impact: "low"
  quality:
    - "usability"
    - "maintainability"
    - "reliability"
  reversibility: "easy"
  scope: "operational"
  tech_areas:
    - "bash"
    - "shell-script"
    - "pass-fail-warn"

tags: ["color-conventions", "output", "ux", "printf", "ansi"]
stakeholders: ["@dev-team"]
effort: "low"
---

# ADR 611: Conventions de couleurs de sortie — PASS/WARN/FAIL/INFO via `printf` + ANSI

## 📊 Vue d'Ensemble

| Attribut | Valeur |
|----------|--------|
| **Statut** | ✅ Accepté |
| **Date Décision** | 2026-06-17 |
| **Stakeholders** | @dev-team |
| **Impact** | 🟢 Faible |
| **Effort Implémentation** | 🟢 Faible |
| **Risque Technique** | 🟢 Faible |

---

## 🎯 Contexte & Problème

La sortie du validator doit être **immédiatement lisible** par un opérateur qui scanne un long rapport de conformité, et **parsable** de façon fiable par la CI. Sans convention :

- les statuts (succès, avertissement, échec) se ressemblent visuellement ;
- l'usage de `echo -e` (non portable selon le shell) produit des séquences ANSI littérales ou des comportements divergents ;
- les couleurs sont réinventées d'un script à l'autre, créant de l'incohérence.

Cet ADR formalise une décision **déjà appliquée** dans `lib/_common.sh` (ancien `0004-color-conventions.md`), perdue lors de la migration vers le système ADR numéroté.

---

## ✅ Décision

### Approche Choisie

La sortie de statut utilise **`printf`** (jamais `echo -e`) avec des **codes couleur ANSI**, selon le code suivant :

| Statut | Couleur | Code ANSI | Helper |
|--------|---------|-----------|--------|
| **PASS** | 🟢 Vert | `\033[32m` | `ctt_pass` |
| **WARN** | 🟡 Jaune | `\033[33m` | `ctt_warn` |
| **FAIL** | 🔴 Rouge | `\033[31m` | `ctt_fail` |
| **INFO** | 🔵 Bleu | `\033[34m` | `ctt_info` |

Tous les helpers résident dans `lib/_common.sh` et incrémentent les compteurs `CTT_PASS` / `CTT_WARN` / `CTT_FAIL` pour le récapitulatif `ctt_summary`.

### Comment Cette Solution Résout le Problème

1. **Lisibilité** → un échec rouge ressort instantanément dans un long flux.
2. **Portabilité** → `printf` se comporte de façon identique sur tout shell POSIX, contrairement à `echo -e`.
3. **Cohérence** → une seule définition partagée, pas de réinvention.

### Principes Architecturaux Appliqués

- ✅ **Portabilité shell**: `printf` exclusivement.
- ✅ **DRY**: couleurs et helpers centralisés dans `lib/_common.sh`.
- ✅ **Observabilité**: compteurs PASS/WARN/FAIL pour le résumé machine et humain.

---

## 📊 Matrice de Décision Quantifiée

| Critère | Poids | `echo -e` + couleurs ad hoc | Pas de couleur | `printf` + ANSI centralisé (choisi) | Notes |
|---------|-------|-----------------------------|----------------|-------------------------------------|-------|
| **Lisibilité opérateur** | 35% | 🟡 Moyen (6/10) | 🔴 Faible (3/10) | 🟢 Élevé (9/10) | Couleurs sémantiques |
| **Portabilité shell** | 30% | 🔴 Faible (3/10) | 🟢 Élevé (9/10) | 🟢 Élevé (9/10) | `printf` POSIX |
| **Cohérence** | 20% | 🔴 Faible (3/10) | 🟢 Élevé (8/10) | 🟢 Élevé (9/10) | Source unique |
| **Simplicité** | 15% | 🟢 Élevé (8/10) | 🟢 Élevé (9/10) | 🟢 Élevé (8/10) | Helpers triviaux |
| **Score Total Pondéré** | 100% | **4.65** | **7.05** | **8.85** ⭐ | Winner |

```
echo -e ad hoc : (6*0.35)+(3*0.30)+(3*0.20)+(8*0.15) = 4.80
Pas de couleur : (3*0.35)+(9*0.30)+(8*0.20)+(9*0.15) = 6.70
printf + ANSI  : (9*0.35)+(9*0.30)+(9*0.20)+(8*0.15) = 8.85 ✅
```

---

## ⚖️ Conséquences

### ✅ Positives (Bénéfices)

| Bénéfice | Métrique Cible | Valeur Attendue | Mesure |
|----------|----------------|-----------------|--------|
| Lisibilité | Temps de repérage d'un FAIL | Immédiat | Revue opérateur |
| Portabilité | Comportement inter-shells | Identique | Test bash/dash |
| Cohérence | Définitions couleur dupliquées | 1 (centralisée) | Audit `lib/` |

### ⚠️ Négatives (Risques & Limitations)

| Risque | Impact | Probabilité | Mitigation | Responsable |
|--------|--------|-------------|------------|-------------|
| Sortie ANSI dans un log non-TTY (CI) | 🟢 Faible | 🟡 Moyen | Codes inoffensifs ; option future `NO_COLOR` | @dev-team |

---

## 🔄 Alternatives Considérées

### Alternative 1: `echo -e` avec couleurs définies dans chaque script

**Rejetée parce que**: `echo -e` n'est pas portable (dash l'ignore) et la duplication mène à l'incohérence. **Score**: 4.80/10.

### Alternative 2: Sortie monochrome

**Rejetée parce que**: portable mais nuit fortement à la lisibilité d'un long rapport de conformité. **Score**: 6.70/10.

---

## 🚀 Plan d'Implémentation

| Phase | Durée | Deliverables | Statut |
|-------|-------|--------------|--------|
| **Phase 1: Helpers couleur** | — | `ctt_pass/warn/fail/info` dans `lib/_common.sh` | ✅ Complété (bootstrap) |
| **Phase 2: Support `NO_COLOR`** | À planifier | Désactivation couleur si non-TTY ou `NO_COLOR` | 📋 Backlog |

---

## 🎯 Critères de Succès & Validation

| Métrique | Valeur Cible |
|----------|--------------|
| Scripts utilisant `printf` (jamais `echo -e`) | 100% |
| Définitions couleur centralisées | 1 source |

---

## 🔗 Traçabilité & Liens

- [ADR-000](./000-META-processus-creation-adr.md) — Processus ADR
- [ADR-601](./601-DEVOPS-nomenclature-scripts-de-test.md) — Nomenclature des tests
- `lib/_common.sh` — implémentation des helpers `ctt_pass/warn/fail/info`
- [NO_COLOR convention](https://no-color.org/) — standard de désactivation des couleurs

---

## 📝 Notes & Historique

| Date | Auteur | Changement | Raison |
|------|--------|------------|--------|
| 2026-06-17 | @dev-team | Migration de l'ancien `0004-color-conventions.md` vers le format ADR numéroté AI-optimized | Préserver la décision perdue lors du bootstrap du système ADR |
