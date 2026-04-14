# 🧠 Sistema de Mindfulness e Higiene del Sueño - ESPE

## 📌 Descripción del Proyecto

Este proyecto consiste en el diseño y desarrollo de un sistema integral de apoyo a la higiene del sueño y la autorregulación emocional, dirigido a la comunidad universitaria de la Universidad de las Fuerzas Armadas ESPE.

La solución está compuesta por:

- 📱 Aplicación móvil (Flutter) para el usuario final (Paciente)
- 🧑‍⚕️ Módulo profesional para Bienestar Universitario
- ⚙️ Backend serverless basado en Supabase

El sistema tiene un enfoque **no clínico**, orientado a promover hábitos saludables mediante prácticas como:

- Ejercicios de respiración guiada
- Rutinas de relajación
- Reproducción de audios
- Registro de pensamientos
- Autopercepción emocional
- Seguimiento de hábitos de sueño

---

## 👤 Usuario del Sistema

El sistema está dirigido al **Paciente**, definido como:

> Cualquier miembro de la comunidad universitaria de la ESPE (estudiantes, docentes, personal militar o administrativo) que utilice la aplicación para mejorar su bienestar.

---

## 🎯 Objetivo

Desarrollar una herramienta digital accesible, usable y centrada en el usuario que permita:

- Mejorar la calidad del sueño
- Reducir el estrés nocturno
- Fomentar la autorregulación emocional

---

## 🏗️ Arquitectura del Sistema

El sistema sigue una arquitectura moderna basada en:

### 🔹 Frontend

- Flutter (Mobile App)
- Arquitectura: MVVM

### 🔹 Backend (BaaS)

- Supabase
  - PostgreSQL (Base de datos)
  - Auth (Autenticación)
  - Storage (Audios y recursos)
  - Realtime (sincronización)
  - Edge Functions (lógica server-side ligera)

---

## 🔄 Flujo General

1. El usuario interactúa con la app Flutter
2. Flutter se conecta directamente a Supabase
3. Supabase gestiona:
   - Autenticación
   - Persistencia de datos
   - Seguridad (RLS)
4. Los datos se almacenan en PostgreSQL

---

## 🧩 Principales Módulos

- Autenticación
- Perfil de usuario
- Configuración de sueño
- Rutinas y contenido
- Seguimiento emocional
- Historial y métricas

---

## 🛠️ Tecnologías

- Flutter
- Supabase
- PostgreSQL
- Dart

---

## 🧪 Enfoque de Desarrollo

- Metodología: Scrum
- Diseño: DCU (Diseño Centrado en el Usuario)
- Evaluación UX:
  - SUS
  - UEQ
  - AttrakDiff

---

## 🔒 Consideraciones

- El sistema **no reemplaza terapia clínica**
- Manejo seguro de datos (RLS)
- Uso optimizado para contexto nocturno
- Sesiones breves (5–8 minutos)

---

## 🚀 Estado del Proyecto

En desarrollo bajo un enfoque incremental por sprints.

---

## 📚 Autor

Proyecto de tesis – Ingeniería en Software  
Universidad de las Fuerzas Armadas ESPE
