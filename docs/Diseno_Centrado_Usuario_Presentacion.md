# Diseño Centrado en el Usuario – Guía de UX (detallada)

**Archivo origen:** `docs/Diseno_Centrado_Usuario_Presentacion.pdf`

Breve: principios y directrices para diseñar una experiencia orientada a uso nocturno y baja carga cognitiva.

## 1. Principios de diseño

- Mínima fricción: acciones críticas ≤ 3 pasos.
- Lectura y contraste: alto contraste en modo nocturno/diurno según horario.
- Accesibilidad: compatibilidad con tamaños de letra grandes y lectores de pantalla.

## 2. Personas (resumen)

| Persona                  | Necesidades principales                                         |
| ------------------------ | --------------------------------------------------------------- |
| Estudiante fatigado      | Flujos simples, recordatorios, modo nocturno y control de audio |
| Profesional de bienestar | Acceso a métricas agregadas y asignaciones de rutinas           |

## 3. Flujos clave

- Inicio de rutina: seleccionar rutina → instrucciones breves → reproducir audio → finalizar sesión (3 pasos).
- Registro de sueño: abrir diario → completar métricas (latencia, calidad) → guardar.
- Diario íntimo: escribir entrada → cifrado automático al guardar.

## 4. Componentes y patrones UI

| Componente            | Recomendación                                          |
| --------------------- | ------------------------------------------------------ |
| Barra inferior        | Navegación principal (Inicio, Rutinas, Diario, Perfil) |
| Tarjetas de rutina    | Título, duración, categoría, botón de reproducir       |
| Modal de confirmación | Uso para acciones irreversibles (borrar entradas)      |

## 5. Modo nocturno y reglas de tiempo

- Detectar horario local (`habitual_bedtime` / `habitual_wake_time`) y activar modo oscuro automáticamente.
- Reducir brillo y limitar animaciones no esenciales durante hora «silenciosa».

## 6. Accesibilidad (Checklist rápido)

- Contraste ≥ 4.5:1 para texto normal; 3:1 para textos grandes.
- Tamaño mínimo de objetivo táctil: 44x44 dp.
- Compatibilidad con TalkBack/VoiceOver y navegación por teclado.

## 7. Métricas UX y evaluación

- SUS para evaluar usabilidad general.
- UEQ para percepción emocional.
- Tasa de finalización de rutinas y % de usuarios que registran sueño.

## 8. Entregables de diseño

- Prototipos interactivos (Figma) con estados de modo nocturno.
- Tokens de diseño (colores, tipografías, espaciado) documentados.

Si quieres, genero un `design-tokens.md` con los valores (colores, tipografías y tokens de espaciado) listos para el equipo de frontend.
