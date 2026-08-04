# Base de conocimiento — "Crónicas de Miguel"

Documento de referencia para que un asistente de IA (Claude) pueda **continuar el
desarrollo del juego de forma análoga a como se ha hecho hasta ahora**, incluso
desde otro ordenador tras descargar el código. Léelo entero antes de empezar.

Documentos hermanos:
- `cronicas-de-miguel-juego.md` (raíz) — resumen del estado en lenguaje llano.
- `docs/plan.md` — plan por requisitos.
- `docs/inventario-sprites.md` — inventario de imágenes + prompts para generarlas.
- `assets/LEEME.txt` — nombres EXACTOS de cada archivo de imagen.

---

## 1. Qué es el proyecto
- Videojuego de rol **medieval, vista superior (top-down)** que **Daniel** hace
  con su hijo **Miguel (12 años)**. Título: **"CRÓNICAS DE MIGUEL"**.
- Es un proyecto **educativo y en familia**: el objetivo no es solo el juego, sino
  que Miguel entienda y pueda trastear el código.
- Protagonista: **Seok** (un joven caballero con espada).

## 2. Tecnología y cómo ejecutar
- **HTML5 + Canvas + JavaScript puro**. Sin librerías, sin build, sin frameworks.
- Ejecutar: terminal en la carpeta del proyecto → `node server.js` → abrir
  **http://localhost:8080**. (Requiere Node.js. El preview `file://` NO sirve
  porque el navegador bloquea el JS; hay que servirlo por HTTP.)
- Canvas lógico de **960×540**, pixel art nítido (`imageSmoothingEnabled=false`).

## 3. CONVENCIONES DE TRABAJO (importante para continuar igual)
1. **Idioma y estilo de código:** todo en **español**, comentado y **sencillo**
   para que Miguel lo entienda. Nombres de variables/métodos en español.
2. **Método incremental:** se avanza en requisitos pequeños; se **prueba cada
   cosa** antes de seguir. No meter features enormes de golpe.
3. **Diálogos dictados por el usuario:** Daniel dicta los diálogos "por partes".
   Hay que **respetar sus palabras**, corrigiendo solo tildes/ortografía. Cada
   "parte" suele tener una réplica del personaje y otra de Seok, y se avanza con
   **Enter**.
4. **Imágenes (assets):** se generan con **Nano Banana (Gemini 2.5 Flash Image)**.
   - Cuando el juego necesita una imagen nueva, el asistente **da un prompt** y el
     usuario la genera y la guarda en `assets/`.
   - Guardar SIEMPRE como **.png**, nombre EXACTO en minúsculas y **sin acentos**
     (el juego busca `arbol.png`, no `árbol.png`). El JFIF/JPEG ensucia el recorte.
   - Los personajes/objetos van con **fondo magenta** liso (`#FF00FF`) para
     recortarlo; los fondos de pantalla completa (portada, interiores, tilesets)
     van con fondo lleno (sin magenta).
   - **Hojas de sprites** de personaje = 4 filas (abajo/arriba/izq/der) × 3
     columnas (ciclo de andar con piernas CLARAMENTE distintas). Objetos = imagen
     única. Tilesets = tira horizontal de casillas.
5. **Todo asset tiene DIBUJO DE RESERVA** en código: si falta el PNG, el juego lo
   dibuja de forma sencilla y sigue funcionando. Nunca romper el juego por un
   archivo que falte.
6. **Verificación en el navegador (flujo del asistente):**
   - En `js/main.js` se añade TEMPORALMENTE un gancho de depuración:
     `window.__game = game;` justo tras crear el juego.
   - Con la herramienta de navegador, se ejecuta JavaScript sobre `window.__game`
     para teletransportar al jugador, forzar estados (`_iniciarPartida`,
     `_viajarAMinerales`, `_entrarCasa`, etc.), abrir menús, etc., y se hacen
     **capturas** para comprobar el resultado.
   - Al terminar la verificación, se **QUITA el gancho** `window.__game` para
     dejar el código limpio, y se avisa al usuario de recargar con F5.
   - El bucle del navegador se pausa si el panel no está visible; puede hacer
     falta llamar a `game.update(dt)`/`game.draw()` a mano para probar lógica.
