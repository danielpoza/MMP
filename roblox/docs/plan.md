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

## Fase 2 — La idea ✅
- [x] Miguel cuenta de qué va el juego → `docs/IDEA-DEL-JUEGO.md`
- [x] Diseño del juego "La Noche" → `docs/DISENO-LA-NOCHE.md`

## Fase 3 — El cuarto y la noche  ← ESTAMOS AQUÍ
- [ ] Pegar `NocheOscura.server.lua` (todo oscuro, niebla, medianoche)
- [ ] Pegar `ConstruirCuarto.server.lua` (paredes, cama, puerta, silla, ventana)
- [ ] Comprobar que apareces DENTRO del cuarto y que no puedes salir

## Fase 4 — Las 3 opciones
- [ ] Tecla **E** en la Cama, la Puerta y la Silla (ProximityPrompt)
- [ ] De momento que solo escriban en la Output qué has elegido

## Fase 5 — Las barras y el reloj
- [ ] Hambre, Sueño y Estrés (suben cada hora)
- [ ] Reloj de la noche: 00:00 → 06:00, y ganar al amanecer
- [ ] Verlas en pantalla (StarterGui)

## Fase 6 — El pasillo y la cocina
- [ ] Construir pasillo oscuro + cocina con la nevera
- [ ] Salir del cuarto, comer y volver

## Fase 7 — El monstruo
- [ ] Personaje del monstruo (Rig Builder, alto y oscuro)
- [ ] Que ronde el pasillo y te persiga si sales
- [ ] Si te pilla → pierdes

## Fase 8 — Dormir y las pesadillas
- [ ] Pantalla a negro al dormir
- [ ] Trocito de pesadilla
- [ ] Mientras duermes, el monstruo se acerca

## Fase 9 — Sonido y miedo
- [ ] Pasos en el pasillo, golpes en la puerta, latidos del corazón
- [ ] La pantalla tiembla cuando el estrés es alto

## Fase 10 — Publicar
- [ ] Icono y descripción del juego
- [ ] File → Publish to Roblox y ponerlo en Public
