# 🗺️ Plan del juego de Roblox

Se avanza **de arriba abajo**, un paso cada vez, probando siempre antes de
seguir. Marca ✅ lo que ya esté hecho.

## Fase 0 — Preparativos
- [ ] Instalar Roblox Studio y entrar con la cuenta (`docs/01-preparar-studio.md`)
- [ ] Crear el place con la plantilla **Baseplate** y guardarlo (Save to Roblox)
- [ ] Abrir Explorer, Properties, Output y Toolbox
- [ ] Trastear: crear un Part, cambiarle color/tamaño, marcarlo Anchored

## Fase 1 — Que funcionen los scripts
- [ ] Pegar `scripts/ServerScriptService/PruebaDeConexion.server.lua`
- [ ] Ver el mensaje en la Output y el cubo girando ✅ (¡ya sabemos programar!)

## Fase 2 — La idea
- [ ] Miguel cuenta de qué va el juego → se apunta en `docs/IDEA-DEL-JUEGO.md`
- [ ] Elegir el **primer trocito jugable** (la cosa más pequeña que ya sea divertida)

## Fase 3 — El personaje
- [ ] Decidir: ¿avatar normal de Roblox o cuerpo propio (`StarterCharacter`)?
- [ ] Crear el rig con **Rig Builder** (`docs/03-personajes.md`)
- [ ] Vestirlo (BodyColors, Shirt, Pants, accesorios)
- [ ] Pasar el checklist de personaje válido

## Fase 4 — El mapa
- [ ] Zona de aparición (spawn) y suelo
- [ ] Bloquear que el jugador se caiga al vacío
- [ ] Decorar con Parts y modelos del Toolbox (¡borrando sus scripts!)
- [ ] Luz y ambiente (Lighting)

## Fase 5 — La mecánica principal
- [ ] Lo que el jugador hace todo el rato (saltar / recoger / pegar / construir)
- [ ] Que se note cuando lo hace bien (sonido, efecto, puntos)

## Fase 6 — Puntos e interfaz
- [ ] `leaderstats` (la tabla de puntuación de la esquina)
- [ ] Textos y botones en pantalla (StarterGui)

## Fase 7 — NPCs y enemigos
- [ ] NPC que habla
- [ ] Enemigo que persigue y quita vida

## Fase 8 — Guardar la partida
- [ ] DataStores para que no se pierdan los puntos al salir

## Fase 9 — Publicar
- [ ] Icono y descripción del juego
- [ ] File → Publish to Roblox
- [ ] Ponerlo en **Public** y probarlo desde la app de Roblox