7. **Tono con el usuario:** cercano, motivador, en español, con emojis. Explicar
   los cambios de forma breve. Ofrecer siempre el siguiente paso.
8. **Actualizar la documentación:** tras cada avance importante, actualizar
   `cronicas-de-miguel-juego.md` y esta base de conocimiento.

## 4. Estructura del código (`js/`)
| Archivo | Contenido |
|---|---|
| `main.js` | Arranque, bucle (`requestAnimationFrame`), `Assets.load(...)`, listener de clic (convierte a coords del canvas y llama `game.onClick`). |
| `game.js` | El "director": estados, HUD, menús, diálogos, misiones, tiendas, mapa, guardado. Es el archivo más grande. |
| `world.js` | Isla del anciano (mapa inicial). Constantes de casillas `T_AGUA/T_HIERBA/T_CAMINO/T_PUENTE/T_ARENA` y `TILE=48`. |
| `isla_minerales.js` | Isla de los minerales (`IslaMinerales`). |
| `isla_comercio.js` | Isla del comercio (`IslaComercio`). |
| `interior.js` | Interior de la casa roja (`Interior`, escena del anciano). |
| `calabozo.js` | La PRISIÓN (`Calabozo`) tras tumbar la puerta: usa el mapa `prision.png` como suelo y ZONAS caminables (rectángulos en coords de imagen, `esScala` 0.6) para las colisiones. |
| `enemigo.js` | Esqueletos (`Esqueleto`): dormido/despierto/muerto, persigue y ataca; barra de vida. |
| `player.js` | El caballero Seok (`Player`): movimiento, dibujo, stats, inventarios. |
| `camera.js` | `Camera` que sigue al jugador. |
| `input.js` | `Input`: teclado. `Input.pressed[...]` para pulsaciones de una vez. Acciones registradas: enter, escape, arrowup, arrowdown, espacio, "e", "f", "p". |
| `assets.js` | `Assets`: carga PNG y quita el magenta (chroma-key). |
| `guardado.js` | `Guardado`: guardar/cargar en localStorage. |
| `ui.js` | `TitleScreen` (título + menú) y `ByeScreen`. |

Orden de carga en `index.html`: assets, input, camera, world, isla_minerales,
isla_comercio, player, interior, ui, guardado, game, main.

## 5. Estados del juego (`game.estado`)
`titulo` · `jugando` (isla del anciano) · `interior` (casa roja) ·
`isla_minerales` · `tienda` (picos) · `isla_comercio` · `tienda_comercio`
(fruta/verdura/pollo/minerales/puros) · `calabozo` (sala tras la puerta) · `salir`.

Un "mundo" (World / IslaMinerales / IslaComercio / Interior) expone: `esCaminable(px,py)`,
`pixelWidth`, `pixelHeight`, `time`, `drawGround(ctx,cam)`, `drawObjects(ctx,cam,player)`
y a veces `update(dt)`. Así se reutilizan el mismo `Player` y `Camera` en todas las escenas.

## 6. El jugador (`player.js`)
- Posición/movimiento con flechas o WASD; colisión por separado en X e Y.
- Sprite `caballero.png` (hoja 4×3); animación de andar recorriendo `[0,1,2,1]`.
- Stats: `reales`, `vida` (0–`vidaMax`=100).
- `picos` (id→true), `picoEquipado`, `picoDurabilidad`.
- `inventario` (mineral→cantidad), `comida` (nombre→cantidad).

## 7. Sistemas (dónde está cada cosa, en `game.js` salvo que se indique)

### Assets + chroma (`assets.js`)
`Assets.load(nombre, ruta, {chroma:true})`. Con chroma, quita el magenta oscuro
(umbral: `g<75 && r>85 && b>85`). `Assets.listo(n)`, `Assets.el(n)`, `Assets.w/h(n)`.

