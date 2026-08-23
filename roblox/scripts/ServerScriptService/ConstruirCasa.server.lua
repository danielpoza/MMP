--[[
	ConstruirCasa
	-------------
	Construye TODA la casa (de una sola planta) al otro lado de tu puerta:

	  🚪 PASILLO  — mármol, alfombra roja, molduras doradas y cuadros
	  🛋️ SALÓN    — escritorio alto, sofá cama, sofá, tele y lámpara de araña
	  🪟 CORTINAS — tapan el comedor (se abren con [E]... si te atreves)
	  🍽️ COMEDOR  — mesa ancha con una planta encima y seis sillas
	  🔒 HABITACIÓN DE PAPÁ Y MAMÁ — cerrada con llave
	  🍳 COCINA   — muchísimos cajones, isla central y la nevera

	Y TODAS las luces parpadean solas, cada una a su ritmo. 💡😨

	Dónde va: Explorer -> ServerScriptService -> ➕ -> Script
	Nómbralo: ConstruirCasa
	(Si todavía tienes el script ConstruirPasillo, bórralo: este lo sustituye.)
]]

local ALTO = 16                    -- techos altos, que es una casa de ricos
local Y_PARED = 1 + ALTO / 2       -- centro de las paredes
local Y_TECHO = 1 + ALTO + 0.5     -- altura del techo

local C = {
	pared   = Color3.fromRGB(200, 189, 168),   -- crema
	techo   = Color3.fromRGB(236, 232, 224),
	oro     = Color3.fromRGB(198, 162, 82),
	marmol  = Color3.fromRGB(226, 223, 214),
	parquet = Color3.fromRGB(96, 62, 38),
	madera  = Color3.fromRGB(72, 46, 30),
	tela    = Color3.fromRGB(96, 104, 120),
	cortina = Color3.fromRGB(112, 26, 38),
	alfombra= Color3.fromRGB(120, 30, 34),
	metal   = Color3.fromRGB(198, 200, 206),
	negro   = Color3.fromRGB(18, 18, 20),
	planta  = Color3.fromRGB(58, 120, 52),
	bombilla= Color3.fromRGB(255, 236, 200),
}

local anterior = workspace:FindFirstChild("Casa")
if anterior then
	anterior:Destroy()
end

local casa = Instance.new("Model")
casa.Name = "Casa"
casa.Parent = workspace

local lamparas = {}   -- aquí guardamos todas las luces, para el parpadeo

--==================================================================
-- 🧰 HERRAMIENTAS: funciones que usamos una y otra vez
--==================================================================
local function bloque(nombre, tam, pos, color, material)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.Position = pos
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = casa
	return p
end

-- Suelo y techo de una sala, dando sus dos esquinas
local function suelo(nombre, x1, x2, z1, z2, color, material)
	return bloque(nombre, Vector3.new(x2 - x1, 1, z2 - z1),
		Vector3.new((x1 + x2) / 2, 0.5, (z1 + z2) / 2), color, material)
end

local function techo(nombre, x1, x2, z1, z2)
	return bloque(nombre, Vector3.new(x2 - x1, 1, z2 - z1),
		Vector3.new((x1 + x2) / 2, Y_TECHO, (z1 + z2) / 2), C.techo)
end

-- Pared que corre a lo largo (paredX = de norte a sur, paredZ = de este a oeste)
local function paredX(nombre, x, z1, z2)
	return bloque(nombre, Vector3.new(1, ALTO, z2 - z1),
		Vector3.new(x, Y_PARED, (z1 + z2) / 2), C.pared)
end

local function paredZ(nombre, z, x1, x2)
	return bloque(nombre, Vector3.new(x2 - x1, ALTO, 1),
		Vector3.new((x1 + x2) / 2, Y_PARED, z), C.pared)
end

