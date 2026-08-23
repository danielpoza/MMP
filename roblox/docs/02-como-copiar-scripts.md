# 2️⃣ Cómo copiar los scripts que te paso

Yo te doy el código ya escrito. Tú solo tienes que **crear el script en el sitio
correcto** y **pegar** dentro.

## Paso a paso (30 segundos)

1. En **Explorer**, busca la carpeta que yo te diga (por ejemplo
   `ServerScriptService`).
2. Pon el ratón encima y pulsa el **➕** que aparece a la derecha del nombre.
3. Elige el tipo de script:
   - **Script** → si te digo "script de servidor" (archivos `.server.lua`)
   - **LocalScript** → si te digo "script del jugador" (archivos `.client.lua`)
   - **ModuleScript** → si te digo "módulo" (archivos `.lua`)
4. Se abre una ventana de código con algo escrito ya. Haz clic dentro,
   **Ctrl + A** (seleccionar todo) y **Supr** (borrar).
5. **Ctrl + V** para pegar mi código.
6. **Renombra el script**: doble clic en su nombre en el Explorer y pon el nombre
   que yo te diga (sin el `.server.lua`, eso es solo del repo).
7. **Ctrl + S** para guardar y **▶ Play** para probar.

## Trucos de la ventana de código

| Atajo         | Qué hace                    |
|---------------|-----------------------------|
| `Ctrl + A`    | Seleccionar todo            |
| `Ctrl + V`    | Pegar                       |
| `Ctrl + Z`    | Deshacer                    |
| `Ctrl + S`    | Guardar                     |
| `Ctrl + F`    | Buscar dentro del script    |

## Si sale algo en rojo en la Output

No pasa nada, es normal. Cópiame **la línea roja entera** y te digo qué arreglar.
Los errores rojos suelen decir el **nombre del script** y el **número de línea**.

## Comandos sueltos (Command Bar)

A veces te pasaré un **comando de una sola línea** para hacer algo rápido
(por ejemplo crear 20 árboles de golpe). Eso NO va en un script:

1. **View → Command Bar** (aparece una barrita abajo).
2. Pegas el comando y pulsas **Enter**. Se ejecuta una vez y ya está.

⚠️ Los comandos de la Command Bar cambian el mundo **de verdad** (se guardan),
mientras que lo que haces en modo ▶ Play se borra al pulsar ⏹ Stop.

## Ojo con el Toolbox

Los modelos gratis del **Toolbox** están muy bien para decorar (árboles, casas,
coches), **pero** algunos llevan scripts escondidos que rompen el juego o hacen
cosas raras. Regla: cuando metas un modelo del Toolbox, ábrelo en el Explorer
(flechita ▶) y **borra cualquier Script/LocalScript que traiga dentro** si no
sabes qué hace.
