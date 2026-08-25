--[[
	LA NOCHE  ·  TODO LO DE TU PANTALLA EN UN SOLO SCRIPT   ⚠️ LocalScript
	======================================================================
	  1. El texto blanco de abajo y el panel de la nevera
	  2. La animación del monstruo (brazos y piernas, a 60 fps)

	🎬 La animación va aquí, en TU ordenador, y no en el servidor. Si la
	   hiciera el servidor la verías a tirones, porque solo manda los
	   cambios unas 20 veces por segundo y tu pantalla dibuja 60. 🧈

	Dónde va: StarterPlayer -> StarterPlayerScripts -> ➕ -> LocalScript
	Nómbralo: LaNocheCliente
]]

if _G.LaNocheClienteYaArranco then
	warn("⛔ Hay un LocalScript DUPLICADO en StarterPlayerScripts. Bórralo.")
	return
end

_G.LaNocheClienteYaArranco = true

--==================================================================
-- ✍️ 1. TEXTOS Y NEVERA
--==================================================================
local function interfaz()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local jugador = Players.LocalPlayer
local pantalla = jugador:WaitForChild("PlayerGui")

local eventos = ReplicatedStorage:WaitForChild("Eventos")
local MostrarMensaje = eventos:WaitForChild("MostrarMensaje")
local AbrirNevera = eventos:WaitForChild("AbrirNevera")
local CogerComida = eventos:WaitForChild("CogerComida")

-- La "hoja" donde dibujamos todo
local gui = Instance.new("ScreenGui")
gui.Name = "InterfazJuego"
gui.ResetOnSpawn = false        -- que no se borre al reaparecer
gui.IgnoreGuiInset = true
gui.Parent = pantalla

--==================================================================
-- ✍️ EL TEXTO BLANCO DE ABAJO
--==================================================================
local mensaje = Instance.new("TextLabel")
mensaje.Name = "Mensaje"
mensaje.Size = UDim2.new(0.7, 0, 0, 70)
mensaje.Position = UDim2.new(0.15, 0, 0.76, 0)
mensaje.BackgroundTransparency = 1
mensaje.Font = Enum.Font.Gotham
mensaje.TextSize = 22
mensaje.TextWrapped = true
mensaje.TextColor3 = Color3.fromRGB(255, 255, 255)     -- blanco
mensaje.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)     -- bordecito negro para leerlo
mensaje.TextStrokeTransparency = 0.35
mensaje.TextTransparency = 1                            -- empieza invisible
mensaje.Text = ""
mensaje.Parent = gui

local turno = 0    -- para que un mensaje nuevo cancele el borrado del anterior

MostrarMensaje.OnClientEvent:Connect(function(texto)
	turno += 1
	local mio = turno

	mensaje.Text = texto
	mensaje.TextTransparency = 0
	mensaje.TextStrokeTransparency = 0.35

	-- a los 5 segundos se desvanece poco a poco
	task.delay(5, function()
		if turno ~= mio then return end
		TweenService:Create(mensaje, TweenInfo.new(1.5), {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}):Play()
	end)
end)

--==================================================================
-- 🧊 LA NEVERA ABIERTA
--==================================================================
local panel = Instance.new("Frame")
panel.Name = "Nevera"
panel.Size = UDim2.new(0, 520, 0, 470)
panel.Position = UDim2.new(0.5, -260, 0.5, -235)
panel.BackgroundColor3 = Color3.fromRGB(228, 236, 243)
panel.Visible = false
panel.Parent = gui

local esquinas = Instance.new("UICorner")
esquinas.CornerRadius = UDim.new(0, 16)
esquinas.Parent = panel

local borde = Instance.new("UIStroke")
borde.Color = Color3.fromRGB(150, 158, 168)
borde.Thickness = 4
borde.Parent = panel

-- Título
local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 54)
titulo.BackgroundTransparency = 1
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 26
titulo.TextColor3 = Color3.fromRGB(50, 60, 72)
titulo.Text = "🧊  NEVERA"
titulo.Parent = panel

-- Botón de cerrar
local cerrar = Instance.new("TextButton")
cerrar.Size = UDim2.new(0, 40, 0, 40)
cerrar.Position = UDim2.new(1, -50, 0, 8)
cerrar.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
cerrar.Font = Enum.Font.GothamBold
cerrar.TextSize = 22
cerrar.TextColor3 = Color3.fromRGB(255, 255, 255)
cerrar.Text = "✕"
cerrar.Parent = panel

