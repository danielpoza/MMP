/* =========================================================
   enemigo.js  —  Los esqueletos de la maldición
   ---------------------------------------------------------
   Por ahora, el esqueleto de MANOS (cuerpo a cuerpo): está
   SENTADO y dormido (ojos apagados) en el suelo del calabozo
   y, cuando el jugador se acerca, DESPIERTA (ojos verde claro)
   y te persigue. Si te toca, te quita vida.
   Tiene 50 de vida con una BARRA ROJA (con el número) encima.
   Todo dibujado por código (dibujo de reserva); cuando existan
   los PNG (esqueleto_manos*.png) se podrán enchufar aquí.
   ========================================================= */

class Esqueleto {
  constructor(x, y, tipo = "manos") {
    this.x = x; this.y = y;
    this.ancho = 26; this.alto = 34;
    this.tipo = tipo;
    this.vidaMax = 50;
    this.vida = 50;
    this.dano = 15;                 // lo que te quita al tocarte
    this.velocidad = 110;           // más lento que el jugador (165)
    this.estado = "dormido";        // dormido / despierto / muerto
    this.dir = "abajo";
    this.paso = 0;
    this.time = 0;
    this.hitFlash = 0;              // parpadeo blanco al recibir un golpe
    this.golpeCD = 0;              // enfriamiento entre sus ataques
    this.atacandoT = 0;            // animación de zarpazo
    this.radioDespertar = 150;     // a qué distancia se despierta
    this.radioGolpe = 32;          // a qué distancia te toca
  }

  get centroX() { return this.x + this.ancho / 2; }
  get centroY() { return this.y + this.alto / 2; }

  // Recibe un espadazo del jugador
  recibirGolpe(dmg) {
    if (this.estado === "muerto") return;
    if (this.estado === "dormido") this.estado = "despierto";  // le despierta el golpe
    this.vida = Math.max(0, this.vida - dmg);
    this.hitFlash = 0.18;
    if (this.vida <= 0) this.estado = "muerto";
  }

  update(dt, player, world, game) {
    this.time += dt;
    if (this.hitFlash > 0) this.hitFlash -= dt;
    if (this.golpeCD > 0) this.golpeCD -= dt;
    if (this.atacandoT > 0) this.atacandoT -= dt;
    if (this.estado === "muerto") return;

    const pcx = player.x + player.ancho / 2, pcy = player.y + player.alto / 2;
    const dx = pcx - this.centroX;
    const dy = pcy - this.centroY;
    const dist = Math.hypot(dx, dy);

    if (this.estado === "dormido") {
      if (dist < this.radioDespertar) this.estado = "despierto";   // ¡se despierta!
      return;
    }

    // Despierto: perseguir al jugador
    let mx = dx, my = dy; const len = Math.hypot(mx, my) || 1; mx /= len; my /= len;
    if (Math.abs(mx) > Math.abs(my)) this.dir = mx < 0 ? "izq" : "der";
    else this.dir = my < 0 ? "arriba" : "abajo";
    const v = this.velocidad * dt;
    const nx = this.x + mx * v, ny = this.y + my * v;
    if (world.esCaminable(nx + this.ancho / 2, this.y + this.alto)) this.x = nx;
    if (world.esCaminable(this.x + this.ancho / 2, ny + this.alto)) this.y = ny;
    this.paso += dt * 8;

    // Atacar al tocar al jugador (con enfriamiento)
    if (dist < this.radioGolpe && this.golpeCD <= 0) {
      player.vida = Math.max(0, player.vida - this.dano);
      this.golpeCD = 0.9;
      this.atacandoT = 0.25;
      if (game) game.recibirDano();
    }
  }

  // ================= DIBUJO =================
  draw(ctx, cam) {
    const x = Math.round(this.x - cam.x), y = Math.round(this.y - cam.y);
    const w = this.ancho, h = this.alto;
    const cx = x + w / 2;

    if (this.estado === "muerto") { this._dibujarHuesos(ctx, cx, y + h); return; }

    // Sombra
    ctx.fillStyle = "rgba(0,0,0,.28)";
    ctx.beginPath(); ctx.ellipse(cx, y + h, w * 0.5, w * 0.2, 0, 0, Math.PI * 2); ctx.fill();

    // Cuerpo: con los PNG (dibujo real) o con el dibujo de reserva
    if (this._tieneSprites()) this._dibujarSprite(ctx, cx, y + h);
    else this._dibujarReservaCuerpo(ctx, x, y, w, h, cx);

    // Barra de vida (roja, con número) cuando está despierto
    if (this.estado === "despierto") {
      const barY = this._tieneSprites() ? (y + h - this.SPRITE_H) : (y - 12);
      this._barraVida(ctx, cx, barY);
    }
  }

