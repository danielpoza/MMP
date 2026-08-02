# 🎨 Plan de creación de sprites / bitmaps — Crónicas de Miguel

Guía completa para crear TODAS las imágenes del juego con un modelo de imagen.
Incluye: qué modelo usar, el flujo de trabajo, las reglas de estilo comunes, el
**inventario** de cada asset y un **prompt preciso** para cada uno.

---

## 1. ¿Qué modelo usar?

**Recomendado: Google "Nano Banana" (Gemini 2.5 Flash Image).**
Por qué encaja con este proyecto:

- **Consistencia de personaje/estilo:** puedes darle una imagen de referencia y
  pedir "el MISMO caballero, ahora de espaldas". Es clave para que todos los
  fotogramas del héroe parezcan el mismo dibujo.
- **Edición por conversación:** "cámbiale el tejado a azul", "quítale el fondo",
  "hazlo más pixelado". Ideal para ir afinando sin empezar de cero.
- **Sigue instrucciones largas** (paleta, vista cenital, cuadrícula...).

**Alternativas útiles:**

| Modelo / herramienta | Cuándo usarlo |
|---|---|
| **PixelLab.ai** | Especializado en *pixel art* y sprites: genera hojas de fotogramas, rotaciones y animaciones. Muy bueno **solo para el caballero**. |
| **Retro Diffusion** | Modelo pensado para pixel art nítido (tiles y objetos). |
| DALL·E 3 (ChatGPT) / Midjourney | Buena calidad, pero peor en consistencia exacta y transparencias. |
| **Aseprite** (de pago) / **Piskel** (gratis, web) | NO generan con IA: son editores para **recortar la hoja, limpiar y exportar** los PNG finales. Imprescindibles al final. |

> **Nuestra receta:** el escenario y los objetos con **Nano Banana**; el
> caballero animado con **PixelLab** (o Nano Banana + paciencia); y el recorte
> final en **Piskel/Aseprite**.

---

## 2. Flujo de trabajo (los 7 pasos)

1. **Ancla de estilo primero.** Genera UNA imagen de muestra (p. ej. el
   caballero) que os guste. Esa imagen será la **referencia** que adjuntaréis en
   los demás prompts para que todo tenga el mismo estilo y paleta.
2. **Fondo fácil de recortar.** Pedid **fondo magenta liso `#FF00FF`** (o verde
   `#00FF00`) en vez de "transparente": la IA lo hace más limpio y luego se
   quita ese color en un clic. Para los *tiles* del suelo, en cambio, se pide
   **sin fondo, que rellene todo el cuadro**.
3. **Generad en grande y reducid.** Pedid la imagen grande (1024 px) y luego
   **reducidla a su tamaño final con "vecino más cercano" (nearest neighbor)**
   en Piskel/Aseprite: así queda pixelado y nítido, no borroso.
4. **Paleta fija.** Pegad en cada prompt la paleta de colores (sección 4). Así
   lo generado combina con lo que ya dibuja el juego.
5. **Un asset por imagen** (salvo los *tilesets* y la hoja del héroe, que van en
   una sola imagen con cuadrícula).
6. **Recortad y nombrad** los PNG con el nombre exacto del inventario (sección 3)
   y guardadlos en una carpeta nueva `assets/`.
7. **Avisadme** y adapto el código para cargar esos PNG (Req 2 y Req 4). La
   jugabilidad no cambia, solo el aspecto.

---

## 3. Inventario de assets

Tamaños "para el juego" = cómo conviene que quede el PNG final para encajar tal
cual. Podéis generarlo más grande y reducirlo después.

