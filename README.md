# Azure Marketplace VM Validator

[![CI](https://github.com/michel-heon/azure-marketplace-vm-validator/actions/workflows/ci.yml/badge.svg)](https://github.com/michel-heon/azure-marketplace-vm-validator/actions/workflows/ci.yml)
[![Multi-distro](https://github.com/michel-heon/azure-marketplace-vm-validator/actions/workflows/ci-multi-distro.yml/badge.svg)](https://github.com/michel-heon/azure-marketplace-vm-validator/actions/workflows/ci-multi-distro.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Reusable, project-agnostic Bash conformance toolkit for Azure Marketplace Linux
VM offers. Validates Microsoft VM Offer certification requirements (section 200),
using `az vm run-command invoke` only — **no inbound SSH required**.

## Quick start

```bash
export CTT_VM_NAME="my-vm"
export CTT_RESOURCE_GROUP="my-rg"
export CTT_SUBSCRIPTION="00000000-0000-0000-0000-000000000000"

make validate          # check az/jq versions and Azure context
make tests             # run all 22 conformance tests
make report            # run tests + generate JSON + JUnit XML reports
make test TEST=test_2003_walinuxagent   # single test
make list              # list available tests
```

## Policy coverage

| Section | Topic | Tests | Status |
|---------|-------|-------|--------|
| 200.2.x | Required packages | `test_2002_required_packages` | ✅ |
| 200.3.3 | Linux requirements | 10 tests (`test_2003_*`) | ✅ |
| 200.4.x | Image preparation | 4 tests (`test_2004_*`) | ✅ |
| 200.5.x | Security | 6 tests (`test_2005_*`) | ✅ |
| 200.6.x | Primary functionality | `test_2006_required_services` | ✅ |

Full mapping: [`docs/policy-mapping.md`](docs/policy-mapping.md)

## Distro matrix

| Distro | `CTT_DISTRO` | Adapter | Security scan |
|--------|-------------|---------|--------------|
| Ubuntu 20.04 / 22.04 / 24.04 | `ubuntu` *(default)* | `lib/_distro_ubuntu.sh` | `apt-get -s dist-upgrade` |
| RHEL 8/9, CentOS Stream, Rocky, Alma | `rhel` | `lib/_distro_rhel.sh` | `dnf updateinfo list updates security` |
| Debian 11 / 12 | `debian` | `lib/_distro_debian.sh` | `apt-get -s dist-upgrade` vs `*-security` |

Leave `CTT_DISTRO` unset to auto-detect from `/etc/os-release` on the remote VM.

## Reports

```bash
# Write timestamped JSON + JUnit XML to a directory
CTT_REPORT_DIR=/tmp/ctt-reports make report
```

See [`docs/usage.md`](docs/usage.md) for the full API reference.

## Use as a git submodule

```bash
git submodule add https://github.com/michel-heon/azure-marketplace-vm-validator.git tools/ctt
cd tools/ctt && CTT_VM_NAME=my-vm CTT_RESOURCE_GROUP=my-rg CTT_SUBSCRIPTION=... make tests
```

## Reusable GitHub Actions workflow

```yaml
jobs:
  conformance:
    uses: michel-heon/azure-marketplace-vm-validator/.github/workflows/conformance.yml@v1.0.0
    with:
      vm_name: my-vm
      resource_group: my-rg
      subscription: ${{ vars.AZURE_SUBSCRIPTION_ID }}
      severity_warn_is_fail: true
      upload_reports: true
    secrets: inherit
```

## Structure

```
scripts/
  ctt.sh          CLI: validate | tests | test <name> | list
  ctt-report.sh   JSON + JUnit XML report generator
lib/
  _common.sh          PASS/FAIL/WARN helpers, az run-command wrappers
  _distro_ubuntu.sh   Ubuntu adapter
  _distro_rhel.sh     RHEL / CentOS / Rocky / Alma adapter
  _distro_debian.sh   Debian 11/12 adapter
  _malware_scanner.sh ClamAV transient scanner (200.5.2)
tests/
  test_<chapter>_<area>.sh   22 conformance tests
  unit/                      bats unit tests for lib/
docs/
  usage.md          Full API reference (CTT_* variables, CLI, reports)
  policy-mapping.md Test → policy section mapping table
  adr/              6 Architecture Decision Records
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for adding tests or distro adapters.