  get SPRITE_H() { return 60; }
  _tieneSprites() { return Assets.listo("esqueleto_" + this.tipo); }

  // Elige el fotograma adecuado según el estado (dormido / andando / atacando)
  _dibujarSprite(ctx, cx, baseY) {
    const t = this.tipo, H = this.SPRITE_H;
    if (this.estado === "dormido") {
      const s = "esqueleto_" + t + "_sentado";        // hoja 2col × 4fil, ojos apagados
      if (Assets.listo(s)) {
        // fila 0 = sentado de frente; fila 2 = sentado de perfil (mira a la izquierda)
        const perfil = (this.dir === "izq" || this.dir === "der");
        const flip = this.dir === "der";               // el perfil mira a la izq; se voltea si mira a la der
        this._sprite(ctx, s, 0, 2, perfil ? 2 : 0, 4, cx, baseY, H, flip);
        return;
      }
    }
    if (this.atacandoT > 0) {
      const s = "esqueleto_" + t + "_ataque";          // zarpazo (fila 0, col 1); mira a la izq.
      if (Assets.listo(s)) { this._sprite(ctx, s, 1, 2, 0, 4, cx, baseY, H, this.dir === "der"); return; }
    }
    // Andando: hoja de perfil (mira a la derecha), 3 col × 4 filas = 12 fotogramas
    const idx = Math.floor(this.paso * 1.2) % 12;
    this._sprite(ctx, "esqueleto_" + t, idx % 3, 3, Math.floor(idx / 3), 4, cx, baseY, H, this.dir === "izq");
  }

  // Recorta una celda (col,row) de una hoja y la dibuja centrada en cx con los pies en baseY
  _sprite(ctx, nombre, col, ncols, row, nrows, cx, baseY, destH, flip) {
    const el = Assets.el(nombre);
    const cw = Assets.w(nombre) / ncols, ch = Assets.h(nombre) / nrows;
    const insx = cw * 0.05, insy = ch * 0.04;         // recorte para evitar la rejilla negra
    const sx = col * cw + insx, sy = row * ch + insy, sw = cw - insx * 2, sh = ch - insy * 2;
    const destW = destH * (sw / sh);
    const dx = Math.round(cx - destW / 2), dy = Math.round(baseY - destH);
    ctx.save();
    if (flip) { ctx.translate(dx + destW, dy); ctx.scale(-1, 1); ctx.drawImage(el, sx, sy, sw, sh, 0, 0, destW, destH); }
    else ctx.drawImage(el, sx, sy, sw, sh, dx, dy, destW, destH);
    if (this.hitFlash > 0) {                            // parpadeo al recibir un golpe
      ctx.globalCompositeOperation = "lighter"; ctx.globalAlpha = 0.55;
      if (flip) ctx.drawImage(el, sx, sy, sw, sh, 0, 0, destW, destH);
      else ctx.drawImage(el, sx, sy, sw, sh, dx, dy, destW, destH);
    }
    ctx.restore();
  }

