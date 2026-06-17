# Policy Mapping — Tests to Azure Marketplace Certification Policies

This table maps every test shipped in `tests/` to its corresponding Microsoft
certification policy clause, severity, distro support, and expected behavior.

Reference: [Marketplace certification policies §200 — Virtual Machines](https://learn.microsoft.com/en-us/legal/marketplace/certification-policies#200-virtual-machines)

---

## Mapping table

| Test file | Policy section | Clause summary | Severity | Distros | Remote command |
|-----------|---------------|----------------|----------|---------|----------------|
| `test_2003_bash_history_size.sh` | 200.3.3 | Bash history size limited (no sensitive history) | FAIL | ubuntu | `wc -l < ~/.bash_history` vs threshold |
| `test_2003_cloudinit.sh` | 200.3.3 | `cloud-init` service present and enabled | FAIL | ubuntu | `systemctl is-enabled cloud-init` |
| `test_2003_external_dns.sh` | 200.3.3 | External DNS resolution works (outbound connectivity) | WARN | ubuntu | `getent hosts microsoft.com` |
| `test_2003_hyperv_drivers.sh` | 200.3.3 | Hyper-V LIS / KVP drivers loaded | FAIL | ubuntu | `lsmod | grep -q hv_` |
| `test_2003_kernel_cmdline.sh` | 200.3.3 | Kernel cmdline contains Azure-required params | FAIL | ubuntu | `cat /proc/cmdline` |
| `test_2003_no_osdisk_swap.sh` | 200.3.3 | No swap on OS disk (swap on temp disk is OK) | FAIL | ubuntu | `swapon --summary` |
| `test_2003_shadow_passwords.sh` | 200.3.3 | Shadow passwords in use (no plaintext `/etc/passwd`) | FAIL | ubuntu | `passwd -S root` |
| `test_2003_ssh_hardening.sh` | 200.3.3 | SSH: `PermitRootLogin no`, `PasswordAuthentication no` | FAIL | ubuntu | `sshd -T` |
| `test_2003_tls12_enforced.sh` | 200.3.3 | System-wide TLS minimum ≥ 1.2 | FAIL | ubuntu | `openssl s_client` / GNUTLS config |
| `test_2003_walinuxagent.sh` | 200.3.3 | `walinuxagent` service active | FAIL | ubuntu | `systemctl is-active walinuxagent` |
| `test_2004_no_lisa_users.sh` | 200.4.x | No LISA provisioning users remain (`azureuser`, `lisa*`) | FAIL | ubuntu | `getent passwd` |
| `test_2004_no_zipbomb.sh` | 200.4.x | No `zip-bomb.zip` artifact anywhere on the filesystem | FAIL | ubuntu | `find / -xdev -name 'zip-bomb.zip'` |
| `test_2004_ssh_host_keys_removed.sh` | 200.4.x | `/etc/ssh/ssh_host_*` keys removed (re-generated at boot) | FAIL | ubuntu | `ls /etc/ssh/ssh_host_*` |
| `test_2005_no_pending_security_updates.sh` | 200.5.x | No pending security updates (`apt-get -s dist-upgrade`) | FAIL | ubuntu | distro adapter: `ctt_pkg_update_security_check_cmd` |
| `test_2003_no_empty_passwords.sh` | 200.3.3 | No account in `/etc/shadow` with empty password field | FAIL | ubuntu | `awk -F: '$2 == ""'` on `/etc/shadow` |
| `test_2005_permit_root_login.sh` | 200.5.x | `PermitRootLogin` is `no` or `prohibit-password` | FAIL | ubuntu | `sshd -T` |
| `test_2005_no_default_credentials.sh` | 200.5.x | No active account with trivially short password hash | FAIL | ubuntu | `awk -F: 'length($2) < 20'` on `/etc/shadow` |
| `test_2006_required_services.sh` | 200.6.x | All services in `CTT_REQUIRED_SERVICES` are active | FAIL / WARN¹ | ubuntu | `systemctl is-active` per service |
| `test_2002_required_packages.sh` | 200.2.x | All packages in `CTT_REQUIRED_PACKAGES` are installed | FAIL / WARN¹ | ubuntu | `dpkg -s` per package |
| `test_2005_no_vulnerable_packages.sh` | 200.5.8 | No installed package in `CTT_VULNERABLE_PACKAGES` has a pending security fix (DRIFT-001 generic) | FAIL / WARN¹ | ubuntu | `apt-cache policy` per package |
| `test_2004_no_test_artifacts.sh` | 200.4.x | No forbidden fixture file on filesystem (`CTT_FORBIDDEN_ARTIFACTS`) (DRIFT-002 generic) | FAIL | ubuntu | `find / -xdev -name <artifact>` per filename |
| `test_2005_malware_scan.sh` | 200.5.2 | No malware detected (ClamAV transient scan, paths: `CTT_MALWARE_SCAN_PATHS`) | FAIL | ubuntu, rhel, debian | `clamscan --recursive --infected` + purge |

¹ WARN when the corresponding `CTT_*` variable is unset (parameterized tests skip gracefully).

---

## Severity definitions

| Severity | CLI exit code impact | Description |
|----------|---------------------|-------------|
| `FAIL` | non-zero (immediate) | Policy violation that will cause Partner Center rejection |
| `WARN` | zero (unless `CTT_SEVERITY_WARN_IS_FAIL=1`) | Best-practice gap, does not block certification but should be remediated |
| `INFO` | zero | Informational diagnostic, no compliance impact |

---

## Chapters not yet covered (planned)

| Chapter | Topic | Roadmap phase |
|---------|-------|---------------|
| 200.2.x | Approved base OS images | Phase 2 |
| 200.3.3 | Virus / malware scan (ClamAV) | Phase 2 |
| 200.3.3 | Vulnerability scan (Trivy / Grype) | Phase 2 |
| 200.5.x | Required Azure extensions | Phase 3 |
| 200.6.x | Network hardening (no listening daemons) | Phase 3 |
| 200.10.x | Auto-update enabled | Phase 4 |

---

## Adding a new test

1. Identify the policy clause (e.g., `200.3.3 → test_2003_<area>.sh`).
2. Choose severity (`FAIL` or `WARN`) based on Partner Center documentation.
3. Implement as `tests/test_<chapter>_<area>.sh` using helpers from `lib/_common.sh`.
4. Add a row to this table.
5. Update `docs/usage.md` if a new `CTT_*` variable is introduced.

See [ADR-700](adr/700-TEST-taxonomie-tests-par-chapitre-200.md) for the
file-per-clause taxonomy decision and
[ADR-601](adr/601-DEVOPS-nomenclature-scripts-de-test.md) for the naming
convention.
