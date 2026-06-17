---
# 🤖 Machine-Readable Metadata (Frontmatter YAML)
# Permet parsing automatique par agents IA et recherche/filtrage avancé

# ⚠️ AVANT DE COMMENCER:
# 1. Lire ADR-000 (Processus) : ./000-META-processus-creation-adr.md
# 2. Consulter TAXONOMY.md pour classification complète
# 3. Vérifier README.md pour numérotation disponible dans votre plage
# 4. Ces 4 documents DOIVENT être cohérents - les consulter ensemble

adr: XXX  # Remplacer par numéro dans plage catégorie (voir 000-META)
title: "[Titre Descriptif de la Décision]"
status: "proposed"  # draft|proposed|accepted|rejected|deprecated|superseded
date: YYYY-MM-DD
superseded_by: null
replaces: null
related_adrs: []  # Numéros ADRs liés
related_issues: []  # Issues GitHub liées

# 🗂️ Taxonomie ADR (Voir TAXONOMY.md pour détails complets)
classification:
  # Lifecycle: État dans le cycle de vie
  lifecycle: "proposed"  # draft|proposed|accepted|rejected|deprecated|superseded
  
  # Domain: Domaine architectural principal (voir plages 000-META)
  # meta|architecture|infrastructure|security|data|api|devops|test|business
  domain: "test"
  
  # Impact: Niveau d'impact sur le système
  impact: "medium"  # low|medium|high|critical
  
  # Quality Attributes (ASR): Qualités système affectées (ISO 25010)
  quality:
    - "compliance"        # alignement strict politiques Azure Marketplace
    - "reliability"       # idempotence, déterminisme PASS/FAIL/WARN
    - "maintainability"   # ajout de tests, support multi-distros
    # Autres: performance, security, cost, usability, portability
  
  # Reversibility: Facilité de changement
  reversibility: "moderate"  # easy|moderate|hard|irreversible
  
  # Scope: Portée de la décision
  scope: "tactical"  # strategic|tactical|operational
  
  # Technology Area: Domaines technologiques concernés
  tech_areas:
    - "azure"
    - "az-cli"
    - "vm"
    - "run-command"
    # Autres: bash, shellcheck, bats, jq, github-actions, make,
    #         tls, ssh, systemd, walinuxagent, hyper-v, ubuntu, rhel, debian

# Tags libres pour recherche flexible
tags: ["azure-marketplace", "vm-offer", "certification"]

# Stakeholders impliqués
stakeholders: ["@architecture-team", "@dev-team"]

# Effort estimé d'implémentation
effort: "medium"  # low|medium|high
---

# ADR XXX: [Titre Descriptif de la Décision]

<!-- PLACEHOLDER: Remplacer XXX par le prochain numéro séquentiel dans la plage de catégorie -->
<!-- PLACEHOLDER: Remplacer [Titre Descriptif] par un titre concis et actionable -->

## 📊 Vue d'Ensemble

| Attribut | Valeur |
|----------|--------|
| **Statut** | 🔄 Proposé |
| **Date Décision** | YYYY-MM-DD |
| **Stakeholders** | @architecture-team, @dev-team |
| **Impact** | 🔴 Élevé / 🟡 Moyen / 🟢 Faible |
| **Effort Implémentation** | 🔴 Élevé / 🟡 Moyen / 🟢 Faible |
| **Risque Technique** | 🔴 Élevé / 🟡 Moyen / 🟢 Faible |

<!-- PLACEHOLDER: Remplir le tableau ci-dessus avec les valeurs réelles -->

---

## 🎯 Contexte & Problème

<!-- PLACEHOLDER: Décrire le contexte et le problème ci-dessous -->
<!-- FORMAT: Paragraphes explicatifs + réponses aux questions guidées -->

### Questions Guidées

**1. Quel problème essayons-nous de résoudre?**
- [Décrire le problème principal dans le contexte azure-marketplace-vm-validator]
- [Impact actuel sur la validation de conformité, l'exécution distante ou l'intégration des projets appelants]

**2. Quelles sont les contraintes et exigences?**
- **Techniques**: [Ex: exécution via `az vm run-command`, pas de SSH entrante, Bash strict]
- **Azure Marketplace**: [Ex: politiques de certification VM section 200.x à couvrir]
- **Projet appelant**: [Ex: intégration submodule / reusable workflow, variables `CTT_*`]
- **Portabilité**: [Ex: support multi-distros Ubuntu / Debian / RHEL]

