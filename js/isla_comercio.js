/* =========================================================
   isla_comercio.js  —  La Isla del Comercio
   ---------------------------------------------------------
   Entras por un callejón (donde está el fumador), que sube a
   una PLAZA con 4 puestos: fruta y verdura a la izquierda,
   pollo y minerales a la derecha. Entre dos puestos hay una
   PUERTA ESCONDIDA (llevará a la bóveda, más adelante).

   Suelo de hormigón blanco, paredes de ladrillo blanco
   (tiles_comercio.png). Funciona como un "mundo" para
   reutilizar Player y Camera.
   ========================================================= */

const C_SUELO = 0;   // hormigón
const C_PARED = 1;   // ladrillo blanco

class IslaComercio {
  constructor() {
    this.cols = 26;
    this.rows = 40;
    this.tile = TILE;
    this.pixelWidth = this.cols * TILE;
    this.pixelHeight = this.rows * TILE;
    this.time = 0;

    this.grid = [];
    this.puestos = [];
    this.inicio = { x: 13 * TILE, y: 36 * TILE };   // abajo, en el callejón

    this._generar();
  }

  _get(c, f) {
    if (c < 0 || f < 0 || c >= this.cols || f >= this.rows) return C_PARED;
    return this.grid[f][c];
  }

  _generar() {
    // Todo suelo de hormigón
    for (let f = 0; f < this.rows; f++) {
      this.grid[f] = [];
      for (let c = 0; c < this.cols; c++) this.grid[f][c] = C_SUELO;
    }
    // Muro perimetral (2 de grosor)
    for (let f = 0; f < this.rows; f++)
      for (let c = 0; c < this.cols; c++)
        if (c < 2 || c >= this.cols - 2 || f < 2 || f >= this.rows - 2) this.grid[f][c] = C_PARED;

    // El CALLEJÓN: de la fila 27 hacia abajo solo queda un pasillo central
    const corrL = 11, corrR = 14;
    for (let f = 27; f < this.rows - 2; f++)
      for (let c = 2; c < this.cols - 2; c++)
        if (c < corrL || c > corrR) this.grid[f][c] = C_PARED;

    // Los 4 puestos de la plaza
    const P = (c, f) => ({ x: c * TILE, y: f * TILE });
    this.puestos.push({ tipo: "fruta",     asset: "puesto_fruta",     ...P(3, 9),  w: 2 * TILE, h: 2 * TILE });
    this.puestos.push({ tipo: "verdura",   asset: "puesto_verdura",   ...P(3, 18), w: 2 * TILE, h: 2 * TILE });
    this.puestos.push({ tipo: "pollo",     asset: "puesto_pollo",     ...P(21, 9), w: 2 * TILE, h: 2 * TILE });
    this.puestos.push({ tipo: "minerales", asset: "puesto_minerales", ...P(21, 18), w: 2 * TILE, h: 2 * TILE });

    // Puerta escondida en la pared derecha, entre el puesto de pollo y el de minerales
    this.puerta = { x: 23 * TILE, y: 13 * TILE, w: TILE, h: 2 * TILE };

    // El fumador, quieto en el callejón junto a la entrada
    this.fumador = { x: 11 * TILE, y: 33 * TILE, ancho: 26, alto: 34 };
  }

  update(dt) { this.time += dt; }

  esCaminable(px, py) {
    if (px < 0 || py < 0 || px >= this.pixelWidth || py >= this.pixelHeight) return false;
    if (this._get(Math.floor(px / TILE), Math.floor(py / TILE)) === C_PARED) return false;
    // Puestos (bloquean su base)
    for (const o of this.puestos) {
      if (px > o.x + 6 && px < o.x + o.w - 6 && py > o.y + o.h * 0.45 && py < o.y + o.h) return false;
    }
    // La puerta escondida está cerrada
    const d = this.puerta;
    if (px > d.x - 2 && px < d.x + d.w + 2 && py > d.y && py < d.y + d.h) return false;
    return true;
  }

  // ¿Está el jugador junto a la puerta escondida? (para interactuar luego)
  cercaDePuerta(player) {
    const d = this.puerta;
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    return Math.hypot(px - (d.x + d.w / 2), py - (d.y + d.h / 2)) < 80;
  }

