--[[
	Opciones
	--------
	Pone los carteles de [E] en los muebles del cuarto:
	  🛏️ Cama   -> "Dormir"
	  🚪 Puerta -> "Salir"   (hay que MANTENER la E pulsada 1 segundo)
	  🪑 Silla  -> "Vigilar" (la tercera opción, por si la quieres ya)

	De momento solo escriben en la Output lo que has elegido. En el siguiente
	paso les pondremos las consecuencias de verdad (hambre, sueño, estrés...).

	Dónde va: Explorer -> ServerScriptService -> ➕ -> Script
	Nómbralo: Opciones
]]

-- Esperamos a que ConstruirCuarto haya terminado de montar el cuarto.
-- WaitForChild = "espera a que exista esto antes de seguir".
local cuarto = workspace:WaitForChild("Cuarto")

--[[
	Función de ayuda: le pone un cartel de [E] a un mueble.
	  pieza        = el mueble (la Part)
	  textoAccion  = lo que se lee grande ("Dormir")
	  textoObjeto  = lo que se lee pequeño encima ("Cama")
	  segundos     = cuánto hay que mantener la E pulsada (0 = un toque)
	  alElegir     = la función que se ejecuta cuando pulsas
]]
local function crearOpcion(pieza, textoAccion, textoObjeto, segundos, alElegir)
	local cartel = Instance.new("ProximityPrompt")
	cartel.Name = "Opcion" .. textoAccion
	cartel.ActionText = textoAccion              -- "Dormir"
	cartel.ObjectText = textoObjeto              -- "Cama"
	cartel.KeyboardKeyCode = Enum.KeyCode.E      -- la tecla E
	cartel.HoldDuration = segundos               -- mantener pulsado
	cartel.MaxActivationDistance = 9             -- a qué distancia aparece
	cartel.RequiresLineOfSight = false           -- que salga aunque haya algo delante
	cartel.Parent = pieza

	-- Triggered = "se ha activado". jugador es quien lo ha pulsado.
	cartel.Triggered:Connect(function(jugador)
		alElegir(jugador)
	end)

	return cartel
end

--------------------------------------------------------------------
-- 🛏️ DORMIR
--------------------------------------------------------------------
local cama = cuarto:WaitForChild("Cama")

crearOpcion(cama, "Dormir", "Cama", 0, function(jugador)
	print("🛏️ " .. jugador.Name .. " se ha ido a dormir...")
	print("   (aquí vendrán las pesadillas y el monstruo acercándose)")
end)

--------------------------------------------------------------------
-- 🚪 SALIR (mantener la E pulsada 1 segundo: da más tensión)
--------------------------------------------------------------------
local puerta = cuarto:WaitForChild("Puerta")

crearOpcion(puerta, "Salir", "Puerta", 1, function(jugador)
	print("🚪 " .. jugador.Name .. " abre la puerta muy despacio...")
	print("   (aquí saldrá al pasillo a por comida, y el monstruo le perseguirá)")
end)

--------------------------------------------------------------------
-- 🪑 VIGILAR (la tercera opción. Si no la quieres todavía, borra este trozo)
--------------------------------------------------------------------
local silla = cuarto:WaitForChild("Silla")

crearOpcion(silla, "Vigilar", "Silla", 0, function(jugador)
	print("👁️ " .. jugador.Name .. " se sienta a vigilar la puerta.")
	print("   (aquí subirá el estrés, pero el monstruo se alejará)")
end)

print("✅ Opciones listas: acércate a la cama, a la puerta o a la silla.")
