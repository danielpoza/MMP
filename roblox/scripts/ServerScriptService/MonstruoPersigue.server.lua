--[[
	MonstruoPersigue
	----------------
	Hace que el monstruo ANDE a 2 pisadas por segundo y TE PERSIGA por la casa.

	🧠 Cómo te persigue sin atravesar paredes:
	   usa el PathfindingService de Roblox. Es como el Google Maps del juego:
	   le dices "estoy aquí y quiero llegar allí" y te devuelve una lista de
	   puntos por los que pasar rodeando los obstáculos. El monstruo va
	   caminando de punto en punto. Se recalcula cada poco, porque tú te mueves. 🏃

	⚠️ ANTES DE PEGAR ESTE: en tu script ConstruirMonstruo, borra los dos
	   bloques del final (los que empiezan por "🚶 LA ANIMACIÓN" y por
	   "🧠 LA TELEQUINESIA"). Esos dos los sustituye este script.
	   El print del final puedes dejarlo.

	Dónde va: ServerScriptService -> ➕ -> Script
	Nómbralo: MonstruoPersigue
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

-- ⚙️ AJUSTES
local PISADAS_POR_SEGUNDO = 2      -- lo que has pedido
local VELOCIDAD = 11               -- studs por segundo (tú corres a 16: puedes escapar)
local DISTANCIA_VISION = 300       -- desde cuán lejos te huele
local DISTANCIA_PILLAR = 8         -- a esta distancia te ha pillado
local ALTURA_RAIZ = 9              -- del suelo al centro del monstruo
local CADA_CUANTO_RECALCULA = 0.7  -- segundos entre mapa y mapa

task.wait(1.5)      -- que ConstruirMonstruo termine

local monstruo = workspace:WaitForChild("Monstruo", 20)
if not monstruo then
	warn("❌ No encuentro al Monstruo. ¿Está el script ConstruirMonstruo?")
	return
end

local raiz = monstruo:WaitForChild("HumanoidRootPart")

--==================================================================
-- 🔗 Nos guardamos la postura de reposo de cada articulación
--==================================================================
local juntas = {}

for _, cosa in ipairs(monstruo:GetDescendants()) do
	if cosa:IsA("Motor6D") then
		juntas[cosa.Name] = { junta = cosa, reposo = cosa.C0 }
	end
end

local function girar(x, y, z)
	return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end

local function postura(nombre, cframe)
	local j = juntas[nombre]
	if j then j.junta.C0 = j.reposo * cframe end
end

--==================================================================
-- 🚶 EL ANDAR (2 pisadas por segundo, pero torpe)
--    Una pisada = media vuelta del "reloj" del paso. Por eso multiplicamos
--    por math.pi: media vuelta completa es pi. 🕐
--==================================================================
local fase = 0
local andando = false
local tropiezo = 0
local craneoFuera = 0

RunService.Heartbeat:Connect(function(dt)
	if andando then
		fase += dt * PISADAS_POR_SEGUNDO * math.pi
	end

	-- Las dos piernas van al revés la una de la otra (por eso el + math.pi)
	local izq = math.sin(fase)
	local der = math.sin(fase + math.pi)

	postura("CaderaIzquierda", girar(-32 * izq, 0, 0))
	postura("CaderaDerecha", girar(-32 * der, 0, 0))

	-- La rodilla solo se dobla cuando la pierna va hacia delante
	postura("RodillaIzquierda", girar(42 * math.max(0, izq), 0, 0))
	postura("RodillaDerecha", girar(42 * math.max(0, der), 0, 0))
	postura("TobilloIzquierdo", girar(-14 * izq, 0, 0))
	postura("TobilloDerecho", girar(-14 * der, 0, 0))

	-- Los brazos, medio abiertos haciendo equilibrio y al revés que las piernas
	postura("HombroDerecho", girar(-12 + 22 * izq, 0, 30))
	postura("HombroIzquierdo", girar(-12 + 22 * der, 0, -30))
	postura("CodoDerecho", girar(-50 - 12 * der, 0, 0))
	postura("CodoIzquierdo", girar(-50 - 12 * izq, 0, 0))

	-- El cuerpo se bambolea de lado a lado: sigue andando fatal 🤢
	postura("RootJoint", girar(2 * math.abs(izq), 0, 7 * izq + tropiezo))

	-- El cráneo, flotando cuando toca
	postura("JuntaCraneo", CFrame.new(0, craneoFuera, 0) * girar(-6 * craneoFuera, 10 * craneoFuera, 0))
end)

-- De vez en cuando se tropieza y se recompone
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

-- 🧠 La telequinesia: se arranca media cabeza y se la vuelve a poner
task.spawn(function()
	while monstruo.Parent do
		task.wait(math.random(40, 90) / 10)

		local altura = 1.4 + math.random() * 1.6
		local pasos = 22
		for i = 1, pasos do                        -- sube flotando
			craneoFuera = altura * (i / pasos)
			task.wait(0.03)
		end

		task.wait(0.7)
		craneoFuera = 0                            -- y CLAC, vuelve de golpe 💀
	end
end)

--==================================================================
-- 🎯 A POR QUIÉN VA
--==================================================================
local function jugadorMasCerca()
	local mejor, mejorDistancia

	for _, jugador in ipairs(Players:GetPlayers()) do
		local personaje = jugador.Character
		local cuerpo = personaje and personaje:FindFirstChild("HumanoidRootPart")
		local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")

		if cuerpo and humanoide and humanoide.Health > 0 then
			local distancia = (cuerpo.Position - raiz.Position).Magnitude
			if not mejorDistancia or distancia < mejorDistancia then
				mejor, mejorDistancia = cuerpo, distancia
			end
		end
	end

	return mejor, mejorDistancia
end

--==================================================================
-- 🗺️ EL MAPA: cada poco pedimos el camino hasta el jugador
--==================================================================
local puntosDelCamino = {}
local siguientePunto = 1

local camino = PathfindingService:CreatePath({
	AgentRadius = 4,
	AgentHeight = 14,
	AgentCanJump = false,
	WaypointSpacing = 10,
})

task.spawn(function()
	while monstruo.Parent do
		task.wait(CADA_CUANTO_RECALCULA)

		local objetivo, distancia = jugadorMasCerca()

		if not objetivo or distancia > DISTANCIA_VISION then
			puntosDelCamino = {}          -- no te ve: se queda quieto
		else
			local desde = raiz.Position - Vector3.new(0, ALTURA_RAIZ, 0)
			local hasta = objetivo.Position - Vector3.new(0, 2.5, 0)

			local salioBien = pcall(function()
				camino:ComputeAsync(desde, hasta)
			end)

			if salioBien and camino.Status == Enum.PathStatus.Success then
				puntosDelCamino = {}
				for _, punto in ipairs(camino:GetWaypoints()) do
					table.insert(puntosDelCamino, punto.Position)
				end
				siguientePunto = 2        -- el 1 es donde ya está
			else
				-- Si no encuentra camino, va a por ti en línea recta 😨
				puntosDelCamino = { hasta }
				siguientePunto = 1
			end
		end
	end
end)

--==================================================================
-- 🏃 MOVERSE (esto va cada fotograma, para que sea suave)
--==================================================================
local avisado = 0

RunService.Heartbeat:Connect(function(dt)
	local objetivo, distancia = jugadorMasCerca()

	-- ¿Te ha pillado?
	if objetivo and distancia and distancia < DISTANCIA_PILLAR then
		andando = false

		-- mira fijamente al jugador
		local haciaTi = (objetivo.Position - raiz.Position) * Vector3.new(1, 0, 1)
		if haciaTi.Magnitude > 0.1 then
			raiz.CFrame = CFrame.lookAt(raiz.Position, raiz.Position + haciaTi.Unit)
		end

		if os.clock() - avisado > 3 then
			avisado = os.clock()
			print("👹 ¡TE HA PILLADO!")
			-- 👉 Aquí es donde luego pondremos el final de la partida
		end
		return
	end

	local destino = puntosDelCamino[siguientePunto]
	if not destino then
		andando = false
		return
	end

	local desde = raiz.Position
	local plano = Vector3.new(destino.X - desde.X, 0, destino.Z - desde.Z)

	-- ¿Ya he llegado a este punto del camino? Pues al siguiente
	if plano.Magnitude < 4 then
		siguientePunto += 1
		return
	end

	andando = true

	local direccion = plano.Unit
	local avance = math.min(VELOCIDAD * dt, plano.Magnitude)
	local nueva = desde + direccion * avance

	-- la altura la vamos ajustando poco a poco (para subir escaleras)
	local alturaQueQuiero = destino.Y + ALTURA_RAIZ
	local alturaNueva = desde.Y + (alturaQueQuiero - desde.Y) * math.min(1, dt * 5)

	raiz.CFrame = CFrame.lookAt(
		Vector3.new(nueva.X, alturaNueva, nueva.Z),
		Vector3.new(nueva.X, alturaNueva, nueva.Z) + direccion
	)
end)

print("👹 El monstruo ya te persigue. " .. PISADAS_POR_SEGUNDO .. " pisadas por segundo.")
