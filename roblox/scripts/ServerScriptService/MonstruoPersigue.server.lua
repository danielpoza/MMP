--[[
	MonstruoPersigue
	----------------
	El monstruo anda a 2 pisadas por segundo y te persigue.

	🔧 SI ALGO NO VA: pon CHIVATO = true (viene así) y mira la Output.
	   Te va diciendo cada segundo si te ve, a qué distancia estás y si se
	   está moviendo. Con eso sabemos exactamente qué falla.

	⚠️ En ConstruirMonstruo tienen que estar BORRADOS los dos bloques del
	   final (el de la animación y el de la telequinesia). Si no, los dos
	   scripts se pelean por mover las mismas articulaciones.

	Dónde va: ServerScriptService -> ➕ -> Script -> se llama MonstruoPersigue
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

--==================================================================
-- ⚙️ AJUSTES (aquí es donde tienes que trastear hasta que te guste)
--==================================================================
local VELOCIDAD = 11                -- studs por segundo. Tú corres a 16.
local PISADAS_POR_SEGUNDO = 2
local DISTANCIA_VISION = 1000       -- enorme aposta: que te persiga siempre
local DISTANCIA_PILLAR = 8          -- a esta distancia se para y te mira
local ALTURA_RAIZ = 9               -- del suelo al centro del monstruo
local USAR_MAPA = true              -- false = va en línea recta, atravesando paredes
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

-- Que el Humanoid no intente andar por su cuenta y nos estorbe
local humanoide = monstruo:FindFirstChildOfClass("Humanoid")
if humanoide then
	-- Si el Humanoid se muere, Roblox rompe TODAS las articulaciones y el
	-- cuerpo se queda atrás mientras la raíz invisible se mueve sola.
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
	warn("   Vuelve a pegar ConstruirMonstruo entero y dale a Play otra vez.")
else
	print("✅ Cuerpo bien enganchado: se moverá entero.")
end

--==================================================================
-- 🔗 La postura de reposo de cada articulación
--==================================================================
local juntas = {}
local cuantasJuntas = 0

for _, cosa in ipairs(monstruo:GetDescendants()) do
	if cosa:IsA("Motor6D") then
		juntas[cosa.Name] = { junta = cosa, reposo = cosa.C0 }
		cuantasJuntas += 1
	end
end

print("🦴 Articulaciones encontradas: " .. cuantasJuntas)

local function girar(x, y, z)
	return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end

local function postura(nombre, cframe)
	local j = juntas[nombre]
	if j then j.junta.C0 = j.reposo * cframe end
end

--==================================================================
-- 🚶 EL ANDAR (2 pisadas por segundo)
--==================================================================
local fase = 0
local andando = false
local tropiezo = 0
local craneoFuera = 0

RunService.Heartbeat:Connect(function(dt)
	if andando then
		fase += dt * PISADAS_POR_SEGUNDO * math.pi     -- media vuelta = una pisada
	end

	local izq = math.sin(fase)
	local der = math.sin(fase + math.pi)               -- la otra pierna, al revés

	postura("CaderaIzquierda", girar(-32 * izq, 0, 0))
	postura("CaderaDerecha", girar(-32 * der, 0, 0))
	postura("RodillaIzquierda", girar(42 * math.max(0, izq), 0, 0))
	postura("RodillaDerecha", girar(42 * math.max(0, der), 0, 0))
	postura("TobilloIzquierdo", girar(-14 * izq, 0, 0))
	postura("TobilloDerecho", girar(-14 * der, 0, 0))

	postura("HombroDerecho", girar(-12 + 22 * izq, 0, 30))
	postura("HombroIzquierdo", girar(-12 + 22 * der, 0, -30))
	postura("CodoDerecho", girar(-50 - 12 * der, 0, 0))
	postura("CodoIzquierdo", girar(-50 - 12 * izq, 0, 0))

	postura("RootJoint", girar(2 * math.abs(izq), 0, 7 * izq + tropiezo))
	postura("JuntaCraneo", CFrame.new(0, craneoFuera, 0) * girar(-6 * craneoFuera, 10 * craneoFuera, 0))
end)

task.spawn(function()
	while monstruo.Parent do
		task.wait(math.random(35, 90) / 10)
		if andando then
			tropiezo = math.random(-9, 9)
			task.wait(0.3)
			tropiezo = 0
		end
	end
end)

task.spawn(function()
	while monstruo.Parent do
		task.wait(math.random(40, 90) / 10)

		local altura = 1.4 + math.random() * 1.6
		for i = 1, 22 do
			craneoFuera = altura * (i / 22)
			task.wait(0.03)
		end

		task.wait(0.7)
		craneoFuera = 0            -- CLAC 💀
	end
end)

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
-- 🦶 QUE PISE EL SUELO SIEMPRE
--    Tiramos un rayo hacia abajo para saber dónde está el suelo justo
--    debajo de él. Así sube escaleras y no se hunde ni flota. 📏
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
-- 🗺️ EL CAMINO
--==================================================================
local puntos = {}
local siguiente = 1
local estadoMapa = "sin empezar"

local camino = PathfindingService:CreatePath({
	AgentRadius = 2,          -- ⬅️ antes 4: no cabía por la puerta de tu cuarto
	AgentHeight = 6,          -- ⬅️ antes 12: la puerta mide 8 de alto, no cabía
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
				-- Sin ruta (puertas estrechas, escaleras raras): a por ti en recto
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
local ultimoAviso = 0

RunService.Heartbeat:Connect(function(dt)
	local objetivo, distancia = jugadorMasCerca()

	-- ¿Te ha pillado?
	if objetivo and distancia and distancia < DISTANCIA_PILLAR then
		andando = false

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

	-- ¿No hay camino, o se han acabado los puntos? Pues a por ti en recto.
	local destino = puntos[siguiente]
	if not destino and objetivo then
		destino = objetivo.Position - Vector3.new(0, 2.5, 0)
	end

	if not destino then
		andando = false
		return
	end

	local desde = raiz.Position
	local plano = Vector3.new(destino.X - desde.X, 0, destino.Z - desde.Z)

	if plano.Magnitude < 4 then
		siguiente += 1              -- punto alcanzado, al siguiente
		return
	end

	andando = true

	local direccion = plano.Unit
	local avance = math.min(VELOCIDAD * dt, plano.Magnitude)
	local x = desde.X + direccion.X * avance
	local z = desde.Z + direccion.Z * avance

	-- La altura la decide el SUELO que haya debajo, no el camino
	local suelo = alturaDelSuelo(x, z, desde.Y)
	local y = desde.Y

	if suelo then
		local quiero = suelo + ALTURA_RAIZ
		y = desde.Y + (quiero - desde.Y) * math.min(1, dt * 6)   -- sube suave
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

print("👹 Persecución activada. Velocidad " .. VELOCIDAD .. ", " .. PISADAS_POR_SEGUNDO .. " pisadas/segundo.")
