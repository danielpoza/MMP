--[[
	ConstruirCasa  ·  DOS PLANTAS
	-----------------------------
	📐 LA MEDIDA: en Roblox se mide en "studs". 1 stud ≈ 0,28 metros.
	   Una sala de 20 x 20 studs = 5,6 x 5,6 metros ≈ 32 m². ✅
	   Cada planta mide 10 studs de alto ≈ 2,8 m (como una casa de verdad).

	🏡 EL PLANO
	   PLANTA BAJA                          PLANTA ALTA
	   ┌─────────┬───┬─────────┐            ┌─────────┬───┬─────────┐
	   │ SALÓN   │ P │ COMEDOR │            │DESPACHO │ P │ PADRES  │
	   │ 32 m²   │ A │ 32 m²   │            │ 32 m²   │ A │ 🔒32 m² │
	   ├─────────┤ S ├─────────┤            ├─────────┤ S ├─────────┤
	   │ COCINA  │ I │ESCALERA │            │  BAÑO   │ I │ hueco   │
	   │ 32 m²   │ L │         │            │ 32 m²   │ L │ +rellano│
	   └─────────┴───┴─────────┘            └─────────┴───┴─────────┘
	   Tu cuarto sigue igual, pegado al principio del pasillo.

	Dónde va: ServerScriptService -> ➕ -> Script -> se llama ConstruirCasa
]]

--==================================================================
-- 📐 MEDIDAS (cámbialas y la casa entera se rehace sola)
--==================================================================
local ALTO = 10          -- altura de cada planta
local Y0 = 1             -- suelo de la planta baja
local Y1 = Y0 + ALTO + 1 -- 12 = suelo de la planta alta (1 = grosor del forjado)

-- Las cuatro salas, en {x1, x2, z1, z2}. Todas de 20 x 20 = 32 m²
local SALON    = { -25, -5, 15, 35 }
local COMEDOR  = { 5, 25, 15, 35 }
local COCINA   = { -25, -5, 35, 55 }
local ESCALERA = { 5, 25, 35, 55 }
local RELLANO  = { 5, 25, 48, 55 }

local PAS_X1, PAS_X2 = -5, 5      -- el pasillo (10 de ancho)
local PAS_Z1, PAS_Z2 = 11, 55

local C = {
	pared = Color3.fromRGB(200, 189, 168), techo = Color3.fromRGB(236, 232, 224),
	oro = Color3.fromRGB(198, 162, 82), marmol = Color3.fromRGB(226, 223, 214),
	parquet = Color3.fromRGB(96, 62, 38), madera = Color3.fromRGB(72, 46, 30),
	tela = Color3.fromRGB(96, 104, 120), cortina = Color3.fromRGB(112, 26, 38),
	alfombra = Color3.fromRGB(120, 30, 34), metal = Color3.fromRGB(198, 200, 206),
	negro = Color3.fromRGB(18, 18, 20), planta = Color3.fromRGB(58, 120, 52),
	bombilla = Color3.fromRGB(255, 236, 200), bano = Color3.fromRGB(222, 234, 238),
	agua = Color3.fromRGB(120, 190, 220),
}

local anterior = workspace:FindFirstChild("Casa")
if anterior then anterior:Destroy() end

local casa = Instance.new("Model")
casa.Name = "Casa"
casa.Parent = workspace

local lamparas = {}

--==================================================================
-- 🧰 HERRAMIENTAS
--==================================================================
local function bloque(nombre, tam, pos, color, material)
	local p = Instance.new("Part")
	p.Name = nombre ; p.Size = tam ; p.Position = pos ; p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = casa
	return p
end

-- Suelo: la superficie queda justo en la altura "base"
local function suelo(nombre, x1, x2, z1, z2, base, color, material)
	return bloque(nombre, Vector3.new(x2 - x1, 1, z2 - z1),
		Vector3.new((x1 + x2) / 2, base - 0.5, (z1 + z2) / 2), color or C.parquet, material)
end

local function sala(nombre, caja, base, color, material)     -- suelo de una sala entera
	return suelo(nombre, caja[1], caja[2], caja[3], caja[4], base, color, material)
