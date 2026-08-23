# 🟩 Juego de Roblox de Miguel

Proyecto **nuevo e independiente** del juego web "Crónicas de Miguel".
Aquí guardamos todo lo del juego hecho con **Roblox Studio** (lenguaje **Luau**).

## 📂 Qué hay dentro

```
roblox/
├── README.md                  ← este archivo
├── docs/
│   ├── 01-preparar-studio.md      ← instalar y preparar Roblox Studio
│   ├── 02-como-copiar-scripts.md  ← cómo pegar los scripts que te doy
│   ├── 03-personajes.md           ← personajes válidos en Roblox (jugador y NPC)
│   ├── IDEA-DEL-JUEGO.md          ← lo que Miguel quiere que sea el juego
│   └── plan.md                    ← plan por pasos (se va marcando)
└── scripts/
    ├── ServerScriptService/       ← scripts del SERVIDOR (.server.lua)
    ├── StarterPlayer/
    │   └── StarterPlayerScripts/  ← scripts del JUGADOR (.client.lua)
    └── ReplicatedStorage/         ← módulos compartidos (.lua)
```

**Regla importante:** la carpeta `scripts/` es un **espejo del Explorer de Roblox
Studio**. Un archivo que está en `scripts/ServerScriptService/` va, dentro de
Studio, en `ServerScriptService`. Así nunca hay dudas de dónde pegar cada cosa.

## 🏷️ Cómo se llaman los archivos

| Termina en      | En Studio es      | Dónde se ejecuta            |
|-----------------|-------------------|-----------------------------|
| `.server.lua`   | `Script`          | En el servidor (todos lo ven) |
| `.client.lua`   | `LocalScript`     | En el ordenador del jugador |
| `.lua`          | `ModuleScript`    | Código que otros scripts reutilizan |

## 🎮 Cómo trabajamos

1. **Miguel cuenta** qué quiere que pase en el juego.
2. **Claude explica** con palabras normales qué va a hacer el script.
3. **Claude escribe el script** aquí en el repo y lo enseña para copiar.
4. **Miguel lo pega** en Roblox Studio (mira `docs/02-como-copiar-scripts.md`).
5. **Miguel prueba** con el botón ▶ Play y cuenta qué ha pasado.
6. Si algo falla, Miguel copia el texto **rojo** de la ventana **Output**.

Pasos pequeños, probando siempre antes de seguir. 🚀
