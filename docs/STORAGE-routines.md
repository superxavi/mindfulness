# Subir y leer archivos en Supabase Storage — `routines`

Objetivo: documentar cómo implementar correctamente subida (upload) y lectura (download/stream) de audios en un bucket privado llamado `routines`, de forma que cada usuario solo pueda acceder a sus propios archivos. Incluir ejemplos y checklist para que los desarrolladores lo implementen en Flutter.

0. Suposiciones

- El bucket se llama `routines` y es privado.
- Se exige la convención de rutas: `/ <auth.uid> / <filename>` (ej. `a3b2c1d0-.../intro.mp3`).
- Las políticas (RLS / Storage policies) validan que el `storage_path` comience con el UUID del usuario (`auth.uid()`).
- `public.routine_assets.storage_path` debe contener exactamente el `storagePath` usado al subir.

IMPORTANTE: Si tu `storage_path` no sigue la convención `<auth.uid>/<archivo>`, el upload/download fallará por RLS.

1. Estructura esperada del Storage

- Bucket: `routines` (privado).
- Ruta dentro del bucket: `/<auth.uid>/<filename>`.

Ejemplo:

- `a2c6e9f4-7f1a-4d9d-9f2b-1aa7e3f2c8d1/intro.mp3`

2. Subir un archivo (Upload) — flujo y recomendaciones

Requisitos previos:

- El usuario debe estar autenticado (`supabase.auth.currentUser` no nulo).
- Usar el bucket `routines`.
- Construir `storagePath` siguiendo `userId/filename`.

Flujo recomendado (resumen):

1. Obtener `user.id` (UUID) del usuario autenticado.
2. Generar un nombre de archivo único (p. ej. usando timestamp).
3. Subir bytes/archivo al bucket `routines` en la ruta `${user.id}/${fileName}`.
4. (Opcional) Insertar metadatos en `public.routine_assets` guardando `storage_bucket='routines'` y `storage_path=storagePath`.

Pseudocódigo / ejemplo (Flutter usando `supabase_flutter`):

```dart
// 1) Obtener cliente y usuario
final supabase = Supabase.instance.client;
final user = supabase.auth.currentUser;
if (user == null) throw Exception('Debes iniciar sesión');

// 2) Build storage path
final fileName = 'my_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
final storagePath = '${user.id}/$fileName';

// 3) Leer bytes y subir
final fileBytes = await File('/ruta/local/audio.m4a').readAsBytes();
final res = await supabase.storage
  .from('routines')
  .uploadBinary(
    storagePath,
    fileBytes,
    fileOptions: const FileOptions(contentType: 'audio/m4a'),
  );
if (res.error != null) throw Exception(res.error!.message);

// 4) Opcional: persistir en public.routine_assets (vía PostgREST o RPC)
// INSERT INTO public.routine_assets (routine_id, storage_bucket, storage_path, file_type, file_size_bytes) VALUES (...)
```

Notas:

- Usa nombres únicos para evitar colisiones.
- Guarda exactamente el mismo `storagePath` en `routine_assets.storage_path`.

3. Leer un archivo (Download / Stream)

Escenario: bucket privado — usar Signed URLs.

Flujo recomendado:

1. Consultar `public.routine_assets` para obtener `storage_path` (p. ej. `'<auth.uid>/<file>'`) de la rutina.
2. Por cada asset, pedir una signed URL con TTL (p. ej. 5–10 minutos).
3. Usar la signed URL en el reproductor de audio (o descargar si aplica).

Pseudocódigo / ejemplo (Flutter):

```dart
final supabase = Supabase.instance.client;
final user = supabase.auth.currentUser;
if (user == null) throw Exception('Debes iniciar sesión');

// storagePath obtenido desde public.routine_assets (ej: '${user.id}/intro.mp3')
final storagePath = '${user.id}/intro.mp3';

// Crear signed URL (dependiente de SDK)
final res = await supabase.storage.from('routines').createSignedUrl(storagePath, 60 * 5);
if (res.error != null) throw Exception(res.error!.message);
final signedUrl = res.data!;

// Reproducir
await audioPlayer.play(signedUrl);
```

