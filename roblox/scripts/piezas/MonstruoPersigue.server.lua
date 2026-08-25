--[[
	MonstruoPersigue        (script de SERVIDOR)
	----------------
	Este script SOLO decide DÓNDE está el monstruo y si te ha pillado.
	La animación de brazos y piernas la hace el LocalScript
	"MonstruoAnimacion", en StarterPlayerScripts.

	🎬 ¿Por qué separados? El servidor le manda los cambios a tu pantalla
	   unas 20 veces por segundo, pero tu pantalla dibuja 60. Si la animación
	   la hiciera el servidor verías tirones. Así va suave. 🧈

	Dónde va: ServerScriptService -> ➕ -> Script -> se llama MonstruoPersigue
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

--==================================================================
-- ⚙️ AJUSTES
--==================================================================
local VELOCIDAD = 11                -- studs por segundo. Tú corres a 16.
local DISTANCIA_VISION = 1000       -- enorme aposta: que te persiga siempre
local DISTANCIA_PILLAR = 8          -- a esta distancia se para y te mira
local ALTURA_RAIZ = 9               -- del suelo al centro del monstruo
local USAR_MAPA = true              -- false = línea recta atravesando paredes
local CHIVATO = true                -- que cuente en la Output lo que hace

task.wait(1.5)

local monstruo = workspace:WaitForChild("Monstruo", 20)
if not monstruo then
	warn("❌ No encuentro al Monstruo. ¿Está el script ConstruirMonstruo puesto?")
	return
end

local raiz = monstruo:WaitForChild("HumanoidRootPart")

if not raiz.Anchored then
	warn("⚠️ El HumanoidRootPart no está anclado. Lo anclo yo.")
	raiz.Anchored = true
end

-- Si el Humanoid se muere, Roblox rompe TODAS las articulaciones y el cuerpo
-- se queda atrás mientras la raíz invisible se mueve sola.
local humanoide = monstruo:FindFirstChildOfClass("Humanoid")
if humanoide then
	pcall(function() humanoide.BreakJointsOnDeath = false end)
	pcall(function() humanoide.RequiresNeck = false end)
	pcall(function() humanoide.MaxHealth = math.huge end)
	pcall(function() humanoide.Health = math.huge end)
	pcall(function() humanoide.EvaluateStateMachine = false end)
	pcall(function() humanoide:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
end

-- ✅ ¿Está el cuerpo bien enganchado a la raíz?
task.wait(0.2)
local sueltas = 0
for _, cosa in ipairs(monstruo:GetChildren()) do
	if cosa:IsA("BasePart") and cosa ~= raiz and cosa.AssemblyRootPart ~= raiz then
		sueltas += 1
	end
end

if sueltas > 0 then
	warn("⚠️ ¡" .. sueltas .. " piezas sueltas! El cuerpo NO seguirá a la raíz al moverse.")
else
	print("✅ Cuerpo bien enganchado: se moverá entero.")
end

--==================================================================
-- 🎯 A quién persigue
--==================================================================
local function jugadorMasCerca()
	local mejor, mejorDistancia

	for _, jugador in ipairs(Players:GetPlayers()) do
		local personaje = jugador.Character
		local cuerpo = personaje and personaje:FindFirstChild("HumanoidRootPart")
		local hum = personaje and personaje:FindFirstChildOfClass("Humanoid")

		if cuerpo and hum and hum.Health > 0 then
			local d = (cuerpo.Position - raiz.Position).Magnitude
			if not mejorDistancia or d < mejorDistancia then
				mejor, mejorDistancia = cuerpo, d
			end
		end
	end

	return mejor, mejorDistancia
end

--==================================================================
-- 🦶 Que pise el suelo siempre (rayo hacia abajo)
--==================================================================
local rayo = RaycastParams.new()
rayo.FilterType = Enum.RaycastFilterType.Exclude
rayo.FilterDescendantsInstances = { monstruo }

local function refrescarFiltro()
	local fuera = { monstruo }
	for _, jugador in ipairs(Players:GetPlayers()) do
		if jugador.Character then
			table.insert(fuera, jugador.Character)
		end
	end
	rayo.FilterDescendantsInstances = fuera
end

local function alturaDelSuelo(x, z, yAhora)
	local golpe = workspace:Raycast(Vector3.new(x, yAhora + 12, z), Vector3.new(0, -300, 0), rayo)
	return golpe and golpe.Position.Y or nil
end

--==================================================================
-- 🗺️ El camino
--==================================================================
local puntos = {}
local siguiente = 1
local estadoMapa = "sin empezar"

local camino = PathfindingService:CreatePath({
	AgentRadius = 2,
	AgentHeight = 6,
	AgentCanJump = false,
	WaypointSpacing = 6,
})

task.spawn(function()
	while monstruo.Parent do
		task.wait(0.6)
		refrescarFiltro()

		local objetivo, distancia = jugadorMasCerca()

		if not objetivo or distancia > DISTANCIA_VISION then
			puntos = {}
			estadoMapa = "no te veo"

		elseif not USAR_MAPA then
			puntos = { objetivo.Position }
			siguiente = 1
			estadoMapa = "linea recta"

		else
			local desde = raiz.Position - Vector3.new(0, ALTURA_RAIZ, 0)
			local hasta = objetivo.Position - Vector3.new(0, 2.5, 0)

			local salioBien = pcall(function()
				camino:ComputeAsync(desde, hasta)
			end)

			if salioBien and camino.Status == Enum.PathStatus.Success then
				puntos = {}
				for _, w in ipairs(camino:GetWaypoints()) do
					table.insert(puntos, w.Position)
				end
				siguiente = 2
				estadoMapa = "camino de " .. #puntos .. " puntos"
			else
				puntos = { hasta }
				siguiente = 1
				estadoMapa = "SIN RUTA -> linea recta"
			end
		end
	end
end)

--==================================================================
-- 🏃 MOVERSE
--==================================================================
local andando = false
local ultimoAviso = 0

-- El "cartelito" que lee tu pantalla para saber si mover las piernas
local function avisarSiAnda(valor)
	if andando ~= valor then
		andando = valor
		monstruo:SetAttribute("Andando", valor)
	end
end

monstruo:SetAttribute("Andando", false)

RunService.Heartbeat:Connect(function(dt)
	local objetivo, distancia = jugadorMasCerca()

	-- ¿Te ha pillado?
	if objetivo and distancia and distancia < DISTANCIA_PILLAR then
		avisarSiAnda(false)

		local haciaTi = (objetivo.Position - raiz.Position) * Vector3.new(1, 0, 1)
		if haciaTi.Magnitude > 0.1 then
			raiz.CFrame = CFrame.lookAt(raiz.Position, raiz.Position + haciaTi.Unit)
		end

		if os.clock() - ultimoAviso > 3 then
			ultimoAviso = os.clock()
			print("👹 ¡TE HA PILLADO!")
			-- 👉 Aquí irá el final de la partida
		end
		return
	end

	-- ¿No hay camino o se han acabado los puntos? Pues a por ti en recto.
	local destino = puntos[siguiente]
	if not destino and objetivo then
		destino = objetivo.Position - Vector3.new(0, 2.5, 0)
	end

	if not destino then
		avisarSiAnda(false)
		return
	end

	local desde = raiz.Position
	local plano = Vector3.new(destino.X - desde.X, 0, destino.Z - desde.Z)

	if plano.Magnitude < 4 then
		siguiente += 1              -- punto alcanzado, al siguiente
		return
	end

	avisarSiAnda(true)

	local direccion = plano.Unit
	local avance = math.min(VELOCIDAD * dt, plano.Magnitude)
	local x = desde.X + direccion.X * avance
	local z = desde.Z + direccion.Z * avance

	-- La altura la decide el SUELO que haya debajo
	local suelo = alturaDelSuelo(x, z, desde.Y)
	local y = desde.Y

	if suelo then
		local quiero = suelo + ALTURA_RAIZ
		y = desde.Y + (quiero - desde.Y) * math.min(1, dt * 6)
	end

	local sitio = Vector3.new(x, y, z)
	raiz.CFrame = CFrame.lookAt(sitio, sitio + direccion)
end)

--==================================================================
-- 🔎 EL CHIVATO
--==================================================================
if CHIVATO then
	task.spawn(function()
		while monstruo.Parent do
			task.wait(1)

			local objetivo, distancia = jugadorMasCerca()
			local p = raiz.Position

			print(string.format(
				"👹 %s | dist: %s | mapa: %s | punto %d/%d | andando: %s | está en %.0f, %.0f, %.0f",
				objetivo and "te veo" or "NO HAY JUGADOR",
				distancia and string.format("%.0f", distancia) or "-",
				estadoMapa,
				siguiente, #puntos,
				tostring(andando),
				p.X, p.Y, p.Z
			))
		end
	end)
end

print("👹 Persecución activada (la animación la hace MonstruoAnimacion).")