-- ✨ Los "trazos bonitos": zócalo, moldura de arriba y marcos dorados
local function decorarParedX(x, z1, z2, hacia)     -- hacia = 1 o -1
	local xd = x + hacia * 0.6
	local largo = z2 - z1
	bloque("Zocalo", Vector3.new(0.3, 2, largo), Vector3.new(xd, 2, (z1 + z2) / 2), C.oro, Enum.Material.Metal)
	bloque("Moldura", Vector3.new(0.3, 0.6, largo), Vector3.new(xd, 13.5, (z1 + z2) / 2), C.oro, Enum.Material.Metal)

	local cuantos = math.max(1, math.floor(largo / 9))
	for i = 1, cuantos do
		local zc = z1 + (i - 0.5) * (largo / cuantos)
		bloque("Marco", Vector3.new(0.25, 8, 0.3), Vector3.new(xd, 8, zc - 3), C.oro, Enum.Material.Metal)
		bloque("Marco", Vector3.new(0.25, 8, 0.3), Vector3.new(xd, 8, zc + 3), C.oro, Enum.Material.Metal)
		bloque("Marco", Vector3.new(0.25, 0.3, 6), Vector3.new(xd, 4, zc), C.oro, Enum.Material.Metal)
		bloque("Marco", Vector3.new(0.25, 0.3, 6), Vector3.new(xd, 12, zc), C.oro, Enum.Material.Metal)
	end
end

local function decorarParedZ(z, x1, x2, hacia)
	local zd = z + hacia * 0.6
	local largo = x2 - x1
	bloque("Zocalo", Vector3.new(largo, 2, 0.3), Vector3.new((x1 + x2) / 2, 2, zd), C.oro, Enum.Material.Metal)
	bloque("Moldura", Vector3.new(largo, 0.6, 0.3), Vector3.new((x1 + x2) / 2, 13.5, zd), C.oro, Enum.Material.Metal)
end

-- 💡 Lámpara de techo (se apunta sola a la lista de parpadeo)
local function lampara(nombre, x, z, brillo, alcance, color)
	bloque(nombre .. "Cable", Vector3.new(0.2, 2, 0.2), Vector3.new(x, Y_TECHO - 1.2, z), C.oro, Enum.Material.Metal)

	local bombilla = bloque(nombre, Vector3.new(2.6, 1.4, 2.6), Vector3.new(x, Y_TECHO - 2.6, z),
		C.bombilla, Enum.Material.Neon)

	local luz = Instance.new("PointLight")
	luz.Brightness = brillo
	luz.Range = alcance
	luz.Color = color or Color3.fromRGB(255, 224, 170)
	luz.Shadows = true
	luz.Parent = bombilla

	table.insert(lamparas, { pieza = bombilla, luz = luz })
	return bombilla
end

-- 🕯️ Lámpara de araña: una bola central y seis brazos con velas
local function lamparaArania(nombre, x, z)
	bloque(nombre .. "Cadena", Vector3.new(0.3, 3, 0.3), Vector3.new(x, Y_TECHO - 1.6, z), C.oro, Enum.Material.Metal)
	bloque(nombre .. "Centro", Vector3.new(2, 1.6, 2), Vector3.new(x, Y_TECHO - 3.6, z), C.oro, Enum.Material.Metal)

	for i = 1, 6 do
		local angulo = math.rad(i * 60)
		local bx = x + math.cos(angulo) * 3.5
		local bz = z + math.sin(angulo) * 3.5

		bloque(nombre .. "Brazo", Vector3.new(0.25, 0.25, 0.25), Vector3.new(bx, Y_TECHO - 3.6, bz), C.oro, Enum.Material.Metal)

		local vela = bloque(nombre .. i, Vector3.new(0.9, 1.6, 0.9), Vector3.new(bx, Y_TECHO - 4.4, bz),
			C.bombilla, Enum.Material.Neon)

		local luz = Instance.new("PointLight")
		luz.Brightness = 1.6
		luz.Range = 30
		luz.Color = Color3.fromRGB(255, 220, 160)
		luz.Shadows = true
		luz.Parent = vela

		table.insert(lamparas, { pieza = vela, luz = luz })
	end
end

-- 🖼️ Cuadro con marco dorado colgado de una pared
local function cuadro(x, z, ancho, hacia)
	bloque("CuadroMarco", Vector3.new(0.4, 7, ancho), Vector3.new(x + hacia * 0.7, 8.5, z), C.oro, Enum.Material.Metal)
	bloque("CuadroLienzo", Vector3.new(0.2, 6, ancho - 1), Vector3.new(x + hacia * 1, 8.5, z),
		Color3.fromRGB(40, 34, 44), Enum.Material.SmoothPlastic)
end

