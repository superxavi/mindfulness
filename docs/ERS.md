# ERS – Especificación de Requisitos del Sistema

Versión: 1.0
Fecha: 2026-04-13
Autor: Equipo de Desarrollo / Investigador

## Propósito

Este documento especifica de forma completa los requisitos funcionales y no funcionales, restricciones, políticas de seguridad, criterios de aceptación, pruebas y plan de despliegue para el sistema "Mindfulness y Higiene del Sueño" — aplicación móvil (Flutter) y backend en Supabase.

## Alcance

- Aplicación móvil (Flutter) que permite a usuarios realizar rutinas de mindfulness, registrar sueño, llevar un diario íntimo cifrado y recibir asignaciones de profesionales.
- Backend en Supabase: autenticación, base de datos, almacenamiento de assets, RLS, funciones y triggers.
- Excluye: componentes de hardware, integración con dispositivos biométricos (a menos que se acuerde en una extensión futura).

## Stakeholders

| Rol                   | Responsabilidad                                |
| --------------------- | ---------------------------------------------- |
| Investigador / Owner  | Definición de alcance y validación clínica     |
| Desarrollador Flutter | Implementación UI/UX, integración con Supabase |
| Desarrollador Backend | Schema, RLS, funciones, deploy de Supabase     |
| QA / UX               | Pruebas automatizadas y de usabilidad          |
| Profesional Clínico   | Validación de contenido clínico y protocolos   |

## Definiciones y abreviaturas

- RLS: Row Level Security
- DAU/MAU: usuarios activos diario/mensual
- KMS: Key Management Service

## Requisitos funcionales (detallados)

Se listan por ID, descripción, prioridad y criterios de aceptación (tests).

|    ID | Requisito                              | Prioridad | Criterios de aceptación                                                                                                                                                                                                          |
| ----: | -------------------------------------- | --------: | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FR-01 | Autenticación y gestión de perfiles    |      Alta | Registro/login con Supabase Auth; `profiles` creado a partir de `auth.users` con `role` y `segment`. Test: crear usuario, verificar `profiles` y Roles.                                                                          |
| FR-02 | Catálogo de rutinas                    |      Alta | CRUD de `routines`; assets en `routine_assets`; reproducción de audio mediante URL firmada. Test: crear rutina con asset, reproducir audio en la app.                                                                            |
| FR-03 | Patrones respiratorios parametrizables |     Media | CRUD `breathing_patterns` enlazado a rutinas. Test: cargar patrón y mostrar animación/temporizador.                                                                                                                              |
| FR-04 | Registro de sesiones                   |      Alta | Registrar `activity_sessions` con `started_at`, `completed_at`, `status` y notas. Test: iniciar/terminar rutina y comprobar entrada creada.                                                                                      |
| FR-05 | Autoevaluaciones pre/post              |      Alta | `self_assessments` vinculadas a sesiones; campos `emotion_id`, `intensity`. Test: enviar evaluación pre y post y verificar asociación.                                                                                           |
| FR-06 | Diario de sueño                        |      Alta | `sleep_logs`: `bed_time`, `wake_time`, `sleep_latency_min`, `sleep_quality_rating`. Test: guardar log y visualizar historial.                                                                                                    |
| FR-07 | Diario íntimo cifrado                  |   Crítica | `thought_entries.content_ciphertext` debe almacenarse cifrado; API/Backend acepta texto, cifra y guarda `content_ciphertext` & `key_id`. Test: guardar entrada, verificar que no hay texto plano en DB y que `key_id` es válido. |
| FR-08 | Flags de riesgo y workflow             |   Crítica | `risk_flags` generadas por análisis (automático o manual), con workflow de notificación/seguimiento. Test: generar flag ejemplo y seguir resolución.                                                                             |
| FR-09 | Asignaciones profesionales             |     Media | `assignments` permite que profesionales asignen rutinas y fijen `target_completion`. Test: asignar y verificar visibilidad por paciente y profesional.                                                                           |
| FR-10 | Mensajes de contenido                  |      Baja | `content_messages` con versiones y activación por `is_active`. Test: crear mensaje y mostrarlo en la app.                                                                                                                        |
| FR-11 | Recordatorios                          |     Media | `reminders` por `trigger_time` y `days_of_week`. Test: programar recordatorio y comprobar envío/local notification (según implementación).                                                                                       |
| FR-12 | Administración y auditoría             |      Alta | Panel administrativo para contenidos, asignaciones y auditoría; `consents` para registros de consentimiento. Test: CRUD admin y logs de auditoría.                                                                               |

