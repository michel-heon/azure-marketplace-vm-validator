# Caller project example

## Consume as git submodule

```bash
git submodule add https://github.com/michel-heon/azure-marketplace-vm-validator.git tools/ctt
```

## Reuse workflow from this repository

```yaml
name: Offer Conformance

on:
  workflow_dispatch:

jobs:
  conformance:
    uses: michel-heon/azure-marketplace-vm-validator/.github/workflows/conformance.yml@main
    with:
      vm_name: my-vm
      resource_group: my-rg
      subscription: 00000000-0000-0000-0000-000000000000
    secrets: inherit
```