end

local function techo(nombre, x1, x2, z1, z2, base)
	return bloque(nombre, Vector3.new(x2 - x1, 1, z2 - z1),
		Vector3.new((x1 + x2) / 2, base + ALTO + 0.5, (z1 + z2) / 2), C.techo)
end

local function paredX(nombre, x, z1, z2, base)               -- pared a lo largo de Z
	return bloque(nombre, Vector3.new(1, ALTO, z2 - z1),
		Vector3.new(x, base + ALTO / 2, (z1 + z2) / 2), C.pared)
end

local function paredZ(nombre, z, x1, x2, base)               -- pared a lo largo de X
	return bloque(nombre, Vector3.new(x2 - x1, ALTO, 1),
		Vector3.new((x1 + x2) / 2, base + ALTO / 2, z), C.pared)
end

-- Dintel: el trocito de pared que va ENCIMA del hueco de una puerta
local function dintelX(nombre, x, za, zb, base)
	return bloque(nombre, Vector3.new(1, ALTO - 8, zb - za),
		Vector3.new(x, base + 8 + (ALTO - 8) / 2, (za + zb) / 2), C.pared)
end

local function marcoPuertaX(x, za, zb, base)
	bloque("MarcoA", Vector3.new(0.5, 8.4, 0.6), Vector3.new(x, base + 4.2, za), C.oro, Enum.Material.Metal)
	bloque("MarcoB", Vector3.new(0.5, 8.4, 0.6), Vector3.new(x, base + 4.2, zb), C.oro, Enum.Material.Metal)
	bloque("MarcoC", Vector3.new(0.5, 0.6, zb - za), Vector3.new(x, base + 8.2, (za + zb) / 2), C.oro, Enum.Material.Metal)
end

-- ✨ Los trazos bonitos de las paredes
local function decorarParedX(x, z1, z2, hacia, base)
	local xd = x + hacia * 0.6
	local largo = z2 - z1
	bloque("Zocalo", Vector3.new(0.3, 1.6, largo), Vector3.new(xd, base + 0.8, (z1 + z2) / 2), C.oro, Enum.Material.Metal)
	bloque("Moldura", Vector3.new(0.3, 0.5, largo), Vector3.new(xd, base + ALTO - 0.8, (z1 + z2) / 2), C.oro, Enum.Material.Metal)

	local cuantos = math.max(1, math.floor(largo / 7))
	for i = 1, cuantos do
		local zc = z1 + (i - 0.5) * (largo / cuantos)
		bloque("Marco", Vector3.new(0.25, 5, 0.3), Vector3.new(xd, base + 5.5, zc - 2), C.oro, Enum.Material.Metal)
		bloque("Marco", Vector3.new(0.25, 5, 0.3), Vector3.new(xd, base + 5.5, zc + 2), C.oro, Enum.Material.Metal)
		bloque("Marco", Vector3.new(0.25, 0.3, 4), Vector3.new(xd, base + 3, zc), C.oro, Enum.Material.Metal)
		bloque("Marco", Vector3.new(0.25, 0.3, 4), Vector3.new(xd, base + 8, zc), C.oro, Enum.Material.Metal)
	end
end

local function cuadro(x, z, ancho, hacia, base)
	bloque("CuadroMarco", Vector3.new(0.4, 5, ancho), Vector3.new(x + hacia * 0.8, base + 5.5, z), C.oro, Enum.Material.Metal)
	bloque("CuadroLienzo", Vector3.new(0.2, 4.2, ancho - 0.8), Vector3.new(x + hacia * 1.1, base + 5.5, z), Color3.fromRGB(40, 34, 44))
end

-- 💡 Lámparas (se apuntan solas a la lista del parpadeo)
local function lampara(nombre, x, z, base, brillo, alcance, color)
	local techoY = base + ALTO
	bloque(nombre .. "Cable", Vector3.new(0.2, 1.4, 0.2), Vector3.new(x, techoY - 0.7, z), C.oro, Enum.Material.Metal)
	local bombilla = bloque(nombre, Vector3.new(2.2, 1.2, 2.2), Vector3.new(x, techoY - 2, z), C.bombilla, Enum.Material.Neon)

	local luz = Instance.new("PointLight")
	luz.Brightness = brillo ; luz.Range = alcance
	luz.Color = color or Color3.fromRGB(255, 224, 170)
	luz.Shadows = true ; luz.Parent = bombilla

	table.insert(lamparas, { pieza = bombilla, luz = luz })
	return bombilla
