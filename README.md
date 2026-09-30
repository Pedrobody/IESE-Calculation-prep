# Cálculo IESE · Case Math Trainer

Entrenador de cálculo mental para *case interviews*, pensado para repartir a los
estudiantes de IESE. App web estática (un solo `index.html`, sin build, sin
dependencias), instalable como app en el móvil (PWA) y con ranking online opcional.

## Qué incluye
- **Entrenar (adaptativo):** 10 niveles calibrados. Dentro de cada nivel la
  dificultad es homogénea (nada de mezclar `2000÷100` con `1888÷16`). Subes y
  bajas de nivel según tu **rendimiento reciente**, que valora **acierto y
  velocidad** a la vez (ir lento también baja).
- **Entrenar (práctica libre):** multiplicación configurable (nº de cifras y
  dígitos por lado), sin niveles.
- **Reto del día:** 15 problemas **idénticos para todos** ese día (semilla
  compartida), cronometrados y puntuados por dificultad + velocidad. Es la marca
  que se envía al ranking.
- **Ranking:** clasificación del reto de hoy, **global y por sección** (A/B/C…).
- **Aprender:** biblioteca de estrategias MBB (×, ÷, %) con ejemplos resueltos
  paso a paso.
- XP, rangos (Recruit → Partner) y logros; todo el progreso en el propio
  dispositivo (`localStorage`).

## Puesta en marcha (una sola vez)

### 1) Ranking en Supabase
1. Abre tu proyecto de Supabase → **SQL Editor** → New query → pega el contenido
   de [`supabase-schema.sql`](./supabase-schema.sql) → **Run**.
2. Ve a **Settings → API** y copia la clave **`anon` `public`**.
3. Pega esa clave en [`config.js`](./config.js), en `SUPABASE_ANON_KEY`.
   La `SUPABASE_URL` ya está puesta.
   > La `anon key` es pública por diseño: puede insertar y leer puntuaciones,
   > nada más (lo limitan las políticas RLS del SQL). Nunca pongas la
   > `service_role` key aquí.

La app funciona **sin esto** (entrenamiento, práctica, reto en local y
aprendizaje); solo el ranking online necesita la clave.

### 2) Publicar en GitHub Pages
1. Sube estos archivos al repo `Pedrobody/IESE-Calculation-prep` (ver abajo).
2. En GitHub: **Settings → Pages → Build and deployment → Source: Deploy from a
   branch → Branch: `main` / `root`** → Save.
3. En un par de minutos estará en:
   `https://pedrobody.github.io/IESE-Calculation-prep/`
   Ese es el enlace que repartes a los estudiantes.

### 3) Compartir
Manda el enlace. En el móvil pueden instalarla: iPhone → Compartir → *Añadir a
pantalla de inicio*; Android → menú → *Instalar app*.

## Publicar cambios
Cada vez que edites algo, sube `CACHE_VER` en [`sw.js`](./sw.js) (p. ej. `v1`→`v2`)
para que los estudiantes reciban la versión nueva, y haz `git push`.

## Estructura
```
index.html              app completa (UI + motor + ranking)
config.js               URL y clave de Supabase, y secciones
supabase-schema.sql     tabla + políticas del ranking
manifest.webmanifest    metadatos PWA
sw.js                   service worker (offline)
icon-180/192/512.png    iconos
```

## Notas de diseño del motor
- La dificultad de cada problema se puntúa con una función calibrada
  (`scoreDifficulty`) en escala ~1–100. Cada nivel es una **banda de score** +
  las **familias de estrategia** permitidas; los problemas se generan por
  *reject-sampling* dentro de la banda.
- La progresión usa una **ventana móvil** de las últimas 8 respuestas: sube si el
  rendimiento medio ≥ 0,74, baja si ≤ 0,42. El rendimiento de cada respuesta
  combina acierto y velocidad respecto al tiempo objetivo del nivel.

Estrategias basadas en *“Consulting & DI Fundamentals: Mental Math”* (Mike
Mascarenhas).
