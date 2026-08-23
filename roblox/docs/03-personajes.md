# 3️⃣ Personajes en Roblox (que sean VÁLIDOS)

En Roblox un personaje no es un dibujo: es un **Model** con unas piezas que
tienen que llamarse **exactamente** de cierta manera. Si un nombre está mal, el
personaje se cae al suelo, no anda o no se le puede matar. Esta es la chuleta.

## 🧬 Qué necesita SIEMPRE un personaje válido

Dentro del `Model` tiene que haber:

1. **`Humanoid`** → el "cerebro": da vida (`Health`), velocidad (`WalkSpeed`),
   salto (`JumpPower`) y hace que ande y se anime.
2. **`HumanoidRootPart`** → una pieza invisible en el centro. Es la que se mueve
   de verdad; las demás piezas van pegadas a ella.
3. **`Head`** → tiene que llamarse así, con esa mayúscula, o no se ve el nombre
   ni la barra de vida encima.
4. Las piezas del cuerpo unidas con **`Motor6D`** (son las "articulaciones").
   Sin Motor6D las piezas se separan y el muñeco se desmonta.

👉 **No hay que montar esto a mano.** Roblox tiene un botón que te lo hace.

## 🏗️ La forma fácil y correcta: Rig Builder

1. Pestaña **Avatar** → botón **Rig Builder**.
2. Elige el tipo:
   - **R6** → 6 piezas (el clásico, cuadradote). Más fácil para animar y para
     juegos de plataformas u obbys.
   - **R15** → 15 piezas (brazos y piernas con codo y rodilla). Se mueve mejor y
     es el estándar hoy.
3. Elige el aspecto (**Blocky**, **Man**, **Woman**) y pulsa.
4. Aparece un muñeco en el Workspace **ya válido**: tiene Humanoid,
   HumanoidRootPart, Head y todos los Motor6D bien puestos.

Ese muñeco puede ser: un **NPC** (personaje del juego) o el **personaje del
jugador**.

## 🙋 Personaje del JUGADOR (StarterCharacter)

Si quieres que todos los jugadores tengan un cuerpo concreto (no su avatar de
Roblox):

1. Haz un rig con el **Rig Builder** y decóralo como quieras.
2. Renómbralo **exactamente** `StarterCharacter`.
3. Arrástralo en el Explorer dentro de **StarterPlayer**.
4. **Game Settings → Avatar → Avatar Type** ponlo igual que el rig (**R6** o
   **R15**), para que no se peleen.

Desde ese momento, cada jugador aparece con ese cuerpo. Si un día quieres volver
al avatar normal de Roblox, borra `StarterCharacter` de StarterPlayer.

> Si **no** pones StarterCharacter, cada jugador entra con **su propio avatar** de
> Roblox (su ropa, su cara, sus accesorios). Para muchos juegos es lo mejor.

## 🤖 NPCs (personajes que no controla nadie)

1. Rig Builder → sale el muñeco en Workspace.
2. Renómbralo con su nombre (`Anciano`, `Herrero`, `Enemigo1`...).
3. Selecciona **todas sus piezas** y en Properties marca **`Anchored` ✅** si NO
   quieres que se mueva (un vendedor quieto), o déjalo **desmarcado** si va a
   andar.
4. En el `Humanoid`, en Properties, puedes tocar:
   - `DisplayName` → el nombre que sale encima.
   - `WalkSpeed` → 16 es lo normal, 8 lento, 30 corriendo.
   - `MaxHealth` / `Health` → vida.
   - `HealthDisplayType` → `AlwaysOff` si no quieres barra de vida.

## 👕 Ponerle ropa y aspecto

- **Color de piel:** dentro del Model, añade un **`BodyColors`** (➕ → BodyColors)
  y elige el color de cada parte. O pinta cada pieza con `Color` en Properties.
- **Camiseta y pantalón:** añade un **`Shirt`** y un **`Pants`** dentro del Model
  y en `ShirtTemplate` / `PantsTemplate` pon `rbxassetid://NÚMERO` de una ropa de
  la Marketplace (Creator Store).
- **Camiseta rápida (dibujo por delante):** un **`ShirtGraphic`**.
- **Accesorios (pelo, sombrero, espada en la espalda):** cógelos del **Toolbox**
  y arrástralos **dentro del Model** del personaje; se colocan solos porque
  llevan un `Attachment` que encaja con el del cuerpo.
- **Cara:** dentro de `Head` hay un `Decal` llamado `face`; cambia su `Texture`
  por otro id para cambiar la expresión.

## 🏃 Animaciones

- Los rigs ya andan y saltan solos (Roblox les pone las animaciones por defecto).
- Para inventarte una animación tuya: pestaña **Avatar → Animation Editor**,
  seleccionas el rig, mueves las piezas en la línea de tiempo, y **Export** →
  te da un **id** que luego usamos desde un script.
- Para cambiar las animaciones de andar/correr de TODO el juego:
  **Game Settings → Avatar → Animation**.

## ✅ Checklist antes de decir "mi personaje está listo"

- [ ] Es un **Model** (no una carpeta suelta de piezas).
- [ ] Tiene **Humanoid**.
- [ ] Tiene una pieza llamada **HumanoidRootPart**.
- [ ] Tiene una pieza llamada **Head**.
- [ ] Si lo hiciste con Rig Builder, todo lo anterior ya está ✅.
- [ ] El Model tiene puesto su **PrimaryPart** = `HumanoidRootPart`
      (Properties del Model). Hace falta para teletransportarlo desde scripts.
- [ ] Al pulsar ▶ Play, ni se cae a trozos ni se hunde en el suelo.

## ❌ Errores típicos

| Lo que ves                        | Qué suele ser                                        |
|-----------------------------------|------------------------------------------------------|
| El muñeco se desmonta al jugar    | Faltan los `Motor6D` (lo montaste a mano)            |
| No anda / se queda tieso          | No tiene `Humanoid`, o está todo `Anchored`          |
| Se hunde en el suelo              | Falta `HumanoidRootPart` o el suelo no es `CanCollide`|
| No sale el nombre encima          | La cabeza no se llama `Head`                          |
| El NPC "resbala" al empujarlo     | Marca `Anchored` en sus piezas si no debe moverse     |