end

local function lamparaArania(nombre, x, z, base)
	local techoY = base + ALTO
	bloque(nombre .. "Cadena", Vector3.new(0.3, 2, 0.3), Vector3.new(x, techoY - 1, z), C.oro, Enum.Material.Metal)
	bloque(nombre .. "Centro", Vector3.new(1.8, 1.4, 1.8), Vector3.new(x, techoY - 2.6, z), C.oro, Enum.Material.Metal)

	for i = 1, 6 do
		local angulo = math.rad(i * 60)
		local bx, bz = x + math.cos(angulo) * 3, z + math.sin(angulo) * 3
		bloque(nombre .. "Brazo", Vector3.new(0.22, 0.22, 0.22), Vector3.new(bx, techoY - 2.6, bz), C.oro, Enum.Material.Metal)
		local vela = bloque(nombre .. i, Vector3.new(0.8, 1.4, 0.8), Vector3.new(bx, techoY - 3.3, bz), C.bombilla, Enum.Material.Neon)

		local luz = Instance.new("PointLight")
		luz.Brightness = 1.4 ; luz.Range = 26
		luz.Color = Color3.fromRGB(255, 220, 160)
		luz.Shadows = true ; luz.Parent = vela

		table.insert(lamparas, { pieza = vela, luz = luz })
	end
end

-- 🪑 Mesa con patas. "altura" es lo que levanta el tablero sobre el suelo.
local function mesa(nombre, x, z, ancho, fondo, altura, color, base)
	base = base or Y0
	bloque(nombre, Vector3.new(ancho, 0.6, fondo), Vector3.new(x, base + altura, z), color, Enum.Material.Wood)
	local dx, dz = ancho / 2 - 0.7, fondo / 2 - 0.7
	for _, e in ipairs({ {dx, dz}, {-dx, dz}, {dx, -dz}, {-dx, -dz} }) do
		bloque(nombre .. "Pata", Vector3.new(0.6, altura - 0.3, 0.6),
			Vector3.new(x + e[1], base + (altura - 0.3) / 2, z + e[2]), color, Enum.Material.Wood)
	end
end

-- 🛋️ Sofá. giro = hacia dónde mira (0, 90, 180, 270)
local function sofa(nombre, x, z, ancho, color, giro, base)
	base = base or Y0
	local modelo = Instance.new("Model")
	modelo.Name = nombre ; modelo.Parent = casa

	local piezas = {
		{ Vector3.new(ancho, 1.6, 5.5), Vector3.new(0, 1.3, 0) },
		{ Vector3.new(ancho, 3.2, 1.2), Vector3.new(0, 3.2, -2.6) },
		{ Vector3.new(1.2, 2.4, 5.5), Vector3.new(-ancho / 2 + 0.6, 2.3, 0) },
		{ Vector3.new(1.2, 2.4, 5.5), Vector3.new(ancho / 2 - 0.6, 2.3, 0) },
	}

	local giroCF = CFrame.Angles(0, math.rad(giro), 0)
	for _, d in ipairs(piezas) do
		local p = bloque(nombre .. "Parte", d[1], Vector3.new(0, 0, 0), color, Enum.Material.Fabric)
		p.CFrame = CFrame.new(x, base, z) * giroCF * CFrame.new(d[2])
		p.Parent = modelo
	end
	return modelo
end