  // ================= DIBUJO =================
  drawGround(ctx, cam) {
    const c0 = Math.floor(cam.x / TILE), c1 = Math.ceil((cam.x + cam.ancho) / TILE);
    const f0 = Math.floor(cam.y / TILE), f1 = Math.ceil((cam.y + cam.alto) / TILE);
    for (let f = f0; f <= f1; f++) {
      for (let c = c0; c <= c1; c++) {
        this._dibujarCasilla(ctx, c, f, c * TILE - cam.x, f * TILE - cam.y);
      }
    }
  }

  _dibujarCasilla(ctx, c, f, x, y) {
    const t = this._get(c, f);
    if (Assets.listo("tiles_comercio")) {
      const img = Assets.el("tiles_comercio");
      const sw = Assets.w("tiles_comercio") / 4, sh = Assets.h("tiles_comercio");
      ctx.drawImage(img, t * sw + 0.5, 0.5, sw - 1, sh - 1, x, y, TILE, TILE);
      return;
    }
    // Reserva
    if (t === C_PARED) {
      ctx.fillStyle = "#eef0f3";                       // ladrillo blanco
      ctx.fillRect(x, y, TILE, TILE);
      ctx.strokeStyle = "#c9ccd2"; ctx.lineWidth = 2;
      for (let j = 0; j < TILE; j += 12) {
        ctx.beginPath(); ctx.moveTo(x, y + j); ctx.lineTo(x + TILE, y + j); ctx.stroke();
      }
      const off = (Math.floor((y) / 12) % 2) * 12;
      for (let i = -off; i < TILE; i += 24) { ctx.beginPath(); ctx.moveTo(x + i, y); ctx.lineTo(x + i, y + TILE); ctx.stroke(); }
    } else {
      const h = ((c * 73856093) ^ (f * 19349663)) & 0xff;
      ctx.fillStyle = (h & 8) ? "#e7e9ed" : "#e0e2e7";  // hormigón
      ctx.fillRect(x, y, TILE, TILE);
      ctx.strokeStyle = "#d2d5db"; ctx.lineWidth = 1;
      ctx.strokeRect(x + 0.5, y + 0.5, TILE, TILE);     // juntas
    }
  }

  drawObjects(ctx, cam, player) {
    const lista = [];
    const cull = (x, y, w, h) => !(x + w < cam.x || x > cam.x + cam.ancho || y + h < cam.y || y > cam.y + cam.alto);
    // Puerta escondida (se dibuja pegada a la pared, sutil)
    if (cull(this.puerta.x, this.puerta.y, this.puerta.w, this.puerta.h))
      lista.push({ baseY: this.puerta.y + this.puerta.h, dibujar: () => this._dibujarPuerta(ctx, this.puerta.x - cam.x, this.puerta.y - cam.y) });
    // Puestos
    for (const o of this.puestos) {
      if (!cull(o.x, o.y, o.w, o.h)) continue;
      lista.push({ baseY: o.y + o.h, dibujar: () => this._dibujarPuesto(ctx, o, o.x - cam.x, o.y - cam.y) });
    }
    // Fumador
    const fm = this.fumador;
    if (cull(fm.x, fm.y, fm.ancho, fm.alto))
      lista.push({ baseY: fm.y + fm.alto, dibujar: () => this._dibujarFumador(ctx, fm.x - cam.x, fm.y - cam.y) });
    // Jugador
    lista.push({ baseY: player.y + player.alto, dibujar: () => player.draw(ctx, cam) });

    lista.sort((a, b) => a.baseY - b.baseY);
    for (const e of lista) e.dibujar();
  }

  _sombra(ctx, cx, by, w) {
    ctx.fillStyle = "rgba(0,0,0,.20)";
    ctx.beginPath(); ctx.ellipse(cx, by, w * 0.42, w * 0.15, 0, 0, Math.PI * 2); ctx.fill();
  }

