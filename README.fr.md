# Validateur VM Azure Marketplace

Boîte à outils Bash réutilisable et agnostique au projet pour la conformité des offres VM Linux Azure Marketplace.
Elle valide les exigences de certification Microsoft (chapitres 200.3.3 / 200.4 / 200.5)
via `az vm run-command invoke` uniquement (pas de SSH entrant).

## Démarrage rapide

```bash
export CTT_VM_NAME="ma-vm"
export CTT_RESOURCE_GROUP="mon-rg"
export CTT_SUBSCRIPTION="00000000-0000-0000-0000-000000000000"

make validate
make tests
make test TEST=test_2003_walinuxagent
```

## Structure

- `scripts/ctt.sh` : lanceur de tests (`validate`, `tests`, `test <name>`, `list`)
- `lib/_common.sh` : helpers partagés (couleurs, compteurs, wrappers az)
- `tests/` : un fichier par exigence de conformité
- `.github/workflows/conformance.yml` : workflow réutilisable (`workflow_call`)
- `user-stories/` : récits utilisateur réutilisables (EN/FR)

Voir `CONTRIBUTING.md` pour ajouter un nouveau contrôle.