local esquinasCerrar = Instance.new("UICorner")
esquinasCerrar.CornerRadius = UDim.new(0, 10)
esquinasCerrar.Parent = cerrar

cerrar.Activated:Connect(function()
	panel.Visible = false
end)

-- El interior de la nevera (azulito, con su lucecita)
local interior = Instance.new("Frame")
interior.Size = UDim2.new(1, -36, 1, -80)
interior.Position = UDim2.new(0, 18, 0, 62)
interior.BackgroundColor3 = Color3.fromRGB(206, 224, 236)
interior.Parent = panel

local esquinasInterior = Instance.new("UICorner")
esquinasInterior.CornerRadius = UDim.new(0, 10)
esquinasInterior.Parent = interior

-- Las baldas de la nevera
for i = 1, 2 do
	local balda = Instance.new("Frame")
	balda.Size = UDim2.new(1, -20, 0, 4)
	balda.Position = UDim2.new(0, 10, i / 3, 0)
	balda.BackgroundColor3 = Color3.fromRGB(170, 190, 205)
	balda.BorderSizePixel = 0
	balda.Parent = interior
end

-- La rejilla donde van los botones de comida
local rejilla = Instance.new("Frame")
rejilla.Size = UDim2.new(1, -20, 1, -20)
rejilla.Position = UDim2.new(0, 10, 0, 10)
rejilla.BackgroundTransparency = 1
rejilla.Parent = interior

local orden = Instance.new("UIGridLayout")
orden.CellSize = UDim2.new(0, 100, 0, 100)
orden.CellPadding = UDim2.new(0, 14, 0, 14)
orden.HorizontalAlignment = Enum.HorizontalAlignment.Center
orden.VerticalAlignment = Enum.VerticalAlignment.Center
orden.Parent = rejilla

-- Cartel de "no queda nada"
local vacia = Instance.new("TextLabel")
vacia.Size = UDim2.new(1, 0, 1, 0)
vacia.BackgroundTransparency = 1
vacia.Font = Enum.Font.Gotham
vacia.TextSize = 22
vacia.TextColor3 = Color3.fromRGB(90, 100, 112)
vacia.Text = "La nevera está vacía.\nYa lo has cogido todo."
vacia.Visible = false
vacia.Parent = interior

-- 🍕 Dibuja un botón por cada comida que queda
local function pintarNevera(lista)
	for _, hijo in ipairs(rejilla:GetChildren()) do
		if hijo:IsA("TextButton") then
			hijo:Destroy()
		end
	end

	vacia.Visible = (#lista == 0)

	for _, alimento in ipairs(lista) do
		local boton = Instance.new("TextButton")
		boton.Size = UDim2.new(0, 100, 0, 100)
		boton.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
		boton.AutoButtonColor = true
		boton.Text = ""
		boton.Parent = rejilla

		local redondo = Instance.new("UICorner")
		redondo.CornerRadius = UDim.new(0, 12)
		redondo.Parent = boton

		local icono = Instance.new("TextLabel")
		icono.Size = UDim2.new(1, 0, 0.62, 0)
		icono.BackgroundTransparency = 1
		icono.Text = alimento.icono
		icono.TextScaled = true
		icono.Parent = boton

		local nombre = Instance.new("TextLabel")
		nombre.Size = UDim2.new(1, 0, 0.32, 0)
		nombre.Position = UDim2.new(0, 0, 0.64, 0)
		nombre.BackgroundTransparency = 1
		nombre.Font = Enum.Font.GothamMedium
		nombre.TextSize = 15
		nombre.TextColor3 = Color3.fromRGB(60, 70, 82)
		nombre.Text = alimento.nombre
		nombre.Parent = boton

		-- Al pincharlo, se lo decimos al servidor
		boton.Activated:Connect(function()
			CogerComida:FireServer(alimento.indice)
		end)
	end
end

AbrirNevera.OnClientEvent:Connect(function(lista)
	pintarNevera(lista)
	panel.Visible = true
end)
end

--==================================================================
-- 🎬 2. ANIMACIÓN DEL MONSTRUO
--==================================================================
local function animacionMonstruo()
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
end

-- ▶️ Las dos cosas funcionan a la vez, cada una por su lado
task.spawn(interfaz)
task.spawn(animacionMonstruo)

print("🎬 Pantalla lista (textos, nevera y animación del monstruo).")
