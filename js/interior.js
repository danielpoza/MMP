/* =========================================================
   interior.js  —  El interior de la casa roja
   ---------------------------------------------------------
   Una habitación a oscuras con un anciano (el más viejo de
   la isla) durmiendo en una cama pegada a la pared. Solo se
   ilumina la zona de la cama, gracias a unas velas que hay
   a un lado. El jugador puede moverse por la habitación.

   Funciona como un "mini-mundo": ofrece esCaminable() y un
   tamaño, así que reutiliza el mismo Player (movimiento y
   dibujo) que el mapa exterior. Con Esc se vuelve al mapa.
   ========================================================= */

class Interior {
  constructor(ancho, alto) {
    this.ancho = ancho;
    this.alto = alto;
    this.pixelWidth = ancho;    // la habitación ocupa justo una pantalla
    this.pixelHeight = alto;
    this.time = 0;
    this.pared = 44;            // grosor de las paredes

    // Cama pegada a la pared de arriba, un poco a la derecha del centro
    this.cama = { x: ancho * 0.44, y: this.pared, w: 250, h: 170 };
    // Mesita con velas, a la izquierda de la cama
    this.velas = { x: this.cama.x - 46, y: this.cama.y + 70 };
    // Puerta abajo al centro (por donde se entra y se sale)
    this.puerta = { x: ancho / 2 - 34, y: alto - this.pared, w: 68, h: this.pared };
  }

  update(dt) { this.time += dt; }

  // ¿Tenemos la imagen de primera persona? (entonces la escena es fija)
  esImagen() { return Assets.listo("interior_casa"); }

  // ¿Se puede caminar por aquí? (px, py = pies del jugador, en píxeles)
  esCaminable(px, py) {
    const m = this.pared;
    if (px < m || px > this.ancho - m) return false;          // paredes laterales
    if (py < m + 30 || py > this.alto - 14) return false;     // pared de arriba / abajo
    // No subirse a la cama
    const c = this.cama;
    if (px > c.x - 8 && px < c.x + c.w + 8 && py < c.y + c.h + 6) return false;
    return true;
  }

  // ================= DIBUJO =================
  draw(ctx, player, cam) {
    const W = this.ancho, H = this.alto;

    // Escena en PRIMERA PERSONA: mostramos solo la imagen (fija, sin jugador)
    if (this.esImagen()) {
      ctx.drawImage(Assets.el("interior_casa"), 0, 0, W, H);
      ctx.fillStyle = "rgba(230,220,200,.85)";
      ctx.font = "14px Georgia, serif";
      ctx.textAlign = "center";
      ctx.fillText("Esc: salir de la casa", W / 2, H - 14);
      ctx.textAlign = "left";
      return;
    }

    // ---- Si no hay imagen, la sala dibujada por código (vista superior) ----
    // 1) Suelo de madera
    ctx.fillStyle = "#3f3226";
    ctx.fillRect(0, 0, W, H);
    ctx.fillStyle = "#372b20";
    for (let x = 0; x < W; x += 48) ctx.fillRect(x, 0, 2, H);

    // 2) Paredes
    this._paredes(ctx, W, H);

    // 3) Puerta (por donde se entra)
    this._puerta(ctx);

    // 4) Cama + anciano + velas
    this._cama(ctx);
    this._anciano(ctx);
    this._velas(ctx);

    // 5) El jugador (mismo sprite que en el mapa)
    player.draw(ctx, cam);

    // 6) Oscuridad: casi todo negro salvo la luz de las velas
    this._oscuridad(ctx, player);

    // 7) Textos por encima de la oscuridad
    ctx.fillStyle = "rgba(230,220,200,.85)";
    ctx.font = "14px Georgia, serif";
    ctx.textAlign = "center";
    ctx.fillText("Esc: salir de la casa", W / 2, H - 14);
    ctx.textAlign = "left";
  }

  _paredes(ctx, W, H) {
    const m = this.pared;
    ctx.fillStyle = "#241a12";
    ctx.fillRect(0, 0, W, m);          // arriba
    ctx.fillRect(0, H - m, W, m);      // abajo
    ctx.fillRect(0, 0, m, H);          // izquierda
    ctx.fillRect(W - m, 0, m, H);      // derecha
    // Zócalo más claro
    ctx.fillStyle = "#33251a";
    ctx.fillRect(m, m, W - 2 * m, 6);
  }

  _puerta(ctx) {
    const p = this.puerta;
    ctx.fillStyle = "#5b3b20";
    ctx.fillRect(p.x, p.y - p.h + 6, p.w, p.h);
    ctx.fillStyle = "#3a2414";
    ctx.fillRect(p.x + 6, p.y - p.h + 10, p.w - 12, p.h - 6);
    ctx.fillStyle = "#caa24a";          // pomo
    ctx.beginPath(); ctx.arc(p.x + p.w - 14, p.y - p.h / 2 + 4, 3, 0, Math.PI * 2); ctx.fill();
  }

  _cama(ctx) {
    const c = this.cama;
    // Marco de madera
    ctx.fillStyle = "#5b3b20";
    ctx.fillRect(c.x, c.y, c.w, c.h);
    // Cabecero (contra la pared)
    ctx.fillStyle = "#6e4a29";
    ctx.fillRect(c.x, c.y, c.w, 16);
    // Sábana
    ctx.fillStyle = "#e6ddc8";
    ctx.fillRect(c.x + 8, c.y + 16, c.w - 16, c.h - 24);
    // Almohada (arriba)
    ctx.fillStyle = "#f4eedd";
    ctx.fillRect(c.x + c.w / 2 - 42, c.y + 20, 84, 34);
    // Manta que cubre el cuerpo (de la mitad hacia abajo)
    ctx.fillStyle = "#8a2f2f";
    ctx.fillRect(c.x + 8, c.y + 70, c.w - 16, c.h - 78);
    ctx.fillStyle = "#732626";          // dobladillo
    ctx.fillRect(c.x + 8, c.y + 70, c.w - 16, 8);
  }