  _dibujarPuesto(ctx, o, x, y) {
    this._sombra(ctx, x + o.w / 2, y + o.h - 6, o.w);
    if (o.asset && Assets.listo(o.asset)) {
      const el = Assets.el(o.asset), iw = Assets.w(o.asset), ih = Assets.h(o.asset);
      const dw = o.w * 1.3, dh = dw * ih / iw;
      ctx.drawImage(el, x + o.w / 2 - dw / 2, (y + o.h) - dh + 10, dw, dh);
      return;
    }
    // Reserva: tenderete con toldo y mercancía por color
    const w = o.w, h = o.h, cy = y + h * 0.42;
    ctx.fillStyle = "#6b4a2b"; ctx.fillRect(x + 4, cy, 5, h * 0.55); ctx.fillRect(x + w - 9, cy, 5, h * 0.55);
    ctx.fillStyle = "#7a4a24"; ctx.fillRect(x + 4, y + h * 0.66, w - 8, h * 0.24);   // mostrador
    // Toldo a rayas
    for (let i = 0; i < w - 6; i += 12) {
      ctx.fillStyle = i % 24 === 0 ? "#c0392b" : "#e9dcc3";
      ctx.beginPath(); ctx.moveTo(x + 3 + i, cy); ctx.lineTo(x + 3 + i + 12, cy); ctx.lineTo(x + 3 + i + 6, cy + 10); ctx.closePath(); ctx.fill();
    }
    ctx.fillStyle = "#5b3b20"; ctx.fillRect(x + 3, y + h * 0.34, w - 6, cy - (y + h * 0.34) + 2);
    // Mercancía (colores según el tipo)
    const cols = {
      fruta: ["#e0392b", "#f6a11e", "#6bbf59", "#b06fb0"],
      verdura: ["#6bbf59", "#e0642b", "#3f8a3a", "#e0b53a"],
      pollo: ["#e8c9a0", "#c9a24a", "#8a5a33", "#efe6d0"],
      minerales: ["#f6d357", "#9b59b6", "#bfeaf5", "#b5764a"],
    }[o.tipo] || ["#ccc"];
    let i = 0;
    for (let gx = x + 12; gx < x + w - 12; gx += 12) {
      ctx.fillStyle = cols[i % cols.length];
      ctx.beginPath(); ctx.arc(gx, y + h * 0.62, 5, 0, Math.PI * 2); ctx.fill();
      i++;
    }
  }