-- 🪑 Mesa sencilla con patas (la usamos para el escritorio, la mesa, la isla...)
local function mesa(nombre, x, z, ancho, fondo, altura, color)
	bloque(nombre, Vector3.new(ancho, 0.6, fondo), Vector3.new(x, altura, z), color, Enum.Material.Wood)
	local dx, dz = ancho / 2 - 0.7, fondo / 2 - 0.7
	for _, esquina in ipairs({ {dx, dz}, {-dx, dz}, {dx, -dz}, {-dx, -dz} }) do
		bloque(nombre .. "Pata", Vector3.new(0.6, altura - 1.3, 0.6),
			Vector3.new(x + esquina[1], (altura - 1.3) / 2 + 1, z + esquina[2]), color, Enum.Material.Wood)
	end
end

-- 🛋️ Sofá mirando hacia donde le digamos (giro = 0, 90, 180 o 270 grados)
local function sofa(nombre, x, z, ancho, color, giro)
	local modelo = Instance.new("Model")
	modelo.Name = nombre
	modelo.Parent = casa

	local piezas = {
		{ Vector3.new(ancho, 1.6, 6), Vector3.new(0, 2.3, 0) },              -- asiento
		{ Vector3.new(ancho, 3.4, 1.2), Vector3.new(0, 4.3, -2.9) },         -- respaldo
		{ Vector3.new(1.2, 2.6, 6), Vector3.new(-ancho / 2 + 0.6, 3.4, 0) }, -- brazo izq
		{ Vector3.new(1.2, 2.6, 6), Vector3.new(ancho / 2 - 0.6, 3.4, 0) },  -- brazo der
	}

	local giroCF = CFrame.Angles(0, math.rad(giro), 0)
	for _, datos in ipairs(piezas) do
		local p = bloque(nombre .. "Parte", datos[1], Vector3.new(0, 0, 0), color, Enum.Material.Fabric)
		p.CFrame = CFrame.new(x, 0, z) * giroCF * CFrame.new(datos[2])
		p.Parent = modelo
	end

	return modelo
end

--==================================================================
-- 🚪 EL PASILLO (x de -7 a 7, z de 11 a 40)
--==================================================================
suelo("SueloPasillo", -7, 7, 11, 40, C.marmol, Enum.Material.Marble)
techo("TechoPasillo", -7, 7, 11, 40)
paredX("PasilloIzq", -7, 11, 40)
paredX("PasilloDer", 7, 11, 40)

-- Tapa el hueco que queda encima de la puerta de tu cuarto
bloque("RemateSobrePuerta", Vector3.new(14, 4, 1), Vector3.new(0, 15, 12), C.pared)

decorarParedX(-7, 11, 40, 1)
decorarParedX(7, 11, 40, -1)
cuadro(-7, 22, 6, 1)
cuadro(7, 30, 6, -1)

bloque("AlfombraPasillo", Vector3.new(6, 0.12, 27), Vector3.new(0, 1.06, 25.5), C.alfombra, Enum.Material.Fabric)

-- Consolita con jarrón, para que se note que aquí vive gente con pasta
mesa("Consola", -4.5, 34, 4, 2, 4, C.madera)
bloque("Jarron", Vector3.new(1.6, 3, 1.6), Vector3.new(-4.5, 5.8, 34), Color3.fromRGB(70, 90, 130), Enum.Material.Glass)

lampara("LamparaPasillo1", 0, 18, 1.5, 28)
lampara("LamparaPasillo2", 0, 32, 1.5, 28)

-- La cara de FUERA de tu puerta (invisible): aquí sale el cartel de [E] Entrar
local puertaFuera = bloque("PuertaFuera", Vector3.new(6, 8, 0.4), Vector3.new(0, 5, 12.9), C.pared)
puertaFuera.Transparency = 1
puertaFuera.CanCollide = false

--==================================================================
-- 🛋️ EL SALÓN (x de -26 a 8, z de 40 a 84)
--==================================================================
suelo("SueloSalon", -26, 8, 40, 84, C.parquet, Enum.Material.WoodPlanks)
techo("TechoSalon", -26, 8, 40, 84)

