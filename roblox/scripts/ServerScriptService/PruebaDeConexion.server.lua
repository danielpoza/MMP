--[[
	PruebaDeConexion
	----------------
	Este es el "hola mundo" del juego. Sirve para comprobar dos cosas:
	  1) Que sabes crear un Script y pegarlo en el sitio correcto.
	  2) Que un script puede crear cosas en el mundo y saludar a los jugadores.

	Dónde va: Explorer -> ServerScriptService -> ➕ -> Script
	Nómbralo: PruebaDeConexion

	Qué verás al pulsar ▶ Play:
	  - Un mensaje en la ventana Output.
	  - Un cubo amarillo brillante girando en el aire, encima del suelo.
	  - Tu nombre saldrá en la Output cuando entres a la partida.
]]

-- Los "Services" son las piezas grandes de Roblox. Se piden así:
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 1) Mensaje en la Output para saber que el script funciona
print("✅ El juego de Miguel ha arrancado. ¡Vamos allá!")

-- 2) Creamos un cubo desde código (esto es lo que haremos con TODO el juego)
local cubo = Instance.new("Part")         -- crear una pieza nueva
cubo.Name = "CuboDePrueba"                -- su nombre en el Explorer
cubo.Size = Vector3.new(4, 4, 4)          -- ancho, alto, largo (en "studs")
cubo.Position = Vector3.new(0, 10, 0)     -- x, y(altura), z
cubo.Color = Color3.fromRGB(255, 200, 0)  -- amarillo
cubo.Material = Enum.Material.Neon        -- que brille
cubo.Anchored = true                      -- true = flota, no se cae
cubo.CanCollide = false                   -- false = se puede atravesar
cubo.Parent = workspace                   -- ¡importante! sin esto no aparece

-- 3) Que gire: Heartbeat se ejecuta ~60 veces por segundo.
--    "delta" son los segundos que han pasado desde la vez anterior.
RunService.Heartbeat:Connect(function(delta)
	cubo.CFrame = cubo.CFrame * CFrame.Angles(0, math.rad(90 * delta), 0)
end)

-- 4) Saludar a cada jugador que entre
Players.PlayerAdded:Connect(function(jugador)
	print("👋 Ha entrado: " .. jugador.Name)

	-- CharacterAdded salta cada vez que le nace un cuerpo (al entrar y al revivir)
	jugador.CharacterAdded:Connect(function(personaje)
		-- WaitForChild espera a que la pieza exista antes de tocarla
		local humanoide = personaje:WaitForChild("Humanoid")
		print("   Su personaje tiene " .. humanoide.Health .. " de vida.")
	end)
end)
