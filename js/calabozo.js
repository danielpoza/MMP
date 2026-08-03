/* =========================================================
   calabozo.js  —  La sala del calabozo (tras tumbar la puerta)
   ---------------------------------------------------------
   Una sala medieval OSCURA con el SUELO NEGRO. Aquí es donde
   (más adelante) aparecerán los esqueletos de la maldición.
   Funciona como un "mini-mundo" igual que las islas: ofrece
   esCaminable(), un tamaño y sus dibujos, y reutiliza el mismo
   Player y Camera. Se sale con Esc (se vuelve a la plaza).
   ========================================================= */

class Calabozo {
  constructor() {
    this.cols = 22;
    this.filas = 15;
    this.pixelWidth = this.cols * TILE;    // 1056
    this.pixelHeight = this.filas * TILE;  // 720
    this.pared = 1;                        // grosor de la pared, en casillas
    this.time = 0;

    // El jugador aparece abajo al centro (junto a la entrada)
    this.inicio = { x: (this.cols / 2) * TILE - 14, y: (this.filas - 2) * TILE };
    // Hueco de entrada/salida en la pared de abajo
    this.salida = { c: Math.floor(this.cols / 2), f: this.filas - 1 };

    // Antorchas en las paredes (dan pozos de luz). c,f en casillas
    this.antorchas = [
      { c: 3, f: 1 }, { c: this.cols - 4, f: 1 },
      { c: 1, f: 6 }, { c: this.cols - 2, f: 6 },
      { c: 6, f: this.filas - 2 }, { c: this.cols - 7, f: this.filas - 2 },
    ];

    // Esqueletos de manos, sentados y dormidos por la sala (sobre el suelo negro)
    const E = (c, f) => new Esqueleto(c * TILE + (TILE - 26) / 2, f * TILE, "manos");
    this.enemigos = [ E(5, 4), E(16, 5), E(11, 8) ];
  }

  // ¿Quedan esqueletos vivos?
  enemigosVivos() { return this.enemigos.filter((e) => e.estado !== "muerto").length; }

  update(dt) { this.time += dt; }

  // ¿Es casilla de pared? (borde de la sala, menos el hueco de la salida)
  _esPared(c, f) {
    if (c === this.salida.c && f >= this.filas - 1) return false;  // hueco de salida
    return c < this.pared || c >= this.cols - this.pared || f < this.pared || f >= this.filas - this.pared;
  }

  esCaminable(px, py) {
    if (px < 0 || py < 0 || px >= this.pixelWidth || py >= this.pixelHeight) return false;
    const c = Math.floor(px / TILE), f = Math.floor(py / TILE);
    if (this._esPared(c, f)) return false;
    return true;
  }

  // ¿Está el jugador junto al hueco de salida (abajo)?
  cercaDeSalida(player) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    const sx = (this.salida.c + 0.5) * TILE, sy = (this.salida.f + 0.5) * TILE;
    return Math.hypot(px - sx, py - sy) < 70;
  }

  // ================= DIBUJO =================
  drawGround(ctx, cam) {
    const c0 = Math.floor(cam.x / TILE), c1 = Math.ceil((cam.x + cam.ancho) / TILE);
    const f0 = Math.floor(cam.y / TILE), f1 = Math.ceil((cam.y + cam.alto) / TILE);
    for (let f = f0; f <= f1; f++) {
      for (let c = c0; c <= c1; c++) {
        const x = c * TILE - cam.x, y = f * TILE - cam.y;
        if (this._esPared(c, f)) {
          // Pared de piedra oscura
          ctx.fillStyle = "#20242c"; ctx.fillRect(x, y, TILE, TILE);
          ctx.fillStyle = "#171a20";
          ctx.fillRect(x, y + TILE - 6, TILE, 6);            // base más oscura
          ctx.strokeStyle = "rgba(10,12,16,.8)"; ctx.lineWidth = 1;
          ctx.strokeRect(x + 0.5, y + 0.5, TILE, TILE);       // juntas
        } else {
          // Suelo NEGRO (con una pizca de variación para que no sea plano)
          const h = ((c * 73856093) ^ (f * 19349663)) & 0xff;
          ctx.fillStyle = (h & 8) ? "#0a0b0e" : "#070809";
          ctx.fillRect(x, y, TILE, TILE);
          ctx.strokeStyle = "rgba(40,44,54,.10)"; ctx.lineWidth = 1;
          ctx.strokeRect(x + 0.5, y + 0.5, TILE, TILE);
        }
      }
    }
  }

  drawObjects(ctx, cam, player) {
    const lista = [];
    const cull = (x, y) => !(x + TILE < cam.x || x > cam.x + cam.ancho || y + TILE < cam.y || y > cam.y + cam.alto);

    // Marco iluminado del hueco de salida (abajo)
    const sx = this.salida.c * TILE - cam.x, sy = (this.salida.f) * TILE - cam.y;
    lista.push({ baseY: (this.salida.f + 1) * TILE, dibujar: () => {
      ctx.fillStyle = "#3a2f1c"; ctx.fillRect(sx - 2, sy, TILE + 4, TILE);      // umbral de madera
      ctx.fillStyle = "rgba(240,220,150,.15)"; ctx.fillRect(sx, sy, TILE, TILE); // un poco de luz de la plaza
    }});

    // Antorchas (con llama parpadeante) y su pozo de luz
    for (const a of this.antorchas) {
      const x = a.c * TILE, y = a.f * TILE;
      if (!cull(x, y)) continue;
      lista.push({ baseY: y + TILE, dibujar: () => this._dibujarAntorcha(ctx, x - cam.x, y - cam.y) });
    }

    // Esqueletos
    for (const en of this.enemigos) {
      lista.push({ baseY: en.estado === "muerto" ? -1e9 : en.y + en.alto, dibujar: () => en.draw(ctx, cam) });
    }

    // Jugador
    lista.push({ baseY: player.y + player.alto, dibujar: () => player.draw(ctx, cam) });

    lista.sort((a, b) => a.baseY - b.baseY);
    for (const e of lista) e.dibujar();
  }

  // Antorcha de pared con llama y halo de luz cálida
  _dibujarAntorcha(ctx, x, y) {
    const cx = x + TILE / 2, cy = y + TILE / 2;
    // Halo de luz
    const parp = 0.8 + Math.sin(this.time * 9 + x) * 0.12;
    const g = ctx.createRadialGradient(cx, cy, 6, cx, cy, 120 * parp);
    g.addColorStop(0, "rgba(255,190,90,.35)");
    g.addColorStop(1, "rgba(255,150,60,0)");
    ctx.fillStyle = g; ctx.beginPath(); ctx.arc(cx, cy, 120 * parp, 0, Math.PI * 2); ctx.fill();
    // Soporte
    ctx.fillStyle = "#3a3138"; ctx.fillRect(cx - 3, cy - 2, 6, 16);
    // Llama
    ctx.fillStyle = "#ffcf6a";
    ctx.beginPath(); ctx.ellipse(cx, cy - 8, 5, 9 * parp, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#ff9a3a";
    ctx.beginPath(); ctx.ellipse(cx, cy - 6, 3, 6 * parp, 0, 0, Math.PI * 2); ctx.fill();
  }
}
