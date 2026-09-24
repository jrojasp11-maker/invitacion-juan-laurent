# 📸 Assets Requeridos

Este proyecto necesita dos archivos multimedia que **tú debes proporcionar**:

## 1. `lirios.png` - Imagen del ramo

### Especificaciones

| Propiedad | Valor |
|-----------|-------|
| Nombre | `lirios.png` (exacto, en raíz) |
| Formato | PNG (transparencia) o JPG |
| Dimensiones | 800×600 px (4:3) o 1200×800 px |
| Tamaño | < 200 KB (optimizado web) |
| Estilo | Ramo de lirios asiáticos "Landini" (rosados/blancos) |

### Dónde conseguirlo

**Opción A: Foto propia (recomendada)**
- Toma una foto bonita de lirios Landini
- Edita en Canva/Photoshop: recorta 4:3, comprime

**Opción B: Stock libre de derechos**
- **Unsplash**: https://unsplash.com/s/photos/lilies → busca "asiatic lilies"
- **Pexels**: https://pexels.com/search/lilies/
- **Pixabay**: https://pixabay.com/images/search/lilies/
- **Filtro**: "Free for commercial use" / "No attribution required"

**Opción C: Generado por IA**
- Midjourney / DALL-E 3 / Stable Diffusion
- Prompt: *"Beautiful bouquet of pink and white asiatic Landini lilies, soft natural lighting, elegant arrangement, high quality photography, 4:3 aspect ratio"*

### Optimización (recomendado)

```bash
# Con ImageMagick (instalado via winget/chocolatey/brew)
magick input.jpg -resize 800x600^ -gravity center -extent 800x600 -quality 82 lirios.png

# O con sharp (Node.js)
npx sharp-cli -i input.jpg -o lirios.png --resize 800x600 --quality 82
```

---

## 2. `audio/music.mp3` - Música de fondo

Ver instrucciones detalladas en `audio/README.md`

### Resumen rápido

| Propiedad | Valor |
|-----------|-------|
| Nombre | `music.mp3` (en carpeta `audio/`) |
| Formato | MP3 |
| Duración | 30-60 seg (loop perfecto) |
| Tamaño | < 1 MB |
| Estilo | Piano instrumental, emotivo, estilo Evangelion |

### Fuentes legales gratuitas

1. **Pixabay Music** → busca "piano emotional loop"
2. **YouTube Audio Library** → "Cinematic > Piano"
3. **Free Music Archive** → tag "piano" + license "CC0"
4. **Crea tu propia versión** en GarageBand / FL Studio / BandLab

---

## ✅ Checklist antes de deploy

- [ ] `lirios.png` en raíz del proyecto (< 200 KB)
- [ ] `audio/music.mp3` en carpeta audio (< 1 MB)
- [ ] Ambos archivos son **libres de derechos** o **tuyos**
- [ ] Probado localmente: `npx serve .` → abre localhost
- [ ] Imagen se ve bien en móvil y desktop
- [ ] Audio suena al abrir sobre, botón mute funciona
- [ ] Loop de audio es imperceptible

---

## 📁 Estructura final esperada

```
invitacion-juan-laurent/
├── index.html
├── styles.css
├── script.js
├── vercel.json
├── .gitignore
├── README.md
├── supabase-schema.sql
├── ASSETS_README.md        ← Este archivo
├── lirios.png              ← 👈 TÚ PONES ESTO
└── audio/
    ├── README.md
    └── music.mp3           ← 👈 TÚ PONES ESTO
```