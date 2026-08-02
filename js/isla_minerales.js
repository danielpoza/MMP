/* =========================================================
   isla_minerales.js  —  La Isla de los Minerales
   ---------------------------------------------------------
   El SUELO es de piedra. Los minerales van EMBEBIDOS en el
   suelo (al ras, no como rocas que sobresalen). La piedra,
   al ser el suelo, no cuenta como depósito; el resto de
   minerales mantiene cantidades EXACTAS:
     hierro 120, oro 90, amatista 24, diamante 6  (240 vetas).

   Usa el tileset "tiles_minerales.png" (7 casillas). Si no
   está, se dibuja por código. Funciona como un "mundo"
   (esCaminable, drawGround...) para reutilizar Player/Camera.
   ========================================================= */

// Cantidades exactas de vetas (la piedra es el suelo, no se cuenta)
const MINERAL_CUENTA = { hierro: 120, oro: 90, ametista: 24, diamante: 6 };
// Columna de cada mena dentro de tiles_minerales.png
// (0 piedra, 1 agua, 2 arena, 3 hierro, 4 oro, 5 amatista, 6 diamante)
const MINERAL_COL = { hierro: 3, oro: 4, ametista: 5, diamante: 6 };

// Segundos hasta que una mena picada vuelve a aparecer (10 minutos)
const REGEN_SEG = 600;

class IslaMinerales {
  constructor() {
    this.cols = 80;                 // mucho más grande que la isla del anciano (52x34)
    this.rows = 60;
    this.tile = TILE;
    this.pixelWidth = this.cols * TILE;
    this.pixelHeight = this.rows * TILE;
    this.time = 0;

    this.grid = [];
    this.minerales = [];             // { c, f, tipo, v }
    this.mineralEn = new Map();      // "c,f" -> tipo (para dibujar el suelo)
    this.npcs = [];                  // mineros

    const ci = Math.floor(this.cols / 2), fi = Math.floor(this.rows / 2);
    // Puesto de picos, justo en el punto de aparición
    this.puesto = { x: (ci - 1) * TILE, y: (fi - 1) * TILE, w: 2 * TILE, h: 2 * TILE };
    // Apareces un par de casillas por debajo del puesto
    this.inicio = { x: ci * TILE, y: (fi + 2) * TILE };

    this._generar();
  }

  _get(c, f) {
    if (c < 0 || f < 0 || c >= this.cols || f >= this.rows) return T_AGUA;
    return this.grid[f][c];
  }

