--[[
	LucesDeSuelo
	------------
	Reparte balizas de luz por el SUELO de toda la casa, como las lucecitas
	del pasillo de un cine. Así se ve por dónde vas aunque esté todo negro.

	Lo bueno: no hay que tocar la casa. Este script BUSCA los suelos que haya
	(se llamen como se llamen: Suelo... o Forjado...) y los va llenando él
	solo. Da igual si cambias la ESCALA de la casa: se adapta. 🪄

	Estas luces NO parpadean: son las que te salvan de perderte.

	Dónde va: ServerScriptService -> ➕ -> Script
	Nómbralo: LucesDeSuelo
]]

-- ⚙️ AJUSTES
local SEPARACION = 45        -- cada cuántos studs pone una baliza (menos = más luz)
local TAMANIO = 7            -- lo grande que es cada baliza
local ALCANCE = 60           -- hasta dónde llega su luz (60 es el máximo de Roblox)
local BRILLO = 2.4
local COLOR_LUZ = Color3.fromRGB(190, 215, 255)      -- blanco azulado, frío

task.wait(1.5)   -- dejamos que los constructores terminen

local cuantas = 0

--------------------------------------------------------------------
-- Pone UNA baliza encima de un punto del suelo
--------------------------------------------------------------------
local function baliza(padre, x, y, z)
	local luzSuelo = Instance.new("Part")
	luzSuelo.Name = "BalizaSuelo"
	luzSuelo.Size = Vector3.new(TAMANIO, 0.3, TAMANIO)
	luzSuelo.Position = Vector3.new(x, y + 0.2, z)
	luzSuelo.Color = COLOR_LUZ
	luzSuelo.Material = Enum.Material.Neon
	luzSuelo.Anchored = true
	luzSuelo.CanCollide = false      -- no tropiezas con ella
	luzSuelo.Parent = padre

	local luz = Instance.new("PointLight")
	luz.Brightness = BRILLO
	luz.Range = ALCANCE
	luz.Color = COLOR_LUZ
	luz.Shadows = false              -- sin sombras: son muchas y así no va lento
	luz.Parent = luzSuelo

	cuantas += 1
end

--------------------------------------------------------------------
-- Llena de balizas un suelo entero, repartidas en rejilla
--------------------------------------------------------------------
local function llenarSuelo(pieza, padre)
	local tam = pieza.Size
	local arriba = pieza.Position.Y + tam.Y / 2      -- la cara de arriba del suelo

	local filas = math.max(1, math.floor(tam.X / SEPARACION))
	local columnas = math.max(1, math.floor(tam.Z / SEPARACION))

	for i = 1, filas do
		for j = 1, columnas do
			local x = pieza.Position.X - tam.X / 2 + (i - 0.5) * (tam.X / filas)
			local z = pieza.Position.Z - tam.Z / 2 + (j - 0.5) * (tam.Z / columnas)
			baliza(padre, x, arriba, z)
		end
	end
end

--------------------------------------------------------------------
-- Buscamos los suelos de la casa y del cuarto
--------------------------------------------------------------------
local function esSuelo(pieza)
	if not pieza:IsA("BasePart") then return false end

	local nombre = pieza.Name
	return nombre:sub(1, 5) == "Suelo" or nombre:sub(1, 7) == "Forjado"
end

local function iluminar(modelo)
	if not modelo then return end

	-- primero borramos las balizas de una partida anterior
	for _, cosa in ipairs(modelo:GetChildren()) do
		if cosa.Name == "BalizaSuelo" then
			cosa:Destroy()
		end
	end

	for _, pieza in ipairs(modelo:GetChildren()) do
		if esSuelo(pieza) then
			llenarSuelo(pieza, modelo)
		end
	end
end

local casa = workspace:WaitForChild("Casa", 15)
local cuarto = workspace:WaitForChild("Cuarto", 15)

iluminar(casa)
iluminar(cuarto)

-- 🪜 Y una baliza en cada escalón, para no pegarte el tropezón del siglo
if casa then
	for _, pieza in ipairs(casa:GetChildren()) do
		if pieza:IsA("BasePart") and pieza.Name:sub(1, 7) == "Escalon" then
			local numero = tonumber(pieza.Name:sub(8)) or 0

			if numero % 5 == 0 then                          -- una de cada cinco
				local arriba = pieza.Position.Y + pieza.Size.Y / 2
				baliza(casa, pieza.Position.X, arriba, pieza.Position.Z)
			end
		end
	end
end

print("💡 Balizas de suelo puestas: " .. cuantas)