-- 🗄️ Armario de cocina con dos cajones
local function armario(x, z, giro)
	local giroCF = CFrame.Angles(0, math.rad(giro), 0)

	local cuerpo = bloque("Armario", Vector3.new(3, 4, 2.6), Vector3.new(0, 0, 0), C.madera, Enum.Material.Wood)
	cuerpo.CFrame = CFrame.new(x, Y0 + 2, z) * giroCF

	local encimera = bloque("Encimera", Vector3.new(3.2, 0.5, 3), Vector3.new(0, 0, 0), C.marmol, Enum.Material.Marble)
	encimera.CFrame = CFrame.new(x, Y0 + 4.2, z) * giroCF

	for i = 0, 1 do
		local frente = bloque("Cajon", Vector3.new(2.6, 1.6, 0.2), Vector3.new(0, 0, 0), Color3.fromRGB(92, 62, 42), Enum.Material.Wood)
		frente.CFrame = CFrame.new(x, Y0 + 1.1 + i * 1.9, z) * giroCF * CFrame.new(0, 0, -1.45)
		local tirador = bloque("Tirador", Vector3.new(1.4, 0.24, 0.24), Vector3.new(0, 0, 0), C.oro, Enum.Material.Metal)
		tirador.CFrame = CFrame.new(x, Y0 + 1.1 + i * 1.9, z) * giroCF * CFrame.new(0, 0, -1.7)
	end
end

--==================================================================
-- 🧱 LOS SUELOS
--==================================================================
suelo("SueloPasillo", PAS_X1, PAS_X2, PAS_Z1, PAS_Z2, Y0, C.marmol, Enum.Material.Marble)
sala("SueloSalon", SALON, Y0, C.parquet, Enum.Material.WoodPlanks)
sala("SueloComedor", COMEDOR, Y0, C.marmol, Enum.Material.Marble)
sala("SueloCocina", COCINA, Y0, C.marmol, Enum.Material.Marble)
sala("SueloEscalera", ESCALERA, Y0, C.marmol, Enum.Material.Marble)

-- El FORJADO: es a la vez el techo de abajo y el suelo de arriba.
-- Ojo: encima de la escalera NO hay forjado, para que se vea el hueco. 🕳️
suelo("ForjadoPasillo", PAS_X1, PAS_X2, PAS_Z1, PAS_Z2, Y1, C.parquet, Enum.Material.WoodPlanks)
sala("ForjadoDespacho", SALON, Y1, C.parquet, Enum.Material.WoodPlanks)
sala("ForjadoPadres", COMEDOR, Y1, C.parquet, Enum.Material.WoodPlanks)
sala("ForjadoBano", COCINA, Y1, C.bano, Enum.Material.Marble)
sala("ForjadoRellano", RELLANO, Y1, C.parquet, Enum.Material.WoodPlanks)

-- El tejado, encima de todo
techo("Tejado", -25, 25, PAS_Z1, PAS_Z2, Y1)

--==================================================================
-- 🚪 PLANTA BAJA: paredes
--==================================================================
for _, base in ipairs({ Y0, Y1 }) do
	-- Pared izquierda del pasillo, con dos huecos de puerta
	paredX("PasilloIzqA", PAS_X1, PAS_Z1, 22, base)
	dintelX("PasilloIzqDintel1", PAS_X1, 22, 28, base)
	paredX("PasilloIzqB", PAS_X1, 28, 42, base)
	dintelX("PasilloIzqDintel2", PAS_X1, 42, 48, base)
	paredX("PasilloIzqC", PAS_X1, 48, PAS_Z2, base)
	marcoPuertaX(PAS_X1, 22, 28, base)
	marcoPuertaX(PAS_X1, 42, 48, base)

	-- Fondo del pasillo y decoración
	paredZ("PasilloFondo", PAS_Z2, PAS_X1, PAS_X2, base)
	decorarParedX(PAS_X1, 28, 42, 1, base)
	decorarParedX(PAS_X2, 28, 42, -1, base)
	cuadro(PAS_X1, 35, 4, 1, base)
end

-- Pared derecha del pasillo, PLANTA BAJA (el hueco del comedor va sin dintel,
-- de suelo a techo, porque lo tapan las cortinas)
paredX("PasilloDerA", PAS_X2, PAS_Z1, 22, Y0)
paredX("PasilloDerB", PAS_X2, 28, 42, Y0)
dintelX("PasilloDerDintel", PAS_X2, 42, 48, Y0)
paredX("PasilloDerC", PAS_X2, 48, PAS_Z2, Y0)
marcoPuertaX(PAS_X2, 42, 48, Y0)

