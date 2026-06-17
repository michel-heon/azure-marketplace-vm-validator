---
id: "100"
title: "Contrat d'interface des adapters distro"
status: accepted
date: "2026-06-17"
domain: architecture
tech_areas:
  - bash
  - distro-adapters
  - az-cli
decision_makers:
  - michel-heon
---

# ADR-100 — Contrat d'interface des adapters distro

## Statut

Accepté — 2026-06-17

## Contexte

Le toolkit cible plusieurs distributions Linux approuvées par Azure Marketplace
(Ubuntu, RHEL/CentOS Stream, Debian). Chaque distribution a ses propres
gestionnaires de paquets, chemins de configuration et commandes système. Afin de
garder les fichiers de test (`tests/test_*.sh`) **entièrement agnostiques de la
distro**, toutes les commandes dépendantes de la distribution sont déléguées à un
adapter chargé dynamiquement.

L'amorce d'adapter (`lib/_distro_ubuntu.sh`) existait dès v0.1.0 mais sans
contrat formel : les fonctions obligatoires n'étaient pas documentées, ce qui
rendait l'ajout d'un nouvel adapter source de régressions silencieuses.

## Décision

### 1. Un fichier par distro

Chaque adapter est un script Bash `lib/_distro_<name>.sh` sourcé par
`ctt_load_distro_adapter()` en début d'exécution. Le nom `<name>` correspond à la
valeur de `CTT_DISTRO` (défaut : `ubuntu`).

### 2. Fonctions obligatoires (contrat)

Tout adapter **doit** implémenter les fonctions suivantes. Un adapter incomplet
produit une erreur `ctt_fail` immédiate lors de l'appel.

| Fonction | Retour attendu | Description |
|----------|---------------|-------------|
| `ctt_pkg_update_security_check_cmd` | chaîne de commande shell | Commande distante qui imprime `true` (pas de MaJ sécu) ou `false` (MaJ sécu disponibles). Doit actualiser l'index avant la vérification. |
| `ctt_cloud_init_present_cmd` | chaîne de commande shell | Commande distante qui imprime `true` si cloud-init est installé, `false` sinon. |
| `ctt_pkg_installed_cmd <pkg>` | chaîne de commande shell | Commande distante qui imprime `true` si `<pkg>` est installé, `false` sinon. |

### 3. Convention de retour des commandes distantes

Les fonctions retournent une **chaîne de commande shell** (pas son résultat) qui
sera transmise à `ctt_remote_exec`. Cette chaîne doit imprimer exactement `true`
ou `false` sur stdout, sans autre sortie.

```bash
# Bonne pratique — la fonction retourne une commande, pas son résultat
ctt_pkg_installed_cmd() {
  local pkg="$1"
  printf '%s' "dpkg -s '${pkg}' >/dev/null 2>&1 && echo true || echo false"
}
```

### 4. Fonctions optionnelles (extension)

Les adapters peuvent implémenter des fonctions supplémentaires utilisées par des
tests optionnels, sans casser la compatibilité :

| Fonction | Description |
|----------|-------------|
| `ctt_pkg_manager_name` | Imprime le nom du gestionnaire (`apt`, `dnf`, `yum`, `zypper`). |
| `ctt_os_release_id` | Imprime l'`ID` de `/etc/os-release` (`ubuntu`, `rhel`, `debian`). |
| `ctt_security_updates_count_cmd` | Commande distante retournant le nombre de MaJ sécu disponibles. |

### 5. Auto-détection (P3.4)

Quand `CTT_DISTRO` n'est pas défini, `ctt_load_distro_adapter()` appelle
`ctt_remote_detect_distro()` pour lire `/etc/os-release` sur la VM cible et
déduire l'adapter à charger. Cette fonction est définie dans `lib/_common.sh` et
**ne fait pas partie du contrat adapter** (elle ne peut pas être dans l'adapter
elle-même puisqu'elle précède le chargement).

## Conséquences

- Tout nouvel adapter (RHEL, Debian, SUSE…) doit implémenter les 3 fonctions
  obligatoires.
- Les tests existants n'ont pas besoin d'être modifiés lors de l'ajout d'un
  adapter.
- La compatibilité entre adapters est vérifiable avec un test de contrat unitaire
  (`bats` — Phase 6).
- Le fichier `docs/distro-adapters.md` documente les adapters disponibles et
  leurs spécificités.

## Références

- [ADR-608](608-DEVOPS-frontiere-non-duplication-workload-agnostic.md) — Frontière workload-agnostic
- [ADR-700](700-TEST-taxonomie-tests-par-chapitre-200.md) — Taxonomie des tests
- `lib/_distro_ubuntu.sh` — implémentation de référence
- `docs/distro-adapters.md` — guide des adapters disponibles
