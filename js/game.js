/* =========================================================
   game.js  —  El director del juego
   ---------------------------------------------------------
   Gestiona en qué "pantalla" estamos:
     - "titulo"  : la portada con el menú
     - "jugando" : el mapa con el personaje
     - "salir"   : la despedida
   y pasa el control de una a otra.
   ========================================================= */

// Diálogo con el anciano de la casa roja. Cada "parte" se muestra junta y se
// avanza con Enter. (Seok se presenta en la parte 2; antes es "Joven caballero".)
const DIALOGO_ANCIANO = [
  [
    { quien: "Anciano", texto: "¿Qué te trae por aquí, joven?" },
    { quien: "Joven caballero", texto: "Es un honor poder hablar al fin con usted, señor." },
  ],
  [
    { quien: "Anciano", texto: "¿Y tú cómo te haces llamar?" },
    { quien: "Joven caballero", texto: "Llámeme Seok, por favor. Vengo porque la gente de estas islas dice que usted sabe sobre un tesoro que nadie ha encontrado jamás." },
  ],
  [
    { quien: "Anciano", texto: "Así es. Encontré el mapa hace mucho tiempo, pero padezco una enfermedad que me impide ir a buscarlo." },
    { quien: "Seok", texto: "Me gustaría encontrar el tesoro. Necesito ese mapa." },
  ],
  [
    { quien: "Anciano", texto: "¿Y cómo sé yo que es usted digno de ese tesoro?" },
    { quien: "Seok", texto: "Mi poca sabiduría no demostrará nada, pero le puedo asegurar de que soy un ser muy noble." },
  ],
  [
    { quien: "Anciano", texto: "Entonces pues le haré una prueba: irás a la isla más cercana y me traerás 5 kilos de hierro en bruto sin quedarte nada. Y si sacas más, también deberás entregármelo." },
    { quien: "Seok", texto: "No le defraudaré." },
  ],
];

// Los tres picos de la tienda. velNum = velocidad de picado (mayor = más rápido);
// durMax = durabilidad; desgNum = cuánto se gasta por golpe (mayor = se rompe antes).
const PICOS = [
  { id: "hierro",   nombre: "Pico de hierro",   precio: 50,  color: "#c98a4a", velocidad: "Media",      desgaste: "Lento",  velNum: 1.0, durMax: 80,  desgNum: 1 },
  { id: "oro",      nombre: "Pico de oro",      precio: 60,  color: "#f6d357", velocidad: "Rápida",     desgaste: "Rápido", velNum: 1.5, durMax: 45,  desgNum: 2 },
  { id: "diamante", nombre: "Pico de diamante", precio: 200, color: "#bfeaf5", velocidad: "Muy rápida", desgaste: "Lento",  velNum: 2.3, durMax: 150, desgNum: 1 },
];

// Productos de las tiendas de comida (comprar -> curan vida)
const PRODUCTOS_COMERCIO = {
  fruta: [
    { nombre: "Manzana", precio: 15, vida: 25 },
    { nombre: "Manzana misteriosa", precio: 0, vida: 0, misteriosa: true },
    { nombre: "Pera", precio: 10, vida: 10 },
  ],
  verdura: [
    { nombre: "Lechuga", precio: 30, vida: 50 },
    { nombre: "Pepino", precio: 20, vida: 20 },
  ],
  pollo: [
    { nombre: "Pollo", precio: 15, vida: 5 },
    { nombre: "Pato", precio: 15, vida: 5 },
  ],
  puros: [
    { nombre: "Puro", precio: 5, vida: -10 },
  ],
};
// Efecto de cada consumible al USARLO desde la mochila
const CONSUMIBLES = {
  "Manzana": { vida: 25 },
  "Manzana misteriosa": { misteriosa: true },
  "Pera": { vida: 10 },
  "Lechuga": { vida: 50 },
  "Pepino": { vida: 20 },
  "Pollo": { vida: 5 },
  "Pato": { vida: 5 },
  "Puro": { vida: -10 },
};
// Precio de VENTA de cada mineral en el puesto de minerales
const MINERAL_VENTA = { hierro: 5, oro: 7, ametista: 15, diamante: 21 };
const NOMBRE_TIENDA = { fruta: "Frutería", verdura: "Verdulería", pollo: "Pollería", minerales: "Compra de minerales", puros: "Puros" };
const COLORES_PROD = {
  "Manzana": "#e0392b", "Manzana misteriosa": "#9b59b6", "Pera": "#8bc34a",
  "Lechuga": "#7bc86a", "Pepino": "#3f8a3a", "Pollo": "#e8c9a0", "Pato": "#caa24a", "Puro": "#6b5a4a",
};

// Diálogo del fumador al entrar en la isla del comercio (acaba abriendo la tienda de puros)
const DIALOGO_FUMADOR = [
  [
    { quien: "Señor", texto: "¡Eh, tú!" },
    { quien: "Seok", texto: "¿Qué quiere un fumador de mí?" },
  ],
  [
    { quien: "Señor", texto: "¿Quieres un poco?" },
    { quien: "Seok", texto: "No fumo, déjeme." },
  ],
  [
    { quien: "Señor", texto: "Venga, solo un momento, no será para tanto." },
    { quien: "Seok", texto: "..." },
  ],
];

// Lo que dice Seok al intentar abrir la puerta escondida del calabozo.
// El texto va cambiando según lo que ha averiguado (ver _guionPuerta).
const DIALOGO_PUERTA_TIENDAS = [
  [
    { quien: "Seok", texto: "Está cerrada, miraré en las tiendas por si alguno tiene la llave." },
  ],
];
const DIALOGO_PUERTA_ANCIANO = [
  [
    { quien: "Seok", texto: "Debería preguntarle al anciano." },
  ],
];
const DIALOGO_PUERTA_MANZANA = [
  [
    { quien: "Seok", texto: "Debería mirar esa manzana misteriosa." },
  ],
];

// Conversación con el anciano sobre la llave (tras mirar en todas las tiendas)
const DIALOGO_ANCIANO_LLAVE = [
  [
    { quien: "Anciano", texto: "¿Ya tienes el mapa? Qué rápido." },
    { quien: "Seok", texto: "Necesito tu ayuda. He encontrado un calabozo y estoy seguro de que más allá estará la bóveda, pero no he encontrado la llave. Miré por muchas tiendas y encontré cosas muy extrañas." },
  ],
  [
    { quien: "Anciano", texto: "¿Qué clase de cosas?" },
    { quien: "Seok", texto: "Había uno que vendía puros, otro que vendía una manzana misteriosa GRATIS, y otro que vendía la carne por 15 reales y casi no daba energía." },
  ],
  [
    { quien: "Anciano", texto: "Qué interesante. ¿Cómo era la manzana esa?" },
    { quien: "Seok", texto: "El tipo parecía muy apresurado por venderla." },
  ],
  [
    { quien: "Anciano", texto: "No creo que haya una llave como tal, pero deberías mirar esa manzana." },
    { quien: "Seok", texto: "De acuerdo." },
  ],
];

// Lo que dice el anciano si vuelves a la casa sin haber terminado la misión
const DIALOGO_EXPULSION = [
  [
    { quien: "Anciano", texto: "¿Qué haces aquí? ¡No has terminado la misión!" },
  ],
];

// Segundo diálogo: al volver con la misión CUMPLIDA (5/5 de hierro)
const DIALOGO_ANCIANO_2 = [
  [
    { quien: "Anciano", texto: "Ya lo tienes, bien hecho. Has aprobado." },
    { quien: "Seok", texto: "¿Ya me dará el mapa?" },
  ],
  [
    { quien: "Anciano", texto: "Si lo quieres, tendrás que ir a una bóveda en otra isla llamada la isla del comercio." },
    { quien: "Seok", texto: "¿Ahí está el mapa?" },
  ],
  [
    { quien: "Anciano", texto: "Sí, pero ten cuidado y no compres nada. La gente de ahí solo quiere hacerte ofertas hasta que tu bolsillo esté vacío, y cuando te des cuenta, estarás en la calle como un vagabundo." },
    { quien: "Seok", texto: "Tendré cuidado." },
  ],
];

class Game {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d");
    this.ancho = canvas.width;
    this.alto = canvas.height;

    // Pixel art nítido: sin difuminado al escalar
    this.ctx.imageSmoothingEnabled = false;

    // Pantallas
    this.titulo = new TitleScreen(this.ancho, this.alto);
    this.bye = new ByeScreen(this.ancho, this.alto);

    // Mundo, cámara y jugador (se crean al empezar a jugar)
    this.world = null;
    this.cam = null;
    this.player = null;