-- Pared derecha del pasillo, PLANTA ALTA (puerta de los padres + rellano)
paredX("PasilloDerAltoA", PAS_X2, PAS_Z1, 22, Y1)
dintelX("PasilloDerAltoDintel1", PAS_X2, 22, 28, Y1)
paredX("PasilloDerAltoB", PAS_X2, 28, 48, Y1)
dintelX("PasilloDerAltoDintel2", PAS_X2, 48, 54, Y1)
paredX("PasilloDerAltoC", PAS_X2, 54, PAS_Z2, Y1)
marcoPuertaX(PAS_X2, 22, 28, Y1)
marcoPuertaX(PAS_X2, 48, 54, Y1)

-- El principio del pasillo de arriba (abajo lo tapa la pared de tu cuarto)
paredZ("PasilloFrenteAlto", PAS_Z1, PAS_X1, PAS_X2, Y1)

-- Paredes de fuera de cada sala (las dos plantas a la vez)
for _, base in ipairs({ Y0, Y1 }) do
	paredX("ParedIzqCasaA", -25, 15, 35, base)     -- salón / despacho
	paredX("ParedIzqCasaB", -25, 35, 55, base)     -- cocina / baño
	paredX("ParedDerCasaA", 25, 15, 35, base)      -- comedor / padres
	paredX("ParedDerCasaB", 25, 35, 55, base)      -- escalera (doble altura)
	paredZ("ParedFrenteIzq", 15, -25, PAS_X1, base)
	paredZ("ParedFrenteDer", 15, PAS_X2, 25, base)
	paredZ("ParedFondoIzq", 55, -25, PAS_X1, base)
	paredZ("ParedFondoDer", 55, PAS_X2, 25, base)
	paredZ("ParedMediaIzq", 35, -25, PAS_X1, base) -- entre salón y cocina
	paredZ("ParedMediaDer", 35, PAS_X2, 25, base)  -- entre comedor y escalera
end

-- La cara de FUERA de tu puerta (invisible): aquí sale el cartel [E] Entrar
local puertaFuera = bloque("PuertaFuera", Vector3.new(6, 8, 0.4), Vector3.new(0, Y0 + 4, 12.9), C.pared)
puertaFuera.Transparency = 1
puertaFuera.CanCollide = false

bloque("AlfombraPasillo", Vector3.new(6, 0.12, 40), Vector3.new(0, Y0 + 0.06, 33), C.alfombra, Enum.Material.Fabric)
lampara("LamparaPasillo1", 0, 20, Y0, 1.4, 24)
lampara("LamparaPasillo2", 0, 44, Y0, 1.4, 24)
lampara("LamparaPasilloAlto1", 0, 20, Y1, 1.4, 24)
lampara("LamparaPasilloAlto2", 0, 44, Y1, 1.4, 24)

--==================================================================
-- 🪟 LAS CORTINAS (tapan la entrada del comedor, de suelo a techo)
--==================================================================
bloque("BarraCortinas", Vector3.new(0.7, 0.4, 7), Vector3.new(PAS_X2, Y0 + ALTO - 0.4, 25), C.oro, Enum.Material.Metal)
bloque("CortinaIzq", Vector3.new(0.6, ALTO - 0.6, 3), Vector3.new(PAS_X2, Y0 + (ALTO - 0.6) / 2, 23.5), C.cortina, Enum.Material.Fabric)
bloque("CortinaDer", Vector3.new(0.6, ALTO - 0.6, 3), Vector3.new(PAS_X2, Y0 + (ALTO - 0.6) / 2, 26.5), C.cortina, Enum.Material.Fabric)

--==================================================================
-- 🪜 LA ESCALERA (16 escalones desde la planta baja hasta la de arriba)
--==================================================================
local ESCALONES = 16
local SUBIDA = (Y1 - Y0) / ESCALONES          -- lo que sube cada escalón
local FONDO = 12.5 / ESCALONES                -- lo que ocupa cada escalón

