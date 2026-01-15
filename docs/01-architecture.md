# Architettura

## Componenti
- OpenFGA: motore di autorizzazione (relationship-based access control).
- PostgreSQL: persistenza per store, authorization model, tuples.
- migrate: job one-shot per applicare migrazioni DB.
- (Opzionale) Nginx: reverse proxy e TLS.

## Porte (stack di default)
- OpenFGA HTTP: 8080
- OpenFGA gRPC: 8081
- Playground: 3000 (o 3001) (sconsigliato in produzione)
- Metrics: 2112

In questa repo, le porte sono mappate su 127.0.0.1 (solo locale).
