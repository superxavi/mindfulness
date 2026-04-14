# Planificación del Proyecto – Hoja de ruta operativa (MVP y entregables)

**Archivo origen:** `docs/PLANIFICACION- tesis de mindfulness e higiene del sueño.docx`

## Objetivo

Documento operativo que define: hitos, entregables, sprints, tareas por rol, criterios de aceptación y checklist de lanzamiento para el MVP.

## Entregables principales

| Entregable             | Descripción                                                                      | Responsable             |
| ---------------------- | -------------------------------------------------------------------------------- | ----------------------- |
| MVP móvil              | App Flutter con autenticación, catálogo de rutinas, sesiones y registro de sueño | Dev Flutter             |
| Backend Supabase       | Esquema, RLS, Storage, funciones y triggers aplicados                            | Dev Backend             |
| Seguridad y privacidad | Cifrado para `thought_entries`, registro de consentimientos                      | Dev Backend / Seguridad |
| Evaluación UX          | Estudios SUS/UEQ, reportes y mejoras de usabilidad                               | Investigador UX         |
| Documentación técnica  | ERS, SCHEMA.md, runbooks de despliegue y scripts de seeds                        | Equipo de documentación |

## Cronograma y Hitos (plan sugerido)

Duración total estimada MVP: 9–10 semanas (configurable según recursos).

| Hito                        | Objetivo                                                | Duración estimada |
| --------------------------- | ------------------------------------------------------- | ----------------: |
| H1 – Infra y setup          | Crear proyecto Supabase, configurar FVM, CI básico      |          1 semana |
| H2 – Auth & Perfiles        | Auth, `profiles`, `consents`, políticas básicas RLS     |          1 semana |
| H3 – Catálogo & Assets      | CRUD `routines` y `routine_assets`, integración Storage |         2 semanas |
| H4 – Sesiones & Tracking    | `activity_sessions`, `self_assessments`, `sleep_logs`   |         2 semanas |
| H5 – Diario cifrado & Flags | `thought_entries`, `risk_flags`, key management         |         2 semanas |
| H6 – QA, UX & Ajustes       | Tests, validación RLS, correcciones UX                  |       1–2 semanas |
| H7 – Despliegue MVP         | Deploy a prod, backups, runbook                         |          1 semana |

## Sprint Plan (ejemplo, sprints de 2 semanas)

- Sprint 0 (setup rápido): repos, FVM, acceso a Supabase, CI pipeline mínimo.
- Sprint 1: Auth + perfiles + consentimientos + pruebas RLS básicas.
- Sprint 2: CRUD rutinas + Storage integration + playback.
- Sprint 3: Sesiones, autoevaluaciones y sleep_logs.
- Sprint 4: Diario cifrado, flags, asignaciones profesionales.
- Sprint 5: QA, tests e iteraciones de UX, preparar despliegue.

## Roles y responsabilidades

- Product Owner: prioriza backlog, valida con stakeholders clínicos.
- Dev Flutter: implementa UI, integración con Supabase, automatiza tests widget.
- Dev Backend: aplica schema, políticas RLS, funciones, migrations.
- QA/UX: tests automatizados, test de usabilidad (SUS/UEQ), pruebas manuales.
- DBA/Infra (opcional): backups, monitorización y DR.

## Tareas por rol (ejemplos)

- Dev Backend: aplicar `Supabase/shema.sql`, añadir migrations, crear seeds, configurar RLS tests.
- Dev Flutter: crear pantallas Inicio, Rutinas, Diario, Perfil; integrar reproducción audio; local storage para reintentos.
- QA: escribir tests de integración para endpoints críticos y casos de RLS.

## Plan de pruebas (QA)

1. Unit tests (Flutter & backend helpers).
2. Integration tests: endpoints, workflows completos (signin → create session → assessment → sleep_log).
3. RLS tests: comprobar que different users no acceden a datos ajenos.
4. Seguridad: pruebas de inyección SQL, revisión de dependencias.
5. Usabilidad: sesiones de 5–8 usuarios para recopilar SUS/UEQ.

## Checklist de lanzamiento (MVP)

- [ ] `Supabase/shema.sql` aplicado en `staging` y `production`.
- [ ] RLS policies validadas con cuentas de prueba (patient/professional/admin).
- [ ] Migrations versionadas en repo y pipeline CI que las aplique.
- [ ] Backups automáticos configurados (daily snapshot).
- [ ] Tests de integración y RLS en CI pasan.
- [ ] Runbook de despliegue documentado (`docs/deploy-runbook.md`).

## Configuración de desarrollo local (rápido)

1. Instalar `dart` y `fvm`.
   ```powershell
   dart pub global activate fvm
   # Añadir %USERPROFILE%\AppData\Local\Pub\Cache\bin al PATH si es necesario
   ```
2. Desde la raíz del proyecto:
   ```powershell
   cd C:\proyectos\GestionSueñoTesis\mindfulness
   fvm install
   fvm flutter pub get
   fvm flutter run
   ```
3. Configurar credenciales de Supabase en `.env` o en la sección de configuración del app.
4. Aplicar schema: (remoto) usar la consola Supabase o ejecutar:
   ```powershell
   psql "host=<HOST> user=<USER> dbname=<DB> password=<PASS>" -f Supabase\shema.sql
   ```

## Despliegue y migraciones

- Mantener `Supabase/shema.sql` como fuente de verdad.
- Usar pipeline CI para ejecutar migrations en `staging` y revisar antes de `production`.
- Backup diario y verificación de restores periódica (mensual prueba de restore).

## Riesgos y Plan de mitigación

| Riesgo                    | Probabilidad | Impacto | Plan de mitigación                                                               |
| ------------------------- | -----------: | ------: | -------------------------------------------------------------------------------- |
| RLS mal aplicado          |        Media |    Alto | Pruebas automatizadas de RLS + revisión por pares antes de merge.                |
| Problemas de cifrado      |        Media |    Alto | Usar KMS y políticas de acceso restringido; pruebas de encriptado/desencriptado. |
| Falta de recursos para QA |        Media |   Medio | Priorizar pruebas RLS y flujos críticos; contratación temporal si es necesario.  |

## Entregables de documentación

- `docs/ERS.md` (este documento)
- `Supabase/SCHEMA.md` (esquema y políticas)
- `docs/deploy-runbook.md` (procedimiento de despliegue y restore)
- `docs/README-dev.md` (setup local y comandos frecuentes)

## Estimación de esfuerzo (orientativa)

- Dev Backend: 4–6 semanas (aplicar schema, RLS, funciones, migrations)
- Dev Flutter: 4–6 semanas (UI, reproducción audio, integraciones)
- QA/UX: 2–3 semanas (tests, evaluaciones, correcciones)

## Siguientes pasos recomendados (acción inmediata)

1. Aplicar `Supabase/shema.sql` en `staging` y ejecutar tests RLS.
2. Configurar pipeline CI con ejecución de tests y migrations.
3. Preparar seeds y cuentas de prueba para roles (patient/professional/admin).

Si quieres que genere automáticamente un `Jira` backlog o un `kanban` con las tareas y sprints, lo puedo crear y añadir los issues al repo en formato CSV/Markdown para importación.
