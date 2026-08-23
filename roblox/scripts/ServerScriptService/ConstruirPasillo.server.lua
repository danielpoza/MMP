--[[
	ConstruirPasillo
	----------------
	Construye el pasillo que hay al otro lado de tu puerta. Es largo, estrecho
	y solo tiene dos lámparas medio muertas en el techo. Aquí es donde ronda
	el monstruo. 👹

	Al final del pasillo, más adelante, pondremos la cocina con la nevera.

	Dónde va: Explorer -> ServerScriptService -> ➕ -> Script
	Nómbralo: ConstruirPasillo
]]

local LARGO = 34      -- lo largo que es el pasillo
local ANCHO = 12      -- lo estrecho que es
local ALTO  = 12

local COLOR_SUELO = Color3.fromRGB(48, 44, 42)
local COLOR_PARED = Color3.fromRGB(52, 48, 54)
local COLOR_TECHO = Color3.fromRGB(34, 32, 38)

-- El pasillo empieza pegado a la puerta del cuarto (z = 11) y sigue hacia z = 45
local CENTRO_Z = 28

local anterior = workspace:FindFirstChild("Pasillo")
if anterior then
	anterior:Destroy()
end

local pasillo = Instance.new("Model")
pasillo.Name = "Pasillo"
pasillo.Parent = workspace

local function bloque(nombre, tam, pos, color, material)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.Position = pos
	p.Color = color
	p.Material = material or Enum.Material.Concrete
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = pasillo
	return p
end

-- Suelo, techo y las dos paredes largas
bloque("SueloPasillo", Vector3.new(ANCHO, 1, LARGO), Vector3.new(0, 0.5, CENTRO_Z), COLOR_SUELO)
bloque("TechoPasillo", Vector3.new(ANCHO, 1, LARGO), Vector3.new(0, ALTO + 1.5, CENTRO_Z), COLOR_TECHO)
bloque("ParedPasilloIzq", Vector3.new(1, ALTO, LARGO), Vector3.new(-ANCHO / 2, 7, CENTRO_Z), COLOR_PARED)
bloque("ParedPasilloDer", Vector3.new(1, ALTO, LARGO), Vector3.new(ANCHO / 2, 7, CENTRO_Z), COLOR_PARED)

-- El fondo del pasillo (aquí abriremos la puerta de la cocina más adelante)
bloque("FondoPasillo", Vector3.new(ANCHO, ALTO, 1), Vector3.new(0, 7, 45), COLOR_PARED)

-- 💡 Dos lámparas de techo medio muertas
local function lamparaTecho(nombre, z)
	local l = bloque(nombre, Vector3.new(3, 0.4, 1.5), Vector3.new(0, 12.6, z),
		Color3.fromRGB(210, 220, 255), Enum.Material.Neon)

	local luz = Instance.new("PointLight")
	luz.Brightness = 1.1          -- muy poquita luz
	luz.Range = 24
	luz.Color = Color3.fromRGB(180, 200, 255)   -- blanca azulada, de hospital
	luz.Shadows = true
	luz.Parent = l

	return l
end

lamparaTecho("LamparaPasillo1", 20)
lamparaTecho("LamparaPasillo2", 38)

--------------------------------------------------------------------
-- 🚪 La cara de FUERA de tu puerta: un bloque invisible donde saldrá
--    el cartel de [E] Entrar para volver al cuarto.
--------------------------------------------------------------------
local puertaFuera = bloque("PuertaFuera", Vector3.new(6, 8, 0.4),
	Vector3.new(0, 5, 12.9), COLOR_PARED)
puertaFuera.Transparency = 1      -- no se ve
puertaFuera.CanCollide = false    -- no estorba

print("🚪 Pasillo construido. No mires al fondo...")
