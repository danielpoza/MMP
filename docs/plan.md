# 🗺️ Plan de trabajo — Crónicas de Miguel

Un juego de rol medieval en vista superior (top-down), hecho por Miguel (12) y papá.
Vamos por **requisitos pequeños e incrementales**: cada uno deja el juego jugable.

## Estado de los requisitos

- [x] **Req 1 — POC jugable** ← *hecho*
  - Pantalla de título ambientada con menú **Jugar / Salir**.
  - Mapa (isla) más grande que la pantalla, con **cámara que sigue al personaje**.
  - Camino con una **bifurcación**, **río con puente**, **casas**, **molino**
    (con aspas girando), árboles, arbustos, pozo, playa.
  - Caballero con espada que se mueve (flechas / WASD) y no cruza el agua ni las casas.

- [ ] **Req 2 — Gráficos con bitmaps reales**
  - Generar los `.png` siguiendo `inventario-sprites.md` (inventario + prompts).
  - Cargar imágenes y dibujarlas con `drawImage` (misma lógica, mejor aspecto).

- [ ] **Req 3 — Movimiento por caminos + colisiones finas**
  - Que el caballero ande sobre todo por los caminos; chocar mejor con casas/río.

- [ ] **Req 4 — Animación del personaje**
  - Sprites de caminar en 4 direcciones (usando el sprite sheet).

- [ ] **Req 5 — Interacción y NPCs**
  - Entrar en casas/molino, hablar con aldeanos, mensajes en pantalla.

- [ ] **Req 6 — Enemigos y combate**
  - Enemigos sencillos, ataque con espada, vidas/corazones.

- [ ] **Req 7 — Sonido**
  - Música ambiente y efectos (pasos, espada, río).

## Cómo se organiza el código

| Archivo         | Qué hace                                             |
|-----------------|------------------------------------------------------|
| `index.html`    | La página; carga el canvas y los scripts.            |
| `styles.css`    | Aspecto de la página y del "televisor" del juego.    |
| `js/input.js`   | Lee el teclado.                                      |
| `js/camera.js`  | La cámara que sigue al personaje.                    |
| `js/world.js`   | El escenario: suelo, río, caminos, casas, molino.    |
| `js/player.js`  | El caballero: movimiento y dibujo.                   |
| `js/ui.js`      | Pantalla de título, menú y despedida.                |
| `js/game.js`    | El "director": cambia entre título y juego.          |
| `js/main.js`    | Arranque y bucle principal (~60 veces por segundo).  |
| `server.js`     | Servidor local para jugar (necesita Node).           |

## Ideas para probar juntos (fáciles de cambiar)
- Velocidad del caballero: en `player.js`, la variable `this.velocidad`.
- Tamaño de la isla: en `world.js`, `rx` y `ry`.
- Colores de las casas: en `world.js`, donde pone `color:` de cada casa.
- Título del juego: en `ui.js`, el texto `"CRÓNICAS DE MIGUEL"`.
