# Configuración para desarrolladores — Entorno local e integración con Supabase

Este documento describe cómo preparar el entorno de desarrollo local para el proyecto "gestionsueño", cómo configurar de forma segura las credenciales de Supabase, cómo aplicar el esquema de base de datos y seeds, y cómo ejecutar la app Flutter usando FVM.

Todos los ejemplos asumen un entorno Windows (PowerShell) y que estás en la raíz del repositorio.

## 1) Requisitos previos

- Instalar Dart, Flutter y Git. Para fijar versiones de Flutter usamos FVM (Flutter Version Manager).
- Herramientas opcionales: `psql` o el CLI de Supabase si deseas aplicar el esquema desde la terminal.

## 2) Instalar FVM (si no está instalado)

Ejecuta en PowerShell:

    dart pub global activate fvm
    # añadir pub cache bin al PATH en la sesión (si no está)
    $env:PATH += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
    fvm --version

## 3) Pasos iniciales del proyecto

Ejecuta:

    cd C:\proyectos\GestionSueñoTesis\mindfulness
    fvm install       # instala la versión de Flutter indicada en .fvmrc
    fvm flutter pub get

## 4) Variables de entorno y llaves (manejo seguro)

- Copia `.env.example` a `.env` y reemplaza los placeholders por las llaves reales.
- NO subir `.env` al repositorio. `.gitignore` ya contiene `.env`.
- Puedes inyectar las llaves en la app usando `flutter_dotenv` o `--dart-define`.

Ejemplo de `.env` (local, no commitear):

    SUPABASE_URL=https://<your-project>.supabase.co
    SUPABASE_ANON_KEY=eyJ...anon...
    SUPABASE_SERVICE_ROLE_KEY=eyJ...service_role...  # SOLO USAR EN SERVIDOR/CI

## 5) Cómo pasar las llaves a la app Flutter

- Opción A — `flutter_dotenv`:
  - Añadir `flutter_dotenv` en `pubspec.yaml` y cargar `.env` en `main()`.
- Opción B — `--dart-define` (recomendado para CI/producción):
  - Ejemplo:

    fvm flutter run --dart-define=SUPABASE_URL="https://<your-project>.supabase.co" --dart-define=SUPABASE_ANON_KEY="eyJ..."

## 6) Aplicar el esquema de Supabase (SQL)

Si necesitas volver a ejecutar el esquema desde terminal, usa `psql` o el CLI de Supabase.

Usando `psql`:

    psql "host=<HOST> user=<USER> dbname=<DB> password=<PASS> port=<PORT>" -f Supabase\shema.sql

Usando Supabase CLI (si está instalado):

    supabase db reset --confirm
    supabase db query "$(Get-Content -Raw -Path Supabase\shema.sql)"

Nota: si ya ejecutaste `Supabase/shema.sql` desde el SQL editor, no es necesario repetir estos pasos.

## 7) Seeds y datos de prueba

- Añade `Supabase/seeds/initial_data.sql` con INSERTs para `routines` y otros datos que no dependan de `auth.users`.
- Para `profiles` que referencian `auth.users(id)` debes crear primero los usuarios en Authentication (Dashboard) y luego insertar `profiles` con los UUIDs generados.

Ejemplo (psql):

    psql "host=<HOST> user=<USER> dbname=<DB> password=<PASS>" -f Supabase\seeds\initial_data.sql

## 8) Crear usuarios de prueba (Auth) y `profiles`

- En el Dashboard: Authentication → Users → "New user" crea cuentas de prueba (patient/professional/admin).
- Copia el `id` de cada usuario y ejecuta:

  INSERT INTO public.profiles (id, role, segment, full_name) VALUES ('<USER_UUID>', 'patient', 'student', 'Test Patient');

## 9) Storage (buckets) — configuración para `routines`

- Crea un bucket privado llamado `routines` en Supabase Storage.
- Sube un archivo de audio de ejemplo desde el Dashboard para pruebas.
- Consulta `docs/STORAGE-routines.md` para la implementación de upload/stream usando signed URLs.

## 10) Verificación de RLS

- Revisa que las políticas RLS estén activadas en las tablas sensibles (Database → Policies).
- Prueba acceso/aislamiento con las tres cuentas de prueba.

## 11) Ejecutar la app (desarrollo)

    fvm flutter pub get
    fvm flutter run

O con `--dart-define`:

    fvm flutter run --dart-define=SUPABASE_URL="https://..." --dart-define=SUPABASE_ANON_KEY="..."

## 12) Generar APK / App bundles

    fvm flutter build apk --debug
    fvm flutter build apk --release

## 13) Tests / Formateo / Linter

    fvm flutter test
    fvm flutter format .
    fvm flutter analyze

## 14) CI y secrets

- Añade `SUPABASE_URL`, `SUPABASE_ANON_KEY` y `SUPABASE_SERVICE_ROLE_KEY` como secrets en tu CI (GitHub/GitLab/etc.).
- NUNCA incluir `SUPABASE_SERVICE_ROLE_KEY` en builds cliente.

## 15) Consejos de resolución de problemas

- 403 al descargar un asset: verifica que `storage_path` en `public.routine_assets` coincide con la ruta en Storage y que la signed URL no haya expirado.
- Error de permiso en upload: revisa Storage policies y que el path siga la convención `<auth.uid>/<file>`.
- Problemas de RLS: reproduce con cuentas de prueba y pequeñas queries en el SQL editor.

## 16) Próximos pasos para el front (Sprint 1)

- Implementar la UI de autenticación y verificar la creación de `profiles`.
- Implementar la pantalla de `Routines` leyendo `public.routines`.
- Implementar flujo de `Session` para crear `activity_sessions` y `self_assessments`.
- Consultar `docs/STORAGE-routines.md` para upload/stream de audio.

**Conventions:**

- Codebase: comments and variable names in Dart/SQL must be in English (best practice).
- UI texts/labels/messages that the user will see must be in Spanish.

If you want, I can generate `Supabase/seeds/initial_data.sql` and a simple login screen scaffold in `lib/features/auth/`.