  _rng(seed) {
    let s = seed >>> 0;
    return () => (s = (s * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
  }

  _generar() {
    // 1) Todo mar
    for (let f = 0; f < this.rows; f++) {
      this.grid[f] = [];
      for (let c = 0; c < this.cols; c++) this.grid[f][c] = T_AGUA;
    }
    // 2) Isla grande: suelo de PIEDRA (usamos T_CAMINO como marca de "suelo") con orilla de arena
    const cx = this.cols / 2, cy = this.rows / 2, rx = 37, ry = 27;
    for (let f = 0; f < this.rows; f++) {
      for (let c = 0; c < this.cols; c++) {
        const dx = (c - cx) / rx, dy = (f - cy) / ry;
        const d = dx * dx + dy * dy;
        if (d < 0.9) this.grid[f][c] = T_CAMINO;       // suelo de piedra (pisable)
        else if (d < 1.0) this.grid[f][c] = T_ARENA;   // playa
      }
    }
    // 3) Repartir las vetas con cantidades EXACTAS
    this._colocarMinerales();
    // 4) Los mineros
    this._crearMineros();
  }

  _crearMineros() {
    const T = TILE;
    const base = { tipo: "minero", ancho: 26, alto: 34, paso: 0 };
    this.npcs = [
      { ...base, x: 36 * T, y: 26 * T, quieto: true, dir: "der" },                                  // picando
      { ...base, x: 47 * T, y: 34 * T, quieto: true, dir: "izq" },                                  // picando
      { ...base, x: 46 * T, y: 26 * T, eje: "x", dir: "der",   vel: 38, x1: 44 * T, x2: 52 * T },   // pasea
      { ...base, x: 38 * T, y: 36 * T, eje: "y", dir: "abajo", vel: 36, y1: 34 * T, y2: 44 * T },   // pasea
      { ...base, x: 34 * T, y: 38 * T, eje: "x", dir: "izq",   vel: 40, x1: 28 * T, x2: 38 * T },   // pasea
    ];
  }

  _colocarMinerales() {
    const rnd = this._rng(20240726);

    // Bolsa con exactamente 240 vetas (sin piedra: la piedra es el suelo)
    const bolsa = [];
    for (const tipo in MINERAL_CUENTA) {
      for (let i = 0; i < MINERAL_CUENTA[tipo]; i++) bolsa.push(tipo);
    }
    this._barajar(bolsa, rnd);

    // Casillas de suelo candidatas (dejando libre el centro donde aparece el jugador)
    const ci = Math.floor(this.cols / 2), fi = Math.floor(this.rows / 2);
    const cand = [];
    for (let f = 0; f < this.rows; f++) {
      for (let c = 0; c < this.cols; c++) {
        if (this._get(c, f) !== T_CAMINO) continue;
        if (Math.abs(c - ci) <= 2 && Math.abs(f - fi) <= 2) continue;
        cand.push([c, f]);
      }
    }
    this._barajar(cand, rnd);

    const n = Math.min(bolsa.length, cand.length);
    for (let i = 0; i < n; i++) {
      const [c, f] = cand[i];
      const m = { c, f, tipo: bolsa[i], v: rnd(), picada: false, regenEn: 0 };
      this.minerales.push(m);
      this.mineralEn.set(c + "," + f, m);   // guardamos el objeto (para saber si está picada)
    }
    this.stats = { ...MINERAL_CUENTA, total: n, casillasLibres: cand.length };
  }

  _barajar(arr, rnd) {
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(rnd() * (i + 1));
      const tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
    }
  }

  update(dt) {
    this.time += dt;
    // Mover a los mineros que pasean
    for (const n of this.npcs) {
      if (n.quieto) continue;
      if (n.eje === "x") {
        n.x += (n.dir === "der" ? 1 : -1) * n.vel * dt;
        if (n.x >= n.x2) { n.x = n.x2; n.dir = "izq"; }
        if (n.x <= n.x1) { n.x = n.x1; n.dir = "der"; }
      } else {
        n.y += (n.dir === "abajo" ? 1 : -1) * n.vel * dt;
        if (n.y >= n.y2) { n.y = n.y2; n.dir = "arriba"; }
        if (n.y <= n.y1) { n.y = n.y1; n.dir = "abajo"; }
      }
      n.paso += dt * 8;
    }
  }

  // ¿Hay una mena (sin picar) en la casilla (c,f)? Devuelve el objeto o null.
  menaEn(c, f) {
    const m = this.mineralEn.get(c + "," + f);
    return (m && !m.picada) ? m : null;
  }

  // Picar la mena de (c,f): se vuelve piedra y reaparece a los 10 min. Devuelve el tipo.
  picar(c, f, reloj) {
    const m = this.menaEn(c, f);
    if (!m) return null;
    m.picada = true;
    m.regenEn = reloj + REGEN_SEG;   // 10 minutos después
    return m.tipo;
  }

  // Restaurar las menas cuyo tiempo de regeneración ya ha pasado
  regenerar(reloj) {
    for (const m of this.minerales) {
      if (m.picada && reloj >= m.regenEn) m.picada = false;
    }
  }

  // El agua bloquea; los minerales están en el suelo (se puede pisar); el puesto es sólido
  esCaminable(px, py) {
    if (px < 0 || py < 0 || px >= this.pixelWidth || py >= this.pixelHeight) return false;
    if (this._get(Math.floor(px / TILE), Math.floor(py / TILE)) === T_AGUA) return false;
    const p = this.puesto;
    if (p && px > p.x + 6 && px < p.x + p.w - 6 && py > p.y + p.h * 0.45 && py < p.y + p.h) return false;
    return true;
  }

  // ================= DIBUJO =================
  // Columna del tileset para el suelo base (piedra/agua/arena)
  _tileColBase(t) {
    if (t === T_AGUA) return 1;
    if (t === T_ARENA) return 2;
    return 0; // piedra (suelo)
  }

  drawGround(ctx, cam) {
    const c0 = Math.floor(cam.x / TILE), c1 = Math.ceil((cam.x + cam.ancho) / TILE);
    const f0 = Math.floor(cam.y / TILE), f1 = Math.ceil((cam.y + cam.alto) / TILE);
    for (let f = f0; f <= f1; f++) {
      for (let c = c0; c <= c1; c++) {
        this._dibujarSuelo(ctx, c, f, c * TILE - cam.x, f * TILE - cam.y);
      }
    }
  }

  _dibujarSuelo(ctx, c, f, x, y) {
    const base = this._get(c, f);
    const obj = this.mineralEn.get(c + "," + f);
    const min = (obj && !obj.picada) ? obj.tipo : null;   // picada -> se ve piedra

    if (Assets.listo("tiles_minerales")) {
      const img = Assets.el("tiles_minerales");
      const sw = Assets.w("tiles_minerales") / 7, sh = Assets.h("tiles_minerales");
      const col = min ? MINERAL_COL[min] : this._tileColBase(base);
      ctx.drawImage(img, col * sw + 0.5, 0.5, sw - 1, sh - 1, x, y, TILE, TILE);
    } else {
      this._sueloProc(ctx, base, min, c, f, x, y);
    }

    // Los diamantes (solo 6) titilan un poco para encontrarlos
    if (min === "diamante") this._brilloDiamante(ctx, x, y, c, f);
  }

  _sueloProc(ctx, base, min, c, f, x, y) {
    const h = ((c * 73856093) ^ (f * 19349663)) & 0xff;
    if (base === T_AGUA) {
      const onda = Math.sin(this.time * 2 + c * 0.6 + f * 0.4);
      ctx.fillStyle = onda > 0 ? "#3d7fb5" : "#356fa3";
      ctx.fillRect(x, y, TILE, TILE);
      return;
    }
    if (base === T_ARENA) {
      ctx.fillStyle = (h & 8) ? "#e3d29a" : "#dcc98c";
      ctx.fillRect(x, y, TILE, TILE);
      return;
    }
    // Suelo de piedra
    ctx.fillStyle = (h & 8) ? "#8a8a93" : "#7e7e88";
    ctx.fillRect(x, y, TILE, TILE);
    ctx.fillStyle = "#6c6c74";                       // grietas/manchas
    if (h % 4 === 0) ctx.fillRect(x + (h % 30) + 3, y + (h % 30) + 3, 6, 3);
    if (h % 6 === 0) ctx.fillRect(x + (h % 22) + 10, y + (h % 16) + 20, 3, 5);
    ctx.fillStyle = "#9a9aa2";
    if (h % 5 === 0) ctx.fillRect(x + (h % 24) + 6, y + (h % 24) + 8, 3, 2);

    // Veta de mineral embebida al ras
    if (min) this._vetaProc(ctx, min, x, y, h);
  }

  _vetaProc(ctx, min, x, y, h) {
    let col1, col2;
    if (min === "hierro") { col1 = "#b5764a"; col2 = "#8a5230"; }
    else if (min === "oro") { col1 = "#f6d357"; col2 = "#d9a83a"; }
    else if (min === "ametista") { col1 = "#9b59b6"; col2 = "#7d3c98"; }
    else { col1 = "#e6ffff"; col2 = "#8fd7ea"; }      // diamante
    const puntos = [[13, 15], [27, 21], [18, 31], [31, 13], [9, 27], [23, 34]];
    for (let i = 0; i < 5; i++) {
      const [dx, dy] = puntos[(h + i * 3) % puntos.length];
      const px = x + dx, py = y + dy, r = 3.5;
      ctx.fillStyle = i % 2 ? col2 : col1;
      ctx.beginPath();
      ctx.moveTo(px, py - r); ctx.lineTo(px + r * 0.7, py); ctx.lineTo(px, py + r); ctx.lineTo(px - r * 0.7, py);
      ctx.closePath(); ctx.fill();
    }
  }

  _brilloDiamante(ctx, x, y, c, f) {
    const pulso = 0.5 + 0.5 * Math.abs(Math.sin(this.time * 3 + c * 0.5 + f * 0.9));
    ctx.save();
    ctx.globalCompositeOperation = "lighter";
    const g = ctx.createRadialGradient(x + TILE / 2, y + TILE / 2, 2, x + TILE / 2, y + TILE / 2, 18 * pulso);
    g.addColorStop(0, "rgba(150,230,255,.4)");
    g.addColorStop(1, "rgba(150,230,255,0)");
    ctx.fillStyle = g;
    ctx.fillRect(x - 6, y - 6, TILE + 12, TILE + 12);
    ctx.restore();
    // Destello
    ctx.fillStyle = `rgba(255,255,255,${pulso})`;
    ctx.fillRect(x + TILE * 0.55, y + TILE * 0.3, 2, 2);
  }

  // Dibuja el puesto y al jugador ordenados por profundidad (los minerales son suelo)
  drawObjects(ctx, cam, player) {
    const lista = [];
    const p = this.puesto;
    if (p && !(p.x + p.w < cam.x || p.x > cam.x + cam.ancho || p.y + p.h < cam.y || p.y > cam.y + cam.alto)) {
      lista.push({ baseY: p.y + p.h, dibujar: () => this._dibujarPuesto(ctx, p.x - cam.x, p.y - cam.y, p.w, p.h) });
    }
    for (const n of this.npcs) {
      if (n.x + n.ancho < cam.x || n.x > cam.x + cam.ancho) continue;
      if (n.y + n.alto < cam.y || n.y > cam.y + cam.alto) continue;
      lista.push({ baseY: n.y + n.alto, dibujar: () => this._dibujarMinero(ctx, n, cam) });
    }
    lista.push({ baseY: player.y + player.alto, dibujar: () => player.draw(ctx, cam) });
    lista.sort((a, b) => a.baseY - b.baseY);
    for (const e of lista) e.dibujar();
  }

  // Un minero (sprite minero.png de 4x3, o un monigote de reserva)
  _dibujarMinero(ctx, n, cam) {
    const x = Math.round(n.x - cam.x), y = Math.round(n.y - cam.y), w = n.ancho, h = n.alto;
    ctx.fillStyle = "rgba(0,0,0,.25)";
    ctx.beginPath(); ctx.ellipse(x + w / 2, y + h, w * 0.5, w * 0.22, 0, 0, Math.PI * 2); ctx.fill();

    if (Assets.listo("minero")) {
      const el = Assets.el("minero");
      const cw = Assets.w("minero") / 3, ch = Assets.h("minero") / 4;
      const fila = n.dir === "abajo" ? 0 : n.dir === "arriba" ? 1 : n.dir === "izq" ? 2 : 3;
      const ciclo = [0, 1, 2, 1];
      const col = n.quieto ? 0 : ciclo[Math.floor(n.paso * 0.7) % 4];
      const destH = 50, destW = destH * (cw / ch);
      const bob = n.quieto ? 0 : Math.abs(Math.sin(n.paso)) * 3;
      ctx.drawImage(el, col * cw + 0.5, fila * ch + 0.5, cw - 1, ch - 1,
        Math.round(x + w / 2 - destW / 2), Math.round(y + h - destH + 8 - bob), destW, destH);
      return;
    }
    // Reserva: minero con casco amarillo
    const bob = n.quieto ? 0 : Math.abs(Math.sin(n.paso)) * 2;
    const py = y - bob, sep = n.quieto ? 0 : Math.sin(n.paso) * 3;
    ctx.fillStyle = "#4a3b2a";
    ctx.fillRect(x + 6 + sep, py + h - 10, 6, 10);
    ctx.fillRect(x + w - 12 - sep, py + h - 10, 6, 10);
    ctx.fillStyle = "#8a7a5a";
    ctx.fillRect(x + 4, py + 12, w - 8, h - 20);
    ctx.fillStyle = "#e8b48a";
    ctx.fillRect(x + 8, py + 2, w - 16, 12);
    ctx.fillStyle = "#e0b53a";
    ctx.fillRect(x + 7, py, w - 14, 5);
  }

  // Puesto de picos (imagen tienda_exterior.png o dibujo de reserva)
  _dibujarPuesto(ctx, x, y, w, h) {
    ctx.fillStyle = "rgba(0,0,0,.22)";
    ctx.beginPath(); ctx.ellipse(x + w / 2, y + h - 6, w * 0.42, w * 0.15, 0, 0, Math.PI * 2); ctx.fill();

    if (Assets.listo("tienda_exterior")) {
      const el = Assets.el("tienda_exterior");
      const iw = Assets.w("tienda_exterior"), ih = Assets.h("tienda_exterior");
      const dw = w * 1.35, dh = dw * ih / iw;
      const bajar = 20;   // baja el dibujo para que no flote
      ctx.drawImage(el, x + w / 2 - dw / 2, (y + h) - dh + bajar, dw, dh);
      return;
    }
    // Reserva: tenderete con toldo a rayas y picos
    const cy = y + h * 0.5;
    ctx.fillStyle = "#6b4a2b";                       // postes
    ctx.fillRect(x + 4, cy, 5, h * 0.5);
    ctx.fillRect(x + w - 9, cy, 5, h * 0.5);
    ctx.fillStyle = "#7a4a24";                       // mostrador
    ctx.fillRect(x + 4, y + h * 0.72, w - 8, h * 0.2);
    // Toldo a rayas
    for (let i = 0; i < w - 6; i += 12) {
      ctx.fillStyle = i % 24 === 0 ? "#c0392b" : "#e9dcc3";
      ctx.beginPath();
      ctx.moveTo(x + 3 + i, cy); ctx.lineTo(x + 3 + i + 12, cy); ctx.lineTo(x + 3 + i + 6, cy + 10);
      ctx.closePath(); ctx.fill();
    }
    ctx.fillStyle = "#5b3b20";
    ctx.fillRect(x + 3, y + h * 0.42, w - 6, cy - (y + h * 0.42) + 2);
    // Un pico apoyado
    ctx.strokeStyle = "#8a5a33"; ctx.lineWidth = 3;
    ctx.beginPath(); ctx.moveTo(x + w * 0.5, y + h * 0.7); ctx.lineTo(x + w * 0.62, y + h * 0.5); ctx.stroke();
    ctx.strokeStyle = "#c0c0c8"; ctx.lineWidth = 4;
    ctx.beginPath(); ctx.moveTo(x + w * 0.55, y + h * 0.46); ctx.lineTo(x + w * 0.69, y + h * 0.52); ctx.stroke();
  }
}