### Diálogos
`this.dialogo = { guion, i, alTerminar }`. Guiones: `DIALOGO_ANCIANO`,
`DIALOGO_EXPULSION`, `DIALOGO_ANCIANO_2`, `DIALOGO_FUMADOR` (arrays de "partes";
cada parte = array de `{quien, texto}`). Enter avanza; al acabar → `_finDialogo()`
según `alTerminar`: `asignarYExpulsar`, `expulsar`, `fin2`, `puros`.
Dibujo con `_dibujarDialogo` (caja de pergamino, `_wrap` para ajustar líneas).

### Misiones y el anciano
- `this.misiones` (array). `_asignarMisionAnciano()` (id "hierro", 5 kg, 25 reales),
  `_asignarMisionBoveda()` (id "boveda", 0/1, sin recompensa).
- `_ancianoBloqueado()` = hay misión "hierro" o "boveda" incompleta → la casa roja
  muestra **candado** (`_candado`) y expulsa.
- `_entrarCasa()` elige diálogo: sin hierro → 1º; hierro incompleto → expulsión;
  hierro completo y sin boveda → 2º; boveda incompleta → expulsión.
- Diario de misiones: icono de pergamino clicable (`_iconoPergamino`,
  `_scrollRect`), panel `_dibujarPanelMisiones` con botón "Reclamar X reales"
  (`_cobrarMision`, guarda rects en `_misionRects`).

### Mapa de islas
`_dibujarMapaMundo`, `_islaMapa(tipo verde/roca/ciudad, disp)`. Aparece "Isla de
los minerales" tras hablar con el anciano y "Isla del comercio" tras el 2º diálogo.
Clic viaja (`_viajarAMinerales`, `_viajarAComercio`); rects en `_mapaIslas`.
Marcador "Estás aquí" con `_pinUbicacion`.

### Isla de los minerales (`isla_minerales.js`)
- 80×60. Suelo de piedra; minerales embebidos. Reparto EXACTO (`MINERAL_CUENTA`):
  hierro 120, oro 90, ametista 24, **diamante 6** (240 vetas). Tileset
  `tiles_minerales.png` (7 columnas: piedra, agua, arena, hierro, oro, amatista, diamante).
- **Minar**: clic izquierdo sobre una veta (cerca y con pico) → `picar()` la vuelve
  piedra y `regenerar()` la restaura a los **10 min** (`REGEN_SEG=600`, con `game.reloj`).
  El hierro sube la misión; el pico se desgasta y se rompe.
- **Tienda de picos** (`PICOS`): hierro 50r, oro 60r, diamante 200r (velocidad y
  desgaste distintos). Estado "tienda", `_dibujarTienda`, `_comprarPico`.
- 5 mineros NPC (`minero.png`).

### Isla del comercio (`isla_comercio.js`)
- 26×40. **Callejón** (con el fumador) → **plaza** con 4 puestos: fruta+verdura a
  la izquierda, pollo+minerales a la derecha. Suelo hormigón blanco + paredes
  ladrillo blanco (`tiles_comercio.png`, 4 cols). **Puerta escondida** en la pared
  derecha (`isla.puerta`, bloquea; `cercaDePuerta()`).
- El **fumador** habla al entrar (primera vez, `DIALOGO_FUMADOR`, flag
  `fumadorHablado`) y abre la tienda de **puros**. Luego acercarse + E la reabre.

### Tiendas del comercio (estado "tienda_comercio")
- `PRODUCTOS_COMERCIO` (fruta/verdura/pollo/puros), `CONSUMIBLES` (efecto al usar),
  `MINERAL_VENTA` (precios de venta). `NOMBRE_TIENDA`, `COLORES_PROD`.
- Comprar comida → va a `player.comida` (NO cura al instante). Vender minerales →
  selector +/- por mineral y botón "Vender" (`_venderMinerales`).
