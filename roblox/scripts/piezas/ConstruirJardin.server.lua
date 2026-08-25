--[[
	ConstruirJardin
	---------------
	El jardín de la mansión:
	  🌿 césped, camino de piedra y setos
	  🏊 PISCINA con luces acuáticas por dentro
	  🚧 MUROS INVISIBLES en los cuatro bordes, altísimos, para que nadie
	     se escape a la carretera ni a casa del vecino
	  🛣️ la carretera y la casa del vecino, para que se vea que hay más
	     mundo... aunque no se pueda llegar 😈

	Dónde va: ServerScriptService -> ➕ -> Script
	Nómbralo: ConstruirJardin
]]

print("▶️ ConstruirJardin arrancando...")

--==================================================================
-- 📐 MEDIDAS
--==================================================================
local JARDIN = 190              -- del centro a cada borde (el jardín es enorme)
local ALTO_MURO = 400           -- lo alto que son los muros invisibles
local Y_SUELO = 0               -- la hierba, justo debajo de la mansión

local C = {
	hierba = Color3.fromRGB(72, 122, 58), piedra = Color3.fromRGB(196, 190, 178),
	agua = Color3.fromRGB(70, 170, 210), borde = Color3.fromRGB(226, 222, 212),
	seto = Color3.fromRGB(46, 96, 44), asfalto = Color3.fromRGB(58, 58, 62),
	vecino = Color3.fromRGB(150, 130, 110), tejado = Color3.fromRGB(110, 50, 44),
}

local anterior = workspace:FindFirstChild("Jardin")
if anterior then anterior:Destroy() end

local jardin = Instance.new("Model")
jardin.Name = "Jardin"
jardin.Parent = workspace

local function bloque(nombre, tam, pos, color, material)
	local p = Instance.new("Part")
	p.Name = nombre ; p.Size = tam ; p.Position = pos ; p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = jardin
	return p
end

--==================================================================
-- 🌿 EL CÉSPED
--==================================================================
bloque("Cesped", Vector3.new(JARDIN * 2, 2, JARDIN * 2), Vector3.new(0, Y_SUELO - 1, 0), C.hierba, Enum.Material.Grass)

-- Camino de piedra desde la verja hasta la puerta principal
for i = 0, 12 do
	bloque("Losa", Vector3.new(14, 0.4, 9), Vector3.new(0, Y_SUELO + 0.2, -55 - i * 10), C.piedra, Enum.Material.Slate)
end

--==================================================================
-- 🏊 LA PISCINA (con luces por debajo del agua)
--==================================================================
local PIS_X, PIS_Z = 70, 40           -- dónde está
local PIS_ANCHO, PIS_LARGO = 60, 34
local PROFUNDIDAD = 8

-- El vaso: cuatro paredes y el fondo, para que se pueda meter uno dentro
bloque("PiscinaFondo", Vector3.new(PIS_ANCHO, 1, PIS_LARGO),
	Vector3.new(PIS_X, Y_SUELO - PROFUNDIDAD, PIS_Z), C.borde, Enum.Material.Marble)

bloque("PiscinaParedA", Vector3.new(PIS_ANCHO, PROFUNDIDAD, 1),
	Vector3.new(PIS_X, Y_SUELO - PROFUNDIDAD / 2, PIS_Z - PIS_LARGO / 2), C.borde, Enum.Material.Marble)
bloque("PiscinaParedB", Vector3.new(PIS_ANCHO, PROFUNDIDAD, 1),
	Vector3.new(PIS_X, Y_SUELO - PROFUNDIDAD / 2, PIS_Z + PIS_LARGO / 2), C.borde, Enum.Material.Marble)
bloque("PiscinaParedC", Vector3.new(1, PROFUNDIDAD, PIS_LARGO),
	Vector3.new(PIS_X - PIS_ANCHO / 2, Y_SUELO - PROFUNDIDAD / 2, PIS_Z), C.borde, Enum.Material.Marble)
bloque("PiscinaParedD", Vector3.new(1, PROFUNDIDAD, PIS_LARGO),
	Vector3.new(PIS_X + PIS_ANCHO / 2, Y_SUELO - PROFUNDIDAD / 2, PIS_Z), C.borde, Enum.Material.Marble)

-- El bordillo de alrededor
for _, d in ipairs({ {0, -PIS_LARGO / 2 - 3, PIS_ANCHO + 12, 6}, {0, PIS_LARGO / 2 + 3, PIS_ANCHO + 12, 6} }) do
	bloque("Bordillo", Vector3.new(d[3], 0.6, d[4]), Vector3.new(PIS_X + d[1], Y_SUELO + 0.3, PIS_Z + d[2]), C.borde, Enum.Material.Marble)
end
for _, d in ipairs({ -PIS_ANCHO / 2 - 3, PIS_ANCHO / 2 + 3 }) do
	bloque("Bordillo", Vector3.new(6, 0.6, PIS_LARGO + 12), Vector3.new(PIS_X + d, Y_SUELO + 0.3, PIS_Z), C.borde, Enum.Material.Marble)
end

-- 💧 EL AGUA: se puede atravesar (CanCollide false) para poder bañarse
local agua = bloque("Agua", Vector3.new(PIS_ANCHO - 1, PROFUNDIDAD - 0.6, PIS_LARGO - 1),
	Vector3.new(PIS_X, Y_SUELO - PROFUNDIDAD / 2 + 0.2, PIS_Z), C.agua, Enum.Material.Glass)
agua.Transparency = 0.55
agua.Reflectance = 0.25
agua.CanCollide = false

-- 💡 LAS LUCES ACUÁTICAS: van DENTRO del vaso, en las paredes
local luces = {}

