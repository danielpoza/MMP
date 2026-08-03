/* =========================================================
   calabozo.js  —  La PRISIÓN (tras tumbar la puerta)
   ---------------------------------------------------------
   Usa la imagen "prision.png" (mapa completo dibujado) como
   suelo, y un conjunto de ZONAS caminables (rectángulos) para
   las colisiones: solo se puede andar por dentro de esas zonas
   (el resto son paredes). Las zonas están en coordenadas de la
   IMAGEN (2752×1536) y se convierten al mundo con "escala".
   Reutiliza el mismo Player y Camera que las islas.
   ========================================================= */

class Calabozo {
  constructor() {
    this.imgW = 2752;             // tamaño de prision.png
    this.imgH = 1536;
    this.escala = 0.6;            // reducimos el mapa para que el héroe tenga buen tamaño
    this.pixelWidth = Math.round(this.imgW * this.escala);
    this.pixelHeight = Math.round(this.imgH * this.escala);
    this.time = 0;

    // ZONAS por las que SE PUEDE caminar (en coords de la imagen). El resto = pared.
    // (Primer borrado; se afina comparando con el mapa.)
    this.zonas = [
      { x: 150,  y: 516,  w: 396,  h: 800 },   // 0 calabozo (sala de entrada, izq)
      { x: 500,  y: 637,  w: 960,  h: 373 },   // 1 pasillo (tramo izquierdo)
      { x: 1038, y: 367,  w: 264,  h: 330 },   // 2 celda vacía (con pared agrietada)
      { x: 1370, y: 129,  w: 416,  h: 555 },   // 3 jardín (al aire libre)
      { x: 1300, y: 640,  w: 560,  h: 380 },   // 4 pasillo (tramo central)
      { x: 1795, y: 430,  w: 305,  h: 505 },   // 5 comedor
      { x: 1300, y: 1000, w: 270,  h: 355 },   // 6 pasillo inferior
      { x: 1700, y: 900,  w: 300,  h: 455 },   // 7 celda con llave (regalo)
      { x: 2000, y: 510,  w: 490,  h: 345 },   // 8 pasillo de la bóveda
      { x: 2351, y: 143,  w: 340,  h: 420 },   // 9 bóveda
    ];

    // Entrada (dentro del calabozo) y salida (la puerta tumbada, para volver a la plaza)
    this.inicio = { x: Math.round(330 * this.escala), y: Math.round(900 * this.escala) };
    this.salida = { x: 210, y: 1030, w: 220, h: 200 };   // coords de imagen (puerta tumbada)

    this.enemigos = [];   // los esqueletos se colocan en el Trozo 4
  }

  update(dt) { this.time += dt; }

  // ¿Se puede caminar en (px,py)? (coords del mundo -> coords de imagen)
  esCaminable(px, py) {
    if (px < 0 || py < 0 || px >= this.pixelWidth || py >= this.pixelHeight) return false;
    const ix = px / this.escala, iy = py / this.escala;
    for (const z of this.zonas) {
      if (ix > z.x && ix < z.x + z.w && iy > z.y && iy < z.y + z.h) return true;
    }
    return false;
  }

  // ¿Está el jugador junto a la salida (la puerta tumbada)?
  cercaDeSalida(player) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    const sx = (this.salida.x + this.salida.w / 2) * this.escala;
    const sy = (this.salida.y + this.salida.h / 2) * this.escala;
    return Math.hypot(px - sx, py - sy) < 70;
  }

  // ================= DIBUJO =================
  drawGround(ctx, cam) {
    if (Assets.listo("prision")) {
      ctx.drawImage(Assets.el("prision"), Math.round(-cam.x), Math.round(-cam.y), this.pixelWidth, this.pixelHeight);
    } else {
      ctx.fillStyle = "#0a0b0e"; ctx.fillRect(0, 0, cam.ancho, cam.alto);
    }
  }

  drawObjects(ctx, cam, player) {
    const lista = [];
    for (const en of this.enemigos) {
      lista.push({ baseY: en.estado === "muerto" ? -1e9 : en.y + en.alto, dibujar: () => en.draw(ctx, cam) });
    }
    lista.push({ baseY: player.y + player.alto, dibujar: () => player.draw(ctx, cam) });
    lista.sort((a, b) => a.baseY - b.baseY);
    for (const e of lista) e.dibujar();
  }

  enemigosVivos() { return this.enemigos.filter((e) => e.estado !== "muerto").length; }
}