  _dibujarPuerta(ctx, x, y) {
    const w = this.puerta.w, h = this.puerta.h;

    // Si existe el PNG, lo usamos tal cual (relleno el hueco de la puerta)
    if (Assets.listo("puerta")) {
      ctx.drawImage(Assets.el("puerta"), Math.round(x), Math.round(y), w, h);
      return;
    }

    // ---- DIBUJO DE RESERVA (por si falta el PNG) ----
    // La puerta se NOTA: marco plateado, madera oscura de pino y rejillas de metal.

    // 1) Marco plateado (borde metálico) alrededor de toda la puerta
    ctx.fillStyle = "#b9bec7";                       // acero claro
    ctx.fillRect(x, y, w, h);
    ctx.fillStyle = "#8f95a0";                       // sombra del marco (da relieve)
    ctx.fillRect(x + 2, y + 2, w - 4, h - 4);
    ctx.fillStyle = "#cdd2da";                       // brillo del borde
    ctx.fillRect(x + 1, y + 1, w - 2, 2);
    ctx.fillRect(x + 1, y + 1, 2, h - 2);

    // 2) Madera oscura de pino (tablones verticales) dentro del marco
    const mx = x + 6, my = y + 6, mw = w - 12, mh = h - 12;   // hueco interior de madera
    ctx.fillStyle = "#4a3221";                       // pino oscuro base
    ctx.fillRect(mx, my, mw, mh);
    const tabl = 3;                                  // 3 tablones verticales
    const tw = mw / tabl;
    for (let i = 0; i < tabl; i++) {
      const tx = mx + i * tw;
      // veta del tablón (líneas suaves más claras)
      ctx.strokeStyle = "rgba(120,84,52,.55)"; ctx.lineWidth = 1;
      for (let v = 0; v < 3; v++) {
        const vx = tx + tw * (0.3 + v * 0.22);
        ctx.beginPath(); ctx.moveTo(vx, my + 2); ctx.lineTo(vx, my + mh - 2); ctx.stroke();
      }
      // junta oscura entre tablones
      if (i > 0) { ctx.strokeStyle = "#2e2013"; ctx.beginPath(); ctx.moveTo(tx, my); ctx.lineTo(tx, my + mh); ctx.stroke(); }
    }
    // un par de nudos del pino
    ctx.fillStyle = "#3a2716";
    ctx.beginPath(); ctx.ellipse(mx + tw * 0.5, my + mh * 0.68, 3, 4, 0, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.ellipse(mx + tw * 2.4, my + mh * 0.30, 2.5, 3.5, 0, 0, Math.PI * 2); ctx.fill();

    // 3) Ventanuco enrejado en la parte de arriba: se ve el calabozo OSCURO detrás
    const rw = mw - 8, rh = mh * 0.34;
    const rx = mx + 4, ry = my + 5;
    ctx.fillStyle = "#050608";                       // negrura del calabozo
    ctx.fillRect(rx, ry, rw, rh);
    // barrotes verticales de metal
    ctx.strokeStyle = "#c2c7cf"; ctx.lineWidth = 2;
    const barras = 4;
    for (let i = 1; i <= barras; i++) {
      const bx = rx + (rw * i) / (barras + 1);
      ctx.beginPath(); ctx.moveTo(bx, ry + 1); ctx.lineTo(bx, ry + rh - 1); ctx.stroke();
    }
    // barrote horizontal + marco del ventanuco
    ctx.beginPath(); ctx.moveTo(rx, ry + rh / 2); ctx.lineTo(rx + rw, ry + rh / 2); ctx.stroke();
    ctx.strokeStyle = "#7c828c"; ctx.lineWidth = 2; ctx.strokeRect(rx, ry, rw, rh);

    // 4) Refuerzos de hierro (dos bandas horizontales) y remaches
    ctx.fillStyle = "#6b7079";
    const banda = (by) => {
      ctx.fillRect(mx, by, mw, 4);
      ctx.fillStyle = "#3a3e45";
      for (let i = 0; i < 4; i++) ctx.fillRect(mx + 3 + i * (mw / 4), by + 1, 2, 2);   // remaches
      ctx.fillStyle = "#6b7079";
    };
    banda(my + mh * 0.6);
    banda(my + mh * 0.82);

    // 5) Tirador de hierro
    ctx.fillStyle = "#3a3e45";
    ctx.beginPath(); ctx.arc(x + w - 11, y + h * 0.62, 3.5, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#20242a"; ctx.fillRect(x + w - 13, y + h * 0.62, 4, 8);
  }

  _dibujarFumador(ctx, x, y) {
    const w = this.fumador.ancho, h = this.fumador.alto;
    this._sombra(ctx, x + w / 2, y + h, w * 0.9);
    if (Assets.listo("fumador")) {
      const el = Assets.el("fumador"), iw = Assets.w("fumador"), ih = Assets.h("fumador");
      const destH = 52, destW = destH * (iw / ih);
      ctx.drawImage(el, Math.round(x + w / 2 - destW / 2), Math.round(y + h - destH + 8), destW, destH);
      return;
    }
    // Reserva: hombre con chaqueta y un cigarro humeante
    ctx.fillStyle = "#3a3550"; ctx.fillRect(x + 6, y + h - 10, 6, 10); ctx.fillRect(x + w - 12, y + h - 10, 6, 10);
    ctx.fillStyle = "#4a5a6a"; ctx.fillRect(x + 4, y + 12, w - 8, h - 20);   // chaqueta
    ctx.fillStyle = "#e8b48a"; ctx.fillRect(x + 8, y + 2, w - 16, 12);       // cara
    ctx.fillStyle = "#3a2a1a"; ctx.fillRect(x + 8, y, w - 16, 5);            // pelo
    // Cigarro + brasa + humo
    ctx.fillStyle = "#f2f2f2"; ctx.fillRect(x + w - 8, y + 9, 6, 2);
    ctx.fillStyle = "#ff7a2a"; ctx.fillRect(x + w - 3, y + 9, 2, 2);
    const s = Math.sin(this.time * 3);
    ctx.fillStyle = "rgba(220,220,220,.6)";
    ctx.fillRect(x + w - 2 + s, y + 2, 2, 2);
    ctx.fillRect(x + w + 1 - s, y - 3, 2, 2);
  }
}
