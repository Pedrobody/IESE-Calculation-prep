/* ============================================================
   Configuración del ranking (Supabase).
   ------------------------------------------------------------
   La app funciona SIN esto (entrenamiento, práctica y aprendizaje
   van 100% offline). El ranking online solo se activa cuando
   rellenas la ANON KEY de abajo.

   Cómo obtener la ANON KEY:
   Supabase → tu proyecto → Settings → API → Project API keys →
   copia la clave "anon public" (NO la "service_role") y pégala
   entre las comillas de SUPABASE_ANON_KEY.
   ============================================================ */
window.MMCONFIG = {
  SUPABASE_URL: "https://ezunsbyobljaurrwgwfj.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_krVLYErvtGNKhkRYVgMLvA_6cN8QEYn",   // clave pública (publishable) de Supabase
  SECTIONS: ["A", "B", "C"]   // secciones disponibles en el onboarding
};
