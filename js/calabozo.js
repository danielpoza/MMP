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
      { x: 110,  y: 555,  w: 455,  h: 680 },   // 0 calabozo (sala de entrada)
      { x: 520,  y: 560,  w: 790,  h: 490 },   // 1 pasillo (izquierda, antes de las rejas)
      { x: 1010, y: 400,  w: 235,  h: 300 },   // 2 celda vacía (interior, con la puerta de rejas)
      { x: 1405, y: 150,  w: 375,  h: 525 },   // 3 jardín (al aire libre)
      { x: 1360, y: 700,  w: 460,  h: 350 },   // 4 pasillo (derecha, tras las rejas)
      { x: 1795, y: 400,  w: 335,  h: 545 },   // 5 comedor
      { x: 2010, y: 555,  w: 475,  h: 305 },   // 6 pasillo de la bóveda
      { x: 2300, y: 150,  w: 400,  h: 435 },   // 7 bóveda
      { x: 1775, y: 1000, w: 250,  h: 360 },   // 8 celda con llave (regalo)
    ];

    // Entrada (dentro del calabozo) y salida (la puerta tumbada, para volver a la plaza)
    this.inicio = { x: Math.round(330 * this.escala), y: Math.round(900 * this.escala) };
    this.salida = { x: 210, y: 1030, w: 220, h: 200 };   // coords de imagen (puerta tumbada)

    // Puerta de rejas de la celda vacía (coords de imagen): bloquea hasta abrirla (E)
    this.puertaCelda = { x: 1018, y: 495, w: 180, h: 205, abierta: false };

    this.enemigos = [];   // los esqueletos se colocan en el Trozo 4
  }

  update(dt) { this.time += dt; }

  // ¿Se puede caminar en (px,py)? (coords del mundo -> coords de imagen)
  esCaminable(px, py) {
    if (px < 0 || py < 0 || px >= this.pixelWidth || py >= this.pixelHeight) return false;
    const ix = px / this.escala, iy = py / this.escala;
    let dentro = false;
    for (const z of this.zonas) {
      if (ix > z.x && ix < z.x + z.w && iy > z.y && iy < z.y + z.h) { dentro = true; break; }
    }
    if (!dentro) return false;
    // La puerta de la celda vacía bloquea el paso mientras esté cerrada
    const d = this.puertaCelda;
    if (!d.abierta && ix > d.x && ix < d.x + d.w && iy > d.y && iy < d.y + d.h) return false;
    return true;
  }

  // ¿Está el jugador junto a la salida (la puerta tumbada)?
  cercaDeSalida(player) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    const sx = (this.salida.x + this.salida.w / 2) * this.escala;
    const sy = (this.salida.y + this.salida.h / 2) * this.escala;
    return Math.hypot(px - sx, py - sy) < 70;
  }

  // ¿Está el jugador junto a la puerta de la celda vacía?
  cercaDeCelda(player) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    const d = this.puertaCelda;
    const cx = (d.x + d.w / 2) * this.escala, cy = (d.y + d.h) * this.escala;
    return Math.hypot(px - cx, py - cy) < 95;
  }

  // ================= DIBUJO =================
  drawGround(ctx, cam) {
    if (Assets.listo("prision")) {
      ctx.drawImage(Assets.el("prision"), Math.round(-cam.x), Math.round(-cam.y), this.pixelWidth, this.pixelHeight);
    } else {
      ctx.fillStyle = "#0a0b0e"; ctx.fillRect(0, 0, cam.ancho, cam.alto);
    }
    // Si la puerta de la celda está abierta, tapamos las rejas con un hueco oscuro
    if (this.puertaCelda.abierta) this._dibujarHuecoCelda(ctx, cam);
  }

  _dibujarHuecoCelda(ctx, cam) {
    const d = this.puertaCelda, s = this.escala;
    const x = Math.round(d.x * s - cam.x), y = Math.round(d.y * s - cam.y);
    const w = Math.round(d.w * s), h = Math.round(d.h * s);
    // Hueco oscuro (la celda por dentro) con un poco de suelo al fondo
    ctx.fillStyle = "#0b0c10"; ctx.fillRect(x, y, w, h);
    const g = ctx.createLinearGradient(x, y, x, y + h);
    g.addColorStop(0, "rgba(0,0,0,.55)"); g.addColorStop(1, "rgba(60,58,54,.35)");
    ctx.fillStyle = g; ctx.fillRect(x, y, w, h);
    ctx.fillStyle = "rgba(40,42,48,.6)"; ctx.fillRect(x, y + h - 6, w, 6);   // suelo abajo
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
