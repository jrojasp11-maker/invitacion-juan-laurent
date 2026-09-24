# 🎵 Carpeta de Audio

## Archivo requerido

Coloca aquí tu archivo de música de fondo:

```
audio/
└── music.mp3          # ← Tu archivo aquí
```

## Especificaciones recomendadas

| Propiedad | Valor recomendado |
|-----------|-------------------|
| Formato | MP3 (máxima compatibilidad) |
| Duración | 30-60 segundos (loopable) |
| Bitrate | 128 kbps (suficiente para piano) |
| Tamaño | < 1 MB |
| Volumen | Normalizado a -16 LUFS aprox |

## Características musicales sugeridas

- **Estilo**: Piano instrumental, ambient, minimalista
- **Inspiración**: Neon Genesis Evangelion ("A Cruel Angel's Thesis" piano cover, "Thanatos", "Komm, süsser Tod" instrumental)
- **Mood**: Emotivo, nostálgico, íntimo
- **Loop**: Sin silencios al inicio/final, transiciona limpio

## ⚠️ IMPORTANTE: Derechos de autor

**NO uses** audio con copyright de Evangelion (King Records, Aniplex, etc.) sin licencia.

### Opciones legales gratuitas:

1. **Crear tu propia versión** - Graba un piano cover simple
2. **Free Music Archive** - https://freemusicarchive.org (filtra por "piano" + "CC0" o "CC-BY")
3. **Pixabay Music** - https://pixabay.com/music/ (gratis, sin atribución)
4. **YouTube Audio Library** - studio.youtube.com/channel/UC/music (gratis)
5. **Incompetech** - https://incompetech.com/music/ (Kevin MacLeod, CC-BY)
6. **BenSound** - https://www.bensound.com (gratis con atribución)
7. **OpenGameArt** - https://opengameart.org (busca "piano loop")

### Buscar términos útiles:
- "piano loop emotional"
- "ambient piano cinematic"
- "minimalist piano background"
- "nostalgic piano instrumental"

## Cómo probar

1. Coloca `music.mp3` en esta carpeta
2. Abre `index.html` en navegador
3. Click en el sobre → debería sonar música
4. Botón 🔊/🔇 en esquina sup. der. controla mute

## Conversión (si tienes otro formato)

```bash
# Con ffmpeg (instalado via winget/chocolatey/brew)
ffmpeg -i input.wav -c:a libmp3lame -b:a 128k -af "afade=t=in:st=0:d=2,afade=t=out:st=58:d=2" audio/music.mp3

# Para hacer loop perfecto (requiere edición en Audacity):
# 1. Abre en Audacity
# 2. Selecciona región que loopée bien
# 3. Effect > Repeat > 1 vez
# 4. Exporta como MP3
```