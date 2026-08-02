# Crónicas de Miguel — Estado del proyecto

> Videojuego de rol medieval en vista superior (top-down) que **Daniel** hace
> junto a su hijo **Miguel (12 años)**. Proyecto educativo y en familia: el
> código va comentado en español y de forma sencilla para que Miguel pueda
> entenderlo y trastearlo.
>
> Este documento resume TODO lo que llevamos hecho, para poder retomar el
> proyecto (o continuarlo en otro ordenador) sin perder el contexto.
> _Última actualización: sesión del 31/07/2026._

---

## Cómo ejecutar el juego
1. Abrir una terminal (PowerShell) en la carpeta del proyecto.
2. Ejecutar:  `node server.js`
3. Abrir el navegador en **http://localhost:8080**

(El preview `file://` no vale: el navegador bloquea el JavaScript. Hay que servirlo por HTTP.)

## Tecnología
- **HTML5 + Canvas + JavaScript puro** (sin librerías, sin compilar).
- **Estilo:** pixel art moderno, vista cenital.
- **Imágenes:** generadas con **Nano Banana (Gemini 2.5 Flash Image)**. Guardar
  SIEMPRE como `.png` (el JFIF/JPEG ensucia el recorte del fondo magenta), con el
  nombre EXACTO en minúsculas y sin acentos (el juego busca `arbol.png`, no `árbol.png`).
- **Cómo se cargan:** `js/assets.js` carga los PNG de `assets/` y quita el fondo
  magenta por "chroma-key" (umbral: verde<75 y rojo/azul>85, porque el magenta de
  Nano Banana sale oscuro ~165,0,165, no #FF00FF puro). Si falta un PNG, el juego
  lo dibuja por código (versión de reserva), así nunca se rompe.

## Documentos útiles del proyecto
- `docs/plan.md` — plan por requisitos.
- `docs/inventario-sprites.md` — inventario de imágenes y prompts para generarlas.
- `assets/LEEME.txt` — nombres exactos de cada archivo de imagen.

---

## Estructura del código (carpeta `js/`)
| Archivo | Qué hace |
|---|---|
| `main.js` | Arranque, bucle principal, carga de assets, clic del ratón. |
| `game.js` | El "director": estados del juego, HUD, menús, diálogos, tiendas, misiones. |
| `world.js` | La **isla del anciano** (mapa inicial). |
| `isla_minerales.js` | La **isla de los minerales** (minado). |
| `isla_comercio.js` | La **isla del comercio** (plaza con puestos). |
| `interior.js` | El interior de la casa roja (escena del anciano). |
| `player.js` | El caballero (Seok): movimiento, dibujo, estadísticas. |
| `camera.js` | La cámara que sigue al personaje. |
| `input.js` | Teclado. |
| `assets.js` | Cargador de imágenes + quitar fondo magenta. |
| `guardado.js` | Guardar/cargar la partida (localStorage). |
| `ui.js` | Pantalla de título y menú. |

**Estados del juego** (`game.js`): `titulo`, `jugando` (isla del anciano),
`interior`, `isla_minerales`, `tienda` (picos), `isla_comercio`,
`tienda_comercio` (fruta/verdura/pollo/minerales/puros), `salir`.

---

## La historia
El protagonista se llama **Seok**. Un **anciano** enfermo (en la casa roja de la
isla inicial) tiene el mapa de un tesoro, pero le pone pruebas:
1. Traer **5 kg de hierro** de la isla de los minerales.
2. Ir a una **bóveda** en la **isla del comercio** a por el mapa (avisa de no
   comprar nada allí: los vendedores intentan vaciarte el bolsillo).

---

## Lo que YA está hecho

### Isla del anciano (mapa inicial — `world.js`)
- Caminos con bifurcación, río con puente, casas de colores, molino con aspas
  girando, pozo, árboles, arbustos, un carro de mercader y aldeanos que pasean.
- **Monedas** flotantes: +20 reales al tocarlas.
- **Cartel** en la arena (junto a la casa roja): al clicarlo se abre el **mapa de
  islas** con marcador "Estás aquí".
- **Casa roja** "entrable": botón de pergamino **"Entrar (E)"**.

### El anciano y las misiones
- **1er diálogo** al entrar: asigna la misión del hierro y te expulsa.
- Mientras la misión no esté terminada, la casa muestra un **candado** y, si
  entras, te vuelve a echar.
- **2º diálogo** (al cumplir el hierro): te manda a la isla del comercio; luego la
  casa se vuelve a bloquear con la nueva misión de la bóveda.
- **Diario de misiones**: icono de pergamino (bajo la barra de vida). Muestra
  progreso y un botón **"Reclamar X reales"** al terminar (la del hierro da 25).

### Isla de los minerales (`isla_minerales.js`)
- Isla grande (80×60). Suelo de **piedra**; minerales embebidos en el suelo.
- Reparto EXACTO de **240 vetas**: hierro 120, oro 90, amatista 24, **diamante 6**.
- **Tienda de picos** (al aparecer): pico de hierro (50r), de oro (60r), de
  diamante (200r), con velocidad y desgaste distintos.
- **Minar**: clic izquierdo sobre una veta (cerca y con pico) → se vuelve piedra y
  **reaparece a los 10 minutos**. El pico se desgasta y se rompe. El hierro sube
  la misión del anciano. **5 mineros** ambientan la isla.

### Isla del comercio (`isla_comercio.js`)
- Entras por un **callejón** (con el **fumador**) que sube a una **plaza** con 4
  puestos: **fruta y verdura** a la izquierda; **pollo y minerales** a la derecha.
- **Puerta escondida** en la pared derecha (entre pollo y minerales): se ve bien,
  con marco plateado, madera de pino y rejillas de metal. Al acercarte aparecen
  dos botones: **Abrir (E)** y **Mirar (F)**.
  - **Abrir (E):** está cerrada con llave → *"Está cerrada, buscaré la llave."*
  - **Mirar (F):** te asomas por las rejillas y ves el **calabozo** (oscuro, con
    cadenas, un esqueleto al fondo y una cama de piedra). Se cierra con Esc o F.
- **El fumador** te habla al entrar y te "vende" **puros** (5r, −10 de vida).
- **Tiendas**: comprar comida (va a la mochila) y **vender minerales** (hierro 5r,
  oro 7r, amatista 15r, diamante 21r).

### Sistemas generales
- **Vida** (0–100) y **reales** (dinero), con HUD.
- **Mochila (tecla P)**: minerales, **comida (clic para usar/comer)** y objetos
  (picos). La comida cura/daña al usarla; la manzana misteriosa da efecto aleatorio.
- **Guardar partida**: menú del título con **Continuar / Partida nueva / Guardar /
  Salir** (guarda en el navegador con localStorage; F5 ya no reinicia).

---

## Lo que está PENDIENTE (ideas para seguir)
- ✅ **Puerta escondida (hecha):** se ve bien (marco plateado, madera de pino y
  rejillas). **Mirar (F)** → ves el **calabozo oscuro y siniestro** (cadenas,
  esqueleto, cama de piedra). Falta que la imagen `calabozo.png` la generes con la IA.
- ✅ **La "llave" (en curso):** no es una llave normal, es un misterio por pasos.
  **Abrir (E)** va cambiando: primero *"Está cerrada, miraré en las tiendas por si
  alguno tiene la llave."*; cuando **miras en las 5 tiendas** (incluida la del
  fumador) pasa a *"Debería preguntarle al anciano."* y **la casa del anciano se
  abre**. Al entrar, el anciano te habla (diálogo de 4 partes) y te dice que
  **mires la manzana misteriosa**. Después, Abrir dice *"Debería mirar esa manzana
  misteriosa."*
