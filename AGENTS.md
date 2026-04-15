# 🧠 AGENTS.md – Guía Técnica del Proyecto

## 📌 Propósito

Este documento define las reglas técnicas, arquitectura y lineamientos de desarrollo del sistema de mindfulness e higiene del sueño.

Debe ser seguido por cualquier desarrollador que participe en el proyecto.

---

## 🏗️ Arquitectura General

El sistema utiliza una arquitectura basada en:

- Frontend desacoplado (Flutter)
- Backend como servicio (Supabase)
- Arquitectura interna: MVVM

---

## 📱 Arquitectura Flutter (MVVM)

Se utiliza el patrón **Model-View-ViewModel**, con separación clara de responsabilidades:

### 🔹 Model

- Representa la estructura de datos
- Mapea datos de Supabase

### 🔹 View

- UI (pantallas Flutter)
- No contiene lógica de negocio

### 🔹 ViewModel

- Maneja estado
- Orquesta lógica
- Conecta View con Services

---

## 📂 Estructura de Carpetas

lib/
│
├── core/ # Configuración global
│ ├── constants/
│ ├── utils/
│ ├── theme/
│
├── services/ # Comunicación externa (Supabase)
│ ├── auth_service.dart
│ ├── database_service.dart
│
├── features/ # Módulos del sistema
│
│ ├── auth/
│ │ ├── data/
│ │ ├── domain/
│ │ ├── presentation/
│
│ ├── profile/
│ ├── sleep/
│ ├── routines/
│ ├── tracking/
│
├── models/ # Entidades del sistema
│
├── viewmodels/ # Lógica de presentación
│
├── main.dart

---

## 🔌 Integración con Supabase

### Auth

- Registro: signUp
- Login: signInWithPassword

### Database

- PostgreSQL
- Acceso mediante API Supabase

### Seguridad

- RLS (Row Level Security)
- Usuario solo accede a su información

---

## 🔐 Reglas de Seguridad

- No almacenar contraseñas localmente
- Validar datos en frontend y backend
- Aplicar RLS en todas las tablas
- No exponer errores internos

---

## 📊 Modelado de Datos

Tablas principales:

- profiles
- sleep_settings
- sessions
- thoughts
- emotions

---

## 🔄 Flujo de Datos

1. View solicita acción
2. ViewModel procesa lógica
3. Service interactúa con Supabase
4. Resultado vuelve al ViewModel
5. View se actualiza

---

## 🔒 Seguridad y Modelo de Datos (PGS-7 Hardening)

El sistema aplica un aislamiento estricto de los datos. Todo el esquema de base de datos (`Supabase/shema.sql`) y seguridad (`Supabase/policies.sql`) debe ser idempotente y reproducible.

### 🛡️ Políticas RLS Mandatorias

| Entidad | Regla de Acceso | Justificación |
| :--- | :--- | :--- |
| **`profiles`** | `auth.uid() = id` | Privacidad de identidad. |
| **`thought_entries`** | `auth.uid() = patient_id` | **Aislamiento Total.** Solo el dueño tiene acceso (ni siquiera el profesional). |
| **`sleep_logs`** | `auth.uid() = patient_id` | Datos de salud privados. |
| **`risk_flags`** | `auth.uid() = patient_id` OR `is_assigned_professional()` | Supervisión ética del paciente por un profesional. |
| **`consents`** | `auth.uid() = patient_id` | Registro legal inmutable. |

### 🛠️ Triggers de Integridad

- **Auditoría:** Todas las tablas transaccionales tienen un trigger `handle_updated_at` que actualiza automáticamente la columna `updated_at`.
- **Identidad:** El trigger `on_auth_user_created` captura metadatos del registro (como `full_name`) y crea el perfil en la base de datos de forma atómica.

### 📊 Optimización (Índices)

- Las claves foráneas (`patient_id`, `routine_id`) deben tener índices B-Tree para optimizar las consultas del Dashboard.
- Las tablas con filtros por fecha (`sleep_logs`, `activity_sessions`) deben usar índices descendentes.

---

## 🧪 Buenas Prácticas de Código limpia (Clean Code)

- Separación de responsabilidades: No mezclar lógica de Supabase en los Widgets.
- Uso de estados: Siempre manejar estados de `loading`, `error` y `success` en los ViewModels.
- **Validación de CI:** No realizar push si el linter (`flutter analyze`) o el formateador (`dart format`) fallan.

---

## 🔁 Flujo de Trabajo en Jira

1. Crear historia en Jira.
2. Descomponer en subtareas.
3. Implementar siguiendo el patrón MVVM.
4. **Validar CI localmente (Format, Analyze, Test).**
5. Crear PR y esperar a que el CI de GitHub confirme el éxito.
6. Merge a develop/main.

---

## 🧪 Testing (Futuro)

- Unit testing
- Integration testing
- Evaluación UX:
  - SUS
  - UEQ
  - AttrakDiff

---

## 📌 Nota Final

Este proyecto está diseñado bajo principios de:

- Diseño Centrado en el Usuario (DCU)
- Arquitectura limpia
- Escalabilidad futura

Cualquier cambio en arquitectura debe documentarse aquí.