paredZ("SalonFrenteIzq", 40, -26, -7)     -- el hueco del medio es el pasillo
paredZ("SalonFrenteDer", 40, 7, 8)
paredX("SalonIzq", -26, 40, 84)
paredX("SalonDerA", 8, 40, 48)            -- entre medias van las cortinas
paredX("SalonDerB", 8, 72, 84)
paredZ("SalonFondoA", 84, -26, -20)       -- hueco: puerta de la cocina
paredZ("SalonFondoB", 84, -14, -4)        -- hueco: puerta de papá y mamá
paredZ("SalonFondoC", 84, 2, 8)

decorarParedX(-26, 40, 84, 1)
decorarParedZ(84, -26, 8, -1)
cuadro(-26, 48, 8, 1)

lamparaArania("AraniaSalon", -9, 62)
lampara("LamparaSalon1", -18, 46, 1.2, 30)

bloque("AlfombraSalon", Vector3.new(18, 0.12, 16), Vector3.new(-17, 1.06, 61), Color3.fromRGB(78, 66, 62), Enum.Material.Fabric)

-- 🖊️ Escritorio ALTO con su taburete
mesa("Escritorio", 3, 46, 8, 4, 6, C.madera)
bloque("Flexo", Vector3.new(0.8, 2, 0.8), Vector3.new(6, 7.3, 46), C.oro, Enum.Material.Metal)
mesa("TabureteAlto", 3, 51, 2.4, 2.4, 4.4, C.madera)

-- 🛏️ Sofá cama (mira hacia el salón)
sofa("SofaCama", -16, 47, 11, C.tela, 0)
bloque("MantaSofaCama", Vector3.new(6, 0.3, 4), Vector3.new(-16, 3.2, 48), Color3.fromRGB(150, 150, 160), Enum.Material.Fabric)

-- 🛋️ El sofá de la izquierda, mirando a la tele
sofa("SofaSalon", -20, 57, 9, C.tela, 0)
mesa("MesaCentro", -20, 63, 6, 3.5, 2.6, C.madera)

-- 📺 La tele, más adelante
bloque("MuebleTele", Vector3.new(11, 2.4, 3), Vector3.new(-20, 2.2, 68.5), C.madera, Enum.Material.Wood)
local pantalla = bloque("Tele", Vector3.new(10, 5.6, 0.5), Vector3.new(-20, 6.4, 68.3), C.negro, Enum.Material.Glass)
pantalla.Reflectance = 0.25

local luzTele = Instance.new("PointLight")
luzTele.Brightness = 0.9
luzTele.Range = 20
luzTele.Color = Color3.fromRGB(120, 160, 255)   -- luz azul de tele encendida
luzTele.Parent = pantalla
table.insert(lamparas, { pieza = pantalla, luz = luzTele, noBrillar = true })

--==================================================================
-- 🪟 LAS CORTINAS (tapan el comedor, en x = 8, de z 48 a 72)
--==================================================================
bloque("BarraCortinas", Vector3.new(0.6, 0.5, 26), Vector3.new(8, 16.2, 60), C.oro, Enum.Material.Metal)

local cortinaIzq = bloque("CortinaIzq", Vector3.new(0.6, 15, 12), Vector3.new(8, 8.5, 54), C.cortina, Enum.Material.Fabric)
local cortinaDer = bloque("CortinaDer", Vector3.new(0.6, 15, 12), Vector3.new(8, 8.5, 66), C.cortina, Enum.Material.Fabric)

--==================================================================
-- 🍽️ EL COMEDOR (detrás de las cortinas: x de 8 a 34, z de 44 a 80)
--==================================================================
suelo("SueloComedor", 8, 34, 44, 80, C.marmol, Enum.Material.Marble)
techo("TechoComedor", 8, 34, 44, 80)
paredX("ComedorDer", 34, 44, 80)
paredZ("ComedorFrente", 44, 8, 34)
paredZ("ComedorFondo", 80, 8, 34)
decorarParedX(34, 44, 80, -1)
cuadro(34, 62, 8, -1)

lamparaArania("AraniaComedor", 21, 62)

-- La mesa ANCHA
mesa("MesaComedor", 21, 62, 17, 8, 5.4, C.madera)

