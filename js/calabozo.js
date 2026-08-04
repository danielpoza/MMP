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

    // Cofre camuflado en el pasillo, a la izquierda de la puerta de la celda.
    // (x,y = base/pies en coords de imagen). Dentro hay una Manzana misteriosa.
    this.cofre = { x: 895, y: 815, abierto: false };

    // Pared agrietada (coords de imagen): con la Fuerza de la manzana se rompe (E) y
    // hace un agujero de la celda al jardín. Al romperla, ese trozo se vuelve caminable.
    this.paredAgrietada = { x: 1180, y: 462, w: 240, h: 200, rota: false };

    // Arbustos del jardín (arbusto.png por encima, tapando los pintados del mapa).
    // (x,y = base/pies en coords de imagen). Uno esconde la LLAVE de la celda-regalo.
    this.arbustos = [
      { x: 1465, y: 420 },
      { x: 1715, y: 450, llave: true },   // la llave está detrás de este
      { x: 1445, y: 655 },
      { x: 1715, y: 655 },
    ];
    this.llaveEncontrada = false;

    // Celda-regalo (zona 8, la del candado): dentro hay un cofre con la ESPADA del
    // golpe místico. El cofre está cerrado con llave (la que se esconde en el jardín).
    this.cofreRegalo = { x: 1865, y: 1140, abierto: false };

    // Esqueletos repartidos por las celdas (Trozo 4). Empiezan dormidos (sentados) y
    // despiertan al acercarse. (ix,iy = pies del esqueleto en coords de imagen.)
    const esq = (ix, iy, dir) => {
      const e = new Esqueleto(Math.round(ix * this.escala - 13), Math.round(iy * this.escala - 34), "manos");
      e.dir = dir;
      return e;
    };
    this.enemigos = [
      esq(470, 660, "izq"),    // calabozo de entrada (zona 0): sentado mirando a la izquierda
      esq(1110, 470, "abajo"), // celda de rejas (zona 2): sentado de frente
    ];
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
    // Si la pared agrietada está rota, su hueco también es caminable (celda <-> jardín)
    const p = this.paredAgrietada;
    if (!dentro && p.rota && ix > p.x && ix < p.x + p.w && iy > p.y && iy < p.y + p.h) dentro = true;
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

  // ¿Está el jugador junto al cofre?
  cercaDeCofre(player) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    return Math.hypot(px - this.cofre.x * this.escala, py - (this.cofre.y - 18) * this.escala) < 80;
  }

  // ¿Está el jugador junto al cofre-regalo de la celda con llave?
  cercaDeCofreRegalo(player) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    const c = this.cofreRegalo;
    return Math.hypot(px - c.x * this.escala, py - (c.y - 18) * this.escala) < 80;
  }

  // ¿Junto a qué arbusto está el jugador? (devuelve el arbusto o null)
  cercaDeArbusto(player) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    for (const a of this.arbustos) {
      if (Math.hypot(px - a.x * this.escala, py - (a.y - 22) * this.escala) < 62) return a;
    }
    return null;
  }

  // ¿Está el jugador junto a la pared agrietada (por el lado de la celda)?
  cercaDePared(player) {
    const px = player.x + player.ancho / 2, py = player.y + player.alto / 2;
    const p = this.paredAgrietada;
    const cx = p.x * this.escala, cy = (p.y + p.h / 2) * this.escala;   // borde izquierdo (lado celda)
    return Math.hypot(px - cx, py - cy) < 90;
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
    // Si la pared agrietada está rota, tapamos ese trozo con un agujero (paso al jardín)
    if (this.paredAgrietada.rota) this._dibujarAgujeroPared(ctx, cam);
  }

  _dibujarAgujeroPared(ctx, cam) {
    const p = this.paredAgrietada, s = this.escala;
    const x = Math.round(p.x * s - cam.x), y = Math.round(p.y * s - cam.y);
    const w = Math.round(p.w * s), h = Math.round(p.h * s);
    // Paso: oscuro por el lado de la celda, con luz del jardín por la derecha
    const g = ctx.createLinearGradient(x, y, x + w, y);
    g.addColorStop(0, "#14161b"); g.addColorStop(0.6, "#26302a"); g.addColorStop(1, "#4a6b32");
    ctx.fillStyle = g; ctx.fillRect(x, y, w, h);
    // Escombros de piedra rota en los bordes (arriba, abajo y esquinas)
    ctx.fillStyle = "#3a3e46";
    const chunk = (cx, cy, s2) => { ctx.fillRect(cx, cy, s2, s2 * 0.7); };
    for (let i = 0; i < 6; i++) { chunk(x + 6 + i * (w / 6), y - 2, 10); chunk(x + 4 + i * (w / 6), y + h - 8, 9); }
    ctx.fillStyle = "#52565f";
    chunk(x + 4, y + 8, 8); chunk(x + w - 14, y + 10, 9); chunk(x + w * 0.5, y + h - 16, 8);
    // Un par de piedras sueltas en el suelo del hueco
    ctx.fillStyle = "#5a5e67";
    ctx.beginPath(); ctx.ellipse(x + w * 0.35, y + h - 6, 7, 4, 0, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.ellipse(x + w * 0.62, y + h - 4, 5, 3, 0, 0, Math.PI * 2); ctx.fill();
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
    lista.push({ baseY: this.cofre.y * this.escala, dibujar: () => this._dibujarCofre(ctx, cam) });
    lista.push({ baseY: this.cofreRegalo.y * this.escala, dibujar: () => this._dibujarCofreRegalo(ctx, cam) });
    for (const a of this.arbustos) lista.push({ baseY: a.y * this.escala, dibujar: () => this._dibujarArbusto(ctx, cam, a) });
    lista.push({ baseY: player.y + player.alto, dibujar: () => player.draw(ctx, cam) });
    lista.sort((a, b) => a.baseY - b.baseY);
    for (const e of lista) e.dibujar();
  }

  // Tapa el arbusto pintado del mapa con césped y dibuja arbusto.png encima
  _dibujarArbusto(ctx, cam, a) {
    const s = this.escala;
    const cx = Math.round(a.x * s - cam.x), by = Math.round(a.y * s - cam.y);
    // Capa de césped (mismo tono que el jardín) para tapar el arbusto pintado
    ctx.save();
    const grass = ["#648a4d", "#5a7f45", "#6f9553"];
    const blob = (dx, dy, rx, ry, i) => { ctx.fillStyle = grass[i]; ctx.beginPath(); ctx.ellipse(cx + dx, by - 22 + dy, rx, ry, 0, 0, Math.PI * 2); ctx.fill(); };
    blob(0, 0, 52, 40, 0); blob(-16, 6, 34, 26, 1); blob(18, -8, 30, 22, 2); blob(4, 14, 40, 22, 1);
    ctx.restore();
    // Sombra + arbusto.png (o reserva)
    ctx.fillStyle = "rgba(0,0,0,.20)"; ctx.beginPath(); ctx.ellipse(cx, by, 24, 8, 0, 0, Math.PI * 2); ctx.fill();
    if (Assets.listo("arbusto")) {
      const el = Assets.el("arbusto"), iw = Assets.w("arbusto"), ih = Assets.h("arbusto");
      const dh = 56, dw = dh * (iw / ih);
      ctx.drawImage(el, Math.round(cx - dw / 2), Math.round(by - dh), dw, dh);
    } else {
      ctx.fillStyle = "#3f7a37"; ctx.beginPath(); ctx.ellipse(cx, by - 16, 22, 18, 0, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = "#4a8a40"; ctx.beginPath(); ctx.ellipse(cx - 6, by - 22, 12, 10, 0, 0, Math.PI * 2); ctx.fill();
    }
  }

  // Cofre del tesoro de la celda-regalo (dorado). Dibujo por código (no necesita PNG).
  _dibujarCofreRegalo(ctx, cam) {
    const s = this.escala, c = this.cofreRegalo;
    const cx = Math.round(c.x * s - cam.x), by = Math.round(c.y * s - cam.y);
    ctx.save();
    // Sombra
    ctx.fillStyle = "rgba(0,0,0,.35)";
    ctx.beginPath(); ctx.ellipse(cx, by, 26, 8, 0, 0, Math.PI * 2); ctx.fill();
    const w = 46, h = 36, x = cx - w / 2, y = by - h;
    // Base (madera oscura) y tapa (madera clara)
    ctx.fillStyle = "#5e3f20"; ctx.fillRect(x, y + h * 0.42, w, h * 0.58);
    ctx.fillStyle = "#7a5327"; ctx.fillRect(x, y, w, h * 0.5);
    // Herrajes dorados (flejes + banda del cierre)
    ctx.fillStyle = "#e9c24c";
    ctx.fillRect(x, y + h * 0.40, w, 5);
    ctx.fillRect(x + 5, y, 5, h);
    ctx.fillRect(x + w - 10, y, 5, h);
    ctx.fillRect(x + w / 2 - 3, y + h * 0.5, 6, 4);         // cerradura
    if (c.abierto) {
      ctx.fillStyle = "rgba(0,0,0,.5)"; ctx.fillRect(x + 6, y + 6, w - 12, 8);       // hueco (ya vacío)
      ctx.fillStyle = "rgba(255,240,180,.7)"; ctx.fillRect(x + 8, y + 7, w - 16, 3); // brillo
    } else {
      // Candado colgando del cierre
      ctx.fillStyle = "#caa24a"; ctx.fillRect(cx - 4, y + h * 0.5 - 1, 8, 8);
      ctx.strokeStyle = "#caa24a"; ctx.lineWidth = 2;
      ctx.beginPath(); ctx.arc(cx, y + h * 0.5 - 1, 3, Math.PI, 0); ctx.stroke();
    }
    ctx.restore();
  }

  _dibujarCofre(ctx, cam) {
    const s = this.escala, c = this.cofre;
    const cx = Math.round(c.x * s - cam.x), by = Math.round(c.y * s - cam.y);
    // Sombra
    ctx.fillStyle = "rgba(0,0,0,.30)";
    ctx.beginPath(); ctx.ellipse(cx, by, 24, 8, 0, 0, Math.PI * 2); ctx.fill();
    if (Assets.listo("cofre")) {
      const el = Assets.el("cofre"), iw = Assets.w("cofre"), ih = Assets.h("cofre");
      const dh = 44, dw = dh * (iw / ih);
      ctx.drawImage(el, Math.round(cx - dw / 2), Math.round(by - dh), dw, dh);
      if (c.abierto) { ctx.fillStyle = "rgba(0,0,0,.5)"; ctx.fillRect(Math.round(cx - dw / 2 + 4), Math.round(by - dh + 4), dw - 8, 8); }
      return;
    }
    this._cofreReserva(ctx, cx, by, c.abierto);
  }

  // Dibujo de reserva: cofre de madera oscura con refuerzos de hierro
  _cofreReserva(ctx, cx, by, abierto) {
    const w = 44, h = 34, x = cx - w / 2, y = by - h;
    ctx.fillStyle = "#3a2716"; ctx.fillRect(x, y + 10, w, h - 10);            // cuerpo madera
    ctx.fillStyle = "#2a1c10"; ctx.fillRect(x, y + h - 6, w, 6);              // base sombra
    ctx.strokeStyle = "#6f4526"; ctx.lineWidth = 1;                          // vetas
    for (let i = 1; i < 3; i++) { ctx.beginPath(); ctx.moveTo(x, y + 10 + i * 7); ctx.lineTo(x + w, y + 10 + i * 7); ctx.stroke(); }
    // Tapa
    if (abierto) {
      ctx.fillStyle = "#050608"; ctx.fillRect(x + 3, y + 6, w - 6, 8);        // interior oscuro
      ctx.fillStyle = "#4a3221"; ctx.fillRect(x - 1, y - 6, w + 2, 8);        // tapa levantada
    } else {
      ctx.fillStyle = "#4a3221"; ctx.beginPath();
      ctx.moveTo(x, y + 12); ctx.quadraticCurveTo(cx, y - 2, x + w, y + 12); ctx.lineTo(x + w, y + 12); ctx.lineTo(x, y + 12); ctx.fill();
    }
    // Refuerzos de hierro y candado
    ctx.fillStyle = "#6b7079"; ctx.fillRect(x + 6, y + 8, 4, h - 8); ctx.fillRect(x + w - 10, y + 8, 4, h - 8);
    ctx.fillStyle = "#caa24a"; ctx.fillRect(cx - 3, y + 14, 6, 7);            // candado dorado
    // Telarañas (camuflaje)
    ctx.strokeStyle = "rgba(230,230,230,.25)"; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(x, y + 8); ctx.lineTo(x + 8, y + 16); ctx.moveTo(x + 4, y + 6); ctx.lineTo(x + 8, y + 16); ctx.stroke();
  }

  enemigosVivos() { return this.enemigos.filter((e) => e.estado !== "muerto").length; }
}
