# Hardening (produzione)

- Non esporre direttamente OpenFGA su internet.
- Usa preshared keys come segreti (rotazione e vault).
- TLS obbligatorio se pubblico (Nginx + certbot).
- Versioni pinnate e update controllato.
- Backup DB regolari + test restore.
- Disabilita Playground in produzione.