-- 🪴 La planta encima de la mesa
bloque("Maceta", Vector3.new(2.6, 2.4, 2.6), Vector3.new(21, 6.9, 62), Color3.fromRGB(150, 92, 60), Enum.Material.Slate)
for _, sitio in ipairs({ Vector3.new(0, 2.4, 0), Vector3.new(1.1, 1.8, 0.6), Vector3.new(-1, 1.9, -0.5) }) do
	local hoja = bloque("Hojas", Vector3.new(2.6, 2.6, 2.6), Vector3.new(21, 6.9, 62) + sitio, C.planta, Enum.Material.Grass)
	hoja.Shape = Enum.PartType.Ball
end

-- Seis sillas alrededor de la mesa
for i = 1, 6 do
	local lado = (i <= 3) and -1 or 1
	local zs = 57 + ((i - 1) % 3) * 5
	bloque("SillaComedor", Vector3.new(2.6, 0.5, 2.6), Vector3.new(21 + lado * 6, 3.6, zs), C.madera, Enum.Material.Wood)
	bloque("SillaRespaldoComedor", Vector3.new(2.6, 4, 0.4), Vector3.new(21 + lado * 6, 5.6, zs + lado * 1.2), C.madera, Enum.Material.Wood)
	for _, d in ipairs({ {1, 1}, {1, -1}, {-1, 1}, {-1, -1} }) do
		bloque("PataSilla", Vector3.new(0.4, 2.4, 0.4),
			Vector3.new(21 + lado * 6 + d[1], 2.3, zs + d[2]), C.madera, Enum.Material.Wood)
	end
end

-- Aparador contra la pared del fondo
mesa("Aparador", 21, 77.5, 12, 3, 4, C.madera)

--==================================================================
-- 🔒 LA HABITACIÓN DE PAPÁ Y MAMÁ (puerta cerrada con llave)
--==================================================================
local puertaPadres = bloque("PuertaPadres", Vector3.new(6, 8, 0.6), Vector3.new(-1, 5, 84), C.madera, Enum.Material.Wood)
bloque("MarcoPuertaPadres", Vector3.new(7.4, 9.4, 0.4), Vector3.new(-1, 5.4, 84.4), C.oro, Enum.Material.Metal)
bloque("PomoPadres", Vector3.new(0.7, 0.7, 0.7), Vector3.new(1.2, 5, 83.6), C.oro, Enum.Material.Metal)
bloque("CerraduraPadres", Vector3.new(0.5, 1, 0.5), Vector3.new(1.2, 4, 83.6), C.metal, Enum.Material.Metal)

--==================================================================
-- 🍳 LA COCINA (x de -34 a -8, z de 84 a 112). Se entra por el salón.
--==================================================================
suelo("SueloCocina", -34, -8, 84, 112, C.marmol, Enum.Material.Marble)
techo("TechoCocina", -34, -8, 84, 112)
paredZ("CocinaFrente", 84, -34, -26)
paredX("CocinaIzq", -34, 84, 112)
paredX("CocinaDer", -8, 84, 112)
paredZ("CocinaFondo", 112, -34, -8)

-- El marco de la puerta de la cocina (el hueco va de x -20 a -14)
bloque("MarcoCocinaIzq", Vector3.new(0.6, 9, 1.4), Vector3.new(-20.3, 5.5, 84), C.oro, Enum.Material.Metal)
bloque("MarcoCocinaDer", Vector3.new(0.6, 9, 1.4), Vector3.new(-13.7, 5.5, 84), C.oro, Enum.Material.Metal)
bloque("MarcoCocinaAlto", Vector3.new(7, 0.6, 1.4), Vector3.new(-17, 9.7, 84), C.oro, Enum.Material.Metal)
bloque("SobrePuertaCocina", Vector3.new(6, 7, 1), Vector3.new(-17, 13.5, 84), C.pared)

lampara("LamparaCocina1", -28, 92, 1.6, 30)
lampara("LamparaCocina2", -16, 106, 1.6, 30)

