-- Migracion: PGS-18 Autopercepcion emocional pre/post actividad
-- Fecha: 2026-04-26
-- Descripcion:
-- 1) Permite UPDATE de activity_sessions por el propio paciente.
-- 2) Evita duplicados pre/post por sesion en self_assessments.

ALTER TABLE public.activity_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Actualiza sus propias sesiones" ON public.activity_sessions;
CREATE POLICY "Actualiza sus propias sesiones"
ON public.activity_sessions
FOR UPDATE
TO authenticated
USING (auth.uid() = patient_id)
WITH CHECK (auth.uid() = patient_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_self_assessments_session_context_unique
ON public.self_assessments (session_id, context)
WHERE session_id IS NOT NULL
  AND context IN ('pre_session', 'post_session');

