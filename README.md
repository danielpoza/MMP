# ⚔️ Crónicas de Miguel

Un pequeño videojuego de rol medieval en vista superior, hecho en familia.
Estás en el **Requisito 1**: una POC jugable con pantalla de título y un mapa
por el que se mueve un caballero, con la cámara siguiéndolo.

## ▶️ Cómo jugar

Necesitas [Node.js](https://nodejs.org) instalado (ya lo tienes: v24).

1. Abre una terminal en esta carpeta.
2. Arranca el servidor:

```bash
node server.js
```

3. Abre el navegador en **http://localhost:8080**

### Controles
- **Mover:** Flechas o `W` `A` `S` `D`
- **Elegir en el menú:** Flechas Arriba/Abajo + `Enter`
- **Volver al menú:** `Esc`

## 📂 Qué hay dentro
Mira `docs/plan.md` para el plan completo y `docs/inventario-sprites.md` para el
inventario de imágenes y los prompts con los que generarlas.

> Nota: hace falta abrirlo por `http://` (con el servidor). Si abres el
> `index.html` haciendo doble clic (`file://`), el navegador bloquea parte del
> juego por seguridad.