for i = 1, ESCALONES do
	local altura = SUBIDA * i
	local z = 35.5 + (i - 0.5) * FONDO

	bloque("Escalon" .. i, Vector3.new(10, altura, FONDO),
		Vector3.new(20, Y0 + altura / 2, z), C.marmol, Enum.Material.Marble)

	-- barandilla del lado abierto
	if i % 2 == 0 then
		bloque("BarrotEscalera", Vector3.new(0.25, 3.4, 0.25), Vector3.new(15.3, Y0 + altura + 1.7, z), C.oro, Enum.Material.Metal)
	end
end

-- El pasamanos va inclinado igual que la escalera (unos 41 grados)
local pasamanos = bloque("PasamanosEscalera", Vector3.new(0.35, 0.35, 16.8),
	Vector3.new(15.3, Y0 + 9.2, 41.8), C.oro, Enum.Material.Metal)
pasamanos.CFrame = CFrame.new(15.3, Y0 + 9.2, 41.8) * CFrame.Angles(math.rad(-41), 0, 0)

-- Barandilla del rellano de arriba, para no caerse por el hueco 🕳️
for i = 0, 5 do
	bloque("BarrotRellano", Vector3.new(0.25, 3.4, 0.25), Vector3.new(5.6 + i * 1.9, Y1 + 1.7, 48), C.oro, Enum.Material.Metal)
end
bloque("PasamanosRellano", Vector3.new(10, 0.35, 0.35), Vector3.new(10, Y1 + 3.4, 48), C.oro, Enum.Material.Metal)

lampara("LamparaEscalera", 12, 44, Y0, 1.3, 26)

--==================================================================
-- 🛋️ EL SALÓN (planta baja, izquierda)
--==================================================================
lamparaArania("AraniaSalon", -15, 25, Y0)
bloque("AlfombraSalon", Vector3.new(12, 0.12, 10), Vector3.new(-15, Y0 + 0.06, 24), Color3.fromRGB(78, 66, 62), Enum.Material.Fabric)

bloque("MuebleTele", Vector3.new(10, 2.2, 2.6), Vector3.new(-15, Y0 + 1.1, 16.8), C.madera, Enum.Material.Wood)
local pantalla = bloque("Tele", Vector3.new(9, 5, 0.5), Vector3.new(-15, Y0 + 5, 16.6), C.negro, Enum.Material.Glass)
pantalla.Reflectance = 0.25

local luzTele = Instance.new("PointLight")
luzTele.Brightness = 0.8 ; luzTele.Range = 18
luzTele.Color = Color3.fromRGB(120, 160, 255)
luzTele.Parent = pantalla
table.insert(lamparas, { pieza = pantalla, luz = luzTele, noBrillar = true })

sofa("SofaSalon", -15, 30, 9, C.tela, 180, Y0)      -- mirando a la tele
mesa("MesaCentro", -15, 24, 5, 3, 2.4, C.madera, Y0)
mesa("Estanteria", -23, 25, 2, 8, 6, C.madera, Y0)

--==================================================================
-- 🍽️ EL COMEDOR (planta baja, derecha, detrás de las cortinas)
--==================================================================
lamparaArania("AraniaComedor", 15, 25, Y0)
mesa("MesaComedor", 15, 25, 12, 6, 5, C.madera, Y0)

bloque("Maceta", Vector3.new(2.2, 2, 2.2), Vector3.new(15, Y0 + 6.2, 25), Color3.fromRGB(150, 92, 60), Enum.Material.Slate)
for _, sitio in ipairs({ Vector3.new(0, 2, 0), Vector3.new(0.9, 1.5, 0.5), Vector3.new(-0.9, 1.6, -0.4) }) do
	local hoja = bloque("Hojas", Vector3.new(2.2, 2.2, 2.2), Vector3.new(15, Y0 + 6.2, 25) + sitio, C.planta, Enum.Material.Grass)
	hoja.Shape = Enum.PartType.Ball
end