for i = -1, 1 do
	for _, lado in ipairs({ -1, 1 }) do
		local foco = bloque("FocoPiscina", Vector3.new(4, 3, 0.6),
			Vector3.new(PIS_X + i * 18, Y_SUELO - 3, PIS_Z + lado * (PIS_LARGO / 2 - 0.9)),
			Color3.fromRGB(190, 240, 255), Enum.Material.Neon)

		local luz = Instance.new("PointLight")
		luz.Brightness = 3
		luz.Range = 34
		luz.Color = Color3.fromRGB(120, 210, 255)      -- azul de piscina 💙
		luz.Shadows = false
		luz.Parent = foco

		table.insert(luces, { pieza = foco, luz = luz })
	end
end

-- Que el agua "respire": las luces suben y bajan de brillo muy despacio
task.spawn(function()
	local t = 0
	while jardin.Parent do
		t += task.wait()
		local onda = 2.4 + math.sin(t * 1.2) * 0.9
		for _, l in ipairs(luces) do
			l.luz.Brightness = onda
		end
	end
end)

-- Tumbonas junto a la piscina
for i = -1, 1 do
	bloque("Tumbona", Vector3.new(9, 1.6, 20), Vector3.new(PIS_X + i * 16, Y_SUELO + 1.4, PIS_Z + PIS_LARGO / 2 + 14), Color3.fromRGB(238, 234, 224), Enum.Material.Fabric)
	bloque("PataTumbona", Vector3.new(9, 1.4, 1.4), Vector3.new(PIS_X + i * 16, Y_SUELO + 0.7, PIS_Z + PIS_LARGO / 2 + 14), C.borde)
end

--==================================================================
-- 🌳 SETOS Y FAROLAS
--==================================================================
for i = -8, 8 do
	if math.abs(i) > 1 then
		bloque("Seto", Vector3.new(12, 9, 8), Vector3.new(i * 20, Y_SUELO + 4.5, -150), C.seto, Enum.Material.Grass)
	end
end

for _, sitio in ipairs({ Vector3.new(-30, 0, -70), Vector3.new(30, 0, -70), Vector3.new(-80, 0, 60), Vector3.new(120, 0, -40) }) do
	bloque("Farola", Vector3.new(2, 26, 2), sitio + Vector3.new(0, Y_SUELO + 13, 0), Color3.fromRGB(48, 48, 52), Enum.Material.Metal)

	local bombilla = bloque("BombillaFarola", Vector3.new(5, 3, 5), sitio + Vector3.new(0, Y_SUELO + 27, 0),
		Color3.fromRGB(255, 236, 190), Enum.Material.Neon)

	local luz = Instance.new("PointLight")
	luz.Brightness = 2
	luz.Range = 60
	luz.Color = Color3.fromRGB(255, 226, 170)
	luz.Shadows = false
	luz.Parent = bombilla
end

--==================================================================
-- 🛣️ LA CARRETERA Y LA CASA DEL VECINO (solo para verlas de lejos)
--==================================================================
bloque("Carretera", Vector3.new(JARDIN * 2 + 200, 1, 50), Vector3.new(0, Y_SUELO + 0.2, -JARDIN - 40), C.asfalto, Enum.Material.Asphalt)
for i = -10, 10 do
	bloque("LineaCarretera", Vector3.new(14, 0.3, 2), Vector3.new(i * 30, Y_SUELO + 0.9, -JARDIN - 40), Color3.fromRGB(240, 236, 210))
end

bloque("CasaVecino", Vector3.new(90, 60, 70), Vector3.new(JARDIN + 90, Y_SUELO + 30, 20), C.vecino, Enum.Material.Brick)
bloque("TejadoVecino", Vector3.new(96, 8, 76), Vector3.new(JARDIN + 90, Y_SUELO + 64, 20), C.tejado, Enum.Material.Slate)

local ventanaVecino = bloque("VentanaVecino", Vector3.new(10, 12, 0.6), Vector3.new(JARDIN + 70, Y_SUELO + 34, -14),
	Color3.fromRGB(255, 226, 150), Enum.Material.Neon)
local luzVecino = Instance.new("PointLight")
luzVecino.Brightness = 1.4 ; luzVecino.Range = 40
luzVecino.Color = Color3.fromRGB(255, 226, 150)
luzVecino.Parent = ventanaVecino

--==================================================================
-- 🚧 LOS MUROS INVISIBLES
--    Un muro en cada borde del jardín, de 400 studs de alto. Nadie
--    los ve, nadie los salta, y nadie sale a la carretera. 🙅
--==================================================================
local bordes = {
	{ Vector3.new(JARDIN * 2 + 20, ALTO_MURO, 4), Vector3.new(0, ALTO_MURO / 2, -JARDIN) },
	{ Vector3.new(JARDIN * 2 + 20, ALTO_MURO, 4), Vector3.new(0, ALTO_MURO / 2, JARDIN) },
	{ Vector3.new(4, ALTO_MURO, JARDIN * 2 + 20), Vector3.new(-JARDIN, ALTO_MURO / 2, 0) },
	{ Vector3.new(4, ALTO_MURO, JARDIN * 2 + 20), Vector3.new(JARDIN, ALTO_MURO / 2, 0) },
}

for i, m in ipairs(bordes) do
	local muro = bloque("MuroInvisible" .. i, m[1], m[2], Color3.fromRGB(255, 0, 255))
	muro.Transparency = 1        -- invisible del todo
	muro.CanCollide = true       -- pero no se puede atravesar
	muro.CastShadow = false
end

print("🌿 Jardín listo: piscina con luces, farolas, carretera y casa del vecino.")
print("   Muros invisibles: 4, de " .. ALTO_MURO .. " studs de alto. De aquí no sales. 🚧")
