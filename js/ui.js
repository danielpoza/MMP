/* =========================================================
   ui.js  —  Pantalla de título y menú
   ---------------------------------------------------------
   Portada ambientada (cielo épico, montañas, una gran
   espada y un dragón a lo lejos) con dos opciones:
   JUGAR y SALIR. Se navega con Arriba/Abajo y Enter.
   ========================================================= */

class TitleScreen {
  constructor(ancho, alto) {
    this.ancho = ancho;
    this.alto = alto;
    // Cada opción es { texto, id }. El Game las cambia según el contexto.
    this.opciones = [{ texto: "Jugar", id: "nueva" }, { texto: "Salir", id: "salir" }];
    this.seleccion = 0;
    this.t = 0;
    this.aviso = ""; this.avisoT = 0;    // mensaje breve ("Partida guardada")
    this.estrellas = this._crearEstrellas(70);
  }

  setOpciones(opts) {
    this.opciones = opts;
    if (this.seleccion >= opts.length) this.seleccion = 0;
  }
  mostrarAviso(txt) { this.aviso = txt; this.avisoT = 2.5; }

  _crearEstrellas(n) {
    let s = 7;                                        // semilla fija -> siempre igual
    const rnd = () => (s = (s * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff;
    const arr = [];
    for (let i = 0; i < n; i++) {
      arr.push({ x: rnd() * this.ancho, y: rnd() * this.alto * 0.55, b: rnd() });
    }
    return arr;
  }

  // Devuelve el id de la opción elegida, o null
  update(dt) {
    this.t += dt;
    if (this.avisoT > 0) this.avisoT -= dt;
    const n = this.opciones.length;
    if (Input.pressed["arrowup"])   this.seleccion = (this.seleccion - 1 + n) % n;
    if (Input.pressed["arrowdown"]) this.seleccion = (this.seleccion + 1) % n;
    if (Input.pressed["enter"] || Input.pressed[" "]) return this.opciones[this.seleccion].id;
    return null;
  }

  draw(ctx) {
    const W = this.ancho, H = this.alto;

    // Fondo: usa la imagen portada.png si existe; si no, se dibuja por código
    if (Assets.listo("portada")) {
      ctx.drawImage(Assets.el("portada"), 0, 0, W, H);
    } else {
    // Cielo degradado (atardecer épico)
    const cielo = ctx.createLinearGradient(0, 0, 0, H);
    cielo.addColorStop(0, "#1a1030");
    cielo.addColorStop(0.5, "#4a2350");
    cielo.addColorStop(1, "#a54a3c");
    ctx.fillStyle = cielo;
    ctx.fillRect(0, 0, W, H);

    // Estrellas parpadeantes
    for (const e of this.estrellas) {
      const brillo = 0.4 + 0.6 * Math.abs(Math.sin(this.t * 2 + e.b * 10));
      ctx.fillStyle = `rgba(255,255,240,${brillo * e.b})`;
      ctx.fillRect(e.x, e.y, 2, 2);
    }

    // Luna
    ctx.fillStyle = "#f4ead0";
    ctx.beginPath(); ctx.arc(W - 130, 90, 34, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "rgba(0,0,0,.10)";
    ctx.beginPath(); ctx.arc(W - 120, 84, 30, 0, Math.PI * 2); ctx.fill();

    // Dragón lejano volando (silueta)
    this._dragon(ctx, W - 130 + Math.sin(this.t * 0.6) * 40, 80 + Math.cos(this.t * 0.6) * 12, this.t);

    // Montañas (dos capas para dar profundidad)
    this._montanas(ctx, H * 0.62, "#2b1830", 7, 40);
    this._montanas(ctx, H * 0.72, "#1c1024", 5, 70);

    // Suelo oscuro delante
    ctx.fillStyle = "#120a18";
    ctx.fillRect(0, H * 0.8, W, H * 0.2);

    // Gran espada clavada en el centro
    this._espadaEpica(ctx, W / 2, H * 0.5);
    }

    // Título
    ctx.textAlign = "center";
    ctx.fillStyle = "#f6d367";
    ctx.font = "bold 74px Georgia, serif";
    ctx.shadowColor = "rgba(0,0,0,.6)";
    ctx.shadowBlur = 8;
    ctx.fillText("SEOK", W / 2, 96);
    ctx.shadowBlur = 0;
    ctx.fillStyle = "#c98a3a";
    ctx.font = "italic 22px Georgia, serif";
    ctx.fillText("~ y la senda de la espada ~", W / 2, 128);

    // Menú (número de opciones variable)
    const n = this.opciones.length;
    const espac = 42;
    const cy = H * 0.76;
    const primero = cy - (n - 1) * espac / 2;

    // Panel semitransparente tras el menú (legible sobre la portada)
    ctx.fillStyle = "rgba(0,0,0,.45)";
    ctx.beginPath();
    ctx.roundRect(W / 2 - 170, primero - 30, 340, n * espac + 24, 12);
    ctx.fill();

    ctx.font = "bold 26px Georgia, serif";
    for (let i = 0; i < n; i++) {
      const y = primero + i * espac;
      if (i === this.seleccion) {
        const p = 0.6 + 0.4 * Math.sin(this.t * 6);
        ctx.fillStyle = `rgba(246,211,103,${p})`;
        ctx.fillText("‹  " + this.opciones[i].texto + "  ›", W / 2, y);
      } else {
        ctx.fillStyle = "#9a8f77";
        ctx.fillText(this.opciones[i].texto, W / 2, y);
      }
    }

    // Aviso ("Partida guardada")
    if (this.avisoT > 0) {
      ctx.globalAlpha = Math.min(1, this.avisoT);
      ctx.fillStyle = "#8fe08f"; ctx.font = "bold 18px Georgia, serif";
      ctx.fillText(this.aviso, W / 2, primero + n * espac + 4);
      ctx.globalAlpha = 1;
    }

    ctx.font = "14px Georgia, serif";
    ctx.fillStyle = "rgba(255,255,255,.55)";
    ctx.fillText("Arriba / Abajo para elegir · Enter para confirmar", W / 2, H - 18);
    ctx.textAlign = "left";
  }

  _montanas(ctx, base, color, picos, altura) {
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(0, base);
    for (let i = 0; i <= picos; i++) {
      const x = (this.ancho / picos) * i;
      const y = base - Math.abs(Math.sin(i * 1.3 + 1)) * altura;
      ctx.lineTo(x, y);
      ctx.lineTo(x + this.ancho / picos / 2, base);
    }
    ctx.lineTo(this.ancho, base);
    ctx.lineTo(this.ancho, this.alto);
    ctx.lineTo(0, this.alto);
    ctx.closePath();
    ctx.fill();
  }

  _espadaEpica(ctx, cx, cy) {
    // Resplandor
    const g = ctx.createRadialGradient(cx, cy, 5, cx, cy, 120);
    g.addColorStop(0, "rgba(246,211,103,.35)");
    g.addColorStop(1, "rgba(246,211,103,0)");
    ctx.fillStyle = g;
    ctx.fillRect(cx - 120, cy - 120, 240, 240);
    // Hoja
    ctx.fillStyle = "#dfe6ef";
    ctx.fillRect(cx - 6, cy - 70, 12, 130);
    ctx.fillStyle = "#b9c2cf";
    ctx.fillRect(cx - 6, cy - 70, 4, 130);
    ctx.beginPath();                            // punta
    ctx.moveTo(cx - 6, cy - 70); ctx.lineTo(cx, cy - 88); ctx.lineTo(cx + 6, cy - 70);
    ctx.closePath(); ctx.fill();
    // Guarda
    ctx.fillStyle = "#caa24a";
    ctx.fillRect(cx - 34, cy + 58, 68, 12);
    // Empuñadura
    ctx.fillStyle = "#5b3b20";
    ctx.fillRect(cx - 5, cy + 70, 10, 34);
    ctx.fillStyle = "#caa24a";
    ctx.beginPath(); ctx.arc(cx, cy + 108, 8, 0, Math.PI * 2); ctx.fill();
  }

  _dragon(ctx, x, y, t) {
    ctx.save();
    ctx.translate(x, y);
    ctx.fillStyle = "rgba(20,10,25,.85)";
    const flap = Math.sin(t * 4) * 10;
    // Cuerpo
    ctx.beginPath();
    ctx.moveTo(-6, 0); ctx.lineTo(10, -3); ctx.lineTo(22, 0); ctx.lineTo(10, 4);
    ctx.closePath(); ctx.fill();
    // Alas
    ctx.beginPath(); ctx.moveTo(2, 0); ctx.lineTo(-18, -14 - flap); ctx.lineTo(-2, -2); ctx.closePath(); ctx.fill();
    ctx.beginPath(); ctx.moveTo(2, 0); ctx.lineTo(-18, 14 + flap); ctx.lineTo(-2, 2); ctx.closePath(); ctx.fill();
    ctx.restore();
  }
}

/* Pantalla simple de "hasta pronto" al pulsar SALIR */
class ByeScreen {
  constructor(ancho, alto) { this.ancho = ancho; this.alto = alto; }
  draw(ctx) {
    ctx.fillStyle = "#0b0b10";
    ctx.fillRect(0, 0, this.ancho, this.alto);
    ctx.textAlign = "center";
    ctx.fillStyle = "#f6d367";
    ctx.font = "bold 40px Georgia, serif";
    ctx.fillText("¡Hasta pronto, caballero!", this.ancho / 2, this.alto / 2 - 10);
    ctx.fillStyle = "#9a8f77";
    ctx.font = "18px Georgia, serif";
    ctx.fillText("Pulsa Enter para volver al menú", this.ancho / 2, this.alto / 2 + 30);
    ctx.textAlign = "left";
  }
}
