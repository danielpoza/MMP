/* =========================================================
   world.js  —  El escenario (la isla)
   ---------------------------------------------------------
   El suelo se guarda en una rejilla ("grid") de casillas.
   Cada casilla es de un tipo: agua, hierba, camino, puente...
   Encima del suelo colocamos objetos: casas, molino, árboles.

   IMPORTANTE (para el Requisito 2): ahora dibujamos todo por
   código. Más adelante bastará con sustituir estos dibujos
   por imágenes .png reales (bitmaps) sin cambiar la lógica.
   ========================================================= */

// Tipos de casilla del suelo
const T_AGUA   = 0;
const T_HIERBA = 1;
const T_CAMINO = 2;
const T_PUENTE = 3;
const T_ARENA  = 4;

const TILE = 48;   // tamaño de cada casilla en píxeles (bloques grandes = pixel art)

class World {
  constructor() {
    this.cols = 52;
    this.rows = 34;
    this.tile = TILE;
    this.pixelWidth  = this.cols * TILE;   // tamaño total del mundo (más grande que la pantalla)
    this.pixelHeight = this.rows * TILE;
    this.time = 0;                          // reloj para animaciones (agua, molino)

    this.grid = [];        // suelo
    this.objetos = [];     // casas, molino, árboles, pozo, carro...
    this.monedas = [];     // monedas flotantes que se recogen
    this.npcs = [];        // aldeanos

    this._generar();
    this._crearMonedas();
    this._crearNpcs();
  }

  // ---- Utilidades de rejilla ----
  _get(c, f) {
    if (c < 0 || f < 0 || c >= this.cols || f >= this.rows) return T_AGUA;
    return this.grid[f][c];
  }
  _set(c, f, v) {
    if (c < 0 || f < 0 || c >= this.cols || f >= this.rows) return;
    this.grid[f][c] = v;
  }

  // ---- Construcción del escenario ----
  _generar() {
    // 1) Todo empieza siendo mar
    for (let f = 0; f < this.rows; f++) {
      this.grid[f] = [];
      for (let c = 0; c < this.cols; c++) this.grid[f][c] = T_AGUA;
    }

    // 2) Recortamos una isla (elipse) de hierba, con una orilla de arena
    const cx = this.cols / 2, cy = this.rows / 2;
    const rx = 23, ry = 15;
    for (let f = 0; f < this.rows; f++) {
      for (let c = 0; c < this.cols; c++) {
        const dx = (c - cx) / rx;
        const dy = (f - cy) / ry;
        const d = dx * dx + dy * dy;       // < 1 dentro de la elipse
        if (d < 0.9)      this._set(c, f, T_HIERBA);
        else if (d < 1.0) this._set(c, f, T_ARENA);   // playita en el borde
      }
    }

    // 3) Un río cruza la isla (banda de agua que serpentea)
    for (let f = 0; f < this.rows; f++) {
      const centro = 35 + 3 * Math.sin(f * 0.28);     // el río culebrea
      for (let c = 0; c < this.cols; c++) {
        if (this._get(c, f) === T_HIERBA && Math.abs(c - centro) < 1.4) {
          this._set(c, f, T_AGUA);
        }
      }
    }

    // 4) Los caminos de tierra, con UNA bifurcación
    //    Coordenadas en casillas (columna, fila).
    const entrada = [24, 31];   // por abajo se entra a la isla
    const cruce   = [24, 22];   // aquí el camino se bifurca
    // Rama izquierda -> aldea de casas
    this._camino([entrada, cruce, [16, 18], [10, 13]]);
    // Rama derecha  -> cruza el río por el puente hasta el molino
    this._camino([cruce, [30, 20], [37, 16], [42, 13]]);

    // 5) Objetos del escenario (posición en casillas -> se pasa a píxeles)
    const P = (c, f) => ({ x: c * TILE, y: f * TILE });

    // Molino junto al río y al puente
    this.objetos.push({ tipo: "molino", asset: "molino_torre", ...P(43, 11), w: 2 * TILE, h: 3 * TILE });

    // Aldea de casas a la izquierda (la roja se puede "entrar")
    this.objetos.push({ tipo: "casa", color: "#c0553b", asset: "casa_roja",     ...P(8, 11),  w: 2 * TILE, h: 2 * TILE, entrable: true });
    this.objetos.push({ tipo: "casa", color: "#5b8bbf", asset: "casa_azul",     ...P(12, 9),  w: 2 * TILE, h: 2 * TILE });
    this.objetos.push({ tipo: "casa", color: "#7aa15a", asset: "casa_verde",    ...P(9, 15),  w: 2 * TILE, h: 2 * TILE });
    // Un par de casas cerca de la entrada
    this.objetos.push({ tipo: "casa", color: "#caa24a", asset: "casa_amarilla", ...P(18, 27), w: 2 * TILE, h: 2 * TILE });
    this.objetos.push({ tipo: "casa", color: "#b06fb0", asset: "casa_morada",   ...P(30, 27), w: 2 * TILE, h: 2 * TILE });

    // Pozo en la aldea
    this.objetos.push({ tipo: "pozo", asset: "pozo", ...P(13, 13), w: TILE, h: TILE });

    // Un aldeano con su carro, aparcado al lado del camino (cerca de la entrada)
    // bajarY: empuja el dibujo hacia abajo para que las ruedas toquen el suelo
    this.objetos.push({ tipo: "carro", asset: "carro", ...P(28, 28), w: 2 * TILE, h: 2 * TILE, bajarY: 16 });

    // Cartel del mapa, en la arena junto a la casa roja (se puede clicar)
    this.cartel = { tipo: "cartel", asset: "cartel", ...P(5, 13), w: TILE, h: TILE };
    this.objetos.push(this.cartel);

    // Árboles y arbustos repartidos por la hierba (sin tapar caminos ni casas)
    this._sembrarVegetacion();

    // Orden de dibujo: por su "pie" (y+h) para que lo de delante tape a lo de detrás
    this.objetos.sort((a, b) => (a.y + a.h) - (b.y + b.h));
  }

