/* =========================================================
   player.js  —  El caballero
   ---------------------------------------------------------
   Un hombre medieval con espada, en vista superior.
   Se mueve con las flechas / WASD y no puede atravesar
   el agua ni las casas (se lo pregunta al "world").
   ========================================================= */

class Player {
  constructor(x, y) {
    this.x = x;             // posición en píxeles del mundo
    this.y = y;
    this.ancho = 28;        // "caja" usada para la cámara y colisiones
    this.alto = 34;
    this.velocidad = 165;   // píxeles por segundo
    this.dir = "abajo";     // hacia dónde mira: abajo/arriba/izq/der
    this.paso = 0;          // contador para la animación de andar
    this.moviendo = false;

    // Estadísticas del héroe
    this.reales = 0;        // dinero (fortuna)
    this.vida = 100;        // vida, de 0 a 100 (100 = a tope)
    this.vidaMax = 100;

    // Picos comprados (id -> true), pico equipado y su durabilidad
    this.picos = {};
    this.picoEquipado = null;
    this.picoDurabilidad = 0;
    // Minerales conseguidos al picar (tipo -> cantidad)
    this.inventario = {};
    // Comida/consumibles comprados (nombre -> cantidad); se usan desde la mochila
    this.comida = {};

    // Efecto de la manzana misteriosa
    this.fuerzaT = 0;       // segundos que queda de "Fuerza" (0 = sin fuerza)
    this.fuerzaNivel = 0;   // nivel de fuerza mientras dura (5 con la manzana)
    this.maldito = false;   // maldición de la manzana (monstruos, se hará más adelante)

    // Combate
    this.ataqueCD = 0;      // enfriamiento entre espadazos
    this.atacandoT = 0;     // animación del tajo (>0 = está dando un espadazo)

    // Llave de la celda-regalo (se encuentra en un arbusto del jardín)
    this.tieneLlave = false;
    // Espada del Golpe Místico (premio del cofre de la celda-regalo): ataques más fuertes
    this.espadaMistica = false;
    // Mapa del tesoro (premio de la bóveda, tras derrotar al esqueleto gigante)
    this.tieneMapaTesoro = false;

    // Factor de tamaño del DIBUJO (no cambia la caja de colisiones). En la bóveda
    // se pone más grande para que Seok se vea imponente junto al esqueleto gigante.
    this.escalaDibujo = 1;
  }

  // ¿Tiene ahora mismo el efecto de fuerza activo?
  get tieneFuerza() { return this.fuerzaT > 0; }

  // Centro de la base (los "pies"), que es lo que usamos para colisiones
  get pieX() { return this.x + this.ancho / 2; }
  get pieY() { return this.y + this.alto; }

  update(dt, world) {
    // 0) La fuerza se va agotando con el tiempo
    if (this.fuerzaT > 0) {
      this.fuerzaT = Math.max(0, this.fuerzaT - dt);
      if (this.fuerzaT === 0) this.fuerzaNivel = 0;   // se acabó
    }
    // Enfriamientos del combate
    if (this.ataqueCD > 0) this.ataqueCD -= dt;
    if (this.atacandoT > 0) this.atacandoT -= dt;

    // 1) Leer dirección deseada
    let mx = 0, my = 0;
    if (Input.left)  mx -= 1;
    if (Input.right) mx += 1;
    if (Input.up)    my -= 1;
    if (Input.down)  my += 1;

    this.moviendo = (mx !== 0 || my !== 0);

    // En diagonal, normalizamos para no ir más rápido
    if (mx !== 0 && my !== 0) { const k = 0.7071; mx *= k; my *= k; }

    // Actualizar hacia dónde mira (prioriza el eje horizontal)
    if (mx < 0) this.dir = "izq";
    else if (mx > 0) this.dir = "der";
    else if (my < 0) this.dir = "arriba";
    else if (my > 0) this.dir = "abajo";

    // 2) Mover, comprobando colisiones por separado en X y en Y
    //    (así puede "deslizarse" a lo largo de una pared)
    //    Con la Fuerza de la manzana andamos más rápido.
    const vel = this.velocidad * (this.tieneFuerza ? 1.6 : 1);
    const dx = mx * vel * dt;
    const dy = my * vel * dt;

    if (world.esCaminable(this.pieX + dx, this.pieY)) this.x += dx;
    if (world.esCaminable(this.pieX, this.pieY + dy)) this.y += dy;

    // 3) Animación de andar
    if (this.moviendo) this.paso += dt * 10;
    else this.paso = 0;
  }

  draw(ctx, cam) {
    const esc = this.escalaDibujo || 1;
    if (esc === 1) { this._dibujarCuerpo(ctx, cam); return; }
    // Escalamos alrededor de los "pies" para que el héroe siga pisando el suelo
    const fx = Math.round(this.x + this.ancho / 2 - cam.x);
    const fy = Math.round(this.y + this.alto - cam.y);
    ctx.save();
    ctx.translate(fx, fy); ctx.scale(esc, esc); ctx.translate(-fx, -fy);
    this._dibujarCuerpo(ctx, cam);
    ctx.restore();
  }

