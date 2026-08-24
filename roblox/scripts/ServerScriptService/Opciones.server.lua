--[[
	Opciones
	--------
	Todo lo que se puede HACER en el juego con la tecla [E]:
	  🛏️ Dormir · 🪑 Vigilar · 🚪 Salir/Entrar (teletransporte)
	  🪟 Abrir cortinas · 🔒 Puerta de papá y mamá · 🧊 Nevera

	Esta versión AVISA en la Output si falta alguna pieza, en vez de
	quedarse esperando en silencio (que es lo que despista siempre).

	Dónde va: ServerScriptService -> ➕ -> Script -> se llama Opciones
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- 👉 Con 0 se activa dando un TOQUE a la E. Ponlo en 1 si prefieres tener
--    que mantenerla pulsada un segundo (da más tensión, pero despista).
local SEGUNDOS_PUERTA = 0

local SITIO_PASILLO = CFrame.lookAt(Vector3.new(0, 4, 17), Vector3.new(0, 4, 30))
local SITIO_CUARTO  = CFrame.lookAt(Vector3.new(0, 4, 7),  Vector3.new(0, 4, -5))

local COMIDA = {
	{ nombre = "Leche",   icono = "🥛", color = Color3.fromRGB(240, 240, 235) },
	{ nombre = "Pizza",   icono = "🍕", color = Color3.fromRGB(220, 160, 70) },
	{ nombre = "Pollo",   icono = "🍗", color = Color3.fromRGB(200, 150, 100) },
	{ nombre = "Queso",   icono = "🧀", color = Color3.fromRGB(245, 205, 90) },
	{ nombre = "Manzana", icono = "🍎", color = Color3.fromRGB(200, 50, 50) },
	{ nombre = "Huevos",  icono = "🥚", color = Color3.fromRGB(245, 235, 215) },
	{ nombre = "Tarta",   icono = "🍰", color = Color3.fromRGB(240, 180, 200) },
	{ nombre = "Zumo",    icono = "🧃", color = Color3.fromRGB(240, 140, 40) },
}

local ESQUINA = Vector3.new(6, 1.8, -6)

--==================================================================
-- 🔎 BUSCADOR CON AVISO (no espera para siempre: avisa a los 10 segundos)
--==================================================================
local function buscar(padre, nombre)
	if not padre then return nil end

	local cosa = padre:WaitForChild(nombre, 10)
	if not cosa then
		warn("❌ FALTA: no encuentro '" .. nombre .. "' dentro de " .. padre:GetFullName())
	end
	return cosa
end

-- Espera a que el constructor termine del todo (bandera "Listo"). Sin esto,
-- si Opciones arranca antes, pone los carteles en un modelo que luego se
-- borra y se vuelve a construir... y la tecla E no hace nada. 🐛
local function esperarModelo(nombre)
	local esperado = 0
	while esperado < 15 do
		local modelo = workspace:FindFirstChild(nombre)
		if modelo and modelo:GetAttribute("Listo") then
			return modelo
		end
		task.wait(0.1)
		esperado += 0.1
	end

	warn("❌ FALTA: no aparece el modelo '" .. nombre .. "' terminado en Workspace.")
	return nil
end

print("🔎 Comprobando las piezas del juego...")

local cuarto = esperarModelo("Cuarto")
local casa = esperarModelo("Casa")

if not cuarto then
	warn("⛔ No hay CUARTO. ¿Está el script ConstruirCuarto en ServerScriptService?")
	return
end

if not casa then
	warn("⛔ No hay CASA. ¿Está el script ConstruirCasa en ServerScriptService?")
	warn("   Sin casa no puede haber teletransporte al pasillo.")
end

--==================================================================
-- 📡 Los Eventos: así hablan el servidor y tu pantalla
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

local MostrarMensaje = crearEvento("MostrarMensaje")
local AbrirNevera = crearEvento("AbrirNevera")
local CogerComida = crearEvento("CogerComida")

local function avisar(jugador, texto)
	MostrarMensaje:FireClient(jugador, texto)
end

--==================================================================
-- 🧠 El estado de cada jugador
--==================================================================
local cogidas = {}

local function prepararJugador(jugador)
	if jugador:FindFirstChild("Estado") then return end
	cogidas[jugador] = {}

	local estado = Instance.new("Folder")
	estado.Name = "Estado"
	estado.Parent = jugador

	local distancia = Instance.new("IntValue")     -- 👹 a cuántos metros está
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
-- 🚀 TELETRANSPORTE (contando en la Output todo lo que hace)
--==================================================================
local function teletransportar(jugador, destino)
	local personaje = jugador.Character
	if not personaje then
		warn("❌ " .. jugador.Name .. " no tiene personaje todavía.")
		return false
	end

	local humanoide = personaje:FindFirstChildOfClass("Humanoid")
	if not humanoide then
		warn("❌ El personaje de " .. jugador.Name .. " no tiene Humanoid.")
		return false
	end

	if humanoide.Health <= 0 then
		warn("❌ " .. jugador.Name .. " está muerto, no lo teletransporto.")
		return false
	end

	-- Si está sentado o tumbado hay que levantarlo, o rebota al sitio de antes
	humanoide.Sit = false
	humanoide.PlatformStand = false

	-- Y le quitamos la velocidad que llevara, para que no salga disparado
	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	if raiz then
		raiz.AssemblyLinearVelocity = Vector3.zero
		raiz.AssemblyAngularVelocity = Vector3.zero
	end

	personaje:PivotTo(destino)

	print("🚀 " .. jugador.Name .. " teletransportado a "
		.. math.floor(destino.Position.X) .. ", "
		.. math.floor(destino.Position.Y) .. ", "
		.. math.floor(destino.Position.Z))

	return true
end

--==================================================================
-- 🅴 Los carteles de [E]
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

	print("   ✔ Cartel [E] " .. textoAccion .. " puesto en " .. pieza:GetFullName())
	return cartel
end

--==================================================================
-- 🛏️ DORMIR  y  🪑 VIGILAR
--==================================================================
local cama = buscar(cuarto, "Cama")
if cama then
	crearOpcion(cama, "Dormir", "Cama", 0, function(jugador)
		avisar(jugador, "Cierras los ojos. Solo un ratito...")
	end)
end

local silla = buscar(cuarto, "Silla")
if silla then
	crearOpcion(silla, "Vigilar", "Silla", 0, function(jugador)
		avisar(jugador, "Te sientas frente a la puerta. No parpadees.")
	end)
end

--==================================================================
-- 🚪 SALIR y ENTRAR (el teletransporte)
--==================================================================
local puerta = buscar(cuarto, "Puerta")
local puertaFuera = buscar(casa, "PuertaFuera")

local cartelSalir, cartelEntrar

if puerta and puertaFuera then
	cartelSalir = crearOpcion(puerta, "Salir", "Puerta", SEGUNDOS_PUERTA, function(jugador)
		if not teletransportar(jugador, SITIO_PASILLO) then return end

		avisar(jugador, "El pasillo está en silencio. Las luces parpadean.")
		cartelSalir.Enabled = false
		cartelEntrar.Enabled = true
	end)

	cartelEntrar = crearOpcion(puertaFuera, "Entrar", "Puerta", SEGUNDOS_PUERTA, function(jugador)
		if not teletransportar(jugador, SITIO_CUARTO) then return end

		avisar(jugador, "Cierras la puerta. Estás a salvo... de momento.")
		cartelEntrar.Enabled = false
		cartelSalir.Enabled = true
	end)

	cartelEntrar.Enabled = false
else
	warn("⛔ NO HAY TELETRANSPORTE: falta la Puerta del cuarto o PuertaFuera de la casa.")
end

--==================================================================
-- 🪟 ABRIR LAS CORTINAS (el monstruo se acerca 5 metros)
--==================================================================
local cortinaIzq = buscar(casa, "CortinaIzq")
local cortinaDer = buscar(casa, "CortinaDer")

local cortinasAbiertas = false
local cartelCortinas

if cortinaIzq and cortinaDer then
	cartelCortinas = crearOpcion(cortinaIzq, "Abrir cortinas", "Cortinas", 1.5, function(jugador)
		if cortinasAbiertas then return end
		cortinasAbiertas = true

		local suave = TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		-- se recogen a los lados del hueco del comedor
		TweenService:Create(cortinaIzq, suave, {
			Size = Vector3.new(1.4, 9.4, 0.9),
			Position = Vector3.new(5, 5.7, 22.45),
		}):Play()

		TweenService:Create(cortinaDer, suave, {
			Size = Vector3.new(1.4, 9.4, 0.9),
			Position = Vector3.new(5, 5.7, 27.55),
		}):Play()

		avisar(jugador, "Descorres las cortinas... y algo, en alguna parte, se ha movido.")
		acercarMonstruo(jugador, 5)
		cartelCortinas.Enabled = false
	end)
end

--==================================================================
-- 🔒 LA PUERTA DE PAPÁ Y MAMÁ
--==================================================================
local puertaPadres = buscar(casa, "PuertaPadres")
if puertaPadres then
	crearOpcion(puertaPadres, "Abrir", "Puerta", 0, function(jugador)
		avisar(jugador, jugador.Name .. ": Es la habitación de papá y mamá, pero está cerrada con llave.")
	end)
end

--==================================================================
-- 🧊 LA NEVERA
--==================================================================
local function enviarNevera(jugador)
	local quedan = {}
	for indice, alimento in ipairs(COMIDA) do
		if not cogidas[jugador][indice] then
			table.insert(quedan, { indice = indice, nombre = alimento.nombre, icono = alimento.icono })
		end
	end
	AbrirNevera:FireClient(jugador, quedan)
end

local neveraPieza = buscar(casa, "Nevera")
if neveraPieza then
	crearOpcion(neveraPieza, "Mirar nevera", "Nevera", 0, function(jugador)
		if not cogidas[jugador] then return end
		enviarNevera(jugador)
	end)
end

-- 📦 Deja la comida amontonada en la esquina de tu cuarto
local function dejarEnLaEsquina(jugador, alimento)
	local estado = jugador:FindFirstChild("Estado")
	local i = estado and estado.ComidaCogida.Value or 0
	local columna, fila, piso = i % 3, math.floor(i / 3) % 3, math.floor(i / 9)

	local trozo = Instance.new("Part")
	trozo.Name = "Comida_" .. alimento.nombre
	trozo.Size = Vector3.new(1.6, 1.6, 1.6)
	trozo.Position = ESQUINA + Vector3.new(columna * 2, piso * 1.8, -fila * 2)
	trozo.Color = alimento.color
	trozo.Anchored = true
	trozo.Parent = cuarto

	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.fromScale(2, 2)
	cartel.StudsOffset = Vector3.new(0, 1.4, 0)
	cartel.Parent = trozo

	local texto = Instance.new("TextLabel")
	texto.Size = UDim2.fromScale(1, 1)
	texto.BackgroundTransparency = 1
	texto.Text = alimento.icono
	texto.TextScaled = true
	texto.Parent = cartel
end

CogerComida.OnServerEvent:Connect(function(jugador, indice)
	-- ⚠️ Nunca te fíes de lo que llega de la pantalla: hay que comprobarlo
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
	enviarNevera(jugador)
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
		if cartelSalir then cartelSalir.Enabled = true end
		if cartelEntrar then cartelEntrar.Enabled = false end
	end)
end)

Players.PlayerRemoving:Connect(function(jugador)
	cogidas[jugador] = nil
end)

print("✅ Opciones listas. Acércate a la puerta y pulsa E para salir.")