- ✅ **La manzana misteriosa (hecha):** al comerla (mochila, tecla P) te da
  **+100 de vida** y **Fuerza nivel 5 durante 30 segundos** (sale una insignia con
  cuenta atrás y Seok brilla con un aura dorada) y te echa una **maldición**. Con la
  Fuerza **andas más rápido** y, junto a la puerta del calabozo, puedes **Tumbarla
  (E)**: se abre hacia dentro (*"¡PUM! Tumbas la puerta de una patada."*).
  - **Falta (paso siguiente):** los **monstruos** de la maldición (aparecen sobre
    píxeles negros) y el **combate** (golpear más fuerte con la Fuerza).
- La **bóveda** de verdad detrás de la puerta (da el mapa del tesoro y completa la misión).
- **Enemigos y combate.**
- Falta guardar algunos PNG: `casa_azul/verde/amarilla/morada.png`, `fumador.png`,
  `int_fruta/verdura/pollo/minerales.png`, `puerta.png`, `calabozo.png`
  (mientras tanto usan dibujo de reserva).

---

## Notas de trabajo (cómo colaboramos)
- Requisitos pequeños e incrementales; probar cada cosa antes de seguir.
- El usuario **dicta los diálogos por partes**; hay que respetar sus palabras
  (solo corregir tildes/ortografía).
- Los diálogos avanzan con **Enter**; casi todo se maneja con **clic** o teclas
  (E = interactuar, P = mochila, Esc = menú/volver).
