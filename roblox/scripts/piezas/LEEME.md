# 🧩 Las piezas sueltas (ya NO se pegan en Studio)

Estos son los scripts originales, uno por tema. Están aquí porque son más
fáciles de leer y de retocar de uno en uno.

**Pero en Roblox Studio ya no se pegan.** Todos juntos forman los dos únicos
scripts del juego:

- `../ServerScriptService/LaNoche.server.lua` ← las 8 piezas del servidor
- `../StarterPlayer/StarterPlayerScripts/LaNocheCliente.client.lua` ← las 2 de pantalla

¿Por qué? Porque Roblox no arranca los scripts siempre en el mismo orden, y
como varios montaban y desmontaban la casa, en cada partida ganaba uno
distinto y la casa cambiaba sola. Juntos se ejecutan en orden, siempre igual.