| # | Archivo (`assets/…`) | Tipo | Tamaño final | Contenido |
|---|---|---|---|---|
| A1 | `tiles.png` | Tileset (cuadrícula) | 240×48 (5 casillas de 48×48) | hierba · camino · agua · arena · puente |
| A2 | `caballero.png` | Hoja de sprites | 144×192 (4 filas × 3 col, celdas 48×48) | héroe con espada: 4 direcciones × 3 pasos |
| A3 | `casa_roja.png` | Objeto | 96×112 | casa tejado rojo |
| A4 | `casa_azul.png` | Objeto | 96×112 | casa tejado azul |
| A5 | `casa_verde.png` | Objeto | 96×112 | casa tejado verde |
| A6 | `casa_amarilla.png` | Objeto | 96×112 | casa tejado amarillo |
| A7 | `casa_morada.png` | Objeto | 96×112 | casa tejado morado |
| A8 | `molino_torre.png` | Objeto | 96×160 | torre del molino (sin aspas) |
| A9 | `molino_aspas.png` | Objeto | 96×96 | aspas sueltas (para girarlas por código) |
| A10 | `pozo.png` | Objeto | 48×64 | pozo de piedra |
| A11 | `arbol.png` | Objeto | 64×96 | árbol frondoso |
| A12 | `arbusto.png` | Objeto | 48×48 | arbusto |
| A13 | `portada.png` | Fondo | 960×540 | ilustración de la pantalla de título |

> Las 5 casas son el **mismo dibujo** cambiando solo el color del tejado: generad
> una y pedid las variantes ("igual, pero tejado azul"). Ahorra mucho tiempo.

---

## 4. Reglas de estilo comunes (pegar en CADA prompt)

Copiad este bloque al inicio de cada prompt (traducido al inglés suele rendir
mejor, así que incluyo ambos):

**ES:**
> Estilo pixel art moderno, nítido, sin difuminado (nearest-neighbor), colores
> vivos, día soleado, luz suave desde arriba a la izquierda, sin contornos negros
> gruesos, sin texto ni marcas de agua. Vista cenital (top-down); los edificios
> con una ligera perspectiva 3/4. Paleta: hierba #69ab4f/#5fa04a, tierra
> #c8a26a/#bd9760, agua #3d7fb5/#356fa3, arena #e3d29a/#dcc98c, madera
> #8a5a33/#6f4526, piedra #d9cdb0, oro #f6d367/#caa24a; héroe: túnica #8a2f2f,
> armadura #c0c0c8, piel #e8b48a, pelo #6b4423, acero de espada #dfe6ef.

**EN:**
> Modern pixel art, crisp (nearest-neighbor), vibrant colors, sunny day, soft
> light from top-left, no thick black outlines, no text or watermark. Top-down
> view; buildings in slight 3/4 perspective. Palette: grass #69ab4f/#5fa04a,
> dirt #c8a26a/#bd9760, water #3d7fb5/#356fa3, sand #e3d29a/#dcc98c, wood
> #8a5a33/#6f4526, stone #d9cdb0, gold #f6d367/#caa24a; hero: red tunic #8a2f2f,
> silver armor #c0c0c8, skin #e8b48a, brown hair #6b4423, steel blade #dfe6ef.

---

## 5. Prompts precisos por asset

*(Añadid delante el bloque de la sección 4. Donde diga "adjuntad la referencia",
usad la imagen ancla del paso 1 del flujo.)*

### A1 · Tileset del suelo — `tiles.png`
> Una tira horizontal de 5 casillas cuadradas idénticas en tamaño, cada una
> **perfectamente repetible sin costuras (seamless/tileable)**, en este orden:
> 1) hierba verde con alguna florecilla amarilla, 2) camino de tierra con
> piedrecitas, 3) agua de río azul con reflejos claros, 4) arena de playa,
> 5) tablones de madera de puente en horizontal. Sin bordes ni marco entre
> casillas, que cada textura rellene todo su cuadro. Fondo: ninguno.
> *(EN: A horizontal strip of 5 equal square tiles, each perfectly seamless/
> tileable, in order: grassy field with a small yellow flower; dirt path with
> pebbles; blue river water with light reflections; beach sand; horizontal
> wooden bridge planks. No borders between tiles, each texture fills its square.)*