-- 🗄️ MUCHÍSIMOS CAJONES: una fila larga contra la pared del fondo...
local function armario(x, z, giro)
	local giroCF = CFrame.Angles(0, math.rad(giro), 0)

	local cuerpo = bloque("Armario", Vector3.new(3, 4, 2.6), Vector3.new(0, 0, 0), C.madera, Enum.Material.Wood)
	cuerpo.CFrame = CFrame.new(x, 3, z) * giroCF

	local encimera = bloque("Encimera", Vector3.new(3.2, 0.5, 3), Vector3.new(0, 0, 0), C.marmol, Enum.Material.Marble)
	encimera.CFrame = CFrame.new(x, 5.2, z) * giroCF

	-- dos cajones con su tirador
	for i = 0, 1 do
		local frente = bloque("Cajon", Vector3.new(2.6, 1.6, 0.2), Vector3.new(0, 0, 0),
			Color3.fromRGB(92, 62, 42), Enum.Material.Wood)
		frente.CFrame = CFrame.new(x, 2.1 + i * 1.9, z) * giroCF * CFrame.new(0, 0, -1.45)

		local tirador = bloque("Tirador", Vector3.new(1.4, 0.24, 0.24), Vector3.new(0, 0, 0), C.oro, Enum.Material.Metal)
		tirador.CFrame = CFrame.new(x, 2.1 + i * 1.9, z) * giroCF * CFrame.new(0, 0, -1.7)
	end
end

for i = 0, 7 do                       -- pared del fondo de la cocina
	armario(-32 + i * 3.2, 110.4, 0)
end
for i = 0, 6 do                       -- pared de la izquierda
	armario(-32.4, 88 + i * 3.2, 90)
end

-- ...y armarios altos encima (más cajones todavía)
for i = 0, 7 do
	bloque("ArmarioAlto", Vector3.new(3, 4, 2), Vector3.new(-32 + i * 3.2, 10, 110.8), C.madera, Enum.Material.Wood)
	bloque("TiradorAlto", Vector3.new(1.4, 0.24, 0.24), Vector3.new(-32 + i * 3.2, 8.4, 109.7), C.oro, Enum.Material.Metal)
end

-- 🏝️ Isla central
mesa("Isla", -22, 98, 11, 6, 5, C.madera)
bloque("EncimeraIsla", Vector3.new(12, 0.5, 7), Vector3.new(-22, 5.4, 98), C.marmol, Enum.Material.Marble)
for i = 0, 2 do
	lampara("LamparaIsla" .. i, -26 + i * 4, 98, 0.9, 18)
end

-- 🧊 LA NEVERA (grande, de dos puertas, contra la pared derecha)
local nevera = bloque("Nevera", Vector3.new(5, 11, 6.5), Vector3.new(-11, 6.5, 100), C.metal, Enum.Material.Metal)
nevera.Reflectance = 0.15
bloque("NeveraPuertaAlta", Vector3.new(0.4, 6.4, 6.1), Vector3.new(-13.6, 8.6, 100), Color3.fromRGB(176, 180, 188), Enum.Material.Metal)
bloque("NeveraPuertaBaja", Vector3.new(0.4, 4, 6.1), Vector3.new(-13.6, 3.4, 100), Color3.fromRGB(176, 180, 188), Enum.Material.Metal)
bloque("NeveraTirador1", Vector3.new(0.35, 4.4, 0.35), Vector3.new(-14, 8.6, 102.4), C.oro, Enum.Material.Metal)
bloque("NeveraTirador2", Vector3.new(0.35, 3, 0.35), Vector3.new(-14, 3.4, 102.4), C.oro, Enum.Material.Metal)

--==================================================================
-- 💡 QUE TODAS LAS LUCES PARPADEEN (cada una a su ritmo)
--==================================================================
for _, lamp in ipairs(lamparas) do
	-- task.spawn lanza esto "en paralelo": todas parpadean a la vez, sin esperarse
	task.spawn(function()
		while lamp.pieza.Parent do
			-- espera tranquila de 3 a 16 segundos
			task.wait(math.random(30, 160) / 10)

			-- y entonces... una ráfaga de parpadeos
			for _ = 1, math.random(2, 7) do
				lamp.luz.Enabled = false
				if not lamp.noBrillar then
					lamp.pieza.Material = Enum.Material.SmoothPlastic
				end
				task.wait(math.random(3, 14) / 100)

				lamp.luz.Enabled = true
				if not lamp.noBrillar then
					lamp.pieza.Material = Enum.Material.Neon
				end
				task.wait(math.random(4, 22) / 100)
			end
		end
	end)
end

print("🏠 Casa construida: pasillo, salón, comedor, cocina y la puerta cerrada.")
print("   Luces parpadeando: " .. #lamparas)