  // Dibuja un camino grueso siguiendo una lista de puntos (en casillas)
  _camino(puntos) {
    const radio = 1.3;   // grosor del camino, en casillas
    for (let i = 0; i < puntos.length - 1; i++) {
      const [c0, f0] = puntos[i];
      const [c1, f1] = puntos[i + 1];
      const pasos = Math.ceil(Math.hypot(c1 - c0, f1 - f0) * 4);
      for (let p = 0; p <= pasos; p++) {
        const t = p / pasos;
        const cc = c0 + (c1 - c0) * t;
        const ff = f0 + (f1 - f0) * t;
        for (let df = -2; df <= 2; df++) {
          for (let dc = -2; dc <= 2; dc++) {
            if (Math.hypot(dc, df) > radio) continue;
            const c = Math.round(cc + dc), f = Math.round(ff + df);
            const actual = this._get(c, f);
            if (actual === T_AGUA) this._set(c, f, T_PUENTE);      // sobre el río -> puente
            else if (actual !== T_PUENTE) this._set(c, f, T_CAMINO);
          }
        }
      }
    }
  }

  _sembrarVegetacion() {
    // Semilla pseudoaleatoria simple para que siempre salga igual
    let semilla = 12345;
    const rnd = () => (semilla = (semilla * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;

    for (let intentos = 0; intentos < 240; intentos++) {
      const c = 2 + Math.floor(rnd() * (this.cols - 4));
      const f = 2 + Math.floor(rnd() * (this.rows - 4));
      if (this._get(c, f) !== T_HIERBA) continue;        // solo en hierba
      // Evitar pegarse demasiado a caminos (para no taparlos)
      if (this._get(c + 1, f) === T_CAMINO || this._get(c - 1, f) === T_CAMINO) continue;
      const esArbol = rnd() > 0.45;
      this.objetos.push({
        tipo: esArbol ? "arbol" : "arbusto",
        asset: esArbol ? "arbol" : "arbusto",
        x: c * TILE + 4, y: f * TILE - (esArbol ? TILE : 6),
        w: TILE, h: esArbol ? TILE * 2 : TILE,
        deco: rnd(),
      });
    }
  }

  // ---- Colisiones ----
  // La "huella" sólida de un objeto: el rectángulo del suelo que ocupa
  // (por dónde NO se puede caminar). Devuelve null si se puede atravesar.
  _huella(o) {
    switch (o.tipo) {
      // Toda la base de la casa (paredes), no solo una franja: así no se
      // puede "subir" al tejado.
      case "casa":   return { x: o.x + 6,        y: o.y + o.h * 0.40, w: o.w - 12,   h: o.h * 0.58 };
      case "molino": return { x: o.x + o.w * 0.2, y: o.y + o.h * 0.30, w: o.w * 0.6, h: o.h * 0.68 };
      case "pozo":   return { x: o.x + 8,         y: o.y + 18,        w: o.w - 16,  h: o.h - 22 };
      case "carro":  return { x: o.x + 6,         y: o.y + o.h * 0.45, w: o.w - 12, h: o.h * 0.50 };
      default:       return null;   // árboles y arbustos se atraviesan
    }
  }

  // ¿Se puede caminar por este punto (en píxeles del mundo)?
  esCaminable(px, py) {
    // Fuera del mapa: no
    if (px < 0 || py < 0 || px >= this.pixelWidth || py >= this.pixelHeight) return false;
    // Agua sin puente: no
    const t = this._get(Math.floor(px / TILE), Math.floor(py / TILE));
    if (t === T_AGUA) return false;
    // Chocar con la huella de casas / molino / pozo
    for (const o of this.objetos) {
      const b = this._huella(o);
      if (!b) continue;
      if (px > b.x && px < b.x + b.w && py > b.y && py < b.y + b.h) return false;
    }
    return true;
  }

  // ---- Monedas y aldeanos ----
  _crearMonedas() {
    // Posiciones (en casillas) sobre los caminos
    const pos = [[24, 28], [24, 25], [24, 23], [20, 19], [16, 17], [30, 20], [35, 17]];
    pos.forEach(([c, f], i) => {
      this.monedas.push({
        x: c * TILE + TILE / 2, y: f * TILE + TILE / 2,
        fase: i * 0.9, tomada: false, valor: 20,
      });
    });
  }

  _crearNpcs() {
    const T = TILE;
    const base = { tipo: "aldeano", ancho: 26, alto: 34, paso: 0 };
    // 1) Pasea arriba/abajo por el camino principal
    this.npcs.push({ ...base, x: 24 * T, y: 26 * T, eje: "y", dir: "abajo", vel: 55, y1: 21 * T, y2: 29 * T });
    // 2) Pasea izquierda/derecha por el sendero de la aldea
    this.npcs.push({ ...base, x: 12 * T, y: 18 * T, eje: "x", dir: "der", vel: 50, x1: 11 * T, x2: 19 * T });
    // 3) Quieto junto a una casa de la aldea
    this.npcs.push({ ...base, x: 11 * T, y: 13 * T, quieto: true, dir: "abajo" });
    // 4) Quieto en el campo, cerca del molino
    this.npcs.push({ ...base, x: 40 * T, y: 14 * T, quieto: true, dir: "izq" });
  }

  // Mueve a los aldeanos (se llama en cada frame)
  update(dt) {
    for (const n of this.npcs) {
      if (n.quieto) continue;                       // los parados no se mueven
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

  // ¿Hay una casa "entrable" cerca del jugador? Devuelve la casa o null.
  casaEntrableCerca(player) {
    const cx = player.x + player.ancho / 2, cy = player.y + player.alto / 2;
    for (const o of this.objetos) {
      if (!o.entrable) continue;
      const hx = o.x + o.w / 2, hy = o.y + o.h / 2;
      if (Math.hypot(cx - hx, cy - hy) < 95) return o;
    }
    return null;
  }

  // Comprueba si el jugador toca alguna moneda; devuelve los reales ganados
  recogerMonedas(player) {
    let ganado = 0;
    const cx = player.x + player.ancho / 2;
    const cy = player.y + player.alto / 2;
    for (const m of this.monedas) {
      if (m.tomada) continue;
      if (Math.hypot(cx - m.x, cy - m.y) < 26) { m.tomada = true; ganado += m.valor; }
    }
    return ganado;
  }

  // ================= DIBUJO =================
  // 1) El suelo (solo las casillas visibles: eficiente aunque el mapa sea enorme)
  drawGround(ctx, cam) {
    const c0 = Math.floor(cam.x / TILE), c1 = Math.ceil((cam.x + cam.ancho) / TILE);
    const f0 = Math.floor(cam.y / TILE), f1 = Math.ceil((cam.y + cam.alto) / TILE);
    for (let f = f0; f <= f1; f++) {
      for (let c = c0; c <= c1; c++) {
        this._dibujarCasilla(ctx, c, f, c * TILE - cam.x, f * TILE - cam.y);
      }
    }
  }

  // 2) Objetos + jugador, ordenados por su "pie" (baseY) para dar profundidad:
  //    lo que está más al sur se dibuja después (delante). Así el caballero
  //    pasa POR DETRÁS de casas y árboles cuando está más arriba que ellos.
  drawObjects(ctx, cam, player) {
    const lista = [];

    for (const o of this.objetos) {
      if (o.x + o.w < cam.x || o.x > cam.x + cam.ancho) continue;
      if (o.y + o.h < cam.y || o.y > cam.y + cam.alto) continue;
      lista.push({ baseY: o.y + o.h, dibujar: () => this._dibujarObjeto(ctx, o, o.x - cam.x, o.y - cam.y) });
    }

    for (const n of this.npcs) {
      if (n.x + n.ancho < cam.x || n.x > cam.x + cam.ancho) continue;
      if (n.y + n.alto < cam.y || n.y > cam.y + cam.alto) continue;
      lista.push({ baseY: n.y + n.alto, dibujar: () => this._dibujarNpc(ctx, n, cam) });
    }

    for (const m of this.monedas) {
      if (m.tomada) continue;
      if (m.x < cam.x - 20 || m.x > cam.x + cam.ancho + 20) continue;
      if (m.y < cam.y - 20 || m.y > cam.y + cam.alto + 20) continue;
      lista.push({ baseY: m.y + 6, dibujar: () => this._dibujarMoneda(ctx, m, m.x - cam.x, m.y - cam.y) });
    }

    if (player) {
      lista.push({ baseY: player.y + player.alto, dibujar: () => player.draw(ctx, cam) });
    }

    lista.sort((a, b) => a.baseY - b.baseY);
    for (const e of lista) e.dibujar();
  }

  // Moneda dorada que flota y "gira" (o su imagen moneda.png si existe)
  _dibujarMoneda(ctx, m, x, y) {
    const flota = Math.sin(this.time * 3 + m.fase) * 4;   // sube y baja
    const cy = y - 8 + flota;
    // Sombra fija en el suelo (para dar sensación de que flota)
    ctx.fillStyle = "rgba(0,0,0,.20)";
    ctx.beginPath(); ctx.ellipse(x, y + 12, 8, 3, 0, 0, Math.PI * 2); ctx.fill();

    // Giro: el ancho cambia como si la moneda rotara sobre su eje
    const giro = Math.abs(Math.cos(this.time * 3 + m.fase));
    const rw = 2 + 9 * giro;   // radio horizontal
    const rh = 11;             // radio vertical

    if (Assets.listo("moneda")) {
      ctx.drawImage(Assets.el("moneda"), x - rw, cy - rh, rw * 2, rh * 2);
      return;
    }
    // Dibujo de reserva: disco dorado con brillo
    ctx.fillStyle = "#a9740a";
    ctx.beginPath(); ctx.ellipse(x, cy, rw, rh, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#f6d367";
    ctx.beginPath(); ctx.ellipse(x, cy, Math.max(1, rw - 2), rh - 2, 0, 0, Math.PI * 2); ctx.fill();
    if (rw > 5) { ctx.fillStyle = "#c9962a"; ctx.fillRect(x - 1, cy - 5, 2, 10); }
    ctx.fillStyle = "rgba(255,255,255,.7)";
    ctx.beginPath(); ctx.ellipse(x - rw * 0.3, cy - rh * 0.4, Math.max(1, rw * 0.2), rh * 0.22, 0, 0, Math.PI * 2); ctx.fill();
  }

  // Aldeano (usa aldeano.png si existe; si no, un monigote sencillo)
  _dibujarNpc(ctx, n, cam) {
    const x = Math.round(n.x - cam.x);
    const y = Math.round(n.y - cam.y);
    const w = n.ancho, h = n.alto;

    // Sombra
    ctx.fillStyle = "rgba(0,0,0,.25)";
    ctx.beginPath(); ctx.ellipse(x + w / 2, y + h, w * 0.5, w * 0.22, 0, 0, Math.PI * 2); ctx.fill();

    if (Assets.listo("aldeano")) {
      const el = Assets.el("aldeano");
      const cw = Assets.w("aldeano") / 3, ch = Assets.h("aldeano") / 4;
      const fila = n.dir === "abajo" ? 0 : n.dir === "arriba" ? 1 : n.dir === "izq" ? 2 : 3;
      // Si está quieto, pose parada (col 0); si anda, recorre los 3 fotogramas
      const ciclo = [0, 1, 2, 1];
      const col = n.quieto ? 0 : ciclo[Math.floor(n.paso * 0.7) % 4];
      const destH = 50, destW = destH * (cw / ch);
      const bob = n.quieto ? 0 : Math.abs(Math.sin(n.paso)) * 3;
      ctx.drawImage(el, col * cw + 0.5, fila * ch + 0.5, cw - 1, ch - 1,
        Math.round(x + w / 2 - destW / 2), Math.round(y + h - destH + 8 - bob), destW, destH);
      return;
    }

    // Reserva: aldeano sencillo (túnica verde, sin espada)
    const bob = n.quieto ? 0 : Math.abs(Math.sin(n.paso)) * 2;
    const py = y - bob;
    const sep = n.quieto ? 0 : Math.sin(n.paso) * 3;
    ctx.fillStyle = "#4a3b2a";
    ctx.fillRect(x + 6 + sep, py + h - 10, 6, 10);
    ctx.fillRect(x + w - 12 - sep, py + h - 10, 6, 10);
    ctx.fillStyle = "#6b8e4e";
    ctx.fillRect(x + 4, py + 12, w - 8, h - 20);
    ctx.fillStyle = "#e8b48a";
    ctx.fillRect(x + 8, py + 2, w - 16, 12);
    ctx.fillStyle = "#8a5a2b";
    ctx.fillRect(x + 8, py, w - 16, 5);
  }

  // Columna de cada tipo dentro de tiles.png (orden: hierba, tierra, agua, arena, puente)
  _colTile(t) {
    if (t === T_HIERBA) return 0;
    if (t === T_CAMINO) return 1;
    if (t === T_AGUA)   return 2;
    if (t === T_ARENA)  return 3;
    return 4; // puente
  }

  _dibujarCasilla(ctx, c, f, x, y) {
    const t = this._get(c, f);

    // Si tenemos el tileset en imagen, lo usamos (recortando la casilla que toca)
    if (Assets.listo("tiles")) {
      const sw = Assets.w("tiles") / 5;   // 5 casillas en la tira
      const sh = Assets.h("tiles");
      const sx = this._colTile(t) * sw;
      // 0.5 px de margen para que no se "cuele" el borde de la casilla vecina
      ctx.drawImage(Assets.el("tiles"), sx + 0.5, 0.5, sw - 1, sh - 1, x, y, TILE, TILE);
      return;
    }

    // Ruidito determinista para dar variación sin que "parpadee"
    const h = ((c * 73856093) ^ (f * 19349663)) & 0xff;

    if (t === T_HIERBA) {
      ctx.fillStyle = (h & 8) ? "#5fa04a" : "#69ab4f";
      ctx.fillRect(x, y, TILE, TILE);
      if (h % 7 === 0) { ctx.fillStyle = "#e7e34c"; ctx.fillRect(x + (h % TILE), y + (h % 20) + 8, 4, 4); } // florecilla
      if (h % 11 === 0) { ctx.fillStyle = "#4f9040"; ctx.fillRect(x + (h % 30) + 6, y + (h % 15) + 20, 6, 3); }
    } else if (t === T_ARENA) {
      ctx.fillStyle = (h & 8) ? "#e3d29a" : "#dcc98c";
      ctx.fillRect(x, y, TILE, TILE);
    } else if (t === T_CAMINO) {
      ctx.fillStyle = (h & 8) ? "#c8a26a" : "#bd9760";
      ctx.fillRect(x, y, TILE, TILE);
      ctx.fillStyle = "#a9834f";
      if (h % 5 === 0) ctx.fillRect(x + (h % 30) + 4, y + (h % 30) + 4, 6, 6);   // piedrecitas
    } else if (t === T_PUENTE) {
      ctx.fillStyle = "#8a5a33";
      ctx.fillRect(x, y, TILE, TILE);
      ctx.fillStyle = "#6f4526";               // tablas
      for (let i = 0; i < TILE; i += 10) ctx.fillRect(x + i, y, 2, TILE);
    } else { // AGUA
      const onda = Math.sin(this.time * 2 + c * 0.6 + f * 0.4);
      ctx.fillStyle = onda > 0 ? "#3d7fb5" : "#356fa3";
      ctx.fillRect(x, y, TILE, TILE);
      if ((h + Math.floor(this.time * 2)) % 9 === 0) {
        ctx.fillStyle = "rgba(255,255,255,.35)";
        ctx.fillRect(x + (h % 30) + 4, y + (h % 24) + 10, 10, 3);   // brillo del agua
      }
    }
  }

  // Cuánto agrandar la imagen respecto a la "huella" del objeto (para que el
  // tejado/copa sobresalga un poco). Se afina a ojo con cada dibujo.
  _escalaImg(tipo) {
    if (tipo === "casa")    return 1.25;
    if (tipo === "molino")  return 1.15;
    if (tipo === "pozo")    return 1.20;
    if (tipo === "arbol")   return 1.55;
    if (tipo === "arbusto") return 1.15;
    if (tipo === "carro")   return 1.00;   // más pequeño que una casa
    if (tipo === "cartel")  return 1.25;
    return 1;
  }

  // Dibuja una imagen a lo ancho de o.w (por su escala), apoyada por su base
  // en el "pie" del objeto (para que encaje con la sombra y la profundidad).
  _blit(ctx, asset, o, x, y) {
    const el = Assets.el(asset);
    const iw = Assets.w(asset), ih = Assets.h(asset);
    const dw = o.w * this._escalaImg(o.tipo);
    const dh = dw * ih / iw;
    const dx = x + o.w / 2 - dw / 2;
    const dy = (y + o.h) - dh + (o.bajarY || 0);   // bajarY asienta el dibujo en el suelo
    ctx.drawImage(el, dx, dy, dw, dh);
    return { dx, dy, dw, dh };
  }

  _dibujarObjeto(ctx, o, x, y) {
    // El molino tiene tratamiento especial (torre + aspas girando)
    if (o.tipo === "molino") { this._dibujarMolino(ctx, o, x, y); return; }

    // Si existe la imagen del objeto, la usamos
    if (o.asset && Assets.listo(o.asset)) {
      this._sombra(ctx, x + o.w / 2, y + o.h - 8, o.w * 0.75);
      this._blit(ctx, o.asset, o, x, y);
      return;
    }

    // Reserva: dibujo por código
    switch (o.tipo) {
      case "casa":    this._casa(ctx, x, y, o.w, o.h, o.color); break;
      case "pozo":    this._pozo(ctx, x, y, o.w, o.h); break;
      case "arbol":   this._arbol(ctx, x, y, o.deco); break;
      case "arbusto": this._arbusto(ctx, x, y); break;
      case "carro":   this._carro(ctx, x, y, o.w, o.h); break;
      case "cartel":  this._cartel(ctx, x, y, o.w, o.h); break;
    }
  }

  // Cartel de madera con un mapita grabado (dibujo de reserva)
  _cartel(ctx, x, y, w, h) {
    this._sombra(ctx, x + w / 2, y + h - 4, w * 0.6);
    // Postes
    ctx.fillStyle = "#6b4a2b";
    ctx.fillRect(x + w * 0.30, y + h * 0.35, 5, h * 0.65);
    ctx.fillRect(x + w * 0.60, y + h * 0.35, 5, h * 0.65);
    // Tabla
    ctx.fillStyle = "#8a5a33";
    ctx.fillRect(x + 3, y + h * 0.08, w - 6, h * 0.34);
    ctx.fillStyle = "#6f4526";
    ctx.fillRect(x + 3, y + h * 0.08, w - 6, 3);
    // Mapita grabado (líneas claras)
    ctx.strokeStyle = "#e9dcc3"; ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(x + w * 0.28, y + h * 0.18); ctx.lineTo(x + w * 0.5, y + h * 0.32);
    ctx.lineTo(x + w * 0.72, y + h * 0.2);
    ctx.stroke();
    ctx.fillStyle = "#c0392b";                       // "X" del tesoro
    ctx.fillRect(x + w * 0.5 - 2, y + h * 0.3, 4, 4);
  }

  // Carro de madera con mercancías (dibujo de reserva)
  _carro(ctx, x, y, w, h) {
    this._sombra(ctx, x + w / 2, y + h - 8, w * 0.8);
    const by = y + h * 0.45;                      // altura del cajón
    // Cajón
    ctx.fillStyle = "#7a4a24";
    ctx.fillRect(x + 8, by, w - 16, h * 0.35);
    ctx.fillStyle = "#5e3618";
    for (let i = x + 8; i < x + w - 8; i += 10) ctx.fillRect(i, by, 2, h * 0.35);  // tablas
    // Mercancías (sacos / cajas)
    ctx.fillStyle = "#c9a24a"; ctx.fillRect(x + 12, by - 12, 14, 14);
    ctx.fillStyle = "#b06a3a"; ctx.fillRect(x + 30, by - 16, 16, 18);
    ctx.fillStyle = "#8a9b5a"; ctx.fillRect(x + w - 30, by - 12, 14, 14);
    // Rueda
    ctx.fillStyle = "#3a2a18";
    ctx.beginPath(); ctx.arc(x + w * 0.32, y + h - 8, 10, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(x + w * 0.7, y + h - 8, 10, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#7a5a34";
    ctx.beginPath(); ctx.arc(x + w * 0.32, y + h - 8, 4, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(x + w * 0.7, y + h - 8, 4, 0, Math.PI * 2); ctx.fill();
  }

  // Molino: torre fija + aspas que giran encima del eje
  _dibujarMolino(ctx, o, x, y) {
    if (Assets.listo("molino_torre")) {
      this._sombra(ctx, x + o.w / 2, y + o.h - 8, o.w * 0.75);
      const r = this._blit(ctx, "molino_torre", o, x, y);
      if (Assets.listo("molino_aspas")) {
        // Eje de las aspas: centrado en X, a media altura de la torre (calibrado)
        const ejeX = x + o.w / 2;
        const ejeY = r.dy + r.dh * 0.50;
        const lado = r.dw * 1.45;
        ctx.save();
        ctx.translate(ejeX, ejeY);
        ctx.rotate(this.time * 1.2);
        ctx.drawImage(Assets.el("molino_aspas"), -lado / 2, -lado / 2, lado, lado);
        ctx.restore();
      }
      return;
    }
    this._molino(ctx, x, y, o.w, o.h);   // reserva por código
  }

  _sombra(ctx, x, y, w) {
    ctx.fillStyle = "rgba(0,0,0,.18)";
    ctx.beginPath();
    ctx.ellipse(x + w / 2, y, w * 0.45, w * 0.16, 0, 0, Math.PI * 2);
    ctx.fill();
  }

  _casa(ctx, x, y, w, h, color) {
    this._sombra(ctx, x, y + h - 8, w);
    // Cuerpo
    ctx.fillStyle = "#e9dcc3";
    ctx.fillRect(x + 6, y + h * 0.42, w - 12, h * 0.55);
    // Vigas de madera
    ctx.fillStyle = "#6b4a2b";
    ctx.fillRect(x + 6, y + h * 0.42, 4, h * 0.55);
    ctx.fillRect(x + w - 10, y + h * 0.42, 4, h * 0.55);
    // Puerta
    ctx.fillStyle = "#5b3b20";
    ctx.fillRect(x + w / 2 - 8, y + h - 24, 16, 24);
    // Ventana
    ctx.fillStyle = "#8fd0e0";
    ctx.fillRect(x + 14, y + h * 0.52, 12, 12);
    // Tejado
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(x, y + h * 0.46);
    ctx.lineTo(x + w / 2, y + 4);
    ctx.lineTo(x + w, y + h * 0.46);
    ctx.closePath();
    ctx.fill();
    ctx.fillStyle = "rgba(0,0,0,.15)";     // sombra del tejado
    ctx.fillRect(x, y + h * 0.42, w, 5);
  }

  _molino(ctx, x, y, w, h) {
    this._sombra(ctx, x, y + h - 8, w);
    // Torre
    ctx.fillStyle = "#d9cdb0";
    ctx.fillRect(x + w * 0.2, y + h * 0.28, w * 0.6, h * 0.7);
    ctx.fillStyle = "#c3b493";
    ctx.fillRect(x + w * 0.2, y + h * 0.28, w * 0.6, 8);
    // Puerta
    ctx.fillStyle = "#5b3b20";
    ctx.fillRect(x + w / 2 - 9, y + h - 26, 18, 26);
    // Tejado cónico
    ctx.fillStyle = "#8a4b2f";
    ctx.beginPath();
    ctx.moveTo(x + w * 0.15, y + h * 0.3);
    ctx.lineTo(x + w / 2, y);
    ctx.lineTo(x + w * 0.85, y + h * 0.3);
    ctx.closePath();
    ctx.fill();
    // Aspas girando (¡animación!)
    const cxp = x + w / 2, cyp = y + h * 0.42;
    ctx.save();
    ctx.translate(cxp, cyp);
    ctx.rotate(this.time * 1.2);
    for (let i = 0; i < 4; i++) {
      ctx.rotate(Math.PI / 2);
      ctx.fillStyle = "#efe7d0";
      ctx.fillRect(-3, 0, 6, w * 0.9);
      ctx.fillStyle = "#c9b98f";
      ctx.fillRect(-3, 0, 6, 10);
    }
    ctx.fillStyle = "#3a2a18";
    ctx.beginPath(); ctx.arc(0, 0, 5, 0, Math.PI * 2); ctx.fill();
    ctx.restore();
  }

  _pozo(ctx, x, y, w, h) {
    this._sombra(ctx, x, y + h - 6, w);
    ctx.fillStyle = "#7d7d86";
    ctx.fillRect(x + 8, y + 20, w - 16, h - 24);
    ctx.fillStyle = "#2a2a33";
    ctx.fillRect(x + 12, y + 24, w - 24, 8);   // agua oscura
    ctx.fillStyle = "#6b4a2b";                  // tejadillo
    ctx.fillRect(x + 4, y + 6, w - 8, 8);
    ctx.fillRect(x + 10, y + 6, 4, 18);
    ctx.fillRect(x + w - 14, y + 6, 4, 18);
  }

  _arbol(ctx, x, y, deco) {
    this._sombra(ctx, x + TILE / 2, y + TILE * 2 - 10, TILE);
    // Tronco
    ctx.fillStyle = "#6b4423";
    ctx.fillRect(x + TILE / 2 - 5, y + TILE, 10, TILE);
    // Copa (varios círculos)
    const g = deco > 0.5 ? "#3f8a3a" : "#48973f";
    ctx.fillStyle = g;
    ctx.beginPath(); ctx.arc(x + TILE / 2, y + TILE * 0.7, 22, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(x + TILE / 2 - 14, y + TILE, 15, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(x + TILE / 2 + 14, y + TILE, 15, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "rgba(255,255,255,.12)";   // brillo de sol
    ctx.beginPath(); ctx.arc(x + TILE / 2 - 6, y + TILE * 0.6, 8, 0, Math.PI * 2); ctx.fill();
  }

  _arbusto(ctx, x, y) {
    this._sombra(ctx, x + TILE / 2, y + TILE - 6, TILE * 0.8);
    ctx.fillStyle = "#3f8a3a";
    ctx.beginPath(); ctx.arc(x + TILE / 2 - 8, y + TILE / 2, 11, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(x + TILE / 2 + 8, y + TILE / 2, 11, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(x + TILE / 2, y + TILE / 2 - 6, 12, 0, Math.PI * 2); ctx.fill();
  }
}