### A2 · Caballero con espada (hoja de sprites) — `caballero.png`
> Hoja de sprites de un caballero medieval joven con espada, vista cenital.
> Cuadrícula de **4 filas y 3 columnas**, celdas iguales, personaje centrado en
> cada celda, mismo personaje en todas. Filas por dirección: fila 1 mirando
> **abajo**, fila 2 **arriba** (de espaldas), fila 3 **izquierda**, fila 4
> **derecha**. Columnas = animación de andar: col 1 quieto, col 2 pie izquierdo
> adelante, col 3 pie derecho adelante. Túnica roja, peto plateado, pelo castaño,
> espada de acero en la mano. Fondo magenta liso #FF00FF. Sin sombra bajo los
> pies (la pone el juego).
> *(EN: Sprite sheet of a young medieval knight with a sword, top-down. 4 rows ×
> 3 columns grid, equal cells, same character centered in each. Rows = facing:
> row1 down, row2 up (back), row3 left, row4 right. Columns = walk cycle: idle,
> left foot forward, right foot forward. Red tunic, silver breastplate, brown
> hair, steel sword. Flat magenta #FF00FF background, no ground shadow.)*
>
> 💡 Truco de consistencia: si la hoja sale descuadrada, generad **una fila cada
> vez** ("las 3 poses de andar mirando hacia abajo, en fila") adjuntando siempre
> la misma referencia, y montad la hoja en Piskel. O usad **PixelLab**, que hace
> esto automáticamente.

### A3–A7 · Casas de aldea — `casa_roja.png` … `casa_morada.png`
> Una casita medieval de campo, vista ligeramente cenital (3/4). Paredes de
> adobe claro (#e9dcc3) con vigas de madera, una puerta de madera y una ventana
> pequeña. **Tejado a dos aguas de color ROJO (#c0553b)**. Ocupa el cuadro
> dejando un pequeño margen; la base (paredes) apoyada abajo. Fondo magenta liso
> #FF00FF, sin sombra en el suelo (la pone el juego).
> *(EN: A small medieval cottage, slight 3/4 top-down. Light adobe walls
> (#e9dcc3) with wooden beams, a wooden door and a small window. **Red gabled
> roof (#c0553b)**. Flat magenta #FF00FF background, no ground shadow.)*
>
> Variantes (mismo dibujo, cambiar el tejado): **azul #5b8bbf**, **verde
> #7aa15a**, **amarillo #caa24a**, **morado #b06fb0**. Pedidlas como edición de
> la primera: "la misma casa, pero el tejado azul".

### A8 · Torre del molino (sin aspas) — `molino_torre.png`
> Un molino de viento medieval SIN aspas, vista ligeramente cenital. Torre alta
> de piedra clara (#d9cdb0) con una puerta de madera y un tejado cónico marrón
> (#8a4b2f) en la punta. En el centro del frente, un pequeño eje/soporte redondo
> oscuro donde luego irán las aspas. Formato vertical. Fondo magenta liso
> #FF00FF, sin sombra.
> *(EN: A medieval windmill tower WITHOUT blades, slight top-down. Tall light
> stone tower (#d9cdb0), wooden door, brown conical roof (#8a4b2f) on top, and a
> small dark round hub on the front where blades will attach. Tall format, flat
> magenta #FF00FF background, no shadow.)*

### A9 · Aspas del molino (sueltas) — `molino_aspas.png`
> Solo las **cuatro aspas** de un molino de viento, en forma de cruz (+),
> centradas en el cuadro, de madera clara con tela (#efe7d0) y un buje redondo
> oscuro en el centro exacto. Dejad espacio igual por los cuatro lados para que
> giren bien. Cuadro cuadrado. Fondo magenta liso #FF00FF.
> *(EN: Only the four windmill blades forming a plus/cross shape, centered, light
> wood-and-cloth (#efe7d0) with a dark round hub at the exact center. Equal empty
> margin on all four sides so they can rotate. Square canvas, flat magenta
> #FF00FF background.)*

### A10 · Pozo — `pozo.png`
> Un pozo medieval de piedra gris con brocal redondo, un tejadillo de madera a
> dos aguas sostenido por dos postes, y agua oscura dentro. Vista ligeramente
> cenital. Fondo magenta liso #FF00FF, sin sombra.
> *(EN: A medieval gray stone well with a round rim, a small wooden gabled roof
> on two posts, dark water inside. Slight top-down, flat magenta background.)*

### A11 · Árbol — `arbol.png`
> Un roble frondoso de copa redondeada verde (#3f8a3a/#48973f) con tronco marrón
> (#6b4423), visto ligeramente desde arriba. Formato vertical, copa arriba y
> tronco abajo centrado. Fondo magenta liso #FF00FF, sin sombra.
> *(EN: A leafy oak with a round green canopy (#3f8a3a/#48973f) and brown trunk
> (#6b4423), slight top-down. Tall format, flat magenta background, no shadow.)*

### A12 · Arbusto — `arbusto.png`
> Un arbusto pequeño y redondo de hojas verdes (#3f8a3a), visto desde arriba.
> Cuadro cuadrado, fondo magenta liso #FF00FF, sin sombra.
> *(EN: A small round green bush (#3f8a3a), top-down, square canvas, flat magenta
> background, no shadow.)*

### A13 · Fondo de portada — `portada.png`
> Ilustración apaisada de portada de videojuego de fantasía medieval épica, pixel
> art moderno. Cielo de atardecer púrpura y naranja con estrellas y una luna
> clara, montañas oscuras en silueta al fondo, una gran espada de acero clavada
> en una roca con un resplandor dorado en el centro, y un pequeño dragón volando
> a lo lejos. Ambiente heroico tipo Golden Axe / El Señor de los Anillos. **Deja
> la mitad superior algo despejada** para el título y la zona inferior-centro
> para el menú. Sin texto. Formato 16:9.
> *(EN: Wide epic medieval fantasy game title illustration, modern pixel art.
> Purple-orange sunset sky with stars and a pale moon, dark silhouetted
> mountains, a large steel sword stuck in a rock with a golden glow at center, a
> small dragon flying in the distance. Heroic Golden Axe / LOTR mood. Keep the
> top area clearer for the title and the lower-center for a menu. No text, 16:9.)*

---

## 6. Orden recomendado de creación

1. **A2 caballero** (es la "ancla" de estilo y lo más difícil → hacedlo primero).
2. **A1 tiles** (el suelo, se ve en todas partes).
3. **A3 casa** + variantes A4–A7.
4. **A8 + A9 molino**, **A10 pozo**, **A11 árbol**, **A12 arbusto**.
5. **A13 portada** (podéis dejarla para el final o incluso quedaros con la actual,
   que ya está hecha por código).

## 7. Cómo lo integraré en el juego
- **Req 2:** cargo `tiles.png` y los objetos (casas, molino, pozo, árboles) y los
  dibujo con `drawImage`. Mismo mapa, mismas colisiones, mejor aspecto.
- **Req 4:** uso la hoja `caballero.png` para animar el andar en 4 direcciones.
- Si algún PNG no encaja de tamaño, no pasa nada: lo escalo yo por código.

> Cuando tengáis aunque sea 2 o 3 assets (por ejemplo el caballero y los tiles),
> avisadme y os los enchufo para que veáis el cambio enseguida. 🚀

---

## 8. Items nuevos: dinero y aldeanos

Añadidos en la fase de "dinero, vida y NPCs". La vida y el marcador de reales se
dibujan por código (no necesitan imagen). Estos tres sí:

| # | Archivo (`assets/…`) | Tipo | Tamaño final | Contenido |
|---|---|---|---|---|
| A14 | `moneda.png` | Objeto | 48×48 | moneda de oro (flota y gira; vale 20 reales) |
| A15 | `aldeano.png` | Hoja de sprites | 144×192 (4 filas × 3 col) | aldeano andante, sin espada |
| A16 | `carro.png` | Objeto | 96×112 | carro cargado de mercancías con su vendedor |

### A14 · Moneda — `moneda.png`
> Pixel art moderno y nítido, sin difuminado, sin texto. Una moneda de oro
> medieval vista DE FRENTE, redonda y brillante (#f6d367 con borde #a9740a), con
> un relieve sencillo en el centro (una corona o una estrella) y el canto
> marcado. Centrada y grande en un lienzo cuadrado. Fondo magenta liso #FF00FF,
> sin sombra.

### A15 · Aldeano andante (hoja de sprites) — `aldeano.png`
> Pixel art moderno y nítido, vista cenital, sin texto. Hoja de sprites de un
> ALDEANO medieval (campesino, SIN espada ni armadura), misma estructura que el
> caballero: cuadrícula de 4 filas × 3 columnas, mismo personaje en las 12
> celdas. Filas por dirección: fila 1 abajo, fila 2 arriba, fila 3 izquierda,
> fila 4 derecha. Columnas = andar: quieto, pie izquierdo, pie derecho. Ropa
> humilde: túnica marrón o verde, delantal, gorro sencillo, botas. Fondo magenta
> liso #FF00FF, sin sombra. Mismo estilo y tamaño que caballero.png.

### A16 · Carro del mercader — `carro.png`
> Pixel art moderno y nítido, vista ligeramente cenital (3/4), sin texto. Un
> carro de madera de dos ruedas cargado de mercancías (cajas, sacos y un par de
> barriles), y junto a él, de pie, un MERCADER medieval con túnica y delantal.
> Madera cálida (#7a4a24), ruedas de radios. Formato un poco más alto que ancho.
> Fondo magenta liso #FF00FF, sin sombra en el suelo (la pone el juego).

---

## 9. La isla del comercio: la puerta escondida

| # | Archivo (`assets/…`) | Tipo | Tamaño final | Contenido |
|---|---|---|---|---|
| A17 | `puerta.png` | Objeto | 48×96 | puerta escondida del calabozo (pared derecha de la plaza) |

### A17 · Puerta escondida del calabozo — `puerta.png`
> Pixel art moderno y nítido, sin difuminado, sin texto. Una **puerta medieval
> alta y estrecha** (formato vertical, más alta que ancha, proporción 1:2) vista
> **de frente**, como si estuviera **empotrada en una pared** (se ve de lado, en
> el lateral de un edificio). **Que se NOTE, nada camuflada.** Tiene un **marco
> metálico plateado** de acero con remaches alrededor de todo el borde; el cuerpo
> de la puerta es de **madera oscura de pino** (tablones verticales con vetas y
> algún nudo, color #4a3221). En la parte de arriba, un **ventanuco con rejas de
> metal** (barrotes verticales de hierro) por el que se ve **oscuridad total**
> (un calabozo negro y siniestro). Dos **bandas de refuerzo de hierro**
> horizontales con remaches y un **tirador de hierro**. Fondo magenta liso
> #FF00FF, sin sombra en el suelo (la pone el juego).
> *(EN: Modern crisp pixel art, no text. A tall narrow medieval door (portrait,
> ~1:2), seen from the front, embedded in a wall (side of a building). Make it
> clearly VISIBLE, not camouflaged. A silver steel frame with rivets around the
> whole border; the door body is dark pine wood (vertical planks with grain and a
> knot, #4a3221). Near the top, a small barred window (vertical iron bars) showing
> total darkness (a black, sinister dungeon). Two horizontal iron reinforcement
> bands with rivets and an iron handle. Flat magenta #FF00FF background, no ground
> shadow.)*
>
> 💡 Ya está dibujada por código (dibujo de reserva), así que el juego la muestra
> aunque falte este PNG. Cuando guardes `puerta.png` en `assets/`, el juego usará
> tu imagen automáticamente.
