# 💌 Invitación Interactiva: Juan → Laurent

Una invitación web personalizada con experiencia de "sobre 3D" animado, selección de preferencias, confirmación con confeti y persistencia en Supabase.

![Demo](https://img.shields.io/badge/Demo-Live-brightgreen) ![License](https://img.shields.io/badge/License-MIT-blue) ![Stack](https://img.shields.io/badge/Stack-HTML%2FCSS%2FJS-orange)

## ✨ Características

- **Sobre 3D interactivo** - Animación de apertura con perspectiva CSS 3D
- **Audio de fondo** - Piano instrumental en loop (respeta políticas de autoplay)
- **Selectores visuales** - Película (4 géneros) y Sushi (4 tipos) con feedback háptico
- **Botón evasivo** - El botón "No" huye del cursor/touch
- **Confeti celebratorio** - Animación completa con canvas-confetti
- **Persistencia Supabase** - Guarda respuestas en PostgreSQL con RLS
- **Totalmente responsive** - Mobile-first, funciona en cualquier dispositivo
- **Accesible** - ARIA, focus management, prefers-reduced-motion

## 🚀 Demo en Vivo

> **[Ver invitación desplegada](https://invitacion-juan-laurent.vercel.app)** *(URL se actualiza tras deploy)*

## 📁 Estructura del Proyecto

```
invitacion-juan-laurent/
├── index.html          # Estructura HTML semántica
├── styles.css          # Estilos completos (CSS custom properties)
├── script.js           # Lógica vanilla JS (ES6+)
├── vercel.json         # Configuración de deploy Vercel
├── .gitignore          # Archivos ignorados por Git
├── README.md           # Este archivo
├── supabase-schema.sql # Esquema de base de datos
├── lirios.png          # Imagen del ramo (proveer)
└── audio/
    └── music.mp3       # Audio de fondo (proveer - libre de derechos)
```

## 🛠 Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Frontend | HTML5, CSS3 (Custom Properties), Vanilla JS (ES6+) |
| Fuentes | Google Fonts: Dancing Script + Inter |
| Audio | HTML5 Audio API |
| Confeti | canvas-confetti (CDN) |
| Backend | Supabase (PostgreSQL + RLS) |
| Deploy | Vercel (Static Hosting) |
| Control de versiones | Git + GitHub CLI |

## ⚙️ Instalación y Desarrollo Local

### Prerrequisitos

- Cuenta en [Supabase](https://supabase.com) (gratis)
- Cuenta en [GitHub](https://github.com)
- Cuenta en [Vercel](https://vercel.com)
- Node.js 18+ (opcional, para servidor local)

### 1. Clonar y configurar

```bash
git clone https://github.com/TU-USUARIO/invitacion-juan-laurent.git
cd invitacion-juan-laurent
```

### 2. Configurar Supabase

1. Crea un proyecto en [Supabase Dashboard](https://app.supabase.com)
2. Ve a **SQL Editor** y ejecuta el contenido de `supabase-schema.sql`
3. En **Settings > API**, copia:
   - `Project URL` → `SUPABASE_URL`
   - `anon public` key → `SUPABASE_ANON_KEY`

### 3. Configurar variables de entorno

Crea un archivo `.env` (no se commitea):

```env
# .env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
WHATSAPP_PHONE=54911XXXXXXXX  # Formato internacional sin +
```

### 4. Actualizar configuración en script.js

Edita `script.js` y reemplaza las constantes en `CONFIG`:

```javascript
const CONFIG = {
    supabase: {
        url: 'https://TU-PROYECTO.supabase.co',      // ← Tu URL
        anonKey: 'TU-ANON-KEY-AQUI'                  // ← Tu clave
    }
    // ... resto de config
};
```

### 5. Agregar assets multimedia

Coloca tus archivos en el proyecto:

```
├── lirios.png          # Ramo de lirios (recomendado: 800x600px, <200KB)
└── audio/
    └── music.mp3       # Piano instrumental (recomendado: <1MB, 30-60s loop)
```

> ⚠️ **Legal**: Usa solo audio con licencia propia, Creative Commons, o dominio público. No incluya música con derechos de autor de Evangelion sin licencia.

### 6. Servidor local (opcional)

```bash
# Con Node.js
npx serve .

# Con Python
python -m http.server 8000

# Con PHP
php -S localhost:8000
```

Abre `http://localhost:8000` en tu navegador.

## 🗄 Base de Datos (Supabase)

### Esquema

```sql
-- Ver archivo supabase-schema.sql para versión completa
CREATE TABLE IF NOT EXISTS respuestas_cita (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now(),
  genero_pelicula TEXT NOT NULL,
  sushi_favorito TEXT NOT NULL,
  estado TEXT DEFAULT 'Aceptado'
);

ALTER TABLE respuestas_cita ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir inserciones publicas" ON respuestas_cita
  FOR INSERT TO anon WITH CHECK (true);
```

### Políticas RLS

- **INSERT**: Permitido para rol `anon` (público)
- **SELECT**: Solo para roles autenticados (dashboard)
- **UPDATE/DELETE**: Solo para `service_role` (admin)

### Ver respuestas

En Supabase Dashboard → **Table Editor** → `respuestas_cita` verás todas las confirmaciones con timestamp.

## 🚀 Deploy en Vercel

### Opción A: Vercel CLI (Recomendado)

```bash
# Instalar Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy desde la raíz del proyecto
vercel

# Deploy a producción
vercel --prod
```

### Opción B: GitHub Integration

1. Push a GitHub:
   ```bash
   git add .
   git commit -m "feat: invitación inicial completa"
   git push origin main
   ```

2. En [Vercel Dashboard](https://vercel.com/dashboard):
   - **Add New Project** → Import from GitHub
   - Selecciona tu repo
   - Framework Preset: **Other**
   - Build Command: (vacío)
   - Output Directory: `.`
   - **Deploy**

3. Configura **Environment Variables** en Vercel:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

4. Actualiza `script.js` para leer de `window.ENV` o usa build-time replacement.

### Opción C: GitHub Actions (CI/CD)

Crea `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Vercel
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

## 📱 Capturas de Pantalla

| Estado | Vista |
|--------|-------|
| Sobre cerrado | ![Sobre](docs/sobre-cerrado.png) |
| Sobre abriéndose | ![Apertura](docs/sobre-abriendo.png) |
| Carta abierta | ![Carta](docs/carta-abierta.png) |
| Confirmación | ![Confeti](docs/confeti.png) |

## 🎨 Personalización

### Colores (CSS Custom Properties)

```css
:root {
    --color-seal: #c0392b;      /* Rojo sello/carta */
    --color-accent: #d4a574;    /* Dorado acentos */
    --color-bg: #fdfbf7;        /* Fondo crema */
    --color-ink: #2d2d2d;       /* Texto principal */
}
```

### Textos

Edita directamente en `index.html`:
- Título: `<h1 class="letter-title">Para ti, Laurent 💛</h1>`
- Cuerpo: párrafos con clase `.letter-text`
- Firma: `<span class="signature-name">Juan</span>`

### Opciones de película/sushi

Modifica los `value` y texto en los `label.option-card` del HTML.

## ♿ Accesibilidad

- ✅ Semántica HTML5 correcta
- ✅ ARIA labels en controles interactivos
- ✅ Focus visible y orden lógico
- ✅ `prefers-reduced-motion` respetado
- ✅ `prefers-contrast: high` soportado
- ✅ Contraste WCAG AA mínimo
- ✅ Screen reader announcements para selecciones

## 🔧 Scripts Útiles

```bash
# Verificar HTML
npx htmlhint index.html

# Verificar CSS
npx stylelint styles.css

# Verificar JS
npx eslint script.js

# Optimizar imagen
npx imagemin lirios.png --out-dir=.

# Verificar accesibilidad
npx pa11y http://localhost:8000
```

## 📄 Licencia

MIT License - Libre para uso personal y comercial.

```
MIT License

Copyright (c) 2025 Juan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software...
```

## 🙏 Créditos

- **Fuentes**: [Google Fonts](https://fonts.google.com/) - Dancing Script & Inter
- **Confeti**: [canvas-confetti](https://github.com/catdad/canvas-confetti) por catdad
- **Backend**: [Supabase](https://supabase.com/) - PostgreSQL como servicio
- **Hosting**: [Vercel](https://vercel.com/) - Deploy estático global
- **Inspiración**: Neon Genesis Evangelion (solo referencia temática, sin assets protegidos)

## 📞 Soporte

¿Problemas? Revisa:

1. **Consola del navegador** (F12) → errores de JS/red
2. **Network tab** → fallos de carga (audio, imagen, Supabase)
3. **Supabase Logs** → Dashboard → Logs → API/Database
4. **Vercel Function Logs** → Dashboard → Functions

---

**Hecho con ❤️ por Juan para Laurent**

*¿Te gustó? ¡Deja una ⭐ en GitHub!*