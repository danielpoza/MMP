# 🚀 Arrancar el proyecto en el Mac (con el MCP de Roblox Studio)

## 1. Instalar y conectar (una sola vez)

Abre la app **Terminal** (⌘ + Espacio → "Terminal") y ejecuta, en orden:

```bash
# ¿Está Node instalado? Tiene que decir algo como v20 o v22
node -v

# Instalar Claude Code (si no lo tienes)
npm install -g @anthropic-ai/claude-code

# Conectar Claude con Roblox Studio
claude mcp add --transport stdio Roblox_Studio -- "/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"

# Traerse el proyecto
git clone https://github.com/danielpoza/MMP.git
cd MMP
git checkout claude/roblox-studio-game-rh6gg7
```

## 2. Cada vez que os pongáis

1. Abre **Roblox Studio** con el mundo del juego cargado (el MCP necesita que
   esté abierto; si Studio pide permiso al plugin, acéptalo).
2. En la Terminal:

```bash
cd MMP
claude
```

3. Pega el texto de abajo. 👇

---

## 📋 TEXTO DE ARRANQUE (copiar y pegar en el Claude del Mac)

```text
Vas a continuar "LA NOCHE", un juego de terror de Roblox que está haciendo
MIGUEL (12 años). El juego es idea suya y lo está montando él solo: el diseño,
las decisiones y las pruebas en Roblox Studio son cosa suya. Háblale a él
directamente, y explícale las cosas para que las entienda y pueda cambiarlas.

CÓMO TRABAJAR
- Tienes el MCP "Roblox_Studio" conectado: crea y edita los scripts
  DIRECTAMENTE en Studio, no le pidas a Miguel que copie y pegue.
- Código en español, comentado y sencillo, para que Miguel lo entienda.
- Avanza en pasos pequeños y prueba cada cosa antes de seguir.
- Tono cercano, con emojis. Explica qué hace cada cambio antes de hacerlo.

EL JUEGO
Miguel tiene que aguantar una noche encerrado en su cuarto porque fuera hay un
monstruo. Tres opciones con la tecla E: salir a por comida, dormir o quedarse
despierto vigilando. Cada una tiene consecuencias. Se gana llegando a las 6:00.
El detalle está en roblox/docs/DISENO-LA-NOCHE.md y roblox/docs/IDEA-DEL-JUEGO.md

DÓNDE ESTÁ EL CÓDIGO
- roblox/scripts/ServerScriptService/LaNocheCorta.server.lua  ← LA VERSIÓN QUE
  FUNCIONA AHORA MISMO. Un solo Script, va en ServerScriptService y se llama
  "LaNoche" dentro de Studio. Construye: la noche, la mansión de 4 niveles más
  azotea, la escalera en zigzag, el garaje con el coche (matrícula Y 75689 HM3),
  las cortinas, el cuarto de Miguel en el piso 2 (justo encima del spawner), la
  habitación cerrada de los padres, las balizas de luz y las opciones de la
  tecla E. No necesita LocalScript.
- roblox/scripts/piezas/  ← versiones largas y separadas por temas (monstruo con
  articulaciones escondidas, nevera con comida, jardín con piscina). Sirven para
  ir recuperando cosas de una en una.

REGLA DE ORO QUE NOS COSTÓ CARA
Que NUNCA haya dos scripts construyendo lo mismo. Roblox no los arranca siempre
en el mismo orden, y como cada uno borraba y volvía a montar la casa, en cada
partida ganaba uno distinto y la casa cambiaba sola. Un solo script.

LO QUE ESTÁ PENDIENTE AHORA MISMO
1. Terminar de bajar las luces (todo brillaba como una linterna en los ojos).
   Miguel ya aplicó el cambio del bloque Lighting.ClockTime. Faltan:
   - la función lampara(): brillo 0.8, alcance 30, bombilla de color oscuro
   - las balizas del suelo: una cada 45 studs, brillo 0.5, alcance 22, color
     azul oscuro (80,115,175)
   - luzMesita: brillo 1, alcance 20
   El motivo: en Roblox muchas luces fuertes solapadas "queman" la imagen, y el
   material Neon brilla siempre a tope (por eso su color tiene que ir oscuro).
   La versión ya corregida está en el repo, en LaNocheCorta.server.lua.
2. Recuperar el MONSTRUO (está en roblox/scripts/piezas/, con la cabeza partida
   en dos, codo y rodilla escondidos, y persecución con PathfindingService).
3. Recuperar la nevera con comida y el jardín con la piscina.
4. El final de la partida cuando el monstruo te pilla.

Empieza saludando a Miguel, comprobando que ves Roblox Studio por el MCP, y
proponiendo terminar lo de las luces.
```
