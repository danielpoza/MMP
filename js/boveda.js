/* =========================================================
   boveda.js  —  La BÓVEDA del tesoro (jefe final de la misión)
   ---------------------------------------------------------
   Escena con imagen de fondo (boveda.png). Tiene DOS estados:
     - ataúd cerrado  -> se dibuja "boveda.png"
     - ataúd abierto  -> se dibuja "boveda_ataque.png" (sale el
       ESQUELETO GIGANTE del ataúd)
   Zonas caminables a mano (coords de imagen), igual que la
   prisión. Objetos: el ataúd (despierta al jefe), el cofre del
   mapa del tesoro (sobre el pedestal) y el agujero (Bajar).
   ========================================================= */

class Boveda {
  constructor() {
    this.imgW = 2752;
    this.imgH = 1536;
    this.escala = 0.6;
    this.pixelWidth = Math.round(this.imgW * this.escala);
    this.pixelHeight = Math.round(this.imgH * this.escala);
    this.time = 0;

    // Zonas por las que SE PUEDE caminar (coords de imagen). El resto = pared.
    this.zonas = [
      { x: 210, y: 500, w: 2350, h: 1000 },   // suelo principal de la sala
    ];

    // Obstáculos sólidos (coords de imagen): no se puede caminar por encima.
    this.mesa     = { x: 1060, y: 560,  w: 660, h: 300 };   // mesa de pergaminos
    this.ataud    = { x: 985,  y: 1075, w: 700, h: 455 };   // ataúd de piedra (abajo-centro)
    this.pedestal = { x: 2150, y: 360,  w: 340, h: 290 };   // pedestal del cofre del mapa
    this.agujero  = { x: 2040, y: 1010, w: 470, h: 500 };   // agujero (abajo-derecha)

    // Entrada (aparece junto a la puerta) y puerta de salida (volver a la prisión)
    this.inicio = { x: Math.round(560 * this.escala), y: Math.round(560 * this.escala) };
    this.puertaSalida = { x: 400, y: 380, w: 320, h: 240 };  // hueco de la puerta abierta

    // Estado de la misión
    this.ataudAbierto = false;   // ¿ha salido el gigante? (cambia el fondo)
    this.jefeDerrotado = false;  // ¿está muerto el esqueleto gigante?
    this.mapaObtenido = false;   // ¿ha cogido el mapa del tesoro?

    this.enemigos = [];          // el gigante se añade cuando se abre el ataúd
  }

  update(dt) {
    this.time += dt;
    // Si el gigante ha muerto, marcamos la misión como superada
    if (!this.jefeDerrotado && this.enemigos.length && this.enemigos.every((e) => e.estado === "muerto")) {
      this.jefeDerrotado = true;
    }
  }

  _solidos() {
    // El ataúd deja de estorbar cuando el jefe ya ha salido (para poder rodearlo)
    const s = [this.mesa, this.pedestal, this.agujero];
    if (!this.ataudAbierto) s.push(this.ataud);
    return s;
  }

  esCaminable(px, py) {
    if (px < 0 || py < 0 || px >= this.pixelWidth || py >= this.pixelHeight) return false;
    const ix = px / this.escala, iy = py / this.escala;
    let dentro = false;
    for (const z of this.zonas) {
      if (ix > z.x && ix < z.x + z.w && iy > z.y && iy < z.y + z.h) { dentro = true; break; }
    }
    if (!dentro) return false;
    for (const s of this._solidos()) {
      if (ix > s.x && ix < s.x + s.w && iy > s.y && iy < s.y + s.h) return false;
    }
    return true;
  }

  // ---- Cercanías (para los avisos "(E)") ----
  _cerca(player, ix, iy, r) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    return Math.hypot(px - ix * this.escala, py - iy * this.escala) < r;
  }
  cercaDeAtaud(player)     { return this._cerca(player, this.ataud.x + this.ataud.w / 2, this.ataud.y, 95); }
  cercaDeCofreMapa(player) { return this._cerca(player, this.pedestal.x + this.pedestal.w / 2, this.pedestal.y + this.pedestal.h, 95); }
  // El agujero es grande y sólido (no se entra): medimos la distancia a su BORDE,
  // no al centro, para que salga "Bajar (E)" al acercarse por cualquier lado.
  cercaDeAgujero(player) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    const A = this.agujero, s = this.escala;
    const x0 = A.x * s, y0 = A.y * s, x1 = (A.x + A.w) * s, y1 = (A.y + A.h) * s;
    const dx = Math.max(x0 - px, 0, px - x1);
    const dy = Math.max(y0 - py, 0, py - y1);
    return Math.hypot(dx, dy) < 55;
  }
  cercaDeSalida(player)    { return this._cerca(player, this.puertaSalida.x + this.puertaSalida.w / 2, this.puertaSalida.y + this.puertaSalida.h, 90); }

  // Despierta al jefe: abre el ataúd (cambia el fondo) y lo hace salir
  despertarGigante() {
    if (this.ataudAbierto) return;
    this.ataudAbierto = true;
    // El gigante sale del ataúd (pies un poco por encima del centro del ataúd)
    const gx = Math.round((this.ataud.x + this.ataud.w / 2) * this.escala - 27);
    const gy = Math.round((this.ataud.y + 40) * this.escala - 80);
    this.enemigos.push(new EsqueletoGigante(gx, gy));
  }

  // ================= DIBUJO =================
  drawGround(ctx, cam) {
    const fondo = this.ataudAbierto ? "boveda_ataque" : "boveda";
    if (Assets.listo(fondo)) {
      ctx.drawImage(Assets.el(fondo), Math.round(-cam.x), Math.round(-cam.y), this.pixelWidth, this.pixelHeight);
    } else {
      ctx.fillStyle = "#1a1408"; ctx.fillRect(0, 0, cam.ancho, cam.alto);
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