for i = 1, 6 do
	local lado = (i <= 3) and -1 or 1
	local zs = 21 + ((i - 1) % 3) * 4
	bloque("SillaComedor", Vector3.new(2.4, 0.5, 2.4), Vector3.new(15 + lado * 4.6, Y0 + 2.6, zs), C.madera, Enum.Material.Wood)
	bloque("SillaRespaldo", Vector3.new(2.4, 3.6, 0.4), Vector3.new(15 + lado * 4.6, Y0 + 4.4, zs + lado * 1.1), C.madera, Enum.Material.Wood)
	for _, d in ipairs({ {0.9, 0.9}, {0.9, -0.9}, {-0.9, 0.9}, {-0.9, -0.9} }) do
		bloque("PataSilla", Vector3.new(0.35, 2.2, 0.35), Vector3.new(15 + lado * 4.6 + d[1], Y0 + 1.1, zs + d[2]), C.madera, Enum.Material.Wood)
	end
end

mesa("Aparador", 15, 17.5, 10, 2.6, 4, C.madera, Y0)
cuadro(25, 25, 5, -1, Y0)

--==================================================================
-- 🍳 LA COCINA (planta baja, izquierda al fondo)
--==================================================================
lampara("LamparaCocina", -15, 45, Y0, 1.6, 28)

for i = 0, 4 do armario(-22 + i * 3.2, 53.4, 0) end        -- fila del fondo
for i = 0, 4 do armario(-23.4, 38 + i * 3.2, 90) end       -- fila de la izquierda
for i = 0, 4 do                                            -- armarios altos
	bloque("ArmarioAlto", Vector3.new(3, 3.4, 2), Vector3.new(-22 + i * 3.2, Y0 + 7.2, 53.6), C.madera, Enum.Material.Wood)
	bloque("TiradorAlto", Vector3.new(1.4, 0.24, 0.24), Vector3.new(-22 + i * 3.2, Y0 + 5.8, 52.6), C.oro, Enum.Material.Metal)
end

mesa("Isla", -15, 45, 9, 4.5, 4.2, C.madera, Y0)
bloque("EncimeraIsla", Vector3.new(10, 0.5, 5.5), Vector3.new(-15, Y0 + 4.5, 45), C.marmol, Enum.Material.Marble)
for i = 0, 2 do lampara("LamparaIsla" .. i, -18 + i * 3, 45, Y0, 0.8, 14) end

-- 🧊 LA NEVERA (pegada a la pared del pasillo)
local nevera = bloque("Nevera", Vector3.new(4.5, 9, 6), Vector3.new(-8, Y0 + 4.5, 42), C.metal, Enum.Material.Metal)
nevera.Reflectance = 0.15
bloque("NeveraPuertaAlta", Vector3.new(0.4, 5.2, 5.6), Vector3.new(-10.3, Y0 + 6.2, 42), Color3.fromRGB(176, 180, 188), Enum.Material.Metal)
bloque("NeveraPuertaBaja", Vector3.new(0.4, 3.4, 5.6), Vector3.new(-10.3, Y0 + 1.9, 42), Color3.fromRGB(176, 180, 188), Enum.Material.Metal)
bloque("NeveraTirador1", Vector3.new(0.3, 3.6, 0.3), Vector3.new(-10.6, Y0 + 6.2, 44.3), C.oro, Enum.Material.Metal)
bloque("NeveraTirador2", Vector3.new(0.3, 2.4, 0.3), Vector3.new(-10.6, Y0 + 1.9, 44.3), C.oro, Enum.Material.Metal)

--==================================================================
-- 🖊️ EL DESPACHO (planta alta, izquierda)
--==================================================================
lampara("LamparaDespacho", -15, 25, Y1, 1.4, 26)
mesa("Escritorio", -19, 20, 8, 4, 6, C.madera, Y1)          -- el escritorio ALTO
bloque("Flexo", Vector3.new(0.7, 1.8, 0.7), Vector3.new(-16.5, Y1 + 7, 20), C.oro, Enum.Material.Metal)
mesa("TabureteAlto", -19, 24.5, 2.2, 2.2, 4.2, C.madera, Y1)

sofa("SofaCama", -15, 31, 10, C.tela, 180, Y1)
bloque("MantaSofaCama", Vector3.new(5, 0.3, 3.5), Vector3.new(-15, Y1 + 2.2, 30), Color3.fromRGB(150, 150, 160), Enum.Material.Fabric)
mesa("EstanteriaDespacho", -23.5, 30, 2, 9, 7, C.madera, Y1)
cuadro(-25, 20, 5, 1, Y1)

