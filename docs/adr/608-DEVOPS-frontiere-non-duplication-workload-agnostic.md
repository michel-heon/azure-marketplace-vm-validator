---
# 🤖 Machine-Readable Metadata (Frontmatter YAML)
adr: 608
title: "Frontière de non-duplication — uniquement des contrôles workload-agnostic"
status: "accepted"
date: 2026-06-17
superseded_by: null
replaces: "docs/adr/0003-non-duplication.md (ancien format pré-bootstrap)"
related_adrs: [0, 700]
related_issues: [2]

# 🗂️ Taxonomie ADR
classification:
  lifecycle: "accepted"
  domain: "devops"
  impact: "high"
  quality:
    - "maintainability"
    - "portability"
    - "reliability"
  reversibility: "moderate"
  scope: "strategic"
  tech_areas:
    - "bash"
    - "github-actions"
    - "workflow-call"

tags: ["non-duplication", "separation-of-concerns", "reusability", "workload-agnostic"]
stakeholders: ["@architecture-team", "@dev-team"]
effort: "low"
---

# ADR 608: Frontière de non-duplication — uniquement des contrôles workload-agnostic

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

`azure-marketplace-vm-validator` a vocation à être **partagé** entre plusieurs offres VM Marketplace (PeerTube, WordPress, GitLab, etc.). Chaque projet appelant possède déjà ses propres tests applicatifs (smoke tests, e2e).

Sans frontière explicite, deux dérives apparaissent :

