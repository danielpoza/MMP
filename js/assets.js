/* =========================================================
   assets.js  —  Cargador de imágenes (bitmaps)
   ---------------------------------------------------------
   Carga los PNG de la carpeta assets/ y avisa cuándo están
   listos. Si un archivo no existe todavía, el juego sigue
   funcionando con los dibujos por código (no se rompe nada).

   Opción "chroma": convierte el fondo magenta (#FF00FF) en
   transparente automáticamente, para no tener que recortarlo.
   ========================================================= */

const Assets = {
  items: {},   // nombre -> { el, w, h, ok }

  // Empieza a cargar un PNG.
  //   nombre : clave para pedirlo luego
  //   ruta   : ruta del archivo (p. ej. "assets/tiles.png")
  //   opts   : { chroma: true } para quitar el fondo magenta
  load(nombre, ruta, opts = {}) {
    const entrada = { el: null, w: 0, h: 0, ok: false };
    this.items[nombre] = entrada;

    const img = new Image();
    img.onload = () => {
      if (opts.chroma) {
        entrada.el = this._quitarMagenta(img);   // devuelve un canvas
      } else {
        entrada.el = img;
      }
      entrada.w = img.naturalWidth;
      entrada.h = img.naturalHeight;
      entrada.ok = true;
    };
    img.onerror = () => { entrada.ok = false; };   // si falta, no pasa nada
    img.src = ruta;
    return entrada;
  },

  listo(nombre) {
    const e = this.items[nombre];
    return !!(e && e.ok);
  },
  el(nombre) { return this.items[nombre] && this.items[nombre].el; },
  w(nombre)  { return this.items[nombre] ? this.items[nombre].w : 0; },
  h(nombre)  { return this.items[nombre] ? this.items[nombre].h : 0; },

  // Copia la imagen a un canvas y pone transparentes los píxeles
  // magenta (y su "halo" rosado de los bordes).
  _quitarMagenta(img) {
    const cv = document.createElement("canvas");
    cv.width = img.naturalWidth;
    cv.height = img.naturalHeight;
    const cx = cv.getContext("2d");
    cx.imageSmoothingEnabled = false;
    cx.drawImage(img, 0, 0);
    const datos = cx.getImageData(0, 0, cv.width, cv.height);
    const p = datos.data;
    for (let i = 0; i < p.length; i += 4) {
      const r = p[i], g = p[i + 1], b = p[i + 2];
      // Fondo magenta: verde MUY bajo con rojo y azul presentes. Funciona aunque
      // el magenta sea oscuro (~165,0,165) y NO borra los morados de los tejados
      // (que tienen el verde más alto, ~111).
      if (g < 75 && r > 85 && b > 85) p[i + 3] = 0;   // alpha = 0 (invisible)
    }
    cx.putImageData(datos, 0, 0);
    return cv;
  },
};
