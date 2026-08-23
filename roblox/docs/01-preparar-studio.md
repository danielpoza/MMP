# 1️⃣ Preparar Roblox Studio

## Instalar

1. Entra en **https://create.roblox.com** e inicia sesión con la cuenta de Roblox.
2. Pulsa **Start Creating** / **Download Studio** y ejecuta el instalador.
3. Abre **Roblox Studio** e inicia sesión con la misma cuenta.

## Crear el sitio (place) del juego

1. En Studio: **New** → plantilla **Baseplate** (un suelo gris vacío, es la mejor
   para empezar desde cero).
2. **File → Save to Roblox As...** y le pones nombre al juego.
   Así se guarda en la nube y no se pierde.
   (Con **File → Save to File** también puedes guardar un `.rbxl` en el ordenador
   como copia de seguridad.)

## Las 4 ventanas que hay que tener abiertas

En la pestaña **View** (arriba) enciende estas:

| Ventana        | Para qué sirve                                                  |
|----------------|-----------------------------------------------------------------|
| **Explorer**   | El árbol del juego: Workspace, Players, ServerScriptService...  |
| **Properties** | Las propiedades de lo que seleccionas (color, tamaño, nombre)   |
| **Output**     | Donde salen los mensajes de `print` y los **errores en rojo**   |
| **Toolbox**    | Modelos e imágenes gratis hechos por otra gente                 |

👉 La **Output** es la más importante: si algo no funciona, ahí está la pista.

## Qué es cada cosa del Explorer (las que usaremos)

- **Workspace** → todo lo que se ve y se toca en el mundo (suelo, casas, NPCs).
- **Players** → los jugadores conectados.
- **ServerScriptService** → scripts del servidor. Manda el servidor: aquí va la
  lógica importante (vida, dinero, enemigos) porque nadie puede hacer trampas.
- **ReplicatedStorage** → cosas compartidas entre servidor y jugadores
  (módulos, RemoteEvents, plantillas de objetos).
- **StarterPlayer → StarterPlayerScripts** → scripts que se copian a cada jugador
  al entrar (cámara, controles, efectos).
- **StarterGui** → la interfaz: botones, textos, barras de vida.
- **Lighting** → luz, hora del día, niebla.

## Cómo probar el juego

- **▶ Play** → juegas con tu personaje desde el punto de aparición.
- **Play Here** → apareces justo donde está la cámara (para probar una zona lejana).
- **Run** → el mundo funciona pero tú no apareces (para ver cómo se mueven los NPCs).
- **⏹ Stop** → parar. ⚠️ **Todo lo que muevas o crees mientras juegas NO se guarda.**

## Antes de escribir código

Prueba a mover el mundo:
- **Botón derecho + WASD** = volar con la cámara. Rueda = zoom.
- Pestaña **Model → Part** para crear un bloque.
- Con el bloque seleccionado, en **Properties**: cambia `Size`, `Color`,
  `Material` y marca `Anchored` ✅ (para que no se caiga).

Cuando esto lo tengas dominado, pasamos a los scripts.