--==================================================================
-- 🛁 EL BAÑO (planta alta, izquierda al fondo)
--==================================================================
lampara("LamparaBano", -15, 45, Y1, 1.5, 24)

bloque("Banera", Vector3.new(9, 3, 5), Vector3.new(-20, Y1 + 1.5, 50), C.bano, Enum.Material.SmoothPlastic)
bloque("AguaBanera", Vector3.new(8.2, 0.4, 4.2), Vector3.new(-20, Y1 + 2.9, 50), C.agua, Enum.Material.Glass)
bloque("Grifo", Vector3.new(0.4, 1.6, 0.4), Vector3.new(-24, Y1 + 3.8, 50), C.metal, Enum.Material.Metal)

bloque("Lavabo", Vector3.new(4, 1.2, 3), Vector3.new(-20, Y1 + 4, 38), C.bano)
bloque("PieLavabo", Vector3.new(1.4, 3.4, 1.4), Vector3.new(-20, Y1 + 1.7, 38), C.bano)
local espejo = bloque("Espejo", Vector3.new(3.6, 4, 0.3), Vector3.new(-20, Y1 + 6.6, 36.4), Color3.fromRGB(190, 210, 220), Enum.Material.Glass)
espejo.Reflectance = 0.6

bloque("Vater", Vector3.new(2.6, 2.4, 3), Vector3.new(-9, Y1 + 1.2, 50), C.bano)
bloque("VaterTapa", Vector3.new(2.6, 2.6, 0.6), Vector3.new(-9, Y1 + 2.5, 51.6), C.bano)

--==================================================================
-- 🔒 LA HABITACIÓN DE PAPÁ Y MAMÁ (planta alta, derecha, CERRADA)
--==================================================================
bloque("PuertaPadres", Vector3.new(0.6, 8, 6), Vector3.new(PAS_X2, Y1 + 4, 25), C.madera, Enum.Material.Wood)
bloque("PomoPadres", Vector3.new(0.7, 0.7, 0.7), Vector3.new(PAS_X2 - 0.6, Y1 + 4, 22.8), C.oro, Enum.Material.Metal)
bloque("CerraduraPadres", Vector3.new(0.5, 1, 0.5), Vector3.new(PAS_X2 - 0.6, Y1 + 3, 22.8), C.metal, Enum.Material.Metal)

-- Está cerrada, pero por dentro también hay habitación (para el día que se abra 👀)
bloque("CamaPadres", Vector3.new(10, 1.6, 8), Vector3.new(18, Y1 + 0.8, 25), C.madera, Enum.Material.Wood)
bloque("ColchonPadres", Vector3.new(9.4, 1, 7.4), Vector3.new(18, Y1 + 2.1, 25), Color3.fromRGB(180, 175, 165), Enum.Material.Fabric)
mesa("ArmarioPadres", 10, 18, 3, 6, 8, C.madera, Y1)
lampara("LamparaPadres", 15, 25, Y1, 1, 22)

--==================================================================
-- 💡 QUE TODAS LAS LUCES PARPADEEN
--==================================================================
for _, lamp in ipairs(lamparas) do
	task.spawn(function()
		while lamp.pieza.Parent do
			task.wait(math.random(30, 160) / 10)
			for _ = 1, math.random(2, 7) do
				lamp.luz.Enabled = false
				if not lamp.noBrillar then lamp.pieza.Material = Enum.Material.SmoothPlastic end
				task.wait(math.random(3, 14) / 100)
				lamp.luz.Enabled = true
				if not lamp.noBrillar then lamp.pieza.Material = Enum.Material.Neon end
				task.wait(math.random(4, 22) / 100)
			end
		end
	end)
end

-- 🚩 Bandera: avisa a los demás scripts de que la casa ya está terminada
casa:SetAttribute("Listo", true)

print("🏠 Casa de DOS PLANTAS construida. Salas de 20x20 studs ≈ 32 m².")
print("   Luces parpadeando: " .. #lamparas)