  _anciano(ctx) {
    const c = this.cama;
    const cx = c.x + c.w / 2, cy = c.y + 40;   // cabeza sobre la almohada
    // Pelo cano (aureola blanca)
    ctx.fillStyle = "#e9e9ee";
    ctx.beginPath(); ctx.arc(cx, cy, 20, 0, Math.PI * 2); ctx.fill();
    // Cara
    ctx.fillStyle = "#d9a679";
    ctx.beginPath(); ctx.arc(cx, cy + 2, 14, 0, Math.PI * 2); ctx.fill();
    // Calva por arriba
    ctx.fillStyle = "#d9a679";
    ctx.fillRect(cx - 10, cy - 12, 20, 8);
    // Barba blanca larga (baja hacia el pecho)
    ctx.fillStyle = "#eef0f2";
    ctx.beginPath();
    ctx.moveTo(cx - 12, cy + 4);
    ctx.lineTo(cx + 12, cy + 4);
    ctx.lineTo(cx + 8, cy + 34);
    ctx.lineTo(cx - 8, cy + 34);
    ctx.closePath(); ctx.fill();
    // Ojos cerrados (descansando)
    ctx.strokeStyle = "#6b4a2b"; ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(cx - 8, cy); ctx.lineTo(cx - 3, cy);
    ctx.moveTo(cx + 3, cy); ctx.lineTo(cx + 8, cy);
    ctx.stroke();
    // Cejas canas
    ctx.strokeStyle = "#e9e9ee"; ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(cx - 9, cy - 4); ctx.lineTo(cx - 3, cy - 3);
    ctx.moveTo(cx + 3, cy - 3); ctx.lineTo(cx + 9, cy - 4);
    ctx.stroke();
    // Manos sobre la manta
    ctx.fillStyle = "#d9a679";
    ctx.fillRect(cx - 26, c.y + 74, 12, 9);
    ctx.fillRect(cx + 14, c.y + 74, 12, 9);
  }

  _velas(ctx) {
    const v = this.velas;
    // Mesita
    ctx.fillStyle = "#4a301b";
    ctx.fillRect(v.x - 18, v.y + 6, 40, 44);
    ctx.fillStyle = "#5b3b20";
    ctx.fillRect(v.x - 18, v.y + 6, 40, 8);
    // Dos velas de distinta altura
    this._vela(ctx, v.x - 8, v.y - 8, 22);
    this._vela(ctx, v.x + 10, v.y - 2, 16);
  }

  _vela(ctx, x, y, alto) {
    // Cuerpo de la vela
    ctx.fillStyle = "#efe6c8";
    ctx.fillRect(x - 4, y, 8, alto);
    ctx.fillStyle = "#d8cba2";
    ctx.fillRect(x + 2, y, 2, alto);
    // Llama parpadeante
    const f = 0.8 + Math.abs(Math.sin(this.time * 9 + x)) * 0.4;
    ctx.fillStyle = "#ffd257";
    ctx.beginPath(); ctx.ellipse(x, y - 5, 3.2, 7 * f, 0, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#ff8a2a";
    ctx.beginPath(); ctx.ellipse(x, y - 3, 1.8, 4 * f, 0, 0, Math.PI * 2); ctx.fill();
  }

  // La magia: oscurecer toda la habitación menos la zona de las velas/cama
  _oscuridad(ctx, player) {
    const W = this.ancho, H = this.alto;
    // Centro de la luz: sobre la cama y el anciano (calibrado)
    const lx = this.cama.x + this.cama.w * 0.40;
    const ly = this.cama.y + this.cama.h * 0.42;
    // Parpadeo suave del alcance de la luz
    const flick = 0.94 + Math.sin(this.time * 8) * 0.05 + Math.sin(this.time * 19) * 0.03;
    const r = 260 * flick;

    // 1) Capa oscura con un "agujero" de luz sobre la cama
    const g = ctx.createRadialGradient(lx, ly, 55, lx, ly, r);
    g.addColorStop(0, "rgba(0,0,0,0)");
    g.addColorStop(0.55, "rgba(8,4,0,0.40)");
    g.addColorStop(1, "rgba(0,0,0,0.95)");
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, W, H);

    // 2) Pequeña luz tenue alrededor del jugador (para no perderlo en la oscuridad)
    const px = player.x + player.ancho / 2;
    const py = player.y + player.alto / 2;
    ctx.save();
    ctx.globalCompositeOperation = "destination-out";
    const pg = ctx.createRadialGradient(px, py, 10, px, py, 85);
    pg.addColorStop(0, "rgba(0,0,0,0.72)");
    pg.addColorStop(1, "rgba(0,0,0,0)");
    ctx.fillStyle = pg;
    ctx.fillRect(0, 0, W, H);
    ctx.restore();

    // 3) Brillo cálido (aditivo) de las velas
    ctx.save();
    ctx.globalCompositeOperation = "lighter";
    const wg = ctx.createRadialGradient(lx, this.velas.y - 6, 6, lx, this.velas.y - 6, 150 * flick);
    wg.addColorStop(0, "rgba(255,180,90,0.28)");
    wg.addColorStop(1, "rgba(255,150,50,0)");
    ctx.fillStyle = wg;
    ctx.fillRect(0, 0, W, H);
    ctx.restore();
  }
}
