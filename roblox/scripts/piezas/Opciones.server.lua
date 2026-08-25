--[[
	Opciones  ·  TODAS LAS OPCIONES EN UN SOLO SCRIPT
	-------------------------------------------------
	🛏️ Cama    -> Dormir
	🪑 Silla   -> Vigilar
	🚪 Puerta  -> Salir  (te teletransporta al pasillo)
	🚪 fuera   -> Entrar (vuelves al cuarto)
	🪟 Cortinas-> Abrir  (el monstruo se acerca 5 metros)
	🔒 Puerta de papá y mamá -> texto blanco: está cerrada con llave
	🧊 Nevera  -> Mirar nevera (se abre en tu pantalla y coges comida)

	✅ Funciona con CUALQUIER versión de ConstruirCuarto y ConstruirCasa:
	   no necesita banderas ni atributos, solo que existan las piezas
	   Cama, Silla, Puerta / PuertaFuera, CortinaIzq, CortinaDer,
	   PuertaPadres y Nevera.

	Dónde va: ServerScriptService -> ➕ -> Script -> se llama Opciones
	(Necesita también el LocalScript "Interfaz" en StarterPlayerScripts
	 para los textos blancos y el panel de la nevera.)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- ⚙️ AJUSTES QUE PUEDES TOCAR
local SEGUNDOS_PUERTA = 0                       -- 0 = un toque de E; 1 = mantenerla
local SITIO_PASILLO = CFrame.lookAt(Vector3.new(0, 4, 17), Vector3.new(0, 4, 30))
local SITIO_CUARTO  = CFrame.lookAt(Vector3.new(0, 4, 7),  Vector3.new(0, 4, -5))
local ESQUINA = Vector3.new(6, 1.8, -6)         -- dónde se amontona la comida
local METROS_CORTINAS = 5                       -- lo que se acerca el monstruo

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

--==================================================================
-- ⏳ ESPERAR A LOS CONSTRUCTORES
-- Los scripts de ServerScriptService arrancan en cualquier orden. Con
-- esperar un segundito, los constructores ya han terminado del todo.
--==================================================================
task.wait(1)

local function esperarModelo(nombre)
	local esperado = 0
	while esperado < 15 do
		local modelo = workspace:FindFirstChild(nombre)
		if modelo then
			return modelo
		end
		task.wait(0.2)
		esperado += 0.2
	end

	warn("❌ No aparece el modelo '" .. nombre .. "' en Workspace.")
	return nil
end

local function buscar(padre, nombre)
	if not padre then return nil end

	local cosa = padre:WaitForChild(nombre, 8)
	if not cosa then
		warn("❌ FALTA la pieza '" .. nombre .. "' dentro de " .. padre:GetFullName())
	end
	return cosa
end

print("🔎 Comprobando las piezas del juego...")


local cuarto = esperarModelo("Cuarto")
local casa = esperarModelo("Casa")

if not cuarto then
	warn("⛔ No hay CUARTO. ¿Está el script ConstruirCuarto en ServerScriptService?")
	return
end

if not casa then
	warn("⛔ No hay CASA. Sin ella no habrá teletransporte ni nevera.")
end

--==================================================================
-- 📡 EVENTOS (así hablan el servidor y tu pantalla)
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
-- 🧠 EL ESTADO DE CADA JUGADOR
--==================================================================
local cogidas = {}

local function prepararJugador(jugador)
	cogidas[jugador] = cogidas[jugador] or {}
	if jugador:FindFirstChild("Estado") then return end

	local estado = Instance.new("Folder")
	estado.Name = "Estado"
	estado.Parent = jugador

	local distancia = Instance.new("IntValue")      -- 👹 a cuántos metros está
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
-- 🚀 TELETRANSPORTE
--==================================================================
local function teletransportar(jugador, destino)
	local personaje = jugador.Character
	if not personaje then
		warn("❌ " .. jugador.Name .. " no tiene personaje todavía.")
		return false
	end

	local humanoide = personaje:FindFirstChildOfClass("Humanoid")
	if not humanoide or humanoide.Health <= 0 then
		warn("❌ " .. jugador.Name .. " no se puede teletransportar ahora.")
		return false
	end

	humanoide.Sit = false               -- si está sentado, rebotaría al sitio
	humanoide.PlatformStand = false

	local raiz = personaje:FindFirstChild("HumanoidRootPart")
	if raiz then
		raiz.AssemblyLinearVelocity = Vector3.zero
		raiz.AssemblyAngularVelocity = Vector3.zero
	end

	personaje:PivotTo(destino)
	print("🚀 " .. jugador.Name .. " teletransportado.")
	return true
end

--==================================================================
-- 🅴 LOS CARTELES DE [E]
--==================================================================
local function crearOpcion(pieza, textoAccion, textoObjeto, segundos, alElegir)
	if not pieza then return nil end

	-- si ya había un cartel de otra partida, fuera
	local viejo = pieza:FindFirstChildOfClass("ProximityPrompt")
	if viejo then viejo:Destroy() end

	local cartel = Instance.new("ProximityPrompt")
	cartel.Name = "Opcion" .. textoAccion
	cartel.ActionText = textoAccion
	cartel.ObjectText = textoObjeto
	cartel.KeyboardKeyCode = Enum.KeyCode.E
	cartel.HoldDuration = segundos
	-- En una casa gigante las piezas son enormes y el cartel sale del centro
	-- de la pieza, así que la distancia se calcula sola según su tamaño.
	cartel.MaxActivationDistance = math.max(12, pieza.Size.Magnitude * 0.7)
	cartel.RequiresLineOfSight = false
	cartel.Parent = pieza

	cartel.Triggered:Connect(function(jugador)
		alElegir(jugador)
	end)

	print("   ✔ [E] " .. textoAccion .. "  →  " .. pieza:GetFullName())
	return cartel
end

--==================================================================
-- 🛏️ DORMIR  ·  🪑 VIGILAR
--==================================================================
crearOpcion(buscar(cuarto, "Cama"), "Dormir", "Cama", 0, function(jugador)
	avisar(jugador, "Cierras los ojos. Solo un ratito...")
end)

crearOpcion(buscar(cuarto, "Silla"), "Vigilar", "Silla", 0, function(jugador)
	avisar(jugador, "Te sientas frente a la puerta. No parpadees.")
end)

--==================================================================
-- 🚪 SALIR  ·  ENTRAR
--==================================================================
local puerta = buscar(cuarto, "Puerta")
local puertaFuera = buscar(casa, "PuertaFuera")

-- Si la casa trae su propio punto de llegada, usamos ese (así, si cambias
-- el tamaño de la casa, el teletransporte se ajusta solo 🪄)
local llegada = casa and casa:FindFirstChild("LlegadaPasillo")
if llegada then
	SITIO_PASILLO = llegada.CFrame
	print("   ✔ Punto de llegada de la casa encontrado.")
end

-- Y el de volver al cuarto. Como el cuarto va colgado fuera de la mansión,
-- la casa deja una marca dentro de él y nosotros la usamos. 🎯
local llegadaCuarto = casa and casa:FindFirstChild("LlegadaCuarto")
if llegadaCuarto then
	SITIO_CUARTO = llegadaCuarto.CFrame
	print("   ✔ Punto de llegada del cuarto encontrado.")
end
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
	warn("⛔ SIN TELETRANSPORTE: falta 'Puerta' en el cuarto o 'PuertaFuera' en la casa.")
end

--==================================================================
-- 🪟 ABRIR LAS CORTINAS
-- Se recogen solas hacia su lado, midiendo dónde están AHORA. Así vale
-- para cualquier versión de la casa, sin tocar números a mano. 👌
--==================================================================
local cortinaIzq = buscar(casa, "CortinaIzq")
local cortinaDer = buscar(casa, "CortinaDer")
local cortinasAbiertas = false
local cartelCortinas

local function recoger(cortina, haciaAtras, suave)
	local ancho = cortina.Size.Z
	local recogido = math.max(0.8, ancho * 0.3)

	-- el borde por el que se queda pegada a la pared
	local borde = haciaAtras and (cortina.Position.Z - ancho / 2)
		or (cortina.Position.Z + ancho / 2)
	local nuevoZ = haciaAtras and (borde + recogido / 2) or (borde - recogido / 2)

	TweenService:Create(cortina, suave, {
		Size = Vector3.new(cortina.Size.X * 2.2, cortina.Size.Y, recogido),
		Position = Vector3.new(cortina.Position.X, cortina.Position.Y, nuevoZ),
	}):Play()
end

if cortinaIzq and cortinaDer then
	cartelCortinas = crearOpcion(cortinaIzq, "Abrir cortinas", "Cortinas", 1.5, function(jugador)
		if cortinasAbiertas then return end
		cortinasAbiertas = true

		local suave = TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		-- la que está más "atrás" se recoge hacia atrás, y la otra hacia delante
		local primera = (cortinaIzq.Position.Z <= cortinaDer.Position.Z) and cortinaIzq or cortinaDer
		local segunda = (primera == cortinaIzq) and cortinaDer or cortinaIzq

		recoger(primera, true, suave)
		recoger(segunda, false, suave)

		avisar(jugador, "Descorres las cortinas... y algo, en alguna parte, se ha movido.")
		acercarMonstruo(jugador, METROS_CORTINAS)
		cartelCortinas.Enabled = false
	end)
end

--==================================================================
-- 🔒 LA PUERTA DE PAPÁ Y MAMÁ
--==================================================================
crearOpcion(buscar(casa, "PuertaPadres"), "Abrir", "Puerta", 0, function(jugador)
	avisar(jugador, jugador.Name .. ": Es la habitación de papá y mamá, pero está cerrada con llave.")
end)

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

crearOpcion(buscar(casa, "Nevera"), "Mirar nevera", "Nevera", 0, function(jugador)
	if not cogidas[jugador] then return end
	enviarNevera(jugador)
end)

-- 📦 La comida cogida se amontona en una esquina de tu cuarto
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
-- 👤 JUGADORES
--==================================================================
local function seguirJugador(jugador)
	prepararJugador(jugador)

	jugador.CharacterAdded:Connect(function()
		if cartelSalir then cartelSalir.Enabled = true end
		if cartelEntrar then cartelEntrar.Enabled = false end
	end)
end

for _, jugador in ipairs(Players:GetPlayers()) do
	seguirJugador(jugador)
end

Players.PlayerAdded:Connect(seguirJugador)

Players.PlayerRemoving:Connect(function(jugador)
	cogidas[jugador] = nil
end)

print("✅ Opciones listas. Acércate a la cama, la silla o la puerta.")