- Dibujo: `_dibujarTiendaComercio`, `_uiComida`/`_tarjetaProducto`, `_uiVenta`.
  Avisos "comprar/vender (E)": `_hintPuestoComercio`, `_hintFumador`.

### Mochila / inventario (tecla P)
`_dibujarInventario`: secciones **Minerales**, **Comida (clic para usar)** y
**Objetos** (picos). Comer/fumar con `_consumir` (aplica `CONSUMIBLES`; manzana
misteriosa = `_efectoMisterioso` aleatorio). Rects clicables en `_invBotones`.

### HUD
Barra de vida (`_corazon`), reales (`_moneda`), icono de pergamino de misiones,
y en la isla de minerales el pico equipado + durabilidad (`_dibujarPicoHUD`).

### Guardado (`guardado.js`)
localStorage, clave `cronicas_de_miguel_save`. Menú del título con opciones
dinámicas (`TitleScreen.setOpciones`): Continuar / Partida nueva / Guardar / Salir.
`_guardarPartida` serializa player (pos, reales, vida, picos, durabilidad,
inventario, comida) + misiones + reloj; `_cargarPartida` recrea el mundo y aplica.
(No se guarda qué vetas estaban picadas: regeneran solas.)

## 8. Controles
Mover: flechas o WASD · Interactuar (entrar/comprar): **E** · Picar mena: **clic
izquierdo** · Mochila: **P** · Diario de misiones: clic en el pergamino ·
Menú/volver: **Esc** · Avanzar diálogo: **Enter** · Junto a la puerta escondida:
**E** = abrir (está cerrada), **F** = mirar por las rejillas (cierra con Esc o F).

## 9. La historia y guiones ya escritos
- **1er diálogo** (anciano, 5 partes): pregunta quién eres; Seok se presenta;
  el anciano tiene un mapa pero está enfermo y te encarga traer **5 kg de hierro**.
- **Expulsión**: "¿Qué haces aquí? ¡No has terminado la misión!"
- **2º diálogo** (misión cumplida, 3 partes): "Ya lo tienes, bien hecho. Has
  aprobado." → te manda a la **bóveda** de la **isla del comercio** a por el mapa,
  avisando de no comprar nada.
- **Fumador** (3 partes): "¡Eh, tú!"… te acaba colando la tienda de puros.

## 10. PENDIENTE (próximos pasos)
- ✅ **Puerta escondida (hecho):** al acercarse aparecen dos botones, **Abrir (E)**
  y **Mirar (F)**. Mirar abre la vista del **calabozo** a pantalla completa
  (`game.mirandoCalabozo`, `_dibujarCalabozo`/`_calabozoReserva`, asset
  `calabozo.png`), con rejillas por delante, cadenas, un esqueleto al fondo y una
  cama de piedra. Se cierra con **Esc** o **F**.
- ✅ **La "llave" (en curso):** no es una llave física, es una cadena de pistas.
  El texto de **Abrir (E)** cambia según el progreso (`_guionPuerta`):
  1. Antes de mirar tiendas → *"Está cerrada, miraré en las tiendas por si alguno
     tiene la llave."* (`DIALOGO_PUERTA_TIENDAS`).
  2. Tras visitar **las 5 tiendas** del comercio (fruta/verdura/pollo/minerales/
     puros; se registran en `game.tiendasVistas` desde `_entrarTiendaComercio`,
     comprobadas con `_todasTiendasVistas`) → *"Debería preguntarle al anciano."*
     (`DIALOGO_PUERTA_ANCIANO`). En ese momento la casa del anciano se **abre**
     aunque la misión "boveda" siga a medias (`_puedeHablarLlave` hace que
     `_ancianoBloqueado` devuelva false).
  3. Al entrar en la casa → **`DIALOGO_ANCIANO_LLAVE`** (4 partes; `alTerminar:
     "llaveHablado"` pone `game.ancianoLlaveHablado=true` y sale de la casa). El
     anciano sugiere mirar la **manzana misteriosa**.
  4. Después, Abrir (E) dice *"Debería mirar esa manzana misteriosa."*
     (`DIALOGO_PUERTA_MANZANA`). `tiendasVistas` y `ancianoLlaveHablado` se
     guardan/cargan en la partida.
