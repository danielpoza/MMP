--[[
	Opciones
	--------
	Todo lo que se puede HACER en el juego con la tecla [E]:

	  🛏️ Cama            -> Dormir
	  🪑 Silla           -> Vigilar
	  🚪 Puerta          -> Salir (te teletransporta al pasillo)
	  🚪 Puerta (fuera)  -> Entrar (vuelves al cuarto)
	  🪟 Cortinas        -> Abrir (¡el monstruo se acerca 5 metros!)
	  🔒 Puerta de papá y mamá -> sale un texto blanco: está cerrada con llave
	  🧊 Nevera          -> Mirar nevera (se abre la nevera en la pantalla)

	La comida que coges aparece amontonada en una esquina de tu cuarto.

	Dónde va: Explorer -> ServerScriptService -> ➕ -> Script
	Nómbralo: Opciones   (si ya lo tienes, borra lo de dentro y pega esto)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local cuarto = workspace:WaitForChild("Cuarto")
local casa = workspace:WaitForChild("Casa")

-- 📍 Los dos sitios del teletransporte
local SITIO_PASILLO = CFrame.lookAt(Vector3.new(0, 4, 17), Vector3.new(0, 4, 30))
local SITIO_CUARTO  = CFrame.lookAt(Vector3.new(0, 4, 7),  Vector3.new(0, 4, -5))

-- 🍗 La comida que hay dentro de la nevera
local COMIDA = {
	{ nombre = "Leche",    icono = "🥛", color = Color3.fromRGB(240, 240, 235) },
	{ nombre = "Pizza",    icono = "🍕", color = Color3.fromRGB(220, 160, 70) },
	{ nombre = "Pollo",    icono = "🍗", color = Color3.fromRGB(200, 150, 100) },
	{ nombre = "Queso",    icono = "🧀", color = Color3.fromRGB(245, 205, 90) },
	{ nombre = "Manzana",  icono = "🍎", color = Color3.fromRGB(200, 50, 50) },
	{ nombre = "Huevos",   icono = "🥚", color = Color3.fromRGB(245, 235, 215) },
	{ nombre = "Tarta",    icono = "🍰", color = Color3.fromRGB(240, 180, 200) },
	{ nombre = "Zumo",     icono = "🧃", color = Color3.fromRGB(240, 140, 40) },
}

-- 📦 La esquina de tu cuarto donde se va amontonando la comida
local ESQUINA = Vector3.new(6, 1.8, -6)

--==================================================================
-- 📡 Los "Eventos": así hablan el servidor y tu pantalla
--==================================================================
local eventos = ReplicatedStorage:FindFirstChild("Eventos")
if not eventos then
	eventos = Instance.new("Folder")
	eventos.Name = "Eventos"
	eventos.Parent = ReplicatedStorage
end

local function crearEvento(nombre)
	local e = eventos:FindFirstChild(nombre)
	if not e then
		e = Instance.new("RemoteEvent")
		e.Name = nombre
		e.Parent = eventos
	end
	return e
end

local MostrarMensaje = crearEvento("MostrarMensaje")   -- servidor -> pantalla
local AbrirNevera    = crearEvento("AbrirNevera")      -- servidor -> pantalla
local CogerComida    = crearEvento("CogerComida")      -- pantalla -> servidor

local function avisar(jugador, texto)
	MostrarMensaje:FireClient(jugador, texto)
end

--==================================================================
-- 🧠 El estado de cada jugador
--==================================================================
local cogidas = {}    -- qué comida ha cogido ya cada jugador

local function prepararJugador(jugador)
	if jugador:FindFirstChild("Estado") then return end   -- ya estaba preparado
	cogidas[jugador] = {}

	local estado = Instance.new("Folder")
	estado.Name = "Estado"
	estado.Parent = jugador

	-- A cuántos metros está el monstruo. Cuanto menos, peor. 👹
	local distancia = Instance.new("IntValue")
	distancia.Name = "DistanciaMonstruo"
	distancia.Value = 30
	distancia.Parent = estado

	local comidaCogida = Instance.new("IntValue")
	comidaCogida.Name = "ComidaCogida"
	comidaCogida.Value = 0
	comidaCogida.Parent = estado
end

local function acercarMonstruo(jugador, metros)
	local estado = jugador:FindFirstChild("Estado")
	if not estado then return end

	local distancia = estado:FindFirstChild("DistanciaMonstruo")
	distancia.Value = math.max(0, distancia.Value - metros)

	print("👹 El monstruo está ahora a " .. distancia.Value .. " metros de " .. jugador.Name)
end

--==================================================================
-- 🚀 Teletransporte
--==================================================================
local function teletransportar(jugador, destino)
	local personaje = jugador.Character
	if not personaje then return false end

	local humanoide = personaje:FindFirstChildOfClass("Humanoid")
	if not humanoide or humanoide.Health <= 0 then return false end

	personaje:PivotTo(destino)
	return true
end

--==================================================================
-- 🅴 Función para crear los carteles de [E]
--==================================================================
local function crearOpcion(pieza, textoAccion, textoObjeto, segundos, alElegir)
	local cartel = Instance.new("ProximityPrompt")
	cartel.Name = "Opcion" .. textoAccion
	cartel.ActionText = textoAccion
	cartel.ObjectText = textoObjeto
	cartel.KeyboardKeyCode = Enum.KeyCode.E
	cartel.HoldDuration = segundos
	cartel.MaxActivationDistance = 10
	cartel.RequiresLineOfSight = false
	cartel.Parent = pieza

	cartel.Triggered:Connect(function(jugador)
		alElegir(jugador)
	end)

	return cartel
end

--==================================================================
-- 🛏️ DORMIR  y  🪑 VIGILAR
--==================================================================
crearOpcion(cuarto:WaitForChild("Cama"), "Dormir", "Cama", 0, function(jugador)
	print("🛏️ " .. jugador.Name .. " se ha ido a dormir...")
	avisar(jugador, "Cierras los ojos. Solo un ratito...")
end)

crearOpcion(cuarto:WaitForChild("Silla"), "Vigilar", "Silla", 0, function(jugador)
	print("👁️ " .. jugador.Name .. " se sienta a vigilar la puerta.")
	avisar(jugador, "Te sientas frente a la puerta. No parpadees.")
end)

--==================================================================
-- 🚪 SALIR y ENTRAR
--==================================================================
local puerta = cuarto:WaitForChild("Puerta")
local puertaFuera = casa:WaitForChild("PuertaFuera")

local cartelSalir, cartelEntrar

cartelSalir = crearOpcion(puerta, "Salir", "Puerta", 1, function(jugador)
	if not teletransportar(jugador, SITIO_PASILLO) then return end

	print("🚪 " .. jugador.Name .. " ha salido al pasillo.")
	avisar(jugador, "El pasillo está en silencio. Las luces parpadean.")

	cartelSalir.Enabled = false
	cartelEntrar.Enabled = true
end)

cartelEntrar = crearOpcion(puertaFuera, "Entrar", "Puerta", 1, function(jugador)
	if not teletransportar(jugador, SITIO_CUARTO) then return end

	print("🚪 " .. jugador.Name .. " vuelve a su cuarto.")
	avisar(jugador, "Cierras la puerta. Estás a salvo... de momento.")

	cartelEntrar.Enabled = false
	cartelSalir.Enabled = true
end)

cartelEntrar.Enabled = false

--==================================================================
-- 🪟 ABRIR LAS CORTINAS (el monstruo se acerca 5 metros)
--==================================================================
local cortinaIzq = casa:WaitForChild("CortinaIzq")
local cortinaDer = casa:WaitForChild("CortinaDer")

local cortinasAbiertas = false

local cartelCortinas

cartelCortinas = crearOpcion(cortinaIzq, "Abrir cortinas", "Cortinas", 1.5, function(jugador)
	if cortinasAbiertas then return end
	cortinasAbiertas = true

	-- Tween = movimiento suave. Las cortinas se recogen a los lados.
	local suave = TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	TweenService:Create(cortinaIzq, suave, {
		Size = Vector3.new(1.6, 15, 2.5),
		Position = Vector3.new(8, 8.5, 49.2),
	}):Play()

	TweenService:Create(cortinaDer, suave, {
		Size = Vector3.new(1.6, 15, 2.5),
		Position = Vector3.new(8, 8.5, 70.8),
	}):Play()

	print("🪟 " .. jugador.Name .. " ha abierto las cortinas.")
	avisar(jugador, "Descorres las cortinas... y algo, en alguna parte, se ha movido.")

	acercarMonstruo(jugador, 5)
	cartelCortinas.Enabled = false
end)

--==================================================================
-- 🔒 LA PUERTA DE PAPÁ Y MAMÁ
--==================================================================
crearOpcion(casa:WaitForChild("PuertaPadres"), "Abrir", "Puerta", 0, function(jugador)
	avisar(jugador, jugador.Name .. ": Es la habitación de papá y mamá, pero está cerrada con llave.")
	print("🔒 " .. jugador.Name .. " intenta abrir la habitación de sus padres.")
end)

--==================================================================
-- 🧊 LA NEVERA
--==================================================================

-- Le manda a la pantalla del jugador la comida que TODAVÍA queda
local function enviarNevera(jugador)
	local quedan = {}
	for indice, alimento in ipairs(COMIDA) do
		if not cogidas[jugador][indice] then
			table.insert(quedan, {
				indice = indice,
				nombre = alimento.nombre,
				icono = alimento.icono,
			})
		end
	end

	AbrirNevera:FireClient(jugador, quedan)
end

crearOpcion(casa:WaitForChild("Nevera"), "Mirar nevera", "Nevera", 0, function(jugador)
	if not cogidas[jugador] then return end
	enviarNevera(jugador)
end)

-- 📦 Deja la comida amontonada en la esquina de tu cuarto
local function dejarEnLaEsquina(jugador, alimento)
	local estado = jugador:FindFirstChild("Estado")
	local cuantas = estado and estado.ComidaCogida.Value or 0

	-- las colocamos en filas de 3, y cuando se llena una capa, encima
	local i = cuantas
	local columna = i % 3
	local fila = math.floor(i / 3) % 3
	local piso = math.floor(i / 9)

	local trozo = Instance.new("Part")
	trozo.Name = "Comida_" .. alimento.nombre
	trozo.Size = Vector3.new(1.6, 1.6, 1.6)
	trozo.Position = ESQUINA + Vector3.new(columna * 2, piso * 1.8, -fila * 2)
	trozo.Color = alimento.color
	trozo.Material = Enum.Material.SmoothPlastic
	trozo.Anchored = true
	trozo.Parent = cuarto

	-- Un cartelito flotando encima con el dibujo de la comida
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromScale(2, 2)
	cartel.StudsOffset = Vector3.new(0, 1.4, 0)
	cartel.AlwaysOnTop = false
	cartel.Parent = trozo

	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.fromScale(1, 1)
	texto.BackgroundTransparency = 1
	texto.Text = alimento.icono
	texto.TextScaled = true
	texto.Parent = cartel
end

-- Cuando el jugador pincha en una comida de la nevera
CogerComida.OnServerEvent:Connect(function(jugador, indice)
	-- ⚠️ Nunca te fíes de lo que llega de la pantalla: hay que comprobarlo.
	if typeof(indice) ~= "number" then return end
	if not COMIDA[indice] then return end
	if not cogidas[jugador] or cogidas[jugador][indice] then return end

	cogidas[jugador][indice] = true

	dejarEnLaEsquina(jugador, COMIDA[indice])

	local estado = jugador:FindFirstChild("Estado")
	if estado then
		estado.ComidaCogida.Value = estado.ComidaCogida.Value + 1
	end
	print("🍗 " .. jugador.Name .. " ha cogido: " .. COMIDA[indice].nombre)

	enviarNevera(jugador)      -- refrescamos la nevera abierta
end)

--==================================================================
-- 👤 Jugadores
--==================================================================
for _, jugador in ipairs(Players:GetPlayers()) do
	prepararJugador(jugador)
end

Players.PlayerAdded:Connect(function(jugador)
	prepararJugador(jugador)

	jugador.CharacterAdded:Connect(function()
		cartelSalir.Enabled = true
		cartelEntrar.Enabled = false
	end)
end)

Players.PlayerRemoving:Connect(function(jugador)
	cogidas[jugador] = nil
end)

print("✅ Opciones listas: puerta, cortinas, habitación cerrada y nevera.")
