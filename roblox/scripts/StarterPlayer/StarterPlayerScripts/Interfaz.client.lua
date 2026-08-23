--[[
	Interfaz
	--------
	Todo lo que se ve EN TU PANTALLA (no en el mundo):

	  · El texto blanco de abajo (por ejemplo, cuando intentas abrir la
	    habitación de papá y mamá).
	  · La NEVERA ABIERTA: un panel con la comida, y cada comida es un botón.
	    Lo que pinches, aparecerá en la esquina de tu cuarto.

	Dónde va: Explorer -> StarterPlayer -> StarterPlayerScripts -> ➕ -> LocalScript
	Nómbralo: Interfaz

	⚠️ OJO: aquí es LocalScript, no Script. Es el script de TU pantalla.
]]

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
