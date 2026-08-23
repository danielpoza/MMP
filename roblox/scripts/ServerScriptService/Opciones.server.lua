--[[
	Opciones
	--------
	Los carteles de [E] del juego:
	  🛏️ Cama       -> "Dormir"
	  🚪 Puerta     -> "Salir"   -> TE TELETRANSPORTA AL PASILLO
	  🪑 Silla      -> "Vigilar"
	  🚪 (desde el pasillo) -> "Entrar" -> te devuelve al cuarto

	Dónde va: Explorer -> ServerScriptService -> ➕ -> Script
	Nómbralo: Opciones   (si ya lo tienes, borra lo de dentro y pega esto)
]]

local Players = game:GetService("Players")

-- Esperamos a que estén construidos el cuarto y el pasillo
local cuarto = workspace:WaitForChild("Cuarto")
local pasillo = workspace:WaitForChild("Pasillo")

-- 📍 LOS DOS SITIOS DEL TELETRANSPORTE
-- CFrame.lookAt(dónde apareces, hacia dónde miras)
local SITIO_PASILLO = CFrame.lookAt(Vector3.new(0, 4, 17), Vector3.new(0, 4, 30))
local SITIO_CUARTO  = CFrame.lookAt(Vector3.new(0, 4, 7),  Vector3.new(0, 4, -5))

--------------------------------------------------------------------
-- 🚀 La función del teletransporte
--------------------------------------------------------------------
local function teletransportar(jugador, destino)
	local personaje = jugador.Character
	if not personaje then
		return false          -- todavía no tiene cuerpo
	end

	local humanoide = personaje:FindFirstChildOfClass("Humanoid")
	if not humanoide or humanoide.Health <= 0 then
		return false          -- está muerto, no lo movemos
	end

	-- PivotTo mueve el personaje ENTERO de golpe a otro sitio
	personaje:PivotTo(destino)
	return true
end

--------------------------------------------------------------------
-- Función de ayuda para crear los carteles de [E]
--------------------------------------------------------------------
local function crearOpcion(pieza, textoAccion, textoObjeto, segundos, alElegir)
	local cartel = Instance.new("ProximityPrompt")
	cartel.Name = "Opcion" .. textoAccion
	cartel.ActionText = textoAccion
	cartel.ObjectText = textoObjeto
	cartel.KeyboardKeyCode = Enum.KeyCode.E
	cartel.HoldDuration = segundos
	cartel.MaxActivationDistance = 9
	cartel.RequiresLineOfSight = false
	cartel.Parent = pieza

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
	print("   (aquí vendrán las pesadillas)")
end)

--------------------------------------------------------------------
-- 🪑 VIGILAR
--------------------------------------------------------------------
local silla = cuarto:WaitForChild("Silla")

crearOpcion(silla, "Vigilar", "Silla", 0, function(jugador)
	print("👁️ " .. jugador.Name .. " se sienta a vigilar la puerta.")
	print("   (aquí subirá el estrés, pero el monstruo se alejará)")
end)

--------------------------------------------------------------------
-- 🚪 SALIR y ENTRAR (el teletransporte)
--------------------------------------------------------------------
local puerta = cuarto:WaitForChild("Puerta")
local puertaFuera = pasillo:WaitForChild("PuertaFuera")

-- Los declaramos antes para poder encenderlos y apagarlos el uno al otro
local cartelSalir, cartelEntrar

cartelSalir = crearOpcion(puerta, "Salir", "Puerta", 1, function(jugador)
	if not teletransportar(jugador, SITIO_PASILLO) then
		return
	end

	print("🚪 " .. jugador.Name .. " ha salido al pasillo. Está muy oscuro...")

	-- Apagamos el cartel de Salir y encendemos el de Entrar
	cartelSalir.Enabled = false
	cartelEntrar.Enabled = true
end)

cartelEntrar = crearOpcion(puertaFuera, "Entrar", "Puerta", 1, function(jugador)
	if not teletransportar(jugador, SITIO_CUARTO) then
		return
	end

	print("🚪 " .. jugador.Name .. " vuelve al cuarto y cierra la puerta. Uf. 😮‍💨")

	cartelEntrar.Enabled = false
	cartelSalir.Enabled = true
end)

-- Al empezar la partida estás DENTRO del cuarto
cartelEntrar.Enabled = false

--------------------------------------------------------------------
-- Si te mueres o reapareces, vuelves a estar dentro del cuarto
--------------------------------------------------------------------
Players.PlayerAdded:Connect(function(jugador)
	jugador.CharacterAdded:Connect(function()
		cartelSalir.Enabled = true
		cartelEntrar.Enabled = false
	end)
end)

print("✅ Opciones listas. La puerta ya teletransporta al pasillo.")