## Requisitos no funcionales (NFR)

|     ID | Requisito           | Métrica / Criterio                                                                                |
| -----: | ------------------- | ------------------------------------------------------------------------------------------------- |
| NFR-01 | Seguridad de acceso | RLS habilitado en todas las tablas sensibles; ejecución de pruebas de fuga de datos.              |
| NFR-02 | Privacidad          | Consentimientos registrados; cifrado de diarios; minimizar retención de datos sensibles.          |
| NFR-03 | Disponibilidad      | SLA objetivo 99% para endpoints críticos; backups diarios.                                        |
| NFR-04 | Rendimiento         | Lecturas de catálogo < 200ms en promedio; índices en BD aplicados.                                |
| NFR-05 | Escalabilidad       | Storage de assets escalable (Supabase Storage / CDN); API stateless para escalar horizontalmente. |
| NFR-06 | Accesibilidad       | WCAG 2.1 AA como objetivo.                                                                        |
| NFR-07 | Mantenibilidad      | Migrations versionadas; cobertura de tests > 70% para backend crítico.                            |

## Restricciones

- Uso de Supabase como servicio PaaS: limita control del servidor, pero acelera despliegue.
- `thought_entries` no puede compartirse fuera del propietario salvo mecanismo explícito y auditado.

## Supuestos

- Los usuarios disponen de conexión intermitente; la app debe ser tolerante a interrupciones (reintentos/cola local para envíos críticos).
- El proyecto dispone de una cuenta Supabase con permisos administrativos para aplicar schema y políticas.

## Modelo de datos (referencia vinculada)

La definición completa está en `Supabase/shema.sql` y el resumen en `Supabase/SCHEMA.md`. Componentes clave:

- `profiles`, `consents`, `patient_settings`, `reminders`.
- `routines`, `routine_assets`, `breathing_patterns`.
- `activity_sessions`, `self_assessments`, `sleep_logs`.
- `thought_entries`, `risk_flags`, `assignments`, `content_messages`.

## Diseño de API (sugerido)

Se sugiere diseño REST sobre HTTPS con tokens de Supabase (JWT). A modo de guía:

- POST /auth/sign_up — body: {email, password, role, segment}
- POST /auth/sign_in — body: {email, password}
- GET /profiles/me — devuelve profile del usuario autenticado
- GET /routines — lista rutinas (paginado)
- POST /routines — crear rutina (admin/professional)
- GET /routines/{id}/assets — lista assets y urls firmadas
- POST /sessions — crear `activity_sessions` (patient only, check auth.uid())
- POST /assessments — crear `self_assessments`
- POST /sleep_logs — crear `sleep_logs`
- POST /thought_entries — crea entrada cifrada (server-side o cliente)
- GET /risk_flags — para profesionales con permiso (policy via function `is_assigned_professional`)

## Políticas RLS (implementación recomendada)

Ejemplos de políticas críticas (resumen operativo):

1. `activity_sessions` — sólo el paciente o su profesional asignado pueden leer:

```sql
ALTER TABLE public.activity_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Visualiza sus propias sesiones"
	ON public.activity_sessions
	FOR SELECT
	TO authenticated
	USING (auth.uid() = patient_id OR public.is_assigned_professional(patient_id));
CREATE POLICY "Inserta sus propias sesiones"
	ON public.activity_sessions
	FOR INSERT
	TO authenticated
	WITH CHECK (auth.uid() = patient_id);
```

