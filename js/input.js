/* =========================================================
   input.js  —  Lee el teclado
   ---------------------------------------------------------
   Guardamos qué teclas están pulsadas en cada momento.
   Así el juego solo tiene que preguntar: "¿está pulsada
   la flecha derecha?" sin preocuparse de los eventos.
   ========================================================= */

const Input = {
  // Direcciones de movimiento (true = pulsada)
  up: false,
  down: false,
  left: false,
  right: false,

  // Teclas de "acción" que queremos detectar una sola vez
  pressed: {},        // se pone a true el frame en que se pulsa
  _down: {},          // control interno para no repetir

  init() {
    window.addEventListener("keydown", (e) => this._set(e, true));
    window.addEventListener("keyup",   (e) => this._set(e, false));
  },

  _set(e, valor) {
    const k = e.key.toLowerCase();

    // Movimiento (flechas o WASD)
    if (k === "arrowup"    || k === "w") this.up = valor;
    if (k === "arrowdown"  || k === "s") this.down = valor;
    if (k === "arrowleft"  || k === "a") this.left = valor;
    if (k === "arrowright" || k === "d") this.right = valor;

    // Acciones (Enter, Escape, flechas para menús, E interactuar, F mirar, P inventario)
    const acciones = ["enter", "escape", "arrowup", "arrowdown", " ", "e", "f", "p"];
    if (acciones.includes(k)) {
      // "pressed" solo en el instante de pulsar, no mientras se mantiene
      if (valor && !this._down[k]) this.pressed[k] = true;
      this._down[k] = valor;
      e.preventDefault();   // que las flechas no muevan la página
    }
  },

  // Se llama al final de cada frame para limpiar las pulsaciones "de una vez"
  endFrame() {
    this.pressed = {};
  },
};