  // ---- Dibujo de reserva del cuerpo (si faltan los PNG) ----
  _dibujarReservaCuerpo(ctx, x, y, w, h, cx) {
    const sentado = this.estado === "dormido";
    const ojosVerdes = this.estado === "despierto";
    const bob = (!sentado && this.paso) ? Math.abs(Math.sin(this.paso)) * 2 : 0;
    const top = y - bob + (sentado ? 8 : 0);   // sentado = más bajo
    const hueso = this.hitFlash > 0 ? "#ffffff" : "#e8e4d2";
    const sombra = this.hitFlash > 0 ? "#ffd0d0" : "#b9b4a0";

    // Piernas / base
    ctx.strokeStyle = sombra; ctx.lineWidth = 3;
    if (sentado) {
      ctx.beginPath(); ctx.moveTo(cx, top + 26); ctx.lineTo(x + 3, top + 32); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(cx, top + 26); ctx.lineTo(x + w - 3, top + 32); ctx.stroke();
    } else {
      const sep = Math.sin(this.paso) * 3;
      ctx.beginPath(); ctx.moveTo(cx - 4, top + 24); ctx.lineTo(cx - 5 - sep, top + 34); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(cx + 4, top + 24); ctx.lineTo(cx + 5 + sep, top + 34); ctx.stroke();
    }

    // Columna + caja torácica
    ctx.strokeStyle = hueso; ctx.lineWidth = 3;
    ctx.beginPath(); ctx.moveTo(cx, top + 12); ctx.lineTo(cx, top + 26); ctx.stroke();
    ctx.lineWidth = 2;
    for (let i = 0; i < 3; i++) {
      const ry = top + 15 + i * 4;
      ctx.beginPath(); ctx.moveTo(cx, ry); ctx.quadraticCurveTo(cx - 8, ry + 2, cx - 7, ry + 4); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(cx, ry); ctx.quadraticCurveTo(cx + 8, ry + 2, cx + 7, ry + 4); ctx.stroke();
    }

    // Brazos / garras
    ctx.strokeStyle = hueso; ctx.lineWidth = 3;
    const alcance = this.atacandoT > 0 ? 12 : (sentado ? 4 : 8);
    const fx = this.dir === "izq" ? -1 : this.dir === "der" ? 1 : 0;
    const fy = this.dir === "arriba" ? -1 : this.dir === "abajo" ? 0.6 : 0;
    ctx.beginPath(); ctx.moveTo(cx - 5, top + 14); ctx.lineTo(cx - 5 + fx * alcance, top + 16 + fy * alcance); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(cx + 5, top + 14); ctx.lineTo(cx + 5 + fx * alcance, top + 16 + fy * alcance); ctx.stroke();

    // Cráneo
    ctx.fillStyle = hueso;
    ctx.beginPath(); ctx.arc(cx, top + 6, 7, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = hueso; ctx.fillRect(cx - 4, top + 11, 8, 4);
    if (ojosVerdes) {
      ctx.save(); ctx.shadowColor = "#8ef58a"; ctx.shadowBlur = 6; ctx.fillStyle = "#8ef58a";
      ctx.beginPath(); ctx.arc(cx - 3, top + 5, 1.9, 0, Math.PI * 2); ctx.fill();
      ctx.beginPath(); ctx.arc(cx + 3, top + 5, 1.9, 0, Math.PI * 2); ctx.fill();
      ctx.restore();
    } else {
      ctx.fillStyle = "#20242a";
      ctx.beginPath(); ctx.arc(cx - 3, top + 5, 1.8, 0, Math.PI * 2); ctx.fill();
      ctx.beginPath(); ctx.arc(cx + 3, top + 5, 1.8, 0, Math.PI * 2); ctx.fill();
    }
  }

  _barraVida(ctx, cx, y) {
    const w = 40, h = 7, x = cx - w / 2;
    const fr = Math.max(0, this.vida / this.vidaMax);
    ctx.fillStyle = "rgba(0,0,0,.75)"; ctx.fillRect(x - 1, y - 1, w + 2, h + 2);   // borde
    ctx.fillStyle = "#3a0d0d"; ctx.fillRect(x, y, w, h);                            // parte "apagada"
    ctx.fillStyle = "#e23b3b"; ctx.fillRect(x, y, w * fr, h);                       // vida roja
    ctx.fillStyle = "rgba(255,255,255,.25)"; ctx.fillRect(x, y, w * fr, h / 2);     // brillo
    ctx.fillStyle = "#fff"; ctx.font = "bold 9px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText(Math.ceil(this.vida), cx, y + h / 2 + 0.5);
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  _dibujarHuesos(ctx, cx, by) {
    ctx.save();
    ctx.globalAlpha = 0.8;
    ctx.strokeStyle = "#c9c6ba"; ctx.lineWidth = 3;
    ctx.beginPath(); ctx.moveTo(cx - 10, by - 3); ctx.lineTo(cx + 10, by - 1); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(cx - 8, by + 1); ctx.lineTo(cx + 9, by - 4); ctx.stroke();
    ctx.fillStyle = "#d8d4c6"; ctx.beginPath(); ctx.arc(cx - 6, by - 2, 4, 0, Math.PI * 2); ctx.fill();  // calavera
    ctx.fillStyle = "#20242a";
    ctx.beginPath(); ctx.arc(cx - 7, by - 2, 1, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(cx - 5, by - 2, 1, 0, Math.PI * 2); ctx.fill();
    ctx.restore();
  }
}