1. **Pollution applicative** — des tests spécifiques à un workload (ex. « PeerTube répond en HTTP », « nginx sert la page ») se retrouvent dans le toolkit générique, le rendant inutilisable tel quel par une autre offre.
2. **Duplication** — un même contrôle existe à la fois dans le validator et dans le projet appelant, créant un risque de divergence (un correctif appliqué d'un seul côté).

Le projet appelant `peertube-azure-marketplace` illustre concrètement ce risque : son `scripts/marketplace-ctt.sh` mélange des contrôles génériques (walinuxagent, SSH, TLS) et des contrôles applicatifs (nginx, postgresql, peertube.service).

Cet ADR formalise une décision **déjà appliquée** (ancien `0003-non-duplication.md`), perdue lors de la migration vers le système ADR numéroté.

---

## ✅ Décision

### Approche Choisie

Ce dépôt inclut **exclusivement** des contrôles de conformité **agnostiques au workload** (workload-agnostic), c'est-à-dire applicables à **toute** image VM Linux Azure Marketplace quelle que soit l'application embarquée.

**Restent en dehors du périmètre** (et donc dans chaque projet appelant) :

- les smoke tests applicatifs (HTTP/HTTPS, parcours utilisateur) ;
- la présence/état de services propres au workload (`nginx`, `postgresql`, service applicatif) ;
- la finalisation post-déploiement (config, secrets, FQDN) ;
- toute assertion liée au produit spécifique.

**Critère d'inclusion** : un test entre dans le validator si et seulement s'il dérive d'une clause de la [section 200 des politiques Microsoft](https://learn.microsoft.com/en-us/legal/marketplace/certification-policies#200-virtual-machines) **et** ne suppose aucune application particulière.

### Comment Cette Solution Résout le Problème

1. **Réutilisabilité** → le toolkit s'applique à n'importe quelle offre VM sans modification.
2. **Source unique de vérité** → les contrôles génériques vivent à un seul endroit.
3. **Séparation des responsabilités** → applicatif chez l'appelant, conformité d'infra ici.

### Principes Architecturaux Appliqués

- ✅ **Single source of truth**: pas de duplication des contrôles génériques.
- ✅ **Separation of concerns**: infra-conformité vs applicatif.
- ✅ **Portability**: project-agnostic et multi-distro.

---

## 📊 Matrice de Décision Quantifiée

| Critère | Poids | Tout dans le toolkit | Tout chez l'appelant | Frontière workload-agnostic (choisi) | Notes |
|---------|-------|----------------------|----------------------|--------------------------------------|-------|
| **Réutilisabilité multi-offres** | 35% | 🔴 Faible (3/10) | 🔴 Faible (2/10) | 🟢 Élevé (10/10) | Cœur de la valeur |
| **Absence de duplication** | 30% | 🟡 Moyen (5/10) | 🟢 Élevé (8/10) | 🟢 Élevé (9/10) | Source unique |
| **Clarté responsabilités** | 20% | 🔴 Faible (3/10) | 🟡 Moyen (6/10) | 🟢 Élevé (10/10) | Frontière nette |
| **Effort d'intégration appelant** | 15% | 🟢 Élevé (8/10) | 🔴 Faible (3/10) | 🟢 Élevé (8/10) | Submodule + workflow |
| **Score Total Pondéré** | 100% | **4.40** | **4.85** | **9.40** ⭐ | Winner |

```
Tout toolkit  : (3*0.35)+(5*0.30)+(3*0.20)+(8*0.15) = 4.35
Tout appelant : (2*0.35)+(8*0.30)+(6*0.20)+(3*0.15) = 4.75
Frontière     : (10*0.35)+(9*0.30)+(10*0.20)+(8*0.15) = 9.40 ✅
```

---

## ⚖️ Conséquences

### ✅ Positives (Bénéfices)

| Bénéfice | Métrique Cible | Valeur Attendue | Mesure |
|----------|----------------|-----------------|--------|
| Réutilisabilité | Offres consommant le toolkit | ≥ 2 | Projets appelants |
| Non-duplication | Contrôles génériques dupliqués | 0 | Audit croisé |
| Clarté | Tests applicatifs dans le toolkit | 0 | Revue de code |

### ⚠️ Négatives (Risques & Limitations)

| Risque | Impact | Probabilité | Mitigation | Responsable |
|--------|--------|-------------|------------|-------------|
| Tentation d'ajouter un test « presque générique » | 🟡 Moyen | 🟡 Moyen | Critère d'inclusion strict (clause 200 + workload-agnostic) | @architecture-team |
| Projet appelant garde un doublon historique | 🟡 Moyen | 🟢 Faible | Migration documentée (ex. PeerTube, issue #2) | @dev-team |

---

## 🔄 Alternatives Considérées

### Alternative 1: Tout centraliser dans le toolkit (y compris l'applicatif)

**Rejetée parce que**: casse la réutilisabilité — un toolkit qui teste PeerTube est inutilisable pour WordPress. **Score**: 4.35/10.

### Alternative 2: Tout laisser chez l'appelant (pas de toolkit)

**Rejetée parce que**: chaque offre ré-implémente les mêmes contrôles d'infra, avec divergence garantie. C'est précisément le problème que ce dépôt résout. **Score**: 4.75/10.

---

## 🚀 Plan d'Implémentation

| Phase | Durée | Deliverables | Statut |
|-------|-------|--------------|--------|
| **Phase 1: Frontière** | — | `tests/` ne contient que des contrôles génériques | ✅ Complété (bootstrap) |
| **Phase 2: Migration PeerTube** | 2-3 jours | Retrait du doublon dans `peertube-azure-marketplace` | 📋 Backlog (issue #2) |

---

## 🎯 Critères de Succès & Validation

| Métrique | Valeur Cible |
|----------|--------------|
| Tests applicatifs dans le toolkit | 0 |
| Contrôles génériques dupliqués chez l'appelant | 0 (post-migration) |

---

## 🔗 Traçabilité & Liens

- [ADR-000](./000-META-processus-creation-adr.md) — Processus ADR
- [ADR-700](./700-TEST-taxonomie-tests-par-chapitre-200.md) — Taxonomie des tests
- `user-stories/RU-CTT-fr.md` — « tests de conformité séparés des smoke tests applicatifs »
- Roadmap migration PeerTube : [issue #2](https://github.com/michel-heon/azure-marketplace-vm-validator/issues/2)

---

## 📝 Notes & Historique

| Date | Auteur | Changement | Raison |
|------|--------|------------|--------|
| 2026-06-17 | @architecture-team | Migration de l'ancien `0003-non-duplication.md` vers le format ADR numéroté AI-optimized | Préserver la décision perdue lors du bootstrap du système ADR |
