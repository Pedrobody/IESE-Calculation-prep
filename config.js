/* ============================================================
   Leaderboard configuration (Supabase).
   ------------------------------------------------------------
   The app works WITHOUT this (training, practice and learning are
   100% offline). The online leaderboard only turns on when you
   fill in the public key below.

   How to get the key:
   Supabase → your project → Settings → API → copy the
   "anon public" / publishable key (NOT the "service_role" key)
   and paste it between the quotes of SUPABASE_ANON_KEY.
   ============================================================ */
window.MMCONFIG = {
  SUPABASE_URL: "https://ezunsbyobljaurrwgwfj.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_krVLYErvtGNKhkRYVgMLvA_6cN8QEYn",   // Supabase public (publishable) key
  SECTIONS: ["A", "B", "C"]   // sections available in onboarding
};
