/* =========================================================
   main.js  —  Arranque y bucle principal
   ---------------------------------------------------------
   Aquí empieza todo. Creamos el juego y lo actualizamos
   ~60 veces por segundo con requestAnimationFrame.
   ========================================================= */

window.addEventListener("load", () => {
  const canvas = document.getElementById("game");
  Input.init();

  // ---- Cargar los bitmaps (si un archivo no existe, se usa el dibujo por código) ----
  Assets.load("tiles", "assets/tiles.png");                    // suelo (fondo lleno)
  Assets.load("caballero", "assets/caballero.png", { chroma: true }); // héroe (fondo magenta)
  Assets.load("casa_roja",     "assets/casa_roja.png",     { chroma: true });
  Assets.load("casa_azul",     "assets/casa_azul.png",     { chroma: true });
  Assets.load("casa_verde",    "assets/casa_verde.png",    { chroma: true });
  Assets.load("casa_amarilla", "assets/casa_amarilla.png", { chroma: true });
  Assets.load("casa_morada",   "assets/casa_morada.png",   { chroma: true });
  Assets.load("molino_torre",  "assets/molino_torre.png",  { chroma: true });
  Assets.load("molino_aspas",  "assets/molino_aspas.png",  { chroma: true });
  Assets.load("pozo",          "assets/pozo.png",          { chroma: true });
  Assets.load("arbol",         "assets/arbol.png",         { chroma: true });
  Assets.load("arbusto",       "assets/arbusto.png",       { chroma: true });
  Assets.load("moneda",        "assets/moneda.png",        { chroma: true });
  Assets.load("aldeano",       "assets/aldeano.png",       { chroma: true });
  Assets.load("minero",        "assets/minero.png",        { chroma: true });
  Assets.load("carro",         "assets/carro.png",         { chroma: true });
  Assets.load("cartel",        "assets/cartel.png",        { chroma: true });
  Assets.load("tiles_minerales", "assets/tiles_minerales.png");   // suelo de la isla de minerales
  Assets.load("tienda_exterior", "assets/tienda_exterior.png", { chroma: true }); // puesto de picos
  Assets.load("tienda_interior", "assets/tienda_interior.png");   // interior de la tienda (fondo lleno)
  // Isla del comercio
  Assets.load("tiles_comercio",   "assets/tiles_comercio.png");                    // hormigón + ladrillo blanco
  Assets.load("puesto_fruta",     "assets/puesto_fruta.png",     { chroma: true });
  Assets.load("puesto_verdura",   "assets/puesto_verdura.png",   { chroma: true });
  Assets.load("puesto_pollo",     "assets/puesto_pollo.png",     { chroma: true });
  Assets.load("puesto_minerales", "assets/puesto_minerales.png", { chroma: true });
  Assets.load("fumador",          "assets/fumador.png",          { chroma: true });
  Assets.load("puerta",           "assets/puerta.png",           { chroma: true }); // puerta escondida del calabozo
  Assets.load("calabozo",         "assets/calabozo.png");                           // vista del calabozo por las rejillas (fondo lleno)
  Assets.load("int_fruta",     "assets/int_fruta.png");       // interiores de las tiendas (fondo lleno)
  Assets.load("int_verdura",   "assets/int_verdura.png");
  Assets.load("int_pollo",     "assets/int_pollo.png");
  Assets.load("int_minerales", "assets/int_minerales.png");
  Assets.load("interior_casa", "assets/interior_casa.png");   // escena 1ª persona (fondo lleno)
  Assets.load("portada",       "assets/portada.png");

  const game = new Game(canvas);

  // Clic del ratón: lo pasamos al juego en coordenadas del canvas
  canvas.addEventListener("click", (e) => {
    const rect = canvas.getBoundingClientRect();
    const x = (e.clientX - rect.left) * (canvas.width / rect.width);
    const y = (e.clientY - rect.top) * (canvas.height / rect.height);
    game.onClick(x, y);
  });

  // Ocultar la pista de teclas tras unos segundos
  setTimeout(() => document.getElementById("hint")?.classList.add("oculto"), 6000);

  let anterior = performance.now();

  function bucle(ahora) {
    // dt = segundos transcurridos desde el frame anterior
    let dt = (ahora - anterior) / 1000;
    anterior = ahora;
    if (dt > 0.05) dt = 0.05;        // evita saltos si la pestaña se congela

    game.update(dt);
    game.draw();
    Input.endFrame();                // limpiar pulsaciones "de una vez"

    requestAnimationFrame(bucle);
  }

  requestAnimationFrame(bucle);
});