    this.estado = "titulo";
    this.casaCerca = null;    // casa "entrable" cercana (o null)
    this.mensaje = "";        // mensaje temporal en pantalla
    this.mensajeT = 0;        // segundos que le quedan al mensaje
    this.dialogo = null;      // { guion, i, alTerminar } o null
    this.misiones = [];       // lista de misiones activas
    this.panelMisiones = false; // ¿está abierto el pergamino de misiones?
    this._scrollRect = null;  // zona clicable del icono de pergamino
    this.mapaAbierto = false; // ¿está abierto el mapa de islas?
    this.cartelCerca = false; // ¿el jugador está junto al cartel?
    this.islaMinerales = null; // escenario de la isla de los minerales (se crea al viajar)
    this.islaComercio = null;  // escenario de la isla del comercio
    this.calabozo = null;      // sala del calabozo (tras tumbar la puerta)
    this._mapaIslas = [];     // zonas clicables de las islas en el mapa
    this.puestoComCerca = null; // puesto del comercio cercano (o null)
    this.puertaCerca = false; // ¿el jugador está junto a la puerta escondida?
    this.mirandoCalabozo = false; // ¿está mirando el calabozo por las rejillas?
    this.salidaCerca = false; // ¿el jugador está junto a la salida del calabozo?
    this.tiendasVistas = {};  // tiendas del comercio ya visitadas (fruta/verdura/pollo/minerales/puros)
    this.ancianoLlaveHablado = false; // ¿ya ha hablado con el anciano sobre la llave?
    this.puertaAbierta = false; // ¿se ha tumbado ya la puerta del calabozo?
    this.tiendaComercio = null; // tipo de tienda abierta (fruta/verdura/pollo/minerales)
    this.ventaSel = {};       // minerales seleccionados para vender
    this._comBotones = [];    // botones de la tienda del comercio
    this.comMsg = ""; this.comMsgT = 0;  // aviso de la tienda del comercio
    this.puestoCerca = false; // ¿el jugador está junto al puesto de picos?
    this._tiendaBotones = []; // botones "Comprar" de la tienda (para el ratón)
    this.tiendaMsg = ""; this.tiendaMsgT = 0;  // aviso de la tienda (compra / sin reales)
    this.reloj = 0;           // segundos jugados (para la regeneración de menas)
    this.inventarioAbierto = false;  // ¿está abierta la mochila (tecla P)?
    this._misionRects = [];   // botones "reclamar recompensa" del diario
    this._invBotones = [];    // objetos de comida clicables en la mochila
    this.invMsg = ""; this.invMsgT = 0;   // aviso al comer/fumar
    this.fumadorHablado = false;  // ¿ya ha hablado el fumador la primera vez?
    this.fumadorCerca = false;
  }

  // ---- Cartel del mapa ----
  _cercaDelCartel() {
    const c = this.world && this.world.cartel;
    if (!c) return false;
    const px = this.player.x + this.player.ancho / 2, py = this.player.y + this.player.alto / 2;
    return Math.hypot(px - (c.x + c.w / 2), py - (c.y + c.h / 2)) < 82;
  }
  _clicEnCartel(cx, cy) {
    const c = this.world && this.world.cartel;
    if (!c) return false;
    const wx = cx + this.cam.x, wy = cy + this.cam.y;   // clic -> coordenadas del mundo
    return wx > c.x - 12 && wx < c.x + c.w + 12 && wy > c.y - 34 && wy < c.y + c.h + 8;
  }

  // ---- Misiones ----
  _misionAnciano() { return this.misiones.find((m) => m.id === "hierro") || null; }
  // La casa se bloquea si hay una misión del anciano (hierro o bóveda) sin terminar
  _ancianoBloqueado() {
    // Excepción: si ya has mirado en todas las tiendas, el anciano te recibe
    // para hablar de la llave (aunque la misión de la bóveda siga a medias).
    if (this._puedeHablarLlave()) return false;
    return this.misiones.some((m) => (m.id === "hierro" || m.id === "boveda") && !m.completada);
  }
  // ¿Están ya visitadas las 5 tiendas del comercio (incluida la del fumador)?
  _todasTiendasVistas() {
    return ["fruta", "verdura", "pollo", "minerales", "puros"].every((t) => this.tiendasVistas[t]);
  }
  // ¿Es el momento de ir a hablar con el anciano sobre la llave?
  _puedeHablarLlave() {
    const boveda = this.misiones.find((m) => m.id === "boveda");
    return !!boveda && !boveda.completada && this._todasTiendasVistas() && !this.ancianoLlaveHablado;
  }
  _asignarMisionBoveda() {
    if (this.misiones.find((m) => m.id === "boveda")) return;
    this.misiones.push({
      id: "boveda",
      titulo: "El mapa del tesoro",
      desc: "Accede a la bóveda de la isla del comercio.",
      progreso: 0, objetivo: 1, unidad: "",
      completada: false, recompensa: 0, cobrada: false,
    });
  }
  // Cobrar la recompensa de una misión terminada (al clicarla)
  _cobrarMision(id) {
    const m = this.misiones.find((x) => x.id === id);
    if (!m || !m.completada || m.cobrada) return;
    m.cobrada = true;
    this.player.reales += m.recompensa;
  }
  _asignarMisionAnciano() {
    if (this._misionAnciano()) return;
    this.misiones.push({
      id: "hierro",
      titulo: "El encargo del anciano",
      desc: "Trae 5 kg de hierro en bruto de la isla más cercana.",
      progreso: 0, objetivo: 5, unidad: "kg", completada: false,
      recompensa: 25, cobrada: false,     // 25 reales al reclamarla
    });
  }

  _iniciarPartida() {
    this.world = new World();
    this.cam = new Camera(this.ancho, this.alto);
    // Colocamos al caballero en la entrada del camino, por abajo
    this.player = new Player(24 * TILE, 30 * TILE);
    this.cam.seguir(this.player, this.world.pixelWidth, this.world.pixelHeight);
    // Estado limpio para una partida nueva
    this.misiones = [];
    this.islaMinerales = null;
    this.islaComercio = null;
    this.calabozo = null;
    this.dialogo = null;
    this.panelMisiones = false;
    this.inventarioAbierto = false;
    this.mapaAbierto = false;
    this.fumadorHablado = false;
    this.tiendasVistas = {};
    this.ancianoLlaveHablado = false;
    this.puertaAbierta = false;
    this.reloj = 0;
    this.estado = "jugando";
    document.getElementById("hint")?.classList.remove("oculto");
  }

  // ---- Guardar / cargar ----
  _guardarPartida() {
    const p = this.player;
    if (!p) return;
    Guardado.guardar({
      version: 1,
      reloj: this.reloj,
      player: {
        x: p.x, y: p.y, dir: p.dir,
        reales: p.reales, vida: p.vida, vidaMax: p.vidaMax,
        picos: p.picos, picoEquipado: p.picoEquipado, picoDurabilidad: p.picoDurabilidad,
        inventario: p.inventario, comida: p.comida, maldito: p.maldito,
      },
      misiones: JSON.parse(JSON.stringify(this.misiones)),
      tiendasVistas: { ...this.tiendasVistas },
      ancianoLlaveHablado: this.ancianoLlaveHablado,
      puertaAbierta: this.puertaAbierta,
    });
  }

  _cargarPartida() {
    const d = Guardado.cargar();
    this._iniciarPartida();          // crea mundo/cámara/jugador y limpia el estado
    if (!d) return;                  // sin datos: queda como partida nueva
    const p = this.player, s = d.player || {};
    p.x = s.x ?? p.x; p.y = s.y ?? p.y; p.dir = s.dir || "abajo";
    p.reales = s.reales || 0; p.vida = s.vida ?? 100; p.vidaMax = s.vidaMax || 100;
    p.picos = s.picos || {}; p.picoEquipado = s.picoEquipado || null; p.picoDurabilidad = s.picoDurabilidad || 0;
    p.inventario = s.inventario || {};
    p.comida = s.comida || {};
    p.maldito = !!s.maldito;
    this.misiones = d.misiones || [];
    this.tiendasVistas = d.tiendasVistas || {};
    this.ancianoLlaveHablado = !!d.ancianoLlaveHablado;
    this.puertaAbierta = !!d.puertaAbierta;
    this.reloj = d.reloj || 0;
    this.cam.seguir(p, this.world.pixelWidth, this.world.pixelHeight);
    this.estado = "jugando";
  }

  // Entrar al interior de la casa: guardamos la posición en el mapa
  _entrarCasa() {
    this._mapaPos = { x: this.player.x, y: this.player.y, dir: this.player.dir };
    this.interior = new Interior(this.ancho, this.alto);
    this.player.x = this.ancho / 2 - this.player.ancho / 2;   // aparecemos en la puerta
    this.player.y = this.alto - 90;
    this.player.dir = "arriba";
    this.casaCerca = null;
    const hierro = this.misiones.find((x) => x.id === "hierro");
    const boveda = this.misiones.find((x) => x.id === "boveda");
    if (!hierro) {
      // Primera vez: conversación completa que asigna la misión del hierro
      this.dialogo = { guion: DIALOGO_ANCIANO, i: 0, alTerminar: "asignarYExpulsar" };
    } else if (!hierro.completada) {
      // Misión del hierro a medias: te echa
      this.dialogo = { guion: DIALOGO_EXPULSION, i: 0, alTerminar: "expulsar" };
    } else if (!boveda) {
      // Hierro cumplido y aún no ha oído lo del mapa: segundo diálogo
      this.dialogo = { guion: DIALOGO_ANCIANO_2, i: 0, alTerminar: "fin2" };
    } else if (this._puedeHablarLlave()) {
      // Has mirado en todas las tiendas: conversación sobre la llave y la manzana
      this.dialogo = { guion: DIALOGO_ANCIANO_LLAVE, i: 0, alTerminar: "llaveHablado" };
    } else {
      // Misión de la bóveda a medias: te echa
      this.dialogo = { guion: DIALOGO_EXPULSION, i: 0, alTerminar: "expulsar" };
    }
    this.estado = "interior";
  }

  // Viajar a la isla de los minerales (desde el mapa)
  _viajarAMinerales() {
    this._mapaPos = { x: this.player.x, y: this.player.y, dir: this.player.dir };
    if (!this.islaMinerales) this.islaMinerales = new IslaMinerales();
    this.player.x = this.islaMinerales.inicio.x;
    this.player.y = this.islaMinerales.inicio.y;
    this.player.dir = "abajo";
    this.cam.seguir(this.player, this.islaMinerales.pixelWidth, this.islaMinerales.pixelHeight);
    this.mapaAbierto = false;
    this.mensaje = "Isla de los minerales"; this.mensajeT = 2.5;
    this.estado = "isla_minerales";
  }

  // Volver a la isla del anciano
  _volverDeMinerales() {
    this.player.x = this._mapaPos.x;
    this.player.y = this._mapaPos.y;
    this.player.dir = this._mapaPos.dir;
    this.estado = "jugando";
  }

  // Viajar a la isla del comercio (desde el mapa)
  _viajarAComercio() {
    this._mapaPos = { x: this.player.x, y: this.player.y, dir: this.player.dir };
    if (!this.islaComercio) this.islaComercio = new IslaComercio();
    this.islaComercio.puerta.abierta = this.puertaAbierta;   // ¿ya estaba tumbada?
    this.player.x = this.islaComercio.inicio.x;
    this.player.y = this.islaComercio.inicio.y;
    this.player.dir = "arriba";
    this.cam.seguir(this.player, this.islaComercio.pixelWidth, this.islaComercio.pixelHeight);
    this.mapaAbierto = false;
    this.mensaje = "Isla del comercio"; this.mensajeT = 2.5;
    // La primera vez, el fumador te aborda nada más entrar
    this.dialogo = this.fumadorHablado ? null : { guion: DIALOGO_FUMADOR, i: 0, alTerminar: "puros" };
    this.estado = "isla_comercio";
  }
  _volverDeComercio() {
    this.player.x = this._mapaPos.x;
    this.player.y = this._mapaPos.y;
    this.player.dir = this._mapaPos.dir;
    this.estado = "jugando";
  }

  // Entrar al calabozo por la puerta tumbada
  _entrarCalabozo() {
    this._comercioPos = { x: this.player.x, y: this.player.y, dir: this.player.dir };
    if (!this.calabozo) this.calabozo = new Calabozo();
    this.player.x = this.calabozo.inicio.x;
    this.player.y = this.calabozo.inicio.y;
    this.player.dir = "arriba";
    this.cam.seguir(this.player, this.calabozo.pixelWidth, this.calabozo.pixelHeight);
    this.mensaje = "El calabozo..."; this.mensajeT = 2.2;
    this.estado = "calabozo";
  }
  // Salir del calabozo: volver a la plaza, junto a la puerta
  _salirCalabozo() {
    if (this._comercioPos) {
      this.player.x = this._comercioPos.x;
      this.player.y = this._comercioPos.y;
      this.player.dir = "izq";
    }
    this.cam.seguir(this.player, this.islaComercio.pixelWidth, this.islaComercio.pixelHeight);
    this.estado = "isla_comercio";
  }

  // ---- Tiendas del comercio (comprar comida / vender minerales) ----
  _puestoComercioCerca() {
    if (!this.islaComercio) return null;
    const px = this.player.x + this.player.ancho / 2, py = this.player.y + this.player.alto / 2;
    for (const o of this.islaComercio.puestos) {
      if (Math.hypot(px - (o.x + o.w / 2), py - (o.y + o.h / 2)) < 96) return o;
    }
    return null;
  }
  _entrarTiendaComercio(tipo) {
    this.tiendaComercio = tipo;
    this.ventaSel = {};
    this.tiendasVistas[tipo] = true;   // apuntamos que ya hemos mirado esta tienda
    this.estado = "tienda_comercio";
  }
  // Tumbar la puerta del calabozo (solo con el efecto de Fuerza de la manzana)
  _tumbarPuerta() {
    this.puertaAbierta = true;
    if (this.islaComercio) this.islaComercio.puerta.abierta = true;   // cambia el dibujo a "abierta"
    this.mensaje = "¡PUM! Tumbas la puerta de una patada.";
    this.mensajeT = 2.8;
  }
  // Elige qué dice Seok al intentar abrir la puerta, según lo que ha averiguado
  _guionPuerta() {
    if (!this._todasTiendasVistas()) return DIALOGO_PUERTA_TIENDAS;   // aún le faltan tiendas
    if (!this.ancianoLlaveHablado)   return DIALOGO_PUERTA_ANCIANO;   // ya toca ir al anciano
    return DIALOGO_PUERTA_MANZANA;                                    // el anciano le habló de la manzana
  }
  _comAviso(txt) { this.comMsg = txt; this.comMsgT = 2.4; }

  _comprarComida(tipo, i) {
    const p = PRODUCTOS_COMERCIO[tipo][i];
    if (!p) return;
    if (p.misteriosa && this.puertaAbierta) { this._comAviso("Vendido: ya no queda"); return; }
    if (p.precio > 0 && this.player.reales < p.precio) { this._comAviso("No tienes suficientes reales"); return; }
    this.player.reales -= p.precio;
    this.player.comida[p.nombre] = (this.player.comida[p.nombre] || 0) + 1;
    this._comAviso("Comprado: " + p.nombre + " (úsalo en la mochila, tecla P)");
  }

  // Usar (comer/fumar) un consumible desde la mochila
  _consumir(nombre) {
    if ((this.player.comida[nombre] || 0) <= 0) return;
    this.player.comida[nombre]--;
    if (this.player.comida[nombre] <= 0) delete this.player.comida[nombre];
    const c = CONSUMIBLES[nombre] || {};
    if (c.misteriosa) { this.invMsg = this._efectoManzana(); this.invMsgT = 3.2; return; }
    const antes = this.player.vida;
    this.player.vida = Math.max(0, Math.min(this.player.vidaMax, this.player.vida + (c.vida || 0)));
    const dif = this.player.vida - antes;
    const verbo = nombre === "Puro" ? "Fumas un puro" : "Comes " + nombre;
    this.invMsg = verbo + (dif >= 0 ? " (+" + dif + " vida)" : " (" + dif + " vida)");
    this.invMsgT = 2.6;
  }
  // La manzana misteriosa: cura del todo, da Fuerza nivel 5 (30 s) y te maldice
  _efectoManzana() {
    const p = this.player;
    const antes = p.vida;
    p.vida = Math.min(p.vidaMax, p.vida + 100);   // +100 de vida (hasta el máximo)
    p.fuerzaT = 30;                                // dura 30 segundos
    p.fuerzaNivel = 5;                             // Fuerza nivel 5
    p.maldito = true;                              // maldición (monstruos: más adelante)
    return "¡FUERZA nivel 5! (+" + (p.vida - antes) + " vida, 30 s). Corres más y podrías tumbar puertas... pero notas una maldición.";
  }
  _efectoMisterioso() {
    const r = Math.floor(Math.random() * 4);
    if (r === 0) { const a = this.player.vida; this.player.vida = Math.min(this.player.vidaMax, this.player.vida + 50); return "¡Deliciosa! +" + (this.player.vida - a) + " de vida"; }
    if (r === 1) { this.player.vida = Math.max(0, this.player.vida - 20); return "¡Puaj, estaba podrida! -20 de vida"; }
    if (r === 2) { this.player.reales += 10; return "¡Tenía una moneda dentro! +10 reales"; }
    return "Sabía a nada... no pasó nada.";
  }
  _ajustarVenta(id, d) {
    const tiene = this.player.inventario[id] || 0;
    this.ventaSel[id] = Math.max(0, Math.min(tiene, (this.ventaSel[id] || 0) + d));
  }
  _venderMinerales() {
    let total = 0, algo = false;
    for (const id in MINERAL_VENTA) {
      const n = Math.min(this.ventaSel[id] || 0, this.player.inventario[id] || 0);
      if (n <= 0) continue;
      this.player.inventario[id] -= n;
      total += n * MINERAL_VENTA[id];
      algo = true;
    }
    this.player.reales += total;
    this.ventaSel = {};
    this._comAviso(algo ? "Vendido por " + total + " reales" : "No has seleccionado nada");
  }

  // ---- Puesto de picos / tienda ----
  _cercaDelPuesto() {
    const p = this.islaMinerales && this.islaMinerales.puesto;
    if (!p) return false;
    const px = this.player.x + this.player.ancho / 2, py = this.player.y + this.player.alto / 2;
    return Math.hypot(px - (p.x + p.w / 2), py - (p.y + p.h / 2)) < 140;
  }
  _entrarTienda() {
    this._minPos = { x: this.player.x, y: this.player.y, dir: this.player.dir };
    this.estado = "tienda";
  }
  _salirTienda() {
    this.player.x = this._minPos.x;
    this.player.y = this._minPos.y;
    this.player.dir = this._minPos.dir;
    this.estado = "isla_minerales";
  }
  _comprarPico(id) {
    const pico = PICOS.find((p) => p.id === id);
    if (!pico) return;
    if (this.player.picos[id]) {
      this.player.picoEquipado = id;
      this.player.picoDurabilidad = pico.durMax;
      this._tiendaAviso("Equipado: " + pico.nombre); return;
    }
    if (this.player.reales < pico.precio) { this._tiendaAviso("No tienes suficientes reales"); return; }
    this.player.reales -= pico.precio;
    this.player.picos[id] = true;
    this.player.picoEquipado = id;   // se equipa al comprarlo
    this.player.picoDurabilidad = pico.durMax;
    this._tiendaAviso("¡Comprado! " + pico.nombre);
  }
  _tiendaAviso(txt) { this.tiendaMsg = txt; this.tiendaMsgT = 2.2; }

  // Qué pasa cuando termina un diálogo
  _finDialogo() {
    const accion = this.dialogo.alTerminar;
    this.dialogo = null;
    if (accion === "asignarYExpulsar") {
      this._asignarMisionAnciano();
      // ...y acto seguido te echa de casa
      this.dialogo = { guion: DIALOGO_EXPULSION, i: 0, alTerminar: "expulsar" };
    } else if (accion === "expulsar") {
      this._salirCasa();
    } else if (accion === "fin2") {
      this._asignarMisionBoveda();   // nueva misión -> la casa vuelve a bloquearse
    } else if (accion === "puros") {
      this.fumadorHablado = true;
      this._entrarTiendaComercio("puros");   // el fumador te "vende" puros
    } else if (accion === "llaveHablado") {
      this.ancianoLlaveHablado = true;       // ya sabe que debe mirar la manzana
      this._salirCasa();
    }
  }

  _cercaFumador() {
    const f = this.islaComercio && this.islaComercio.fumador;
    if (!f) return false;
    const px = this.player.x + this.player.ancho / 2, py = this.player.y + this.player.alto / 2;
    return Math.hypot(px - (f.x + f.ancho / 2), py - (f.y + f.alto / 2)) < 90;
  }

  // Salir al mapa, en el mismo sitio en el que entramos
  _salirCasa() {
    this.player.x = this._mapaPos.x;
    this.player.y = this._mapaPos.y;
    this.player.dir = this._mapaPos.dir;
    this.estado = "jugando";
  }

  update(dt) {
    this.reloj += dt;          // reloj del juego (para regenerar menas a los 10 min)
    if (this.invMsgT > 0) this.invMsgT -= dt;
    // La tecla P abre/cierra la mochila en las pantallas jugables
    if (Input.pressed["p"] && ["jugando", "isla_minerales", "isla_comercio", "interior"].includes(this.estado)) {
      this.inventarioAbierto = !this.inventarioAbierto;
    }
    switch (this.estado) {
      case "titulo": {
        // Opciones según el contexto (hay partida en memoria / hay guardado)
        const hayPartida = !!this.world;
        const haySave = Guardado.existe();
        const opts = [];
        if (hayPartida || haySave) opts.push({ texto: "Continuar", id: "continuar" });
        opts.push({ texto: (hayPartida || haySave) ? "Partida nueva" : "Jugar", id: "nueva" });
        if (hayPartida) opts.push({ texto: "Guardar", id: "guardar" });
        opts.push({ texto: "Salir", id: "salir" });
        this.titulo.setOpciones(opts);

        const accion = this.titulo.update(dt);
        if (accion === "continuar") { if (this.world) this.estado = "jugando"; else this._cargarPartida(); }
        else if (accion === "nueva") this._iniciarPartida();
        else if (accion === "guardar") { this._guardarPartida(); this.titulo.mostrarAviso("Partida guardada"); }
        else if (accion === "salir") this.estado = "salir";
        break;
      }
      case "jugando": {
        this.world.time += dt;
        // Con el mapa de islas abierto, el juego se pausa; Esc lo cierra
        if (this.mapaAbierto) {
          if (Input.pressed["escape"]) this.mapaAbierto = false;
          break;
        }
        this.world.update(dt);                       // mueve aldeanos
        this.player.update(dt, this.world);
        const ganado = this.world.recogerMonedas(this.player);  // ¿ha tocado monedas?
        if (ganado) this.player.reales += ganado;
        this.casaCerca = this.world.casaEntrableCerca(this.player); // ¿casa que se puede entrar?
        this.cartelCerca = this._cercaDelCartel();                   // ¿junto al cartel?
        // Pulsar E cerca de una casa entrable -> entrar al interior
        if (this.casaCerca && Input.pressed["e"]) { this._entrarCasa(); break; }
        if (this.mensajeT > 0) this.mensajeT -= dt;
        this.cam.seguir(this.player, this.world.pixelWidth, this.world.pixelHeight);
        // Esc -> volver al menú
        if (Input.pressed["escape"]) {
          this.estado = "titulo";
          document.getElementById("hint")?.classList.add("oculto");
        }
        break;
      }
      case "interior": {
        this.interior.update(dt);
        if (this.dialogo) {
          // Durante el diálogo: Enter (o Espacio) avanza de parte
          if (Input.pressed["enter"] || Input.pressed[" "]) {
            this.dialogo.i++;
            if (this.dialogo.i >= this.dialogo.guion.length) this._finDialogo();
          }
        } else if (!this.interior.esImagen()) {
          // Sin diálogo y en la sala de reserva (vista superior) sí puedes andar
          this.player.update(dt, this.interior);
          this.cam.seguir(this.player, this.interior.pixelWidth, this.interior.pixelHeight);
        }
        if (Input.pressed["escape"]) this._salirCasa();   // Esc -> volver al mapa
        break;
      }
      case "isla_minerales": {
        this.islaMinerales.update(dt);               // reloj + mueve a los mineros
        this.islaMinerales.regenerar(this.reloj);    // vuelven las menas a los 10 min
        this.player.update(dt, this.islaMinerales);
        this.cam.seguir(this.player, this.islaMinerales.pixelWidth, this.islaMinerales.pixelHeight);
        this.puestoCerca = this._cercaDelPuesto();
        if (this.puestoCerca && Input.pressed["e"]) { this._entrarTienda(); break; }
        if (this.mensajeT > 0) this.mensajeT -= dt;
        if (Input.pressed["escape"]) this._volverDeMinerales();   // Esc -> volver
        break;
      }
      case "tienda": {
        if (this.tiendaMsgT > 0) this.tiendaMsgT -= dt;
        if (Input.pressed["escape"]) this._salirTienda();   // Esc -> volver a la isla
        break;
      }
      case "isla_comercio": {
        this.islaComercio.update(dt);
        if (this.mensajeT > 0) this.mensajeT -= dt;
        // Estamos mirando el calabozo por las rejillas: Esc o F cierran esa vista
        if (this.mirandoCalabozo) {
          if (Input.pressed["escape"] || Input.pressed["f"]) this.mirandoCalabozo = false;
          break;
        }
        // Diálogo (p. ej. el del fumador): Enter avanza, no te mueves
        if (this.dialogo) {
          if (Input.pressed["enter"] || Input.pressed[" "]) {
            this.dialogo.i++;
            if (this.dialogo.i >= this.dialogo.guion.length) this._finDialogo();
          }
          break;
        }
        this.player.update(dt, this.islaComercio);
        this.cam.seguir(this.player, this.islaComercio.pixelWidth, this.islaComercio.pixelHeight);
        this.puestoComCerca = this._puestoComercioCerca();
        this.fumadorCerca = this._cercaFumador();
        this.puertaCerca = this.islaComercio.cercaDePuerta(this.player);
        if (this.puestoComCerca && Input.pressed["e"]) { this._entrarTiendaComercio(this.puestoComCerca.tipo); break; }
        if (this.fumadorCerca && Input.pressed["e"]) { this._entrarTiendaComercio("puros"); break; }
        // Puerta escondida: E intenta abrir (cerrada con llave), F mira por las rejillas
        if (this.puertaCerca && Input.pressed["e"]) {
          if (this.puertaAbierta) { this._entrarCalabozo(); }           // ya tumbada: se entra al calabozo
          else if (this.player.tieneFuerza) { this._tumbarPuerta(); }   // ¡con fuerza la tiras abajo!
          else { this.dialogo = { guion: this._guionPuerta(), i: 0, alTerminar: "nada" }; }
          break;
        }
        if (this.puertaCerca && Input.pressed["f"]) { this.mirandoCalabozo = true; break; }
        if (Input.pressed["escape"]) this._volverDeComercio();   // Esc -> volver
        break;
      }
      case "tienda_comercio": {
        if (this.comMsgT > 0) this.comMsgT -= dt;
        if (Input.pressed["escape"]) this.estado = "isla_comercio";
        break;
      }
      case "calabozo": {
        this.calabozo.update(dt);
        if (this.mensajeT > 0) this.mensajeT -= dt;
        this.player.update(dt, this.calabozo);
        this.cam.seguir(this.player, this.calabozo.pixelWidth, this.calabozo.pixelHeight);
        this.salidaCerca = this.calabozo.cercaDeSalida(this.player);
        // Salir por el hueco de abajo (E) o con Esc
        if ((this.salidaCerca && Input.pressed["e"]) || Input.pressed["escape"]) this._salirCalabozo();
        break;
      }
      case "salir": {
        if (Input.pressed["enter"] || Input.pressed[" "]) this.estado = "titulo";
        break;
      }
    }
  }

  draw() {
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.ancho, this.alto);

    if (this.estado === "titulo") {
      this.titulo.draw(ctx);
    } else if (this.estado === "salir") {
      this.bye.draw(ctx);
    } else if (this.estado === "jugando") {
      this.world.drawGround(ctx, this.cam);              // 1) el suelo
      this.world.drawObjects(ctx, this.cam, this.player); // 2) objetos + caballero, por profundidad
      if (this.casaCerca) this._botonEntrar(ctx, this.casaCerca);  // 3) botón "Entrar"/candado
      if (this.cartelCerca && !this.mapaAbierto) this._hintCartel(ctx); // aviso del cartel
      this._hud(ctx);
      if (this.mensajeT > 0) this._toast(ctx, this.mensaje);       // 4) mensaje temporal
      if (this.panelMisiones) this._dibujarPanelMisiones(ctx);     // 5) diario de misiones
      if (this.mapaAbierto) this._dibujarMapaMundo(ctx);           // 6) mapa de islas
    } else if (this.estado === "interior") {
      this.interior.draw(ctx, this.player, this.cam);
      this._hud(ctx);
      if (this.dialogo) this._dibujarDialogo(ctx);
      if (this.panelMisiones) this._dibujarPanelMisiones(ctx);
    } else if (this.estado === "isla_minerales") {
      this.islaMinerales.drawGround(ctx, this.cam);
      this.islaMinerales.drawObjects(ctx, this.cam, this.player);
      if (this.puestoCerca) this._hintPuesto(ctx);       // aviso "comprar (E)"
      this._hud(ctx);
      this._dibujarPicoHUD(ctx);                          // pico equipado + durabilidad
      // Aviso de "volver" abajo
      ctx.fillStyle = "rgba(230,220,200,.85)";
      ctx.font = "14px Georgia, serif";
      ctx.textAlign = "center";
      ctx.fillText("Esc: volver a la isla del anciano", this.ancho / 2, this.alto - 14);
      ctx.textAlign = "left";
      if (this.mensajeT > 0) this._toast(ctx, this.mensaje);
      if (this.panelMisiones) this._dibujarPanelMisiones(ctx);
    } else if (this.estado === "tienda") {
      this._dibujarTienda(ctx);
    } else if (this.estado === "isla_comercio") {
      this.islaComercio.drawGround(ctx, this.cam);
      this.islaComercio.drawObjects(ctx, this.cam, this.player);
      if (!this.dialogo && this.puestoComCerca) this._hintPuestoComercio(ctx, this.puestoComCerca);
      if (!this.dialogo && this.fumadorCerca && this.fumadorHablado) this._hintFumador(ctx);
      if (!this.dialogo && this.puertaCerca && !this.mirandoCalabozo) this._hintPuerta(ctx);
      this._hud(ctx);
      ctx.fillStyle = "rgba(230,220,200,.85)"; ctx.font = "14px Georgia, serif"; ctx.textAlign = "center";
      ctx.fillText("Esc: volver a la isla del anciano", this.ancho / 2, this.alto - 14);
      ctx.textAlign = "left";
      if (this.mensajeT > 0) this._toast(ctx, this.mensaje);
      if (this.dialogo) this._dibujarDialogo(ctx);
      if (this.panelMisiones) this._dibujarPanelMisiones(ctx);
      if (this.mirandoCalabozo) this._dibujarCalabozo(ctx);   // vista por las rejillas (encima de todo)
    } else if (this.estado === "tienda_comercio") {
      this._dibujarTiendaComercio(ctx);
    } else if (this.estado === "calabozo") {
      this.calabozo.drawGround(ctx, this.cam);
      this.calabozo.drawObjects(ctx, this.cam, this.player);
      if (this.salidaCerca) this._hintSalidaCalabozo(ctx);
      this._hud(ctx);
      ctx.fillStyle = "rgba(230,220,200,.85)"; ctx.font = "14px Georgia, serif"; ctx.textAlign = "center";
      ctx.fillText("Esc: salir del calabozo", this.ancho / 2, this.alto - 14);
      ctx.textAlign = "left";
      if (this.mensajeT > 0) this._toast(ctx, this.mensaje);
    }
    if (this.inventarioAbierto) this._dibujarInventario(ctx);   // mochila (P), encima de todo
  }

  // Indicadores de arriba mientras se juega: vida y reales
  _hud(ctx) {
    const p = this.player;

    // Panel superior semitransparente
    ctx.fillStyle = "rgba(0,0,0,.40)";
    ctx.fillRect(0, 0, this.ancho, 46);

    // ---- Barra de vida ----
    const bx = 40, by = 14, bw = 170, bh = 18;
    this._corazon(ctx, 20, by + 9, 9);                 // corazón a la izquierda
    ctx.fillStyle = "#000";
    ctx.fillRect(bx - 2, by - 2, bw + 4, bh + 4);       // borde
    ctx.fillStyle = "#3a1414";
    ctx.fillRect(bx, by, bw, bh);                       // fondo vacío
    const frac = Math.max(0, Math.min(1, p.vida / p.vidaMax));
    ctx.fillStyle = frac > 0.5 ? "#5cc85c" : frac > 0.25 ? "#e0a53a" : "#d64b4b";
    ctx.fillRect(bx, by, bw * frac, bh);                // relleno
    ctx.fillStyle = "rgba(255,255,255,.25)";
    ctx.fillRect(bx, by, bw * frac, bh / 2);            // brillo superior
    ctx.fillStyle = "#fff";
    ctx.font = "bold 12px Georgia, serif";
    ctx.textAlign = "center";
    ctx.fillText(Math.round(p.vida) + " / " + p.vidaMax, bx + bw / 2, by + 14);

    // ---- Reales (dinero) ----
    const mx = bx + bw + 40;
    this._moneda(ctx, mx, by + 9, 9);                  // icono de moneda
    ctx.fillStyle = "#f6d367";
    ctx.font = "bold 18px Georgia, serif";
    ctx.textAlign = "left";
    ctx.fillText(p.reales + " reales", mx + 16, by + 15);

    // ---- Pergamino de misiones (debajo de la barra de vida, clicable) ----
    const px0 = 16, py0 = 52, pw = 42, ph = 32;
    this._scrollRect = { x: px0, y: py0, w: pw, h: ph };
    this._iconoPergamino(ctx, px0, py0, pw, ph, this.misiones.length);

    // ---- Indicador de FUERZA (mientras dure la manzana) ----
    if (p.tieneFuerza) this._dibujarFuerzaHUD(ctx, 70, 52);

    // ---- Ayuda (en el mapa: Esc va al menú; en el interior lo indica la escena) ----
    if (this.estado === "jugando") {
      ctx.textAlign = "right";
      ctx.fillStyle = "#d7e6c9";
      ctx.font = "13px Georgia, serif";
      ctx.fillText("Esc: menú", this.ancho - 12, by + 14);
      ctx.textAlign = "left";
    }
  }

  // Insignia de "Fuerza nivel N" con cuenta atrás (30 s de la manzana)
  _dibujarFuerzaHUD(ctx, x, y) {
    const p = this.player, w = 168, h = 30, dur = 30;
    ctx.save();
    // Fondo dorado oscuro
    ctx.fillStyle = "rgba(60,42,12,.9)"; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.fill();
    ctx.strokeStyle = "#f6d367"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.stroke();
    // Rayo (símbolo de fuerza) dibujado a mano
    ctx.fillStyle = "#ffe27a";
    ctx.beginPath();
    ctx.moveTo(x + 14, y + 6); ctx.lineTo(x + 9, y + 17); ctx.lineTo(x + 13, y + 17);
    ctx.lineTo(x + 10, y + 25); ctx.lineTo(x + 19, y + 14); ctx.lineTo(x + 14, y + 14);
    ctx.closePath(); ctx.fill();
    // Texto
    ctx.fillStyle = "#ffe27a"; ctx.font = "bold 14px Georgia, serif"; ctx.textAlign = "left"; ctx.textBaseline = "middle";
    ctx.fillText("Fuerza " + p.fuerzaNivel, x + 24, y + 11);
    // Barra de cuenta atrás
    const fr = Math.max(0, Math.min(1, p.fuerzaT / dur));
    ctx.fillStyle = "#3a2a0e"; ctx.fillRect(x + 24, y + 18, w - 34, 6);
    ctx.fillStyle = "#f6d367"; ctx.fillRect(x + 24, y + 18, (w - 34) * fr, 6);
    ctx.fillStyle = "#fff2c8"; ctx.font = "bold 11px Georgia, serif"; ctx.textAlign = "right";
    ctx.fillText(Math.ceil(p.fuerzaT) + "s", x + w - 8, y + 10);
    ctx.restore(); ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Parte texto largo en varias líneas que quepan en maxW
  _wrap(ctx, texto, maxW) {
    const palabras = texto.split(" ");
    const lineas = [];
    let actual = "";
    for (const p of palabras) {
      const prueba = actual ? actual + " " + p : p;
      if (ctx.measureText(prueba).width > maxW && actual) { lineas.push(actual); actual = p; }
      else actual = prueba;
    }
    if (actual) lineas.push(actual);
    return lineas;
  }

  // Caja de diálogo (pergamino) con la parte actual de la conversación
  _dibujarDialogo(ctx) {
    const guion = this.dialogo.guion;
    const parte = guion[this.dialogo.i];
    const W = this.ancho, H = this.alto;
    const x = 24, w = W - 48, h = 178, y = H - h - 22;
    const pad = 18, maxW = w - pad * 2 - 10;

    // Caja
    ctx.fillStyle = "rgba(28,18,10,.93)";
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 12); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 3;
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 12); ctx.stroke();

    // Contenido (cada intervención: nombre en color + texto ajustado)
    ctx.textAlign = "left"; ctx.textBaseline = "top";
    let cy = y + pad;
    for (const linea of parte) {
      ctx.font = "bold 17px Georgia, serif";
      ctx.fillStyle = linea.quien === "Anciano" ? "#f6d367" : "#9fd0ff";
      ctx.fillText(linea.quien + ":", x + pad, cy);
      cy += 22;
      ctx.font = "16px Georgia, serif";
      ctx.fillStyle = "#efe6d2";
      for (const l of this._wrap(ctx, linea.texto, maxW)) { ctx.fillText(l, x + pad + 12, cy); cy += 20; }
      cy += 8;
    }

    // Contador de parte (abajo izquierda). Solo si hay más de una parte.
    ctx.font = "12px Georgia, serif";
    ctx.fillStyle = "rgba(200,180,140,.7)";
    if (guion.length > 1) ctx.fillText((this.dialogo.i + 1) + " / " + guion.length, x + pad, y + h - 22);

    // "Enter para continuar" parpadeante (abajo derecha)
    const blink = 0.45 + 0.55 * Math.abs(Math.sin(this.reloj * 4));
    const ultima = this.dialogo.i === guion.length - 1;
    ctx.font = "italic 14px Georgia, serif";
    ctx.fillStyle = `rgba(235,225,205,${blink})`;
    ctx.textAlign = "right";
    ctx.fillText((ultima ? "Enter para terminar" : "Enter para continuar") + "  ▸", x + w - pad, y + h - 24);

    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Icono de mineral (cristal con forma de rombo del color indicado)
  _iconoMineral(ctx, cx, cy, r, col) {
    ctx.fillStyle = col;
    ctx.beginPath(); ctx.moveTo(cx, cy - r); ctx.lineTo(cx + r * 0.75, cy); ctx.lineTo(cx, cy + r); ctx.lineTo(cx - r * 0.75, cy);
    ctx.closePath(); ctx.fill();
    ctx.fillStyle = "rgba(255,255,255,.5)";
    ctx.beginPath(); ctx.moveTo(cx, cy - r); ctx.lineTo(cx + r * 0.75, cy); ctx.lineTo(cx, cy); ctx.closePath(); ctx.fill();
  }

  // La mochila (tecla P): minerales, comida (clic para usar) y objetos
  _dibujarInventario(ctx) {
    const W = this.ancho, H = this.alto;
    this._invBotones = [];
    ctx.save();
    ctx.fillStyle = "rgba(8,6,3,.72)"; ctx.fillRect(0, 0, W, H);
    const pw = 600, ph = 470, px = (W - pw) / 2, py = (H - ph) / 2;
    ctx.fillStyle = "#e7d6a8";
    ctx.beginPath(); ctx.roundRect(px, py, pw, ph, 16); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 4;
    ctx.beginPath(); ctx.roundRect(px, py, pw, ph, 16); ctx.stroke();

    // Título y reales
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 26px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText("Mochila", W / 2, py + 28);
    ctx.font = "bold 16px Georgia, serif"; ctx.textAlign = "right"; ctx.fillStyle = "#7a5a1a";
    ctx.fillText(this.player.reales + " reales   ·   Vida " + Math.round(this.player.vida) + "/" + this.player.vidaMax, px + pw - 22, py + 28);

    // ---- Minerales ----
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 17px Georgia, serif";
    ctx.fillText("Minerales", px + 24, py + 56);
    const mins = [["hierro", "Hierro", "#b5764a"], ["oro", "Oro", "#f6d357"], ["ametista", "Amatista", "#9b59b6"], ["diamante", "Diamante", "#bfeaf5"]];
    const sw = (pw - 48) / mins.length, sh = 86, sy = py + 68;
    let sx = px + 24;
    for (const [id, nom, col] of mins) {
      ctx.fillStyle = "#f4ead0"; ctx.beginPath(); ctx.roundRect(sx + 6, sy, sw - 12, sh, 10); ctx.fill();
      ctx.strokeStyle = "#c9b483"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(sx + 6, sy, sw - 12, sh, 10); ctx.stroke();
      this._iconoMineral(ctx, sx + sw / 2, sy + 26, 12, col);
      ctx.fillStyle = "#5b3b20"; ctx.font = "bold 19px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
      ctx.fillText("x" + (this.player.inventario[id] || 0), sx + sw / 2, sy + 54);
      ctx.font = "12px Georgia, serif"; ctx.fillText(nom, sx + sw / 2, sy + 72);
      sx += sw;
    }

    // ---- Comida (clic para usar) ----
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 17px Georgia, serif";
    ctx.fillText("Comida (clic para usar)", px + 24, py + 178);
    const foods = Object.entries(this.player.comida).filter(([n, c]) => c > 0);
    if (foods.length === 0) {
      ctx.fillStyle = "#6b4a2b"; ctx.font = "italic 15px Georgia, serif";
      ctx.fillText("No tienes comida. Cómprala en la isla del comercio.", px + 30, py + 208);
    } else {
      const area = pw - 48, cwF = Math.min(118, area / foods.length), chF = 74, fyF = py + 190;
      let fx = px + 24 + (area - cwF * foods.length) / 2;
      for (const [nombre, cant] of foods) {
        ctx.fillStyle = "#f4ead0"; ctx.beginPath(); ctx.roundRect(fx + 3, fyF, cwF - 6, chF, 9); ctx.fill();
        ctx.strokeStyle = "#c9b483"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(fx + 3, fyF, cwF - 6, chF, 9); ctx.stroke();
        ctx.fillStyle = COLORES_PROD[nombre] || "#c9a24a";
        ctx.beginPath(); ctx.arc(fx + cwF / 2, fyF + 22, 12, 0, Math.PI * 2); ctx.fill();
        ctx.fillStyle = "#5b3b20"; ctx.font = "bold 14px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
        ctx.fillText("x" + cant, fx + cwF / 2, fyF + 44);
        ctx.font = "10px Georgia, serif";
        ctx.fillText(nombre.length > 11 ? nombre.slice(0, 10) + "…" : nombre, fx + cwF / 2, fyF + 62);
        this._invBotones.push({ nombre, x: fx + 3, y: fyF, w: cwF - 6, h: chF });
        fx += cwF;
      }
    }

    // ---- Objetos (picos) ----
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 17px Georgia, serif";
    ctx.fillText("Objetos", px + 24, py + 288);
    const propios = PICOS.filter((p) => this.player.picos[p.id]);
    if (propios.length === 0) {
      ctx.fillStyle = "#6b4a2b"; ctx.font = "italic 15px Georgia, serif";
      ctx.fillText("No tienes objetos todavía.", px + 30, py + 314);
    } else {
      let ox = px + 24;
      for (const p of propios) {
        const eq = this.player.picoEquipado === p.id;
        const bw = 156, bh = 58, oy = py + 300;
        ctx.fillStyle = "#f4ead0"; ctx.beginPath(); ctx.roundRect(ox, oy, bw, bh, 10); ctx.fill();
        ctx.strokeStyle = eq ? "#3f8a3a" : "#c9b483"; ctx.lineWidth = eq ? 3 : 2;
        ctx.beginPath(); ctx.roundRect(ox, oy, bw, bh, 10); ctx.stroke();
        this._dibujarPico(ctx, ox + 26, oy + 30, 0.9, p.color);
        ctx.fillStyle = "#5b3b20"; ctx.font = "bold 14px Georgia, serif"; ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
        ctx.fillText(p.nombre, ox + 48, oy + 26);
        ctx.font = "12px Georgia, serif"; ctx.fillStyle = eq ? "#3f8a3a" : "#6b4a2b";
        ctx.fillText(eq ? "Equipado" : "Guardado", ox + 48, oy + 46);
        ox += bw + 14;
      }
    }

    // Aviso (al comer/fumar)
    if (this.invMsgT > 0) {
      ctx.fillStyle = "#5b3b20"; ctx.font = "bold 15px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
      ctx.fillText(this.invMsg, W / 2, py + ph - 42);
    }
    // Pie
    ctx.fillStyle = "rgba(91,59,32,.75)"; ctx.font = "italic 13px Georgia, serif"; ctx.textAlign = "center";
    ctx.fillText("(P o clic fuera para cerrar)", W / 2, py + ph - 18);
    ctx.restore();
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Indicador del pico equipado y su durabilidad (esquina superior izquierda)
  _dibujarPicoHUD(ctx) {
    const p = this.player;
    const x = 16, y = 92;
    ctx.save();
    ctx.fillStyle = "rgba(0,0,0,.42)";
    ctx.beginPath(); ctx.roundRect(x, y, 176, 42, 8); ctx.fill();
    if (p.picoEquipado) {
      const pico = PICOS.find((pp) => pp.id === p.picoEquipado);
      this._dibujarPico(ctx, x + 20, y + 22, 0.85, pico.color);
      ctx.fillStyle = "#f2e4bb"; ctx.font = "13px Georgia, serif";
      ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
      ctx.fillText(pico.nombre, x + 40, y + 18);
      const bx = x + 40, by = y + 24, bw = 122, bh = 8;
      ctx.fillStyle = "#3a1414"; ctx.fillRect(bx, by, bw, bh);
      const frac = Math.max(0, p.picoDurabilidad / pico.durMax);
      ctx.fillStyle = frac > 0.4 ? "#6bbf59" : frac > 0.15 ? "#e0a53a" : "#d64b4b";
      ctx.fillRect(bx, by, bw * frac, bh);
    } else {
      ctx.fillStyle = "#e6c9a8"; ctx.font = "14px Georgia, serif";
      ctx.textAlign = "left"; ctx.textBaseline = "middle";
      ctx.fillText("Sin pico — ve a la tienda", x + 12, y + 22);
    }
    ctx.restore();
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Aviso "comprar (E)" flotando sobre el puesto de picos
  _hintPuesto(ctx) {
    const p = this.islaMinerales.puesto;
    const cx = Math.round(p.x + p.w / 2 - this.cam.x);
    const bob = Math.sin(this.islaMinerales.time * 3) * 2;
    const w = 128, h = 30;
    const x = cx - w / 2, y = Math.round(p.y - this.cam.y - 10) - h + bob;
    ctx.save();
    ctx.fillStyle = "#f2e4bb";
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.stroke();
    ctx.fillStyle = "#5b3b20";
    ctx.font = "bold 17px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText("comprar (E)", cx, y + h / 2 + 1);
    ctx.restore();
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Un icono de pico del color indicado, centrado en (cx, cy)
  _dibujarPico(ctx, cx, cy, s, color) {
    ctx.save();
    ctx.lineCap = "round";
    ctx.strokeStyle = "#7a4a24"; ctx.lineWidth = 5 * s;   // mango
    ctx.beginPath(); ctx.moveTo(cx - 12 * s, cy + 16 * s); ctx.lineTo(cx + 6 * s, cy - 12 * s); ctx.stroke();
    ctx.strokeStyle = color; ctx.lineWidth = 6 * s;       // cabeza curva
    ctx.beginPath(); ctx.arc(cx + 6 * s, cy - 12 * s, 17 * s, Math.PI * 0.8, Math.PI * 1.75); ctx.stroke();
    ctx.fillStyle = color;                                 // brillo
    ctx.beginPath(); ctx.arc(cx + 6 * s, cy - 12 * s, 3 * s, 0, Math.PI * 2); ctx.fill();
    ctx.restore();
  }

  // Pantalla de la tienda de picos
  _dibujarTienda(ctx) {
    const W = this.ancho, H = this.alto;
    // Fondo: imagen si existe, si no, madera oscura
    if (Assets.listo("tienda_interior")) {
      ctx.drawImage(Assets.el("tienda_interior"), 0, 0, W, H);
      ctx.fillStyle = "rgba(10,6,2,.35)"; ctx.fillRect(0, 0, W, H);
    } else {
      ctx.fillStyle = "#3a2a1c"; ctx.fillRect(0, 0, W, H);
      ctx.fillStyle = "#33251a";
      for (let x = 0; x < W; x += 40) ctx.fillRect(x, 0, 2, H);
    }

    // Título
    ctx.fillStyle = "#f6d367"; ctx.font = "bold 30px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.shadowColor = "rgba(0,0,0,.6)"; ctx.shadowBlur = 6;
    ctx.fillText("Tienda de picos", W / 2, 44);
    ctx.shadowBlur = 0;
    // Reales del jugador
    ctx.font = "bold 18px Georgia, serif"; ctx.fillStyle = "#f6d367";
    ctx.textAlign = "right";
    ctx.fillText("Tus reales: " + this.player.reales, W - 24, 44);

    // Tres tarjetas
    this._tiendaBotones = [];
    const cw = 220, ch = 300, gap = 30;
    const total = PICOS.length * cw + (PICOS.length - 1) * gap;
    let cx0 = (W - total) / 2;
    const cy0 = 92;
    for (const pico of PICOS) {
      this._tarjetaPico(ctx, cx0, cy0, cw, ch, pico);
      cx0 += cw + gap;
    }

    // Aviso de compra
    if (this.tiendaMsgT > 0) {
      ctx.globalAlpha = Math.min(1, this.tiendaMsgT);
      ctx.fillStyle = "#efe6d2"; ctx.font = "bold 18px Georgia, serif";
      ctx.textAlign = "center";
      ctx.fillText(this.tiendaMsg, W / 2, cy0 + ch + 28);
      ctx.globalAlpha = 1;
    }

    // Pie
    ctx.fillStyle = "rgba(230,220,200,.8)"; ctx.font = "italic 14px Georgia, serif";
    ctx.textAlign = "center";
    ctx.fillText("Esc: salir de la tienda", W / 2, H - 16);
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  _tarjetaPico(ctx, x, y, w, h, pico) {
    const comprado = !!this.player.picos[pico.id];
    const equipado = this.player.picoEquipado === pico.id;

    // Panel
    ctx.fillStyle = "rgba(232,216,180,.96)";
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 14); ctx.fill();
    ctx.strokeStyle = equipado ? "#3f8a3a" : "#8a6d3b"; ctx.lineWidth = equipado ? 4 : 3;
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 14); ctx.stroke();

    // Icono del pico
    this._dibujarPico(ctx, x + w / 2, y + 56, 1.7, pico.color);

    // Nombre
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 19px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText(pico.nombre, x + w / 2, y + 108);

    // Estadísticas
    ctx.font = "15px Georgia, serif"; ctx.fillStyle = "#6b4a2b"; ctx.textAlign = "left";
    ctx.fillText("Velocidad: " + pico.velocidad, x + 22, y + 142);
    ctx.fillText("Desgaste: " + pico.desgaste, x + 22, y + 166);

    // Precio
    ctx.textAlign = "center";
    this._moneda(ctx, x + w / 2 - 48, y + 200, 8);
    ctx.fillStyle = "#7a5a1a"; ctx.font = "bold 19px Georgia, serif";
    ctx.fillText(pico.precio + " reales", x + w / 2 + 6, y + 201);

    // Botón
    const bw = w - 44, bh = 40, bx = x + 22, by = y + h - 56;
    let etiqueta, colorBoton, colorTexto;
    if (equipado) { etiqueta = "Equipado"; colorBoton = "#6bbf59"; colorTexto = "#183c14"; }
    else if (comprado) { etiqueta = "Equipar"; colorBoton = "#c9b483"; colorTexto = "#5b3b20"; }
    else if (this.player.reales < pico.precio) { etiqueta = "Sin reales"; colorBoton = "#b9a68a"; colorTexto = "#6b5b45"; }
    else { etiqueta = "Comprar"; colorBoton = "#f2c14e"; colorTexto = "#5b3b20"; }
    ctx.fillStyle = colorBoton;
    ctx.beginPath(); ctx.roundRect(bx, by, bw, bh, 9); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.roundRect(bx, by, bw, bh, 9); ctx.stroke();
    ctx.fillStyle = colorTexto; ctx.font = "bold 18px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText(etiqueta, bx + bw / 2, by + bh / 2 + 1);
    ctx.textBaseline = "alphabetic"; ctx.textAlign = "left";

    // Guardar zona clicable
    this._tiendaBotones.push({ id: pico.id, x: bx, y: by, w: bw, h: bh });
  }

  // Aviso "comprar/vender (E)" sobre un puesto del comercio
  _hintPuestoComercio(ctx, o) {
    const cx = Math.round(o.x + o.w / 2 - this.cam.x);
    const bob = Math.sin(this.islaComercio.time * 3) * 2;
    const w = 130, h = 30, x = cx - w / 2, y = Math.round(o.y - this.cam.y - 10) - h + bob;
    const txt = o.tipo === "minerales" ? "vender (E)" : "comprar (E)";
    ctx.save();
    ctx.fillStyle = "#f2e4bb"; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.stroke();
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 17px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText(txt, cx, y + h / 2 + 1);
    ctx.restore(); ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  _hintFumador(ctx) {
    const f = this.islaComercio.fumador;
    const cx = Math.round(f.x + f.ancho / 2 - this.cam.x);
    const bob = Math.sin(this.islaComercio.time * 3) * 2;
    const w = 128, h = 30, x = cx - w / 2, y = Math.round(f.y - this.cam.y - 10) - h + bob;
    ctx.save();
    ctx.fillStyle = "#f2e4bb"; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.stroke();
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 17px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText("comprar (E)", cx, y + h / 2 + 1);
    ctx.restore(); ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Aviso junto a la puerta escondida: dos botones apilados "Abrir (E)" y "Mirar (F)"
  _hintPuerta(ctx) {
    const d = this.islaComercio.puerta;
    const cx = Math.round(d.x + d.w / 2 - this.cam.x);
    const bob = Math.sin(this.islaComercio.time * 3) * 2;
    const w = 108, h = 28;
    const x = cx - w / 2;
    const yBase = Math.round(d.y - this.cam.y - 8) + bob;   // justo encima de la puerta
    // Dibuja un botón de pergamino con su texto
    const pill = (y, txt) => {
      ctx.fillStyle = "#f2e4bb"; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.fill();
      ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.stroke();
      ctx.fillStyle = "#5b3b20"; ctx.font = "bold 16px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
      ctx.fillText(txt, cx, y + h / 2 + 1);
    };
    ctx.save();
    if (this.puertaAbierta) {
      // Puerta tumbada: se puede entrar al calabozo
      pill(yBase - h, "Entrar (E)");
    } else {
      // Cerrada: "Tumbar (E)" si tienes fuerza, si no "Abrir (E)"; y "Mirar (F)"
      pill(yBase - h * 2 - 4, this.player.tieneFuerza ? "Tumbar (E)" : "Abrir (E)");
      pill(yBase - h, "Mirar (F)");
    }
    ctx.restore(); ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Aviso "Salir (E)" junto al hueco de salida del calabozo
  _hintSalidaCalabozo(ctx) {
    const s = this.calabozo.salida;
    const cx = Math.round((s.c + 0.5) * TILE - this.cam.x);
    const yy = Math.round(s.f * TILE - this.cam.y) - 8;
    const w = 96, h = 28, x = cx - w / 2, y = yy - h;
    ctx.save();
    ctx.fillStyle = "#f2e4bb"; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.stroke();
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 16px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText("Salir (E)", cx, y + h / 2 + 1);
    ctx.restore(); ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Vista del calabozo por las rejillas (pantalla completa). Si falta el PNG, se dibuja por código.
  _dibujarCalabozo(ctx) {
    const W = this.ancho, H = this.alto;
    if (Assets.listo("calabozo")) {
      ctx.drawImage(Assets.el("calabozo"), 0, 0, W, H);
    } else {
      this._calabozoReserva(ctx, W, H);
    }
    // Pie con la ayuda para cerrar
    ctx.fillStyle = "rgba(235,225,205,.9)"; ctx.font = "italic 15px Georgia, serif"; ctx.textAlign = "center";
    ctx.fillText("Miras por las rejillas...   ·   Esc o F para apartarte", W / 2, H - 18);
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Dibujo de reserva del calabozo: oscuro, con cadenas, un esqueleto al fondo,
  // una cama de piedra sujeta por cadenas y las rejillas por delante.
  _calabozoReserva(ctx, W, H) {
    // Fondo muy oscuro con un poco de luz fría al fondo
    ctx.fillStyle = "#07080a"; ctx.fillRect(0, 0, W, H);
    const g = ctx.createRadialGradient(W / 2, H * 0.42, 40, W / 2, H * 0.42, W * 0.6);
    g.addColorStop(0, "rgba(40,48,60,.55)"); g.addColorStop(1, "rgba(5,6,8,0)");
    ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);

    // Suelo de piedra al fondo (una franja algo más clara)
    ctx.fillStyle = "#14161b"; ctx.fillRect(0, H * 0.62, W, H * 0.38);
    ctx.strokeStyle = "rgba(70,78,92,.18)"; ctx.lineWidth = 1;
    for (let y = H * 0.66; y < H; y += 26) { ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(W, y); ctx.stroke(); }

    // Cadenas colgando del techo
    const cadena = (cx, largo) => {
      ctx.strokeStyle = "rgba(150,155,165,.55)"; ctx.lineWidth = 3;
      for (let y = 0; y < largo; y += 10) {
        ctx.beginPath(); ctx.ellipse(cx, y, 3.2, 5, 0, 0, Math.PI * 2); ctx.stroke();
      }
      // grillete al final
      ctx.strokeStyle = "rgba(170,175,185,.6)"; ctx.lineWidth = 3;
      ctx.beginPath(); ctx.arc(cx, largo + 6, 7, 0, Math.PI * 2); ctx.stroke();
    };
    cadena(W * 0.30, H * 0.30);
    cadena(W * 0.42, H * 0.22);

    // Esqueleto al fondo, medio en penumbra (solo se ve una parte)
    const ex = W * 0.66, ey = H * 0.40;
    ctx.save();
    ctx.globalAlpha = 0.9;
    ctx.fillStyle = "#c9c6ba";                       // hueso pálido
    // cráneo
    ctx.beginPath(); ctx.arc(ex, ey, 15, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#0b0c0e";                        // cuencas
    ctx.beginPath(); ctx.arc(ex - 5, ey - 2, 3.4, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.arc(ex + 5, ey - 2, 3.4, 0, Math.PI * 2); ctx.fill();
    ctx.fillRect(ex - 2, ey + 4, 4, 6);              // nariz
    // caja torácica (costillas)
    ctx.strokeStyle = "#b7b4a8"; ctx.lineWidth = 3;
    ctx.beginPath(); ctx.moveTo(ex, ey + 15); ctx.lineTo(ex, ey + 55); ctx.stroke();   // columna
    for (let i = 0; i < 4; i++) {
      const ry = ey + 22 + i * 9;
      ctx.beginPath(); ctx.moveTo(ex, ry); ctx.quadraticCurveTo(ex - 16, ry + 4, ex - 14, ry + 10); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(ex, ry); ctx.quadraticCurveTo(ex + 16, ry + 4, ex + 14, ry + 10); ctx.stroke();
    }
    ctx.restore();
    // Oscuridad que se lo va comiendo hacia abajo (solo se ve la parte de arriba)
    const sk = ctx.createLinearGradient(0, ey + 30, 0, ey + 90);
    sk.addColorStop(0, "rgba(7,8,10,0)"); sk.addColorStop(1, "rgba(7,8,10,1)");
    ctx.fillStyle = sk; ctx.fillRect(ex - 40, ey + 30, 80, 70);

    // Cama de piedra pegada a la pared izquierda, sujeta por cadenas
    const bx = W * 0.10, by = H * 0.50, bw = W * 0.20, bh = 26;
    ctx.fillStyle = "#2b2f37"; ctx.fillRect(bx, by, bw, bh);              // losa
    ctx.fillStyle = "#3a3f49"; ctx.fillRect(bx, by, bw, 6);              // canto iluminado
    ctx.strokeStyle = "#1a1d22"; ctx.lineWidth = 1;
    for (let i = 1; i < 4; i++) { const lx = bx + (bw * i) / 4; ctx.beginPath(); ctx.moveTo(lx, by); ctx.lineTo(lx, by + bh); ctx.stroke(); }
    // cadenas que la sujetan a la pared (arriba)
    ctx.strokeStyle = "rgba(150,155,165,.5)"; ctx.lineWidth = 3;
    for (const lx of [bx + 8, bx + bw - 8]) {
      for (let y = by; y > by - 42; y -= 9) { ctx.beginPath(); ctx.ellipse(lx, y, 2.6, 4, 0, 0, Math.PI * 2); ctx.stroke(); }
    }

    // Viñeta oscura en los bordes
    const v = ctx.createRadialGradient(W / 2, H / 2, H * 0.35, W / 2, H / 2, H * 0.75);
    v.addColorStop(0, "rgba(0,0,0,0)"); v.addColorStop(1, "rgba(0,0,0,.85)");
    ctx.fillStyle = v; ctx.fillRect(0, 0, W, H);

    // REJILLAS por delante (estás mirando a través de ellas): barrotes verticales + horizontales
    ctx.fillStyle = "rgba(8,9,11,.85)";
    const nb = 7;
    for (let i = 1; i <= nb; i++) {
      const bx2 = (W * i) / (nb + 1) - 6;
      ctx.fillRect(bx2, 0, 12, H);
      ctx.fillStyle = "rgba(90,96,106,.35)"; ctx.fillRect(bx2 + 2, 0, 2, H);   // brillo del barrote
      ctx.fillStyle = "rgba(8,9,11,.85)";
    }
    for (const hy of [H * 0.28, H * 0.66]) {
      ctx.fillRect(0, hy - 6, W, 12);
      ctx.fillStyle = "rgba(90,96,106,.35)"; ctx.fillRect(0, hy - 4, W, 2);
      ctx.fillStyle = "rgba(8,9,11,.85)";
    }
  }

  // Pantalla de una tienda del comercio (comida o venta de minerales)
  _dibujarTiendaComercio(ctx) {
    const W = this.ancho, H = this.alto, tipo = this.tiendaComercio;
    this._comBotones = [];
    // Fondo (imagen del interior o color liso)
    if (Assets.listo("int_" + tipo)) {
      ctx.drawImage(Assets.el("int_" + tipo), 0, 0, W, H);
      ctx.fillStyle = "rgba(10,6,2,.35)"; ctx.fillRect(0, 0, W, H);
    } else {
      ctx.fillStyle = "#2e241a"; ctx.fillRect(0, 0, W, H);
    }
    // Título
    ctx.fillStyle = "#f6d367"; ctx.font = "bold 28px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.shadowColor = "rgba(0,0,0,.6)"; ctx.shadowBlur = 6;
    ctx.fillText(NOMBRE_TIENDA[tipo], W / 2, 40); ctx.shadowBlur = 0;
    // Reales y vida
    ctx.font = "bold 16px Georgia, serif"; ctx.textAlign = "right"; ctx.fillStyle = "#f6d367";
    ctx.fillText(this.player.reales + " reales   ·   Vida " + Math.round(this.player.vida) + "/" + this.player.vidaMax, W - 20, 40);

    if (tipo === "minerales") this._uiVenta(ctx);
    else this._uiComida(ctx, tipo);

    // Aviso
    if (this.comMsgT > 0) {
      ctx.globalAlpha = Math.min(1, this.comMsgT);
      ctx.fillStyle = "#efe6d2"; ctx.font = "bold 18px Georgia, serif"; ctx.textAlign = "center";
      ctx.fillText(this.comMsg, W / 2, H - 50); ctx.globalAlpha = 1;
    }
    // Pie
    ctx.fillStyle = "rgba(230,220,200,.8)"; ctx.font = "italic 14px Georgia, serif"; ctx.textAlign = "center";
    ctx.fillText("Esc: salir de la tienda", W / 2, H - 16);
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  _uiComida(ctx, tipo) {
    const W = this.ancho, prods = PRODUCTOS_COMERCIO[tipo];
    const cw = 208, ch = 252, gap = 26;
    const total = prods.length * cw + (prods.length - 1) * gap;
    let x0 = (W - total) / 2; const y0 = 96;
    for (let i = 0; i < prods.length; i++) { this._tarjetaProducto(ctx, prods[i], x0, y0, cw, ch, i); x0 += cw + gap; }
  }

  _tarjetaProducto(ctx, p, x, y, w, h, i) {
    ctx.fillStyle = "rgba(232,216,180,.96)"; ctx.beginPath(); ctx.roundRect(x, y, w, h, 14); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 3; ctx.beginPath(); ctx.roundRect(x, y, w, h, 14); ctx.stroke();
    // Icono (círculo del color del producto)
    ctx.fillStyle = COLORES_PROD[p.nombre] || "#c9a24a";
    ctx.beginPath(); ctx.arc(x + w / 2, y + 52, 20, 0, Math.PI * 2); ctx.fill();
    if (p.misteriosa) {
      ctx.fillStyle = "#fff"; ctx.font = "bold 22px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
      ctx.fillText("?", x + w / 2, y + 53);
    }
    // Nombre
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 18px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText(p.nombre, x + w / 2, y + 96);
    // Efecto (verde si cura, rojo si daña, morado si misterioso)
    ctx.font = "15px Georgia, serif";
    ctx.fillStyle = p.misteriosa ? "#8e44ad" : p.vida < 0 ? "#c0392b" : "#3f8a3a";
    ctx.fillText(p.misteriosa ? "Efecto: ???" : (p.vida < 0 ? p.vida : "+" + p.vida) + " de vida", x + w / 2, y + 128);
    // Precio
    ctx.fillStyle = "#7a5a1a"; ctx.font = "bold 18px Georgia, serif";
    ctx.fillText(p.precio === 0 ? "Gratis" : p.precio + " reales", x + w / 2, y + 160);
    // Botón comprar (la manzana misteriosa queda "VENDIDO" tras tumbar la puerta)
    const bw = w - 44, bh = 40, bx = x + 22, by = y + h - 56;
    const vendido = p.misteriosa && this.puertaAbierta;
    const puede = !vendido && (p.precio === 0 || this.player.reales >= p.precio);
    ctx.fillStyle = vendido ? "#9a8f7d" : puede ? "#f2c14e" : "#b9a68a";
    ctx.beginPath(); ctx.roundRect(bx, by, bw, bh, 9); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(bx, by, bw, bh, 9); ctx.stroke();
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 18px Georgia, serif";
    ctx.fillText(vendido ? "VENDIDO" : puede ? "Comprar" : "Sin reales", bx + bw / 2, by + bh / 2 + 1);
    ctx.textBaseline = "alphabetic"; ctx.textAlign = "left";
    if (!vendido) this._comBotones.push({ accion: "comprar", i, x: bx, y: by, w: bw, h: bh });
  }

  _botonMini(ctx, x, y, s, txt) {
    ctx.fillStyle = "#f2c14e"; ctx.beginPath(); ctx.roundRect(x, y, s, s, 6); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 1.5; ctx.beginPath(); ctx.roundRect(x, y, s, s, 6); ctx.stroke();
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 18px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText(txt, x + s / 2, y + s / 2 + 1);
  }

  _uiVenta(ctx) {
    const W = this.ancho;
    const mins = [["hierro", "Hierro", "#b5764a"], ["oro", "Oro", "#f6d357"], ["ametista", "Amatista", "#9b59b6"], ["diamante", "Diamante", "#bfeaf5"]];
    const panelW = 560, x = (W - panelW) / 2; let y = 92; const rh = 62;
    let total = 0;
    for (const [id, nom, col] of mins) {
      const have = this.player.inventario[id] || 0;
      const sel = this.ventaSel[id] || 0;
      total += sel * MINERAL_VENTA[id];
      ctx.fillStyle = "rgba(232,216,180,.94)"; ctx.beginPath(); ctx.roundRect(x, y, panelW, rh - 8, 10); ctx.fill();
      ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(x, y, panelW, rh - 8, 10); ctx.stroke();
      this._iconoMineral(ctx, x + 26, y + 26, 12, col);
      ctx.fillStyle = "#5b3b20"; ctx.font = "bold 16px Georgia, serif"; ctx.textAlign = "left"; ctx.textBaseline = "middle";
      ctx.fillText(nom, x + 48, y + 18);
      ctx.font = "13px Georgia, serif"; ctx.fillStyle = "#6b4a2b";
      ctx.fillText("Tienes: " + have + "     " + MINERAL_VENTA[id] + " reales c/u", x + 48, y + 38);
      const bs = 28, by = y + (rh - 8) / 2 - bs / 2;
      const menosX = x + panelW - 210, masX = x + panelW - 120;
      this._botonMini(ctx, menosX, by, bs, "-"); this._comBotones.push({ accion: "menos", id, x: menosX, y: by, w: bs, h: bs });
      ctx.fillStyle = "#5b3b20"; ctx.font = "bold 18px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
      ctx.fillText(String(sel), (menosX + bs + masX) / 2, by + bs / 2);
      this._botonMini(ctx, masX, by, bs, "+"); this._comBotones.push({ accion: "mas", id, x: masX, y: by, w: bs, h: bs });
      ctx.fillStyle = "#7a5a1a"; ctx.font = "bold 14px Georgia, serif"; ctx.textAlign = "right"; ctx.textBaseline = "middle";
      ctx.fillText(sel * MINERAL_VENTA[id] + " r", x + panelW - 14, by + bs / 2);
      y += rh;
    }
    // Botón vender
    const bw = 260, bh = 44, bx = (W - bw) / 2, byy = y + 10;
    ctx.fillStyle = total > 0 ? "#6bbf59" : "#b9a68a";
    ctx.beginPath(); ctx.roundRect(bx, byy, bw, bh, 10); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2; ctx.beginPath(); ctx.roundRect(bx, byy, bw, bh, 10); ctx.stroke();
    ctx.fillStyle = "#183c14"; ctx.font = "bold 18px Georgia, serif"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText("Vender  (" + total + " reales)", bx + bw / 2, byy + bh / 2 + 1);
    this._comBotones.push({ accion: "vender", x: bx, y: byy, w: bw, h: bh });
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Mensaje temporal centrado abajo (aviso, diálogo breve...)
  _toast(ctx, texto) {
    ctx.save();
    ctx.font = "bold 18px Georgia, serif";
    ctx.textAlign = "center";
    const w = ctx.measureText(texto).width + 40;
    const x = this.ancho / 2 - w / 2, y = this.alto - 70, h = 40;
    ctx.globalAlpha = Math.min(1, this.mensajeT);   // se desvanece al final
    ctx.fillStyle = "rgba(20,14,8,.82)";
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 10); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 10); ctx.stroke();
    ctx.fillStyle = "#f2e4bb";
    ctx.textBaseline = "middle";
    ctx.fillText(texto, this.ancho / 2, y + h / 2 + 1);
    ctx.restore();
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Botón "Entrar" con aspecto de pergamino, flotando sobre la casa
  _botonEntrar(ctx, casa) {
    const cx = Math.round(casa.x + casa.w / 2 - this.cam.x);
    const base = Math.round(casa.y - this.cam.y - 8);   // justo encima del tejado
    const bw = 150, bh = 46;
    const bob = Math.sin(this.world.time * 3) * 2;       // flota un poquito
    const x = cx - bw / 2, y = base - bh + bob;

    ctx.save();
    // Sombra
    ctx.fillStyle = "rgba(0,0,0,.30)";
    ctx.beginPath(); ctx.roundRect(x + 2, y + 3, bw, bh, 9); ctx.fill();
    // Pergamino
    const g = ctx.createLinearGradient(0, y, 0, y + bh);
    g.addColorStop(0, "#f2e4bb");
    g.addColorStop(1, "#dcc78c");
    ctx.fillStyle = g;
    ctx.beginPath(); ctx.roundRect(x, y, bw, bh, 9); ctx.fill();
    // Borde
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.roundRect(x, y, bw, bh, 9); ctx.stroke();
    // Piquito hacia la casa
    ctx.fillStyle = "#dcc78c";
    ctx.beginPath();
    ctx.moveTo(cx - 6, y + bh - 1); ctx.lineTo(cx + 6, y + bh - 1); ctx.lineTo(cx, y + bh + 7);
    ctx.closePath(); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 1.5;
    ctx.beginPath(); ctx.moveTo(cx - 6, y + bh - 1); ctx.lineTo(cx, y + bh + 7); ctx.lineTo(cx + 6, y + bh - 1); ctx.stroke();
    if (this._ancianoBloqueado()) {
      // Candado (la casa está cerrada hasta terminar la misión)
      this._candado(ctx, cx, y + bh / 2);
    } else {
      // Texto "Entrar (E)"
      ctx.fillStyle = "#5b3b20";
      ctx.font = "bold 23px Georgia, serif";
      ctx.textAlign = "center"; ctx.textBaseline = "middle";
      ctx.fillText("Entrar (E)", cx, y + bh / 2 + 1);
    }
    ctx.restore();
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Dibujo de un candado cerrado, centrado en (cx, cy)
  _candado(ctx, cx, cy) {
    const bodyW = 26, bodyH = 20;
    const bx = cx - bodyW / 2, by = cy - 4;
    // Arco (grillete)
    ctx.strokeStyle = "#4a3320"; ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.arc(cx, by, 8, Math.PI, 0);
    ctx.stroke();
    // Cuerpo
    ctx.fillStyle = "#6b4a2b";
    ctx.beginPath(); ctx.roundRect(bx, by, bodyW, bodyH, 4); ctx.fill();
    ctx.strokeStyle = "#3a2414"; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.roundRect(bx, by, bodyW, bodyH, 4); ctx.stroke();
    // Ojo de la cerradura
    ctx.fillStyle = "#2a1c10";
    ctx.beginPath(); ctx.arc(cx, by + bodyH / 2 - 1, 2.6, 0, Math.PI * 2); ctx.fill();
    ctx.fillRect(cx - 1.2, by + bodyH / 2, 2.4, 6);
  }

  // Iconos del HUD
  _corazon(ctx, cx, cy, r) {
    ctx.fillStyle = "#e23b4b";
    ctx.beginPath();
    ctx.arc(cx - r * 0.5, cy - r * 0.2, r * 0.55, 0, Math.PI * 2);
    ctx.arc(cx + r * 0.5, cy - r * 0.2, r * 0.55, 0, Math.PI * 2);
    ctx.moveTo(cx - r, cy);
    ctx.lineTo(cx, cy + r);
    ctx.lineTo(cx + r, cy);
    ctx.closePath();
    ctx.fill();
  }
  _moneda(ctx, cx, cy, r) {
    ctx.fillStyle = "#a9740a";
    ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#f6d367";
    ctx.beginPath(); ctx.arc(cx, cy, r - 2, 0, Math.PI * 2); ctx.fill();
    ctx.fillStyle = "#c9962a";
    ctx.fillRect(cx - 1, cy - 4, 2, 8);
  }

  // Icono de pergamino enrollado (abre el diario de misiones al clicarlo)
  _iconoPergamino(ctx, x, y, w, h, num) {
    ctx.save();
    ctx.fillStyle = "rgba(0,0,0,.35)";
    ctx.beginPath(); ctx.roundRect(x + 1, y + 2, w, h, 5); ctx.fill();
    // Papel
    ctx.fillStyle = this.panelMisiones ? "#f6ecc8" : "#e9d8a8";
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 5); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 5); ctx.stroke();
    // Rodillos arriba y abajo
    ctx.fillStyle = "#c9b483";
    ctx.fillRect(x, y + 3, w, 3);
    ctx.fillRect(x, y + h - 6, w, 3);
    // Renglones de escritura
    ctx.fillStyle = "#8a6d3b";
    ctx.fillRect(x + 8, y + 12, w - 16, 2);
    ctx.fillRect(x + 8, y + 17, w - 22, 2);
    ctx.fillRect(x + 8, y + 22, w - 13, 2);
    // Contador de misiones
    if (num > 0) {
      ctx.fillStyle = "#c0392b";
      ctx.beginPath(); ctx.arc(x + w - 3, y + 3, 8, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = "#fff";
      ctx.font = "bold 11px Georgia, serif";
      ctx.textAlign = "center"; ctx.textBaseline = "middle";
      ctx.fillText(num, x + w - 3, y + 4);
      ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
    }
    ctx.restore();
  }

  // El usuario ha hecho clic en (cx, cy) en coordenadas del canvas
  onClick(cx, cy) {
    // En una tienda del comercio: comprar comida / ajustar y vender minerales
    if (this.estado === "tienda_comercio") {
      for (const b of this._comBotones) {
        if (cx >= b.x && cx <= b.x + b.w && cy >= b.y && cy <= b.y + b.h) {
          if (b.accion === "comprar") this._comprarComida(this.tiendaComercio, b.i);
          else if (b.accion === "menos") this._ajustarVenta(b.id, -1);
          else if (b.accion === "mas") this._ajustarVenta(b.id, +1);
          else if (b.accion === "vender") this._venderMinerales();
          return;
        }
      }
      return;
    }
    // En la tienda de picos: clic en un botón "Comprar"/"Equipar"
    if (this.estado === "tienda") {
      for (const b of this._tiendaBotones) {
        if (cx >= b.x && cx <= b.x + b.w && cy >= b.y && cy <= b.y + b.h) { this._comprarPico(b.id); return; }
      }
      return;
    }
    // Con el mapa abierto: clic en una isla -> viajar; clic fuera -> cerrar
    if (this.mapaAbierto) {
      for (const isla of this._mapaIslas) {
        if (Math.hypot(cx - isla.cx, cy - isla.cy) < isla.r + 16) {
          if (isla.id === "minerales" && isla.disp) { this._viajarAMinerales(); return; }
          if (isla.id === "comercio" && isla.disp) { this._viajarAComercio(); return; }
          this.mapaAbierto = false; return;   // el resto: solo cierra
        }
      }
      this.mapaAbierto = false;
      return;
    }
    // Con la mochila abierta: clic en una comida la usa; clic fuera la cierra
    if (this.inventarioAbierto) {
      for (const b of this._invBotones) {
        if (cx >= b.x && cx <= b.x + b.w && cy >= b.y && cy <= b.y + b.h) { this._consumir(b.nombre); return; }
      }
      this.inventarioAbierto = false; return;
    }
    // Icono de misiones (HUD)
    const r = this._scrollRect;
    if (r && cx >= r.x && cx <= r.x + r.w && cy >= r.y && cy <= r.y + r.h) {
      this.panelMisiones = !this.panelMisiones;   // abrir/cerrar el diario
      return;
    }
    // Con el diario abierto: clic en "reclamar recompensa" o clic fuera para cerrar
    if (this.panelMisiones) {
      for (const b of this._misionRects) {
        if (cx >= b.x && cx <= b.x + b.w && cy >= b.y && cy <= b.y + b.h) { this._cobrarMision(b.id); return; }
      }
      this.panelMisiones = false; return;
    }
    // Picar en la isla de los minerales (clic izquierdo sobre una mena)
    if (this.estado === "isla_minerales") { this._picar(cx, cy); return; }
    // Clic en el cartel (en el mundo) -> abrir el mapa de islas
    if (this.estado === "jugando" && this._clicEnCartel(cx, cy)) {
      this.mapaAbierto = true; return;
    }
  }

  // Picar la mena que hay bajo el cursor (si estás cerca y con pico)
  _picar(cx, cy) {
    const isla = this.islaMinerales;
    const c = Math.floor((cx + this.cam.x) / TILE), f = Math.floor((cy + this.cam.y) / TILE);
    if (!isla.menaEn(c, f)) return;                    // no hay mena ahí
    // Hay que estar cerca de la veta
    const px = this.player.x + this.player.ancho / 2, py = this.player.y + this.player.alto / 2;
    const mx = c * TILE + TILE / 2, my = f * TILE + TILE / 2;
    if (Math.hypot(px - mx, py - my) > 115) { this._islaAviso("Acércate más a la veta"); return; }
    // Hace falta un pico equipado
    if (!this.player.picoEquipado) { this._islaAviso("Necesitas un pico (cómpralo en la tienda)"); return; }

    const tipo = isla.picar(c, f, this.reloj);         // la mena se vuelve piedra (regresa a los 10 min)
    if (!tipo) return;
    this.player.inventario[tipo] = (this.player.inventario[tipo] || 0) + 1;
    // El hierro cuenta para la misión del anciano
    if (tipo === "hierro") {
      const mi = this._misionAnciano();
      if (mi && !mi.completada) {
        mi.progreso = Math.min(mi.objetivo, mi.progreso + 1);
        if (mi.progreso >= mi.objetivo) mi.completada = true;
      }
    }
    // Desgaste del pico
    const pico = PICOS.find((p) => p.id === this.player.picoEquipado);
    this.player.picoDurabilidad -= pico.desgNum;
    let msg = "Has picado " + this._nombreMineral(tipo);
    if (this.player.picoDurabilidad <= 0) {
      delete this.player.picos[this.player.picoEquipado];
      this.player.picoEquipado = null;
      msg += " · ¡tu pico se ha roto!";
    }
    this._islaAviso(msg);
  }

  _islaAviso(txt) { this.mensaje = txt; this.mensajeT = 2.2; }
  _nombreMineral(t) {
    return { hierro: "Hierro", oro: "Oro", ametista: "Amatista", diamante: "Diamante" }[t] || t;
  }

  // Panel con la lista de misiones y su progreso
  _dibujarPanelMisiones(ctx) {
    this._misionRects = [];
    const x = 16, y = 92, w = 380;
    const h = this.misiones.length ? 56 + this.misiones.length * 100 + 22 : 124;

    // Fondo pergamino
    ctx.save();
    ctx.fillStyle = "rgba(20,14,8,.6)";
    ctx.fillRect(0, 0, this.ancho, this.alto);   // oscurece el fondo
    ctx.fillStyle = "#efe0b8";
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 12); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 3;
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 12); ctx.stroke();

    // Título
    ctx.fillStyle = "#5b3b20";
    ctx.font = "bold 22px Georgia, serif";
    ctx.textAlign = "left"; ctx.textBaseline = "top";
    ctx.fillText("Misiones", x + 18, y + 14);
    ctx.strokeStyle = "#c9b483"; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.moveTo(x + 18, y + 44); ctx.lineTo(x + w - 18, y + 44); ctx.stroke();

    if (this.misiones.length === 0) {
      ctx.fillStyle = "#6b4a2b";
      ctx.font = "italic 16px Georgia, serif";
      ctx.fillText("No hay misiones.", x + 18, y + 56);
      ctx.font = "15px Georgia, serif";
      ctx.fillText("Habla con el anciano en la casa roja.", x + 18, y + 80);
    } else {
      let cy = y + 56;
      for (const m of this.misiones) {
        // Título de la misión
        ctx.fillStyle = m.completada ? "#5a8a3a" : "#5b3b20";
        ctx.font = "bold 17px Georgia, serif"; ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
        ctx.fillText((m.completada ? "✓ " : "• ") + m.titulo, x + 18, cy);
        // Descripción
        ctx.fillStyle = "#6b4a2b";
        ctx.font = "14px Georgia, serif";
        ctx.fillText(m.desc, x + 30, cy + 22);
        // Barra de progreso
        const bx = x + 30, by = cy + 46, bw = w - 92, bh = 12;
        ctx.fillStyle = "#c9b483"; ctx.fillRect(bx, by, bw, bh);
        const frac = Math.max(0, Math.min(1, m.progreso / m.objetivo));
        ctx.fillStyle = m.completada ? "#6bbf59" : "#c98a3a";
        ctx.fillRect(bx, by, bw * frac, bh);
        ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 1.5;
        ctx.strokeRect(bx, by, bw, bh);
        ctx.fillStyle = "#5b3b20";
        ctx.font = "bold 13px Georgia, serif";
        ctx.fillText(m.progreso + " / " + m.objetivo + " " + m.unidad, bx + bw + 8, by - 1);

        // Recompensa (cuando la misión está terminada)
        if (m.completada && m.recompensa) {
          if (!m.cobrada) {
            const rbw = w - 60, rbh = 30, rbx = x + 30, rby = cy + 66;
            ctx.fillStyle = "#f2c14e";
            ctx.beginPath(); ctx.roundRect(rbx, rby, rbw, rbh, 8); ctx.fill();
            ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2;
            ctx.beginPath(); ctx.roundRect(rbx, rby, rbw, rbh, 8); ctx.stroke();
            ctx.fillStyle = "#5b3b20"; ctx.font = "bold 15px Georgia, serif";
            ctx.textAlign = "center"; ctx.textBaseline = "middle";
            ctx.fillText("Reclamar " + m.recompensa + " reales", rbx + rbw / 2, rby + rbh / 2 + 1);
            ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
            this._misionRects.push({ id: m.id, x: rbx, y: rby, w: rbw, h: rbh });
          } else {
            ctx.fillStyle = "#5a8a3a"; ctx.font = "italic 14px Georgia, serif";
            ctx.fillText("Recompensa cobrada (" + m.recompensa + " reales)", x + 30, cy + 82);
          }
        }
        cy += 100;
      }
    }

    // Pie
    ctx.fillStyle = "rgba(91,59,32,.7)";
    ctx.font = "italic 12px Georgia, serif";
    ctx.fillText("(clic para cerrar)", x + 18, y + h - 18);
    ctx.textBaseline = "alphabetic";
    ctx.restore();
  }

  // Pequeño aviso "Ver mapa" flotando sobre el cartel
  _hintCartel(ctx) {
    const c = this.world.cartel;
    const cx = Math.round(c.x + c.w / 2 - this.cam.x);
    const bob = Math.sin(this.world.time * 3) * 2;
    const w = 104, h = 26;
    const x = cx - w / 2, y = Math.round(c.y - this.cam.y - 34) - h + bob;
    ctx.save();
    ctx.fillStyle = "#f2e4bb";
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2;
    ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.stroke();
    ctx.fillStyle = "#5b3b20";
    ctx.font = "bold 15px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText("Ver mapa", cx, y + h / 2 + 1);
    ctx.restore();
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Mapa de islas (se abre al clicar el cartel)
  _dibujarMapaMundo(ctx) {
    const W = this.ancho, H = this.alto;
    ctx.save();
    ctx.fillStyle = "rgba(6,12,20,.82)"; ctx.fillRect(0, 0, W, H);

    // Marco de pergamino
    const mx = 70, my = 52, mw = W - 140, mh = H - 104;
    ctx.fillStyle = "#e7d6a8";
    ctx.beginPath(); ctx.roundRect(mx, my, mw, mh, 16); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 5;
    ctx.beginPath(); ctx.roundRect(mx, my, mw, mh, 16); ctx.stroke();

    // Título
    ctx.fillStyle = "#5b3b20"; ctx.font = "bold 26px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText("Mapa de las islas", W / 2, my + 28);

    // Zona de mar
    const sx = mx + 18, sy = my + 54, sw = mw - 36, sh = mh - 92;
    const g = ctx.createLinearGradient(0, sy, 0, sy + sh);
    g.addColorStop(0, "#8fb4c9"); g.addColorStop(1, "#6f9bb5");
    ctx.fillStyle = g; ctx.fillRect(sx, sy, sw, sh);
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 2; ctx.strokeRect(sx, sy, sw, sh);
    ctx.strokeStyle = "rgba(255,255,255,.22)"; ctx.lineWidth = 1.5;
    for (let i = 0; i < 6; i++) {
      const wy = sy + 20 + i * (sh / 6);
      ctx.beginPath(); ctx.arc(sx + sw * 0.2, wy, 6, Math.PI, 0); ctx.arc(sx + sw * 0.2 + 12, wy, 6, Math.PI, 0); ctx.stroke();
    }

    const hablado = !!this._misionAnciano();                                  // conoce la isla de minerales
    const conoceComercio = !!this.misiones.find((m) => m.id === "boveda");    // conoce la isla del comercio
    this._mapaIslas = [];

    let islas;
    if (!hablado) {
      islas = [{ id: "anciano", nombre: "Isla del anciano", tipo: "verde", aqui: true, disp: true, fx: 0.5, fy: 0.55, r: 60 }];
    } else if (!conoceComercio) {
      islas = [
        { id: "anciano", nombre: "Isla del anciano", tipo: "verde", aqui: true, disp: true, fx: 0.30, fy: 0.55, r: 60 },
        { id: "minerales", nombre: "Isla de los minerales", tipo: "roca", aqui: false, disp: true, fx: 0.70, fy: 0.42, r: 56 },
      ];
    } else {
      islas = [
        { id: "anciano", nombre: "Isla del anciano", tipo: "verde", aqui: true, disp: true, fx: 0.22, fy: 0.56, r: 52 },
        { id: "minerales", nombre: "Isla de los minerales", tipo: "roca", aqui: false, disp: true, fx: 0.50, fy: 0.40, r: 50 },
        { id: "comercio", nombre: "Isla del comercio", tipo: "ciudad", aqui: false, disp: true, fx: 0.78, fy: 0.56, r: 50 },
      ];
    }
    for (const is of islas) {
      const cx = sx + sw * is.fx, cy = sy + sh * is.fy;
      this._islaMapa(ctx, cx, cy, is.r, is.nombre, is.tipo, is.aqui, is.disp);
      this._mapaIslas.push({ id: is.id, cx, cy, r: is.r, disp: is.disp });
    }

    // Pie
    ctx.fillStyle = "rgba(91,59,32,.85)"; ctx.font = "italic 14px Georgia, serif";
    ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText("Clic o Esc para cerrar", W / 2, my + mh - 20);
    ctx.restore();
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Una isla dibujada en el mapa, con su nombre (y marcador si estamos en ella)
  _islaMapa(ctx, cx, cy, r, nombre, tipo, aqui, disp = true) {
    ctx.save();
    if (!disp) ctx.globalAlpha = 0.6;   // las no disponibles se ven apagadas
    // Orilla de arena
    ctx.fillStyle = "#e3d29a";
    ctx.beginPath(); ctx.ellipse(cx, cy, r + 8, (r + 8) * 0.8, 0, 0, Math.PI * 2); ctx.fill();
    // Tierra
    ctx.fillStyle = tipo === "verde" ? "#69ab4f" : tipo === "ciudad" ? "#dcdfe4" : "#9b8b7a";
    ctx.beginPath(); ctx.ellipse(cx, cy, r, r * 0.8, 0, 0, Math.PI * 2); ctx.fill();
    // Detalles
    if (tipo === "verde") {
      ctx.fillStyle = "#3f8a3a";
      for (const [dx, dy] of [[-20, -8], [8, -14], [22, 6], [-6, 12]]) {
        ctx.beginPath(); ctx.arc(cx + dx, cy + dy, 6, 0, Math.PI * 2); ctx.fill();
      }
    } else if (tipo === "ciudad") {
      for (const [dx, dy, w2, h2] of [[-16, 4, 10, 14], [2, 8, 12, 18], [16, 6, 9, 12], [-4, 12, 11, 10]]) {
        ctx.fillStyle = "#f6f8fa"; ctx.fillRect(cx + dx, cy + dy - h2, w2, h2);   // edificio blanco
        ctx.fillStyle = "#b9c0c8"; ctx.fillRect(cx + dx, cy + dy - h2, w2, 3);    // tejadito
      }
    } else {
      ctx.fillStyle = "#6f6157";
      for (const [dx, dy] of [[-16, -6], [6, -12], [18, 6], [-4, 12]]) ctx.fillRect(cx + dx, cy + dy, 9, 7);
    }
    // Etiqueta con el nombre
    ctx.font = "bold 15px Georgia, serif";
    const tw = ctx.measureText(nombre).width + 18;
    const tx = cx - tw / 2, ty = cy + r * 0.8 + 10;
    ctx.fillStyle = "#efe0b8";
    ctx.beginPath(); ctx.roundRect(tx, ty, tw, 24, 6); ctx.fill();
    ctx.strokeStyle = "#8a6d3b"; ctx.lineWidth = 1.5;
    ctx.beginPath(); ctx.roundRect(tx, ty, tw, 24, 6); ctx.stroke();
    ctx.fillStyle = "#5b3b20"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText(nombre, cx, ty + 13);
    if (!disp) {
      ctx.font = "italic 12px Georgia, serif"; ctx.fillStyle = "#7a5a3a";
      ctx.fillText("(próximamente)", cx, ty + 38);
    }
    ctx.restore();
    // Marcador de ubicación (fuera del apagado)
    if (aqui) this._pinUbicacion(ctx, cx, cy - r * 0.8 - 6);
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }

  // Marcador rojo "estás aquí" (chincheta de mapa) que rebota suavemente
  _pinUbicacion(ctx, cx, baseY) {
    const bob = Math.abs(Math.sin(this.world.time * 4)) * 3;
    const y = baseY - 20 - bob;
    ctx.save();
    // Sombra en el suelo
    ctx.fillStyle = "rgba(0,0,0,.25)";
    ctx.beginPath(); ctx.ellipse(cx, baseY, 6, 2.5, 0, 0, Math.PI * 2); ctx.fill();
    // Cuerpo de la chincheta (círculo + punta)
    ctx.fillStyle = "#d64b4b";
    ctx.beginPath(); ctx.arc(cx, y, 9, 0, Math.PI * 2); ctx.fill();
    ctx.beginPath(); ctx.moveTo(cx - 8, y + 4); ctx.lineTo(cx + 8, y + 4); ctx.lineTo(cx, y + 18); ctx.closePath(); ctx.fill();
    ctx.strokeStyle = "#8a2f2f"; ctx.lineWidth = 1.5;
    ctx.beginPath(); ctx.arc(cx, y, 9, 0, Math.PI * 2); ctx.stroke();
    // Hueco
    ctx.fillStyle = "#fff";
    ctx.beginPath(); ctx.arc(cx, y, 3.5, 0, Math.PI * 2); ctx.fill();
    // Etiqueta "Estás aquí"
    ctx.font = "bold 12px Georgia, serif";
    const tw = ctx.measureText("Estás aquí").width + 12;
    const tx = cx - tw / 2, ty = y - 30;
    ctx.fillStyle = "rgba(40,26,14,.9)";
    ctx.beginPath(); ctx.roundRect(tx, ty, tw, 18, 5); ctx.fill();
    ctx.fillStyle = "#f6d367"; ctx.textAlign = "center"; ctx.textBaseline = "middle";
    ctx.fillText("Estás aquí", cx, ty + 9);
    ctx.restore();
    ctx.textAlign = "left"; ctx.textBaseline = "alphabetic";
  }
}
