# Azure Marketplace VM Validator

Reusable, project-agnostic Bash conformance toolkit for Azure Marketplace Linux VM offers.
It validates Microsoft VM Offer certification requirements (chapters 200.3.3 / 200.4 / 200.5),
using `az vm run-command invoke` only (no inbound SSH required).

## Quick start

```bash
export CTT_VM_NAME="my-vm"
export CTT_RESOURCE_GROUP="my-rg"
export CTT_SUBSCRIPTION="00000000-0000-0000-0000-000000000000"

make validate
make tests
make test TEST=test_2003_walinuxagent
```

## Structure

- `scripts/ctt.sh`: test runner (`validate`, `tests`, `test <name>`, `list`)
- `lib/_common.sh`: shared helpers (colors, counters, az wrappers)
- `tests/`: one file per conformance requirement
- `.github/workflows/conformance.yml`: reusable workflow (`workflow_call`)
- `user-stories/`: reusable user stories (EN/FR)

See `CONTRIBUTING.md` for adding new checks.
