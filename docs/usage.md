# Usage Guide — azure-marketplace-vm-validator

Reusable, project-agnostic Bash conformance toolkit for Azure Marketplace Linux
VM offers. All checks execute remotely via `az vm run-command invoke` — no
inbound SSH required.

---

## Quick start

```bash
export CTT_VM_NAME="my-vm"
export CTT_RESOURCE_GROUP="my-rg"
export CTT_SUBSCRIPTION="00000000-0000-0000-0000-000000000000"

make validate   # check runtime prerequisites
make tests      # run all conformance tests
make test TEST=test_2003_walinuxagent   # run a single test
```

---

## Environment variables (public API)

All variables are prefixed `CTT_`. They are the **stable public contract**
between the toolkit and any caller project (git submodule, CI workflow, etc.).

### Required

| Variable | Description |
|----------|-------------|
| `CTT_VM_NAME` | Name of the target Azure VM |
| `CTT_RESOURCE_GROUP` | Resource group containing the VM |
| `CTT_SUBSCRIPTION` | Azure subscription ID |

### Optional

| Variable | Default | Description |
|----------|---------|-------------|
| `CTT_DISTRO` | `ubuntu` | Distro adapter to load (`ubuntu`, `debian`, `rhel`). Auto-detected in a future release. |
| `CTT_DRY_RUN` | `0` | Set to `1` to skip actual `az vm run-command` calls (returns mock `true`). Useful for CI syntax checks. |
| `CTT_OUTPUT_FORMAT` | `human` | Output format: `human` (coloured, for terminals) or `json` (machine-readable, future). |
| `CTT_SEVERITY_WARN_IS_FAIL` | `0` | Set to `1` to treat every `[WARN]` result as a `[FAIL]`. Recommended for Partner Center submission gates. |
| `CTT_REQUIRED_SERVICES` | _(none)_ | Space-separated list of systemd services that must be active (used by `test_2006_required_services.sh` when available). |
| `CTT_REQUIRED_PACKAGES` | _(none)_ | Space-separated list of packages that must be installed (used by `test_2002_required_packages.sh` when available). |
| `CTT_MALWARE_SCAN_PATHS` | `/var/www /home /tmp /var/tmp` | Space-separated paths scanned by the ClamAV transient scanner (`test_2005_malware_scan.sh`). |
| `CTT_REPORT_DIR` | _(none)_ | If set, a timestamped report file is written to this directory after each run. |

---

## CLI reference — `scripts/ctt.sh`

```
ctt.sh validate              Check runtime prerequisites (az, jq, CTT_* vars)
ctt.sh tests                 Run all tests found in tests/
ctt.sh test <name>           Run a single test (name without .sh)
ctt.sh list                  List available test names
```

### `--severity-warn-is-fail` / `CTT_SEVERITY_WARN_IS_FAIL=1`

By default a `[WARN]` result does **not** cause `ctt.sh` to exit non-zero, so CI
pipelines can absorb informational warnings. For Partner Center submission gates,
set this flag to promote every WARN to a FAIL:

```bash
CTT_SEVERITY_WARN_IS_FAIL=1 make tests
# or
./scripts/ctt.sh --severity-warn-is-fail tests
```

---

## Distro adapters

Each distro adapter (`lib/_distro_<name>.sh`) provides shell functions consumed
by the tests. Set `CTT_DISTRO` to select one:

| Value | Adapter | Distros |
|-------|---------|---------|
| `ubuntu` *(default)* | `lib/_distro_ubuntu.sh` | Ubuntu 20.04 / 22.04 / 24.04 |
| `debian` | `lib/_distro_debian.sh` | Debian 11 / 12 *(planned)* |
| `rhel` | `lib/_distro_rhel.sh` | RHEL 8/9, Rocky, Alma *(planned)* |

Auto-detection from `/etc/os-release` is planned (roadmap Phase 3).

---

## Consuming as a git submodule

```bash
# In your caller project:
git submodule add https://github.com/michel-heon/azure-marketplace-vm-validator.git tools/ctt

# Run from the submodule root:
cd tools/ctt
CTT_VM_NAME=my-vm CTT_RESOURCE_GROUP=my-rg CTT_SUBSCRIPTION=... make tests
```

See `examples/caller-project/` for a complete integration example.

---

## Reusable GitHub Actions workflow

```yaml
jobs:
  conformance:
    uses: michel-heon/azure-marketplace-vm-validator/.github/workflows/conformance.yml@main
    with:
      vm_name: my-vm
      resource_group: my-rg
      subscription: ${{ vars.AZURE_SUBSCRIPTION_ID }}
    secrets: inherit
```

The caller workflow must export `AZURE_CREDENTIALS` as a secret for the
`azure/login` step.

---

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | All tests PASS (or WARN only, when `CTT_SEVERITY_WARN_IS_FAIL=0`) |
| `1` | One or more tests FAIL (or WARN promoted to FAIL) |

---

## Reports — JSON and JUnit XML

`scripts/ctt-report.sh` wraps `ctt.sh tests` and produces structured reports.

```bash
# Print JSON + JUnit to stdout
make report

# Write timestamped files to a directory (P5.3)
CTT_REPORT_DIR=/tmp/ctt-reports make report
# → /tmp/ctt-reports/ctt-report-20260617T120000Z.json
# → /tmp/ctt-reports/ctt-junit-20260617T120000Z.xml

# JSON only
./scripts/ctt-report.sh --format json

# JUnit only (for Azure DevOps / other CI)
./scripts/ctt-report.sh --format junit
```

### JSON report structure

```json
{
  "generated_at": "20260617T120000Z",
  "vm_name": "my-vm",
  "distro": "ubuntu",
  "overall": "PASS",
  "summary": { "pass": 21, "warn": 0, "fail": 0, "total": 21 },
  "results": [
    {
      "test_id": "test_2003_walinuxagent",
      "section": "200.3",
      "status": "PASS",
      "message": "walinuxagent is active",
      "duration_ms": 3412
    }
  ]
}
```

### JUnit XML

Compatible with GitHub Actions (`mikepenz/action-junit-report`), Azure DevOps
test reporting, and Jenkins JUnit plugin.

---

## Long-running tests

`test_2005_malware_scan.sh` installs ClamAV transiently on the remote VM,
downloads the latest virus database via `freshclam`, scans the paths in
`CTT_MALWARE_SCAN_PATHS`, then purges ClamAV unconditionally. ClamAV is
**never left in the image**.

Typical execution time: **3–10 minutes** depending on the size of the
scanned paths and the network speed for the DB download (~300 MB). Plan
for a generous `az vm run-command invoke` timeout in your CI pipeline.

> Do NOT run this test on VMs that are in active production service.

---

## Policy references

- [Microsoft Marketplace VM certification policies — section 200](https://learn.microsoft.com/en-us/legal/marketplace/certification-policies#200-virtual-machines)
- [`az vm run-command invoke`](https://learn.microsoft.com/en-us/cli/azure/vm/run-command#az-vm-run-command-invoke)
- [Azure VM certification FAQ](https://learn.microsoft.com/en-us/partner-center/marketplace-offers/azure-vm-certification-faq)