- ✅ **La manzana misteriosa y tumbar la puerta (hecho):** comer la "Manzana
  misteriosa" (mochila, tecla P) llama a `_efectoManzana`: **+100 de vida**,
  **Fuerza nivel 5 durante 30 s** (`player.fuerzaT`/`fuerzaNivel`, cuenta atrás en
  `player.update`, insignia en `_dibujarFuerzaHUD`, aura dorada en `player.draw`) y
  **maldición** (`player.maldito=true`, todavía sin efecto). Con Fuerza andas más
  rápido (×1.6 en `player.update`) y, junto a la puerta, **Abrir (E)** pasa a
  **Tumbar (E)**: `_tumbarPuerta` pone `game.puertaAbierta=true` y
  `islaComercio.puerta.abierta=true`, y la puerta se dibuja **abierta hacia dentro**
  (asset `puerta_abierta.png` / `_puertaAbiertaReserva`). Se guarda en la partida.
  Tras tumbar la puerta (`puertaAbierta`), la **Manzana misteriosa** sale como
  **"VENDIDO"** en la frutería y ya no se puede comprar (es única).
  - **PENDIENTE (combate):** "golpear más fuerte" con la Fuerza, y la **maldición**.
    Diseño acordado de los enemigos (prompts en `docs/inventario-sprites.md` §10):
    - **Esqueleto de manos (cuerpo a cuerpo):** el ÚNICO que está "en el suelo".
      Aparece **sentado y dormido** (ojos apagados) sobre los **píxeles negros
      (#000000)**; al acercarse el jugador maldito, **despierta** (ojos verdes) y
      persigue/ataca. Sprites: `esqueleto_manos(_sentado/_atacar).png`.
    - **Los demás** (bola de pinchos `esqueleto_maza`, espada `esqueleto_espada`,
      arco `esqueleto_arco` + `flecha.png`): NO están en el suelo; **aparecen en
      puntos concretos** que definirá el usuario (encuentros colocados a mano).
    - **Números acordados:** cada esqueleto tiene **50 de vida** (con **barra de
      vida encima**). El de manos hace **15** de daño al tocarte. El **arquero**
      hace daño según la distancia: **cerca 25 · media 20 · lejos 15**; la
      **flecha** usa hitbox completa y **vive como mucho 10 bloques (tiles)** en el
      aire, luego desaparece.
    - **Atacar:** con **barra espaciadora Y con clic derecho** (las dos valen);
      espadazo hacia donde mira Seok. (Asumidos, ajustables: daño de espada **25**,
      mata en 2 golpes, y **50 con Fuerza** = 1 golpe; esqueletos **un poco más
      lentos** que el jugador.)
    - Construir por trozos: aparecer → despertar → perseguir → espadazo + daño →
      arquero + flecha.
- ✅ **El calabozo (sala, hecho):** al tener la puerta tumbada, junto a ella sale
  **Entrar (E)** y se pasa al estado **`calabozo`** (`js/calabozo.js`, clase
  `Calabozo`: 22×15 casillas, **suelo negro**, paredes de piedra oscura, antorchas
  con luz cálida y un hueco de salida abajo). `_entrarCalabozo`/`_salirCalabozo`
  guardan/restauran la posición en la plaza (`_comercioPos`). Se sale con **Esc** o
  con **Salir (E)** junto al hueco. Cargado en `index.html` antes de `player.js`.
  - ✅ **Esqueletos de manos + combate (hecho):** `js/enemigo.js` (clase `Esqueleto`).
    3 esqueletos de manos **dormidos** (ojos apagados, sentados) en el suelo del
    calabozo (`calabozo.enemigos`); al acercarse el jugador (radio 150) **despiertan**
    (ojos verdes) y **persiguen** (más lentos, 110 vs 165). **50 de vida** con **barra
    roja + número** encima. Si te tocan te quitan **15** (con enfriamiento) y hay un
    **flash rojo** (`game.recibirDano`/`danoFlashT`). Atacas con **Espacio o clic
    derecho** (`_atacar`, `onAtaque` desde `main.js` `contextmenu`): daño **25**, o
    **50 con Fuerza** (1 golpe). Muertos = montón de huesos. `_dibujarTajo` pinta el
    espadazo. Contador "Esqueletos: N" en el HUD del calabozo. El ataque funciona en
    **cualquier escena jugable** (jugando/isla_minerales/isla_comercio/calabozo);
    `_atacar` golpea a los enemigos de `_mundoActual().enemigos`. Del **calabozo solo
    se sale llegando a la puerta (Salir E)**, ya NO con Esc.
  - ✅ **PNG del esqueleto de manos conectados:** `enemigo.js` usa las hojas si
    existen (`_tieneSprites`/`_dibujarSprite`/`_sprite`, con dibujo de reserva de
    respaldo). `esqueleto_manos_sentado.png` (2×4) para el dormido (frente, ojos
    apagados = fila 0 col 0); `esqueleto_manos.png` (3×4 = 12 fotogramas, **de perfil
    mirando a la derecha**, se voltea si va a la izquierda) para andar;
    `esqueleto_manos_ataque.png` (2×4, fila 0 col 1 = zarpazo) al atacar. Se recorta
    un ~5% de cada celda para evitar las líneas negras de la rejilla.
  - **PENDIENTE:** los esqueletos con **arma** (maza/espada/arco) en **puntos
    concretos** (falta decidir dónde) y enchufar sus PNG (ojo: el de ataque de la
    espada se subió como `esqueleto_espadea_ataque.png`, con typo); el **arquero** +
    **flecha** (`flecha.png`, alcance 10 tiles, daño 25/20/15); la **muerte del
    jugador** (vida a 0 no hace nada aún); y al fondo la **bóveda** con el mapa.
- ✅ **La prisión — mapa y paredes (Trozo 1, hecho):** el estado `calabozo` ahora
  usa la imagen `prision.png` (mapa dibujado, 2752×1536, escala 0.6) como suelo y un
  array `zonas` (rectángulos caminables en coords de imagen) para las colisiones
  (`Calabozo.esCaminable`). Recorrido: calabozo (entrada) → pasillo → celda vacía →
  jardín → comedor → pasillo de la bóveda → bóveda (+ celda-regalo). Se entra por el
  calabozo y se sale por la puerta tumbada (`salida`, Salir E). Las zonas se han
  **afinado** para pegar a los suelos reales (las paredes ya bloquean bien). Entre el
  pasillo izquierdo (zona 1) y el derecho (zona 4) queda un hueco a la altura de las
  **rejas**: no se cruza el pasillo de frente (obstáculo del Trozo 2). El jardín (zona
  3) queda aislado salvo por la **pared agrietada**, pendiente de abrir con la manzana.
  - ✅ **Puerta de la celda vacía (hecho):** `Calabozo.puertaCelda` (rect en coords
    de imagen). Al acercarse sale **Abrir (E)** (`_hintCeldaVacia`); mientras está
    cerrada bloquea el paso (`esCaminable`); al abrir, se **tapan las rejas** con un
    hueco oscuro (`_dibujarHuecoCelda`) y se puede pasar. (Hecho por código sobre la
    imagen, sin regenerar el mapa.)
  - ✅ **Cofre del pasillo (hecho):** `Calabozo.cofre` (a la izquierda de la puerta de
    la celda). Al acercarse sale **Abrir (E)** (`_hintCofre`); al abrirlo da una
    **Manzana misteriosa** (`player.comida`) y se dibuja abierto. Asset `cofre.png`
    (chroma) con dibujo de reserva (`_cofreReserva`).
  - ✅ **Pared agrietada / Trozo 2 (hecho):** `Calabozo.paredAgrietada` (rect en coords
    de imagen, entre la celda y el jardín). Junto a ella, con **Fuerza** activa sale
    **Romper (E)** (`_hintPared`); al romper (`rota=true`) se **tapa ese trozo con un
    agujero de escombros** (`_dibujarAgujeroPared`) y ese hueco se vuelve caminable
    (celda ↔ jardín en `esCaminable`). Sin Fuerza, avisa que necesita fuerza. Flujo
    completo del Trozo 2: cofre → Manzana → comer (P) → Fuerza → romper pared → jardín.
  - ✅ **Arbustos del jardín + llave escondida (hecho):** `Calabozo.arbustos` (lista de
    4 con x,y en coords de imagen; uno lleva `llave:true`). Se dibujan con
    `_dibujarArbusto` (una capa de césped tapa el arbusto pintado del mapa y encima va
    `arbusto.png`, con reserva por código). Al acercarse sale **Buscar (E)**
    (`_hintArbusto`); buscar en el arbusto de la llave da `player.tieneLlave=true`
    (*"¡Encuentras una llave escondida!"*) y en los demás *"Aquí no hay nada..."*.
    `Calabozo.cercaDeArbusto` y `llaveEncontrada` controlan el estado.
  - ✅ **Celda-regalo / Trozo 3 (hecho):** la celda del candado (zona 8, abajo).
    `Calabozo.cofreRegalo` (x,y en coords de imagen) es un **cofre dorado dibujado por
    código** (`_dibujarCofreRegalo`, sin PNG). Al acercarse sale **Abrir (E)**
    (`_hintCofreRegalo`); si `player.tieneLlave` se abre y pone
    `player.espadaMistica=true` (Espada del Golpe Místico); si no, avisa de que hay que
    buscar la llave en el jardín. Con la espada mística `_atacar` suma +20 de daño y el
    tajo (`_dibujarTajo`) se pinta morado.
  - ✅ **Esqueletos / Trozo 4 (hecho):** `Calabozo.enemigos` se rellena en el
    constructor con dos `Esqueleto("manos")`: uno en el calabozo de entrada (zona 0)
    con `dir="izq"` (sentado **de perfil mirando a la izquierda**) y otro en la celda de
    rejas (zona 2) con `dir="abajo"` (sentado **de frente**). En `enemigo.js`,
    `_dibujarSprite` elige en el estado dormido la fila 0 (frente) o la fila 2 (perfil,
    mira a la izquierda; se voltea si `dir==="der"`) de `esqueleto_manos_sentado`.
    Despiertan al acercarse (radio 150) y persiguen; combate ya existente.
  - **PENDIENTE:** la **bóveda** (zona 7): entrar (E) → escena interior con
    `boveda_ataque.png`, el **esqueleto gigante** (`esqueleto_gigante.png`), el mapa del
    tesoro (cofre "Abrir E") y el agujero "Bajar (E)" bloqueado hasta derrotar al jefe.
    Afinar también que romper/entrar la pared agrietada exija estar dentro de la celda.
- **Enemigos y combate** (la maldición de la manzana).
- Assets que faltan por guardar (usan dibujo de reserva): `casa_azul/verde/
  amarilla/morada.png`, `fumador.png`, `int_fruta/verdura/pollo/minerales.png`,
  `puerta.png`, `calabozo.png`.

## 11. Para continuar en otro ordenador
1. Instalar **Node.js**.
2. Copiar la carpeta `MMP_Games` completa (incluida `assets/` y `docs/`).
3. `node server.js` → http://localhost:8080.
4. Abrir Claude, pegar el contenido de `SYSTEM-PROMPT.md` (raíz del proyecto) y
   pedirle que lea esta base de conocimiento y `cronicas-de-miguel-juego.md`.
5. La partida guardada (localStorage) NO viaja entre ordenadores; en el nuevo PC
   se empieza de cero salvo que se implemente exportar/importar.
