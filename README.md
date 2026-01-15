# OpenFGA su Ubuntu/EC2 (Docker Compose + Nginx opzionale)

Data: 2026-01-15

Questa repository contiene una procedura **operativa DevOps** per installare **OpenFGA** su un server Ubuntu (EC2 o simile) usando:
- **Docker Compose** (OpenFGA + PostgreSQL + migrazione schema)
- **Autenticazione** con **preshared key** (token Bearer)  
- Esposizione **solo locale** di OpenFGA (127.0.0.1) e pubblicazione **via Nginx** (opzionale) su 80/443
- Script per **test API**, bootstrap store/model/tuples, healthcheck, backup/restore DB
- Service **systemd** per avvio automatico a reboot

> Nota: la guida assume che tu abbia accesso al server (SSM/SSH) e che tu possa aprire le porte 80/443 nel Security Group quando esponi Nginx.

---

## 1) Contenuto della repo (struttura)

- `docker-compose.yml`  
  Stack **PostgreSQL + migrate + OpenFGA** (versioni pinnate).
- `.env.example`  
  Variabili richieste (da copiare in `.env`).
- `scripts/`  
  Comandi rapidi per gestione stack e test API.
- `examples/`  
  Esempi di payload JSON (model/tuples/check).
- `nginx/openfga.conf`  
  Esempio di reverse proxy Nginx (OpenFGA resta su 127.0.0.1:8080).
- `systemd/openfga-compose.service`  
  Unit systemd per avvio stack dopo reboot.
- `docs/`  
  Note operative: architettura, concetti, hardening.

---

## 2) Prerequisiti (server)

### 2.1 Risorse consigliate
- Minimo: **2 vCPU / 4 GB RAM** (dev/test)
- Consigliato: **2–4 vCPU / 8 GB RAM** (uso reale)
- Disco: **>= 30 GB**, consigliato **60–100 GB**

### 2.2 Docker e Docker Compose plugin
Verifica:
```bash
docker --version
docker compose version
```

---

## 3) Installazione (quick start)

### 3.1 Copia repo su server
Esempio:
```bash
sudo mkdir -p /opt/openfga
sudo chown -R $USER:$USER /opt/openfga
# Copia qui il contenuto di questa repo in /opt/openfga
cd /opt/openfga
```

### 3.2 Configura variabili in `.env`
Crea `.env` copiando `.env.example`:
```bash
cd /opt/openfga
cp .env.example .env
nano .env
```

**Minimo da cambiare:**
- `POSTGRES_PASSWORD`
- `OPENFGA_AUTHN_PRESHARED_KEYS` (almeno una chiave)
- (se usi Nginx) `OPENFGA_PUBLIC_HOSTNAME` (hostname pubblico es. `fga.example.com`)

Permessi consigliati:
```bash
chmod 600 /opt/openfga/.env
```

### 3.3 Avvia lo stack
```bash
cd /opt/openfga
docker compose pull
docker compose up -d
docker compose ps
```

Test base (dal server):
```bash
curl -sS http://127.0.0.1:8080/healthz || true
```

---

## 4) Testing API (store/model/tuples/check)

Carica env nella shell corrente:
```bash
cd /opt/openfga
set -a
source .env
set +a
export FGA_API_URL="${FGA_API_URL:-http://127.0.0.1:8080}"
```

Esegui in sequenza:
```bash
./scripts/create_store.sh
./scripts/write_model.sh
./scripts/write_tuples.sh
./scripts/check.sh
```

Opzionale:
```bash
./scripts/list_objects.sh
```

---

## 5) Pubblicazione via Nginx (opzionale)

Vedi `nginx/openfga.conf` e:
```bash
sudo cp nginx/openfga.conf /etc/nginx/sites-available/openfga
sudo ln -sf /etc/nginx/sites-available/openfga /etc/nginx/sites-enabled/openfga
sudo nginx -t
sudo systemctl reload nginx
```

HTTPS (con dominio/DNS validi):
```bash
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d fga.example.com
sudo certbot renew --dry-run
```

**Security Group AWS**: inbound su 80/443 (e NON 8080).

---

## 6) Avvio automatico con systemd

```bash
sudo cp systemd/openfga-compose.service /etc/systemd/system/openfga-compose.service
sudo systemctl daemon-reload
sudo systemctl enable --now openfga-compose
sudo systemctl status openfga-compose --no-pager
```

---

## 7) Backup/Restore PostgreSQL

Backup:
```bash
./scripts/backup_postgres.sh
```

Restore:
```bash
./scripts/restore_postgres.sh /opt/openfga/backups/openfga_YYYY-MM-DD.sql
```

---

## 8) Note importanti (produzione)

- Non esporre OpenFGA direttamente su internet (niente 0.0.0.0:8080).
- Usa preshared key e gestiscila come segreto.
- Abilita TLS se pubblico.
- Versioni pinnate (no latest).
- Backup DB regolari e test restore.

Dettagli in `docs/04-production-hardening.md`.

---

## 9) Riferimenti (doc ufficiale)
- Configurazione OpenFGA (env vars, authn, datastore):  
  https://openfga.dev/docs/getting-started/setup-openfga/configuration

- Esempi API:  
  https://openfga.dev/docs/getting-started/
