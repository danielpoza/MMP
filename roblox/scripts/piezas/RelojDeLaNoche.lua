--==================================================================
-- 👁️ PRIMERA PERSONA + 🎯 MIRA + ⏰ EL RELOJ DE LA NOCHE
--==================================================================
local SEGUNDOS_POR_HORA = 300      -- cada cuánto pasa una hora del juego
local HORA_INICIO = 12             -- empieza a las 12:00
local HORA_FINAL = 6               -- al llegar a las 6:00, amanece

local horaActual = HORA_INICIO

-- Después de las 12 viene la 1, no las 13 (es un reloj de los de casa 🕐)
local function siguienteHora(h)
	if h == 12 then return 1 end
	return h + 1
end

local function comoTexto(h, m)
	return string.format("%02d:%02d", h, m)
end

--------------------------------------------------------------------
-- La pantalla de cada jugador: la mira, el reloj y el fundido a negro
--------------------------------------------------------------------
local function prepararPantalla(jugador)
	local pantalla = jugador:WaitForChild("PlayerGui")

	local vieja = pantalla:FindFirstChild("InterfazNoche")
	if vieja then vieja:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "InterfazNoche"
	gui.ResetOnSpawn = false          -- que no se borre al reaparecer
	gui.IgnoreGuiInset = true
	gui.Parent = pantalla

	-- 🎯 EL PUNTITO BLANCO (la mira). En primera persona el ratón se
	--    esconde y se queda clavado en el centro, así que este punto
	--    hace de puntero. 🖱️
	local punto = Instance.new("Frame")
	punto.Name = "Mira"
	punto.Size = UDim2.fromOffset(8, 8)
	punto.Position = UDim2.new(0.5, -4, 0.5, -4)
	punto.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	punto.BackgroundTransparency = 0.15
	punto.BorderSizePixel = 0
	punto.ZIndex = 5
	punto.Parent = gui

	local redondo = Instance.new("UICorner")     -- para que sea redondo
	redondo.CornerRadius = UDim.new(1, 0)
	redondo.Parent = punto

	-- ⏰ EL RELOJ (empieza invisible: solo aparece al cambiar de hora)
	local reloj = Instance.new("TextLabel")
	reloj.Name = "Reloj"
	reloj.Size = UDim2.new(0, 300, 0, 90)
	reloj.Position = UDim2.new(0.5, -150, 0.12, 0)
	reloj.BackgroundTransparency = 1
	reloj.Font = Enum.Font.Code
	reloj.TextSize = 56
	reloj.TextColor3 = Color3.fromRGB(255, 255, 255)
	reloj.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	reloj.TextStrokeTransparency = 0.3
	reloj.TextTransparency = 1
	reloj.Text = comoTexto(HORA_INICIO, 0)
	reloj.ZIndex = 6
	reloj.Parent = gui

	-- ⬛ LA PANTALLA NEGRA del amanecer
	local negro = Instance.new("Frame")
	negro.Name = "Negro"
	negro.Size = UDim2.fromScale(1, 1)
	negro.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	negro.BackgroundTransparency = 1
	negro.BorderSizePixel = 0
	negro.ZIndex = 10
	negro.Parent = gui

	return gui
end

-- Hacer algo en la pantalla de TODOS los jugadores a la vez
local function enTodasLasPantallas(hacer)
	for _, jugador in ipairs(Players:GetPlayers()) do
		local pantalla = jugador:FindFirstChild("PlayerGui")
		local gui = pantalla and pantalla:FindFirstChild("InterfazNoche")
		if gui then hacer(gui, jugador) end
	end
end

--------------------------------------------------------------------
-- 👁️ PRIMERA PERSONA
--------------------------------------------------------------------
local function preparerJugador(jugador)
	jugador.CameraMode = Enum.CameraMode.LockFirstPerson   -- ya no se puede salir
	prepararPantalla(jugador)
end

for _, jugador in ipairs(Players:GetPlayers()) do
	preparerJugador(jugador)
end

Players.PlayerAdded:Connect(preparerJugador)

--------------------------------------------------------------------
-- ⏰ LA TRANSICIÓN DE UNA HORA A OTRA (12:59 -> 01:00)
--------------------------------------------------------------------
local function mostrarCambioDeHora()
	local siguiente = siguienteHora(horaActual)

	-- 1) el reloj aparece poco a poco
	for i = 10, 0, -1 do
		enTodasLasPantallas(function(gui)
			gui.Reloj.TextTransparency = i / 10
		end)
		task.wait(0.04)
	end

	-- 2) los minutos corren: 55, 56, 57, 58, 59...
	for minuto = 55, 59 do
		enTodasLasPantallas(function(gui)
			gui.Reloj.Text = comoTexto(horaActual, minuto)
		end)
		task.wait(0.25)
	end

	-- 3) ¡CAMBIO! Se pone en amarillo y grande un momento
	horaActual = siguiente

	enTodasLasPantallas(function(gui)
		gui.Reloj.Text = comoTexto(horaActual, 0)
		gui.Reloj.TextColor3 = Color3.fromRGB(255, 214, 120)
		gui.Reloj.TextSize = 72
	end)
	task.wait(0.8)

	enTodasLasPantallas(function(gui)
		gui.Reloj.TextColor3 = Color3.fromRGB(255, 255, 255)
		gui.Reloj.TextSize = 56
	end)
	task.wait(1.4)

	-- 4) y se desvanece
	for i = 0, 10 do
		enTodasLasPantallas(function(gui)
			gui.Reloj.TextTransparency = i / 10
		end)
		task.wait(0.05)
	end
end

--------------------------------------------------------------------
-- 🌅 EL AMANECER: pantalla negra, todos al cuarto, y vuelta a las 12
--------------------------------------------------------------------
local function amanecer()
	-- 1) fundido a negro
	for i = 0, 25 do
		enTodasLasPantallas(function(gui)
			gui.Negro.BackgroundTransparency = 1 - i / 25
		end)
		task.wait(0.06)
	end

	-- 2) con la pantalla en negro, todos de vuelta al cuarto
	for _, jugador in ipairs(Players:GetPlayers()) do
		teletransportar(jugador, SITIO_DENTRO)
	end

	task.wait(2)

	-- 3) vuelta a empezar: son otra vez las 12
	horaActual = HORA_INICIO
	enTodasLasPantallas(function(gui)
		gui.Reloj.Text = comoTexto(HORA_INICIO, 0)
	end)

	-- 4) y la pantalla vuelve poco a poco
	for i = 25, 0, -1 do
		enTodasLasPantallas(function(gui)
			gui.Negro.BackgroundTransparency = 1 - i / 25
		end)
		task.wait(0.06)
	end

	print("🌅 Ha amanecido. Vuelta a empezar.")
end

--------------------------------------------------------------------
-- 🕐 EL RELOJ, DANDO VUELTAS PARA SIEMPRE
--------------------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(SEGUNDOS_POR_HORA)
		mostrarCambioDeHora()

		if horaActual == HORA_FINAL then
			amanecer()
		end
	end
end)

print("⏰ Reloj en marcha: una hora cada " .. SEGUNDOS_POR_HORA .. " segundos.")
print("👁️ Cámara en primera persona con mira.")