Si tu versión del SDK no soporta `createSignedUrl`, debes obtener la signed URL desde un backend con `service_role` key o mediante una función RPC segura.

4. Listar assets y reproducir (flujo correcto)

No relies en listar objetos del Storage desde el cliente. En su lugar:

1. Consulta Postgres: `SELECT * FROM public.routine_assets WHERE routine_id = :routineId`.
2. Para cada fila, toma `storage_bucket` y `storage_path`.
3. Solicita signed URL y reproduce.

Pseudoflujo:

```sql
SELECT * FROM public.routine_assets WHERE routine_id = :routineId;
```

Luego en el cliente, para cada `row`:

- bucket = `row.storage_bucket` (debe ser `routines`)
- path = `row.storage_path` (debe ser `'<auth.uid>/<file>'`)
- pedir signed URL y reproducir

5. Contrato mínimo con `public.routine_assets` (qué guardar)

- `storage_bucket` = `'routines'`
- `storage_path` = `'<auth.uid>/<filename>'` EXACTAMENTE igual al path usado en Upload
- (Opcional) `file_type`, `file_size_bytes`, `routine_id`

6. Checklist para que funcione (RLS)

- ✅ `storage_bucket` en DB debe ser `routines`.
- ✅ `storage_path` en DB debe ser `'<auth.uid>/<filename>'`.
- ✅ El usuario debe estar logueado cuando sube/lee.
- ✅ No intentes leer/escribir archivos en carpetas de otros usuarios (`/<otro-uid>/...` será bloqueado).

7. Reglas de seguridad y notas importantes

- No exponer `service_role` key en el cliente. `service_role` SOLO en servidor o CI para generar signed URLs o administrar Storage.
- Si necesitas procesamiento del archivo (p. ej. transcodificar), hazlo en backend con permisos controlados.
- Considera auditar accesos a assets sensibles (tabla `audit_logs`) si el proyecto lo requiere.

8. Preguntas para cuando programes esta funcionalidad

- ¿Tu app guardará `storage_path` exactamente con `user.id` al subir? Pega un ejemplo real de `storage_path` si existe.
- ¿Qué SDK usas en Flutter para Storage? (`supabase_flutter` y versión) o pega el código actual de llamadas a `storage.from(...)`.

9. Ejemplo de errores comunes y cómo diagnosticarlos

- Error: 403 al descargar audio → Posibles causas: `storage_path` guardado en DB no coincide con path en Storage; signed URL expirado; RLS bloqueando el acceso.
- Error: Upload falla con permiso denegado → Causa probable: política RLS / storage policy que impide escribir fuera de `user.id` carpeta.

10. Implementación recomendada para production

- Mantén bucket privado.
- Genera signed URLs con TTL corto (p. ej. 5 minutos).
- Implementa un backend o función segura que use `SUPABASE_SERVICE_ROLE_KEY` para generar signed URLs si la SDK cliente no lo soporta.
- Registra en `public.routine_assets` los metadatos al subir.

11. Snippet SQL para validar paths en DB

```sql
-- Ver assets que no respetan la convención <uuid>/<file>
SELECT * FROM public.routine_assets
WHERE storage_bucket = 'routines'
  AND storage_path !~ '^[0-9a-fA-F\-]{36}/';
```

12. Archivo de ejemplo y próximos pasos

- Añadir esta documentación a `docs/` (este archivo).
- Cuando programes: responde las preguntas en la sección 8 y te entrego snippets exactos adaptados a la versión del SDK.

---

Este documento está pensado para ser la referencia técnica a seguir cuando se implemente la funcionalidad de subir y reproducir audios de `routines` en la app Flutter.