2. `thought_entries` — privacidad inquebrantable (sólo dueño):

```sql
ALTER TABLE public.thought_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Privacidad inquebrantable de pensamientos"
	ON public.thought_entries
	FOR ALL
	TO authenticated
	USING (auth.uid() = patient_id);
```

3. `patient_settings` — sólo el propio usuario puede leer/escribir:

```sql
ALTER TABLE public.patient_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Modifica sus configuraciones"
	ON public.patient_settings
	FOR ALL
	TO authenticated
	USING (auth.uid() = patient_id);
```

## Gestión de cifrado y claves

- Recomendación: el texto del diario íntimo debe ser cifrado en el cliente o en el backend con una clave gestionada por KMS (AWS KMS, GCP KMS o servicio equivalente). En DB se guarda sólo `content_ciphertext` y `key_id`.
- Flujos posibles:
  - Cliente cifra con la clave pública del servidor y envía ciphertext (mejor privacidad, servidor nunca ve texto claro).
  - Servidor cifra (si se requiere procesamiento del texto) y guarda ciphertext; desencriptado sólo en backend con privilegios muy restringidos.
- Rotación de claves: mantener versionado `key_id` y estrategias de re-encrypt cuando se rota clave.

## Auditoría y logging

- Añadir tabla `audit_logs` para cambios críticos (inserciones/actualizaciones/borrados) sobre `thought_entries`, `risk_flags`, `assignments`.
- Usar `pgaudit` o funciones `SECURITY DEFINER` para auditoría si se requieren registros de lectura. Registrar: `user_id`, `action`, `object_id`, `timestamp`, `ip`.

## Pruebas y validación

- Tests unitarios: funciones utilitarias, cifrado, validaciones.
- Tests de integración: endpoints clave, workflows (crear sesión + evaluación + log de sueño).
- Tests de RLS: escenarios con cuentas patient/professional/admin para comprobar aislamiento.
- Tests de carga: catálogo de rutinas y reproducción de assets bajo concurrencia.

## Despliegue y migraciones

- Enfoque: entornos `dev` -> `staging` -> `production`.
- Migrations: mantener `Supabase/shema.sql` como fuente y usar herramienta de migrations (pg-migrate, sqitch o `supabase migrations`).
- Backup: snapshots diarios; prueba de restauración mensual.

## Monitoreo y métricas

- Métricas a instrumentar: latencia API, errores 5xx, tiempo de respuesta del catálogo, DAU/MAU, sesiones completadas.
- Integrar alertas (p.ej. Slack) para errores críticos y para detección de picos inusuales.

## Política de retención de datos y eliminación

- Datos sensibles (`thought_entries`) se conservarán por un periodo definido por regulación/investigador; permitir eliminación completa bajo petición con trazabilidad.
- Logs de auditoría se conservan según políticas institucionales (p.ej. 1-3 años).

## Riesgos y mitigaciones

| Riesgo                     | Probabilidad | Impacto | Mitigación                                                  |
| -------------------------- | -----------: | ------: | ----------------------------------------------------------- |
| RLS mal configurado        |        Media |    Alto | Revisión por par, tests automáticos, auditoría de políticas |
| Gestión de claves insegura |        Media |    Alto | Usar KMS, rotación, no guardar claves en DB                 |
| Fuga de assets             |         Baja |   Medio | Signed URLs, permisos en Storage                            |

## Criterios de aceptación globales

- Todas las funcionalidades críticas con tests automatizados que pasan en CI.
- RLS validado con cuentas de prueba que simulan roles.
- Backups automáticos operativos y proceso de restore documentado.
- Documentación técnica completa (este ERS, SCHEMA.md, runbook de despliegue).

## Anexos

1. Referencia de esquema: `Supabase/shema.sql` y `Supabase/SCHEMA.md`.
2. Ejemplo de seed y cuentas de prueba (plantilla en `Supabase/seeds/` si se desea).

---

Si quieres, exporto esta versión como `docs/ERS-v1.md` y abro un PR con pruebas de RLS y seeds para cuentas de test.
