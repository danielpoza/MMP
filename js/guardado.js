/* =========================================================
   guardado.js  —  Guardar y cargar la partida
   ---------------------------------------------------------
   Usa localStorage del navegador: el progreso se queda
   guardado aunque pulses F5 o cierres la pestaña.
   ========================================================= */

const Guardado = {
  CLAVE: "cronicas_de_miguel_save",

  existe() {
    try { return !!localStorage.getItem(this.CLAVE); } catch (e) { return false; }
  },
  guardar(data) {
    try { localStorage.setItem(this.CLAVE, JSON.stringify(data)); return true; }
    catch (e) { return false; }
  },
  cargar() {
    try { const s = localStorage.getItem(this.CLAVE); return s ? JSON.parse(s) : null; }
    catch (e) { return null; }
  },
  borrar() {
    try { localStorage.removeItem(this.CLAVE); } catch (e) {}
  },
};
