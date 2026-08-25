--[[
	MonstruoAnimacion   ⚠️ ESTE ES UN LocalScript ⚠️
	------------------
	Mueve los brazos, las piernas y el cráneo del monstruo.

	🎬 ¿POR QUÉ AQUÍ Y NO EN EL SERVIDOR?
	   El servidor solo le manda los cambios a tu pantalla unas 20 veces por
	   segundo, pero tu pantalla dibuja 60. Si la animación la hace el
	   servidor, ves: mueve - espera - mueve - espera. Ese tirón.
	   Haciéndola aquí, en TU ordenador, va suave a 60 fotogramas. 🧈

	   El servidor sigue mandando en lo importante (dónde está el monstruo y
	   si te ha pillado). Esto es solo lo que se ve.

	Dónde va: StarterPlayer -> StarterPlayerScripts -> ➕ -> LocalScript
	Nómbralo: MonstruoAnimacion
]]

local RunService = game:GetService("RunService")

-- ⚙️ EL RITMO DE LAS PIERNAS (tus tiempos)
local DURACION_PISADA = 0.5         -- lo que tarda UNA pierna en dar su paso
local PAUSA_ENTRE_PISADAS = 0.05    -- el respiro entre una pierna y la otra
local ANIMAR_SIEMPRE = true         -- true = mueve las piernas aunque no avance

local TURNO = DURACION_PISADA + PAUSA_ENTRE_PISADAS
local CICLO = TURNO * 2

local monstruo = workspace:WaitForChild("Monstruo", 60)
if not monstruo then
	warn("❌ (animación) No aparece el Monstruo.")
	return
end

-- Esperamos a que el cuerpo esté montado del todo
local esperado = 0
while not monstruo:GetAttribute("Listo") and esperado < 15 do
	task.wait(0.1)
	esperado += 0.1
end

--==================================================================
-- 🔗 La postura de reposo de cada articulación
--==================================================================
local juntas = {}
local cuantas = 0

for _, cosa in ipairs(monstruo:GetDescendants()) do
	if cosa:IsA("Motor6D") then
		juntas[cosa.Name] = { junta = cosa, reposo = cosa.C0 }
		cuantas += 1
	end
end

print("🎬 (animación) Articulaciones: " .. cuantas)

local function girar(x, y, z)
	return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end

local function postura(nombre, cframe)
	local j = juntas[nombre]
	if j then j.junta.C0 = j.reposo * cframe end
end

--==================================================================
-- 🚶 EL ANDAR
--    Un reloj que da vueltas. Le toca a una pierna DURACION_PISADA,
--    pausita, le toca a la otra, pausita. Y vuelta a empezar. 🦵🕐
--    El reloj NO se para nunca, para que nada se quede congelado.
--==================================================================
local reloj = 0
local intensidad = 0        -- 0 = quieto, 1 = andando (sube y baja suave)
local tropiezo = 0
local craneoFuera = 0

local function curva(p)     -- 0 -> 1 -> 0 : levanta el pie y lo vuelve a apoyar
	if p <= 0 or p >= 1 then return 0 end
	return math.sin(math.pi * p)
end

RunService.RenderStepped:Connect(function(dt)
	reloj = (reloj + dt) % CICLO

	-- El servidor nos dice si está andando, con un "cartelito" en el modelo
	local anda = ANIMAR_SIEMPRE or monstruo:GetAttribute("Andando") == true
	intensidad += ((anda and 1 or 0) - intensidad) * math.min(1, dt * 6)

	-- ¿A quién le toca ahora, y por qué parte de su paso va?
	local avanceIzq, avanceDer = 0, 0

	if reloj < DURACION_PISADA then
		avanceIzq = reloj / DURACION_PISADA
	elseif reloj >= TURNO and reloj < TURNO + DURACION_PISADA then
		avanceDer = (reloj - TURNO) / DURACION_PISADA
	end

	local izq = curva(avanceIzq) * intensidad
	local der = curva(avanceDer) * intensidad

	postura("CaderaIzquierda", girar(-34 * izq, 0, 0))
	postura("CaderaDerecha", girar(-34 * der, 0, 0))
	postura("RodillaIzquierda", girar(48 * izq, 0, 0))
	postura("RodillaDerecha", girar(48 * der, 0, 0))
	postura("TobilloIzquierdo", girar(-16 * izq, 0, 0))
	postura("TobilloDerecho", girar(-16 * der, 0, 0))

	-- Los brazos, al revés que las piernas
	postura("HombroDerecho", girar(-12 + 26 * izq, 0, 30))
	postura("HombroIzquierdo", girar(-12 + 26 * der, 0, -30))
	postura("CodoDerecho", girar(-50 - 14 * der, 0, 0))
	postura("CodoIzquierdo", girar(-50 - 14 * izq, 0, 0))

	-- El cuerpo se echa hacia la pierna apoyada
	postura("RootJoint", girar(2 * (izq + der), 0, 8 * (izq - der) + tropiezo))
	postura("JuntaCraneo", CFrame.new(0, craneoFuera, 0) * girar(-6 * craneoFuera, 10 * craneoFuera, 0))
end)

-- De vez en cuando se tropieza
task.spawn(function()
	while monstruo.Parent do
		task.wait(math.random(35, 90) / 10)
		if intensidad > 0.5 then
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
		local subiendo = 0

		while subiendo < 0.9 do             -- sube flotando, suave
			local dt = task.wait()
			subiendo += dt
			craneoFuera = altura * math.min(1, subiendo / 0.9)
		end

		task.wait(0.7)
		craneoFuera = 0                     -- CLAC 💀
	end
end)