**3. Quel est l'impact si nous ne prenons pas de décision?**
- **Court terme (0-3 mois)**: [Impact sur la fiabilité des tests / l'adoption]
- **Moyen terme (3-12 mois)**: [Risque de divergence avec les politiques Microsoft]
- **Long terme (12+ mois)**: [Impact sur la maintenabilité et la réutilisabilité]

**4. Quels facteurs influencent cette décision?**
- **Politiques Microsoft Marketplace**: [Sections 200.x applicables]
- **Cible d'exécution Azure**: [`az vm run-command`, identités, scopes RG]
- **Sécurité du runner**: [Pas d'injection, pas de leak de secrets]
- **Déterminisme**: [Idempotence et stabilité PASS/FAIL/WARN]

---

## ✅ Décision

<!-- PLACEHOLDER: Décrire la décision prise ci-dessous -->
<!-- FORMAT: Approche + Justification + Principes appliqués -->

### Approche Choisie

[Décrire en détail la solution retenue]

**Exemple**:
> Nous adoptons **[solution choisie]** pour [objectif] afin de [bénéfice principal].
> Cette approche garantit [propriété clé] tout en respectant les politiques Azure Marketplace et les contraintes d'exécution distante du validator.

### Comment Cette Solution Résout le Problème

[Expliquer point par point comment la décision répond au problème]

1. **Problème X** → Résolu par [mécanisme Y]
2. **Exigence Marketplace Z** → Satisfaite via [approche W]
3. **Contrainte d'exécution / portabilité / sécurité** → Adressée par [solution retenue]

### Principes Architecturaux Appliqués

- ✅ **Project-agnostic**: [Aucune dépendance à une pile applicative spécifique]
- ✅ **Sécurité du runner**: [Pas d'injection, pas de leak de secrets, moindre privilège]
- ✅ **Déterminisme**: [Idempotence, sortie PASS/FAIL/WARN stable]
- ✅ **Conformité Marketplace**: [Alignement strict sur les politiques section 200.x]
- ✅ **[Autre principe]**: [Description]

### Technologies/Outils Utilisées

| Technologie | Version | Rôle | Justification |
|-------------|---------|------|---------------|
| Azure CLI (`az`) | ≥ 2.x | Exécution distante | `vm run-command invoke` |
| `az vm run-command` | - | Canal d'exécution | Aucune SSH entrante requise |
| Bash | ≥ 4.x | Langage des tests | Portable, présent sur les agents |
| `jq` | ≥ 1.6 | Parsing JSON | Extraction de la sortie run-command |
| shellcheck | - | Lint Bash | Qualité et robustesse |
| bats-core | - | Tests unitaires lib | Validation des helpers |
| GitHub Actions | - | CI / reusable workflow | Intégration callers via `workflow_call` |

---

## 📊 Matrice de Décision Quantifiée

<!-- PLACEHOLDER: Remplir le tableau ci-dessous avec les scores réels -->
<!-- FORMAT: Évaluation objective sur 10 pour chaque critère -->

| Critère | Poids | Alternative 1 | Alternative 2 | Décision Choisie | Notes |
|---------|-------|---------------|---------------|------------------|-------|
| **Conformité Marketplace** | 30% | 🟡 Moyen (5/10) | 🟢 Élevé (9/10) | 🟢 Élevé (10/10) | Politiques 200.x |
| **Portabilité (multi-distro / multi-projet)** | 25% | 🟡 Moyen (6/10) | 🟢 Élevé (8/10) | 🟢 Élevé (9/10) | Project-agnostic |
| **Maintenabilité** | 20% | 🟢 Simple (8/10) | 🟡 Moyen (5/10) | 🟢 Simple (8/10) | Ajout d'un test |
| **Sécurité du runner** | 15% | 🟡 Moyen (6/10) | 🟢 Élevé (8/10) | 🟢 Élevé (9/10) | Pas d'injection / leak |
| **Coût d'exécution** | 10% | 🟢 Faible (8/10) | 🔴 Élevé (4/10) | 🟡 Moyen (7/10) | Minutes run-command + RG |
| **Score Total Pondéré** | 100% | **6.30** | **7.45** | **9.05** ⭐ | Winner |

### Calcul Détaillé (Pour Validation IA)

```
Alternative 1: (5*0.30) + (6*0.25) + (8*0.20) + (6*0.15) + (8*0.10) = 6.30
Alternative 2: (9*0.30) + (8*0.25) + (5*0.20) + (8*0.15) + (4*0.10) = 7.45
Décision:      (10*0.30) + (9*0.25) + (8*0.20) + (9*0.15) + (7*0.10) = 9.05 ✅
```

---

## ⚖️ Conséquences

### ✅ Positives (Bénéfices)

| Bénéfice | Métrique Cible | Valeur Attendue | Mesure |
|----------|----------------|-----------------|--------|
| Conformité Marketplace | Couverture policies 200.x | ✅ Mappée | `docs/policy-mapping.md` |
| Déterminisme des tests | Résultat stable | 100% idempotent | Runs répétés identiques |
| Portabilité | Distros supportées | ≥ 2 (Ubuntu + autre) | Matrice CI |
| Intégration caller | Temps d'intégration | < 30 minutes | Test projet appelant |

### ⚠️ Négatives (Risques & Limitations)

| Risque | Impact | Probabilité | Mitigation | Responsable | Deadline |
|--------|--------|-------------|------------|-------------|----------|
| Changements exigences Marketplace | 🟡 Moyen | 🟡 Moyen | Veille policies Microsoft + ADR BIZ | @devops-team | Trim. |
| Variations entre distros | 🟡 Moyen | 🟡 Moyen | Adapter pattern `lib/_distro_*.sh` | @dev-team | Continu |
| **Évolution de l'API `az run-command`** | 🟡 Moyen | 🟢 Faible | Wrapper centralisé dans `lib/_common.sh` | @dev-team | Continu |

---

## 🔄 Alternatives Considérées

### Alternative 1: [Nom Descriptif]

**Description**:
[Brève description de l'alternative avec détails techniques]

**Avantages**:
- ✅ [Avantage 1]
- ✅ [Avantage 2]

**Inconvénients**:
- ❌ [Inconvénient 1]
- ❌ [Inconvénient 2]

**Rejetée parce que**:
[Raisons principales du rejet, référence à la matrice de décision]

**Score Matrice**: 6.30/10

---

### Alternative 2: [Nom Descriptif]

**Description**:
[Brève description]

**Avantages**:
- ✅ [Avantage 1]

**Inconvénients**:
- ❌ [Inconvénient 1]

**Rejetée parce que**:
[Raisons]

**Score Matrice**: 7.45/10

---

## 🚀 Plan d'Implémentation

### Phases & Deliverables

| Phase | Durée Estimée | Deliverables | Blockers Potentiels | Critères de Validation | Responsable |
|-------|---------------|--------------|---------------------|------------------------|-------------|
| **Phase 1: Fondations** | 1 semaine | - Helpers `lib/_common.sh`<br>- CLI `ctt.sh`<br>- Tests bats de base | - Accès Azure<br>- Approbation architecture | - CI vert<br>- Code review approuvé | @dev-team |
| **Phase 2: Couverture 200.x** | 1 semaine | - Tests sections 200.3.3 / 200.4 / 200.5<br>- `docs/policy-mapping.md` | - Fondations validées | - Tests PASS sur VM cible<br>- Mapping complet | @dev-team |
| **Phase 3: Multi-distro** | 1 semaine | - Adapters `_distro_*.sh`<br>- Auto-détection distro<br>- Matrice CI | - Phase 2 OK | - ≥ 2 distros supportées | @devops-team |
| **Phase 4: Intégration callers** | 3 jours | - Reusable workflow<br>- Exemple submodule | - Toutes phases précédentes OK | - Caller externe fonctionnel | @architecture-team |

### Dépendances & Ordre d'Exécution

```mermaid
graph TD
    A[ADR-000: Processus ADR] -->|Fondation| B[ADR-700: Mapping policies 200.x]
    B -->|Pré-requis| C[Phase 1: Fondations toolkit]
    C -->|Bloque| D[Phase 2: Couverture 200.x]
    D -->|Bloque| E[Phase 3: Multi-distro]
    E -->|Bloque| F[Phase 4: Intégration callers]
```

---

## 🎯 Critères de Succès & Validation

### Métriques de Succès (Post-Implémentation)

| Métrique | Valeur Cible | Valeur Baseline | Statut Actuel | Date Mesure |
|----------|--------------|-----------------|---------------|-------------|
| **Couverture policies 200.x** | 100% automatisable | Partielle | ⏳ En cours | - |
| **Distros supportées** | ≥ 2 | 1 (Ubuntu) | ⏳ À mesurer | - |
| **Durée d'une passe complète** | < 10 min | N/A | ⏳ À mesurer | - |
| **Déterminisme (runs identiques)** | 100% | N/A | ⏳ À mesurer | - |

### Critères de Re-évaluation

**Déclencher une review complète si**:
- ⚠️ Changement majeur des politiques Microsoft Marketplace (section 200)
- ⚠️ Évolution incompatible de l'API `az vm run-command`
- ⚠️ Ajout d'une nouvelle famille de distro à supporter
- ⚠️ Faille de sécurité dans le runner (injection, leak)

**Responsable Review**: @architecture-team  
**Fréquence Review Planifiée**: Tous les 6 mois

---

## 🔗 Traçabilité & Liens

### Issues GitHub Liées

| Issue | Type | Relation | Description |
|-------|------|----------|-------------|
| [#XX](link) | Feature | **Origine** | [Description de l'issue qui a motivé cet ADR] |

### ADRs Connexes

| ADR | Titre | Relation | Impact |
|-----|-------|----------|--------|
| [ADR-000](000-META-processus-creation-adr.md) | Processus ADR | **Processus** | Gouvernance ADR |

### Documentation Externe

- [Azure Marketplace VM Offer](https://learn.microsoft.com/en-us/azure/marketplace/azure-vm-offer-setup)
- [Microsoft Marketplace Certification Policies — section 200](https://learn.microsoft.com/en-us/legal/marketplace/certification-policies#200-virtual-machines)
- [Azure VM Certification FAQ](https://learn.microsoft.com/en-us/partner-center/marketplace-offers/azure-vm-certification-faq)
- [`az vm run-command invoke`](https://learn.microsoft.com/en-us/cli/azure/vm/run-command#az-vm-run-command-invoke)

---

## 📝 Notes & Historique

### Changelog

| Date | Auteur | Changement | Raison |
|------|--------|------------|--------|
| YYYY-MM-DD | @architect | Création initiale | Issue #XX |

---

## 🤖 Métadonnées IA (Machine-Only)

```json
{
  "adr_id": "XXX",
  "project": "azure-marketplace-vm-validator",
  "parsing_version": "2.0",
  "generated_at": "YYYY-MM-DDTHH:mm:ssZ",
  "validation_status": "valid",
  "dependency_graph": {
    "depends_on": [],
    "blocks": [],
    "related": []
  }
}
```

---

## 📋 Instructions d'Utilisation

### Pour Humains

1. **Copier ce template**: `cp adr-template-ai-optimized.md XXX-CATÉGORIE-titre-decision.md`
2. **Choisir la catégorie** et **numéro dans la plage** :
   - META (000-099), ARCH (100-199), INFRA (200-299), SEC (300-399)
   - DATA (400-499), API (500-599), DEVOPS (600-699), TEST (700-799), BIZ (800-899)
3. **Remplacer XXX** : Par le prochain numéro disponible dans la plage de votre catégorie
4. **Remplir frontmatter YAML** : Métadonnées + classification 7 dimensions
5. **Compléter placeholders** : Chercher `<!-- PLACEHOLDER:` et remplacer
6. **Remplir matrice décision** : Évaluer objectivement chaque critère sur 10
7. **Valider avec équipe** : Review par stakeholders listés
8. **Committer** : `git commit -m "docs(adr): ADR-XXX [CATÉGORIE] Titre"`
9. **Ajouter à l'index** : Mettre à jour `docs/adr/README.md`

**Exemples noms fichiers (contexte azure-marketplace-vm-validator)** :
```bash
000-META-processus-creation-adr.md                # Méta (000-099)
100-ARCH-modes-execution-ssh-vs-run-command.md    # Architecture (100-199)
200-INFRA-az-vm-run-command-invoke.md             # Infrastructure (200-299)
300-SEC-exigences-hardening-testees.md            # Sécurité (300-399)
400-DATA-format-rapport-pass-fail-warn.md         # Données (400-499)
500-API-reusable-github-workflow-call.md          # API (500-599)
600-DEVOPS-makefile-orchestrateur.md              # DevOps (600-699)
700-TEST-mapping-policies-200.md                  # Tests (700-799)
800-BIZ-sources-officielles-marketplace.md        # Business (800-899)
```

---

## ✅ Checklist Complétude

### Minimum Requis (Obligatoire)
- [ ] Frontmatter YAML rempli (adr, title, status, date, classification)
- [ ] Section Contexte complète (≥ 200 mots)
- [ ] Section Décision complète (≥ 150 mots)
- [ ] Matrice décision avec ≥ 3 critères
- [ ] Conséquences positives ET négatives listées
- [ ] ≥ 2 alternatives considérées
- [ ] Plan implémentation avec phases
- [ ] Critères de succès définis

### Recommandé (Haute Valeur)
- [ ] Métriques quantifiées dans conséquences
- [ ] Stratégies mitigation pour risques élevés
- [ ] Dépendances ADRs/Issues explicites
- [ ] Références politiques Microsoft Marketplace (section 200)
- [ ] Impact multi-distro / portabilité vérifié

---

**Version Template**: 2.0 (AI-Optimized)  
**Dernière Mise à Jour**: 2026-06-17  
**Projet**: azure-marketplace-vm-validator  
**Compatibilité**: Agents IA (ChatGPT, Claude, Copilot) + Humains