  _dibujarCuerpo(ctx, cam) {
    const x = Math.round(this.x - cam.x);
    const y = Math.round(this.y - cam.y);
    const w = this.ancho, h = this.alto;

    // Sombra
    ctx.fillStyle = "rgba(0,0,0,.25)";
    ctx.beginPath();
    ctx.ellipse(x + w / 2, y + h, w * 0.5, w * 0.22, 0, 0, Math.PI * 2);
    ctx.fill();

    // Aura de FUERZA (destellos dorados alrededor mientras dura la manzana)
    if (this.tieneFuerza) {
      const t = this.paso + x * 0.01;
      ctx.save();
      ctx.globalAlpha = 0.55 + Math.sin(t * 6) * 0.25;
      const g = ctx.createRadialGradient(x + w / 2, y + h / 2, 4, x + w / 2, y + h / 2, w);
      g.addColorStop(0, "rgba(255,225,120,.55)");
      g.addColorStop(1, "rgba(255,190,60,0)");
      ctx.fillStyle = g;
      ctx.beginPath(); ctx.ellipse(x + w / 2, y + h / 2, w * 0.95, h * 0.7, 0, 0, Math.PI * 2); ctx.fill();
      ctx.restore();
    }

    // Si tenemos la hoja de sprites, la usamos (y salimos)
    if (Assets.listo("caballero")) { this._dibujarSprite(ctx, x, y, w, h); return; }

    // Balanceo al andar (sube y baja un poquito)
    const bob = this.moviendo ? Math.abs(Math.sin(this.paso)) * 2 : 0;
    const py = y - bob;

    // Piernas
    ctx.fillStyle = "#3a3550";
    const sep = this.moviendo ? Math.sin(this.paso) * 4 : 0;
    ctx.fillRect(x + 6 + sep, py + h - 10, 6, 10);
    ctx.fillRect(x + w - 12 - sep, py + h - 10, 6, 10);

    // Túnica / cuerpo
    ctx.fillStyle = "#8a2f2f";       // rojo medieval
    ctx.fillRect(x + 4, py + 12, w - 8, h - 20);
    ctx.fillStyle = "#c0c0c8";       // peto metálico
    ctx.fillRect(x + 8, py + 14, w - 16, 10);

    // Cabeza
    ctx.fillStyle = "#e8b48a";       // cara
    ctx.fillRect(x + 8, py + 2, w - 16, 12);
    ctx.fillStyle = "#6b4423";       // pelo
    ctx.fillRect(x + 8, py, w - 16, 5);

    // Espada (según hacia dónde mira)
    this._espada(ctx, x, py, w, h);

    // Ojitos según la dirección (detalle simpático)
    ctx.fillStyle = "#2a2a2a";
    if (this.dir === "abajo") {
      ctx.fillRect(x + 11, py + 8, 2, 2);
      ctx.fillRect(x + w - 13, py + 8, 2, 2);
    }
  }

  // Dibuja el fotograma correcto de la hoja caballero.png (4 filas x 3 columnas)
  _dibujarSprite(ctx, x, y, w, h) {
    const el = Assets.el("caballero");
    const cols = 3, filas = 4;
    const cw = Assets.w("caballero") / cols;
    const ch = Assets.h("caballero") / filas;

    // Fila según la dirección: 0 abajo, 1 arriba, 2 izquierda, 3 derecha
    const fila = this.dir === "abajo" ? 0 : this.dir === "arriba" ? 1 : this.dir === "izq" ? 2 : 3;
    // Columna: 0 quieto. Al andar recorre los 3 fotogramas en bucle (0,1,2,1)
    // para que el paso se note (antes solo alternaba 1 y 2).
    const ciclo = [0, 1, 2, 1];
    const col = this.moviendo ? ciclo[Math.floor(this.paso * 0.6) % 4] : 0;

    // Tamaño en pantalla: un poco más alto que la "caja", con los pies abajo
    const destH = 52;
    const destW = destH * (cw / ch);
    // Balanceo al caminar: sube y baja un par de píxeles (da sensación de paso
    // aunque las piernas del sprite lateral apenas cambien)
    const bob = this.moviendo ? Math.abs(Math.sin(this.paso)) * 3 : 0;
    const dx = Math.round(x + w / 2 - destW / 2);
    const dy = Math.round((y + h) - destH + 8 - bob);

    ctx.drawImage(el, col * cw + 0.5, fila * ch + 0.5, cw - 1, ch - 1, dx, dy, destW, destH);
  }

  _espada(ctx, x, py, w, h) {
    ctx.save();
    const hoja = "#dfe6ef", mango = "#5b3b20", guarda = "#caa24a";
    if (this.dir === "der") {
      ctx.fillStyle = mango;  ctx.fillRect(x + w - 2, py + 18, 4, 4);
      ctx.fillStyle = guarda; ctx.fillRect(x + w + 1, py + 16, 3, 8);
      ctx.fillStyle = hoja;   ctx.fillRect(x + w + 3, py + 18, 16, 4);
    } else if (this.dir === "izq") {
      ctx.fillStyle = mango;  ctx.fillRect(x - 2, py + 18, 4, 4);
      ctx.fillStyle = guarda; ctx.fillRect(x - 4, py + 16, 3, 8);
      ctx.fillStyle = hoja;   ctx.fillRect(x - 19, py + 18, 16, 4);
    } else if (this.dir === "arriba") {
      ctx.fillStyle = guarda; ctx.fillRect(x + w - 10, py + 6, 8, 3);
      ctx.fillStyle = hoja;   ctx.fillRect(x + w - 7, py - 12, 4, 18);
    } else { // abajo
      ctx.fillStyle = guarda; ctx.fillRect(x + w - 10, py + h - 12, 8, 3);
      ctx.fillStyle = hoja;   ctx.fillRect(x + w - 7, py + h - 6, 4, 16);
    }
    ctx.restore();
  }
}
