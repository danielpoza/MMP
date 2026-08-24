--[[
	ConstruirCasa  ·  DOS PLANTAS  ·  ESCALA x8
	-------------------------------------------
	🔧 EL NÚMERO MÁGICO está aquí abajo: ESCALA.
	   Con 1 la casa es "normal". Con 8 todo mide 8 veces más:
	   pasillos, habitaciones, escaleras, puertas y cortinas.
	   Si te resulta demasiado, prueba con 4 o con 6. Cambias el número,
	   le das a Play, y la casa entera se rehace sola. 🪄

	📐 Con ESCALA = 8 cada sala mide 160 x 160 studs ≈ 45 x 45 metros.

	🏡 EL PLANO
	   PLANTA BAJA                          PLANTA ALTA
	   ┌─────────┬───┬─────────┐            ┌─────────┬───┬─────────┐
	   │ SALÓN   │ P │ COMEDOR │            │DESPACHO │ P │ PADRES  │
	   ├─────────┤ A ├─────────┤            ├─────────┤ A ├─────────┤
	   │ COCINA  │ S │ESCALERA │            │  BAÑO   │ S │ hueco   │
	   └─────────┴───┴─────────┘            └─────────┴───┴─────────┘
	                ▲ tu CUARTO (ese no cambia)

	Dónde va: ServerScriptService -> ➕ -> Script -> se llama ConstruirCasa
]]

--==================================================================
-- 🔧 LOS DOS INTERRUPTORES
--==================================================================
local ESCALA = 8            -- pasillos, habitaciones, escaleras, puertas y cortinas
local ESCALA_MUEBLES = 1    -- los muebles. Ponlo a 8 si los quieres gigantes también

--==================================================================
-- 📐 EL PLANO (estos números NO cambian: son el plano "en pequeño",
--    y el ESCALA de arriba los multiplica solo)
--==================================================================
local ALTO = 10             -- altura de cada planta
local Y0 = 1                -- suelo de la planta baja
local Y1 = Y0 + ALTO + 1    -- suelo de la planta alta
local Z0 = 11               -- donde empieza la casa, pegada a tu puerta

local SALON    = { -25, -5, 15, 35 }
local COMEDOR  = { 5, 25, 15, 35 }
local COCINA   = { -25, -5, 35, 55 }
local ESCALERA = { 5, 25, 35, 55 }
local RELLANO  = { 5, 25, 48, 55 }

local PAS_X1, PAS_X2 = -5, 5
local PAS_Z1, PAS_Z2 = 11, 55

-- 🧮 Pasar del plano al mundo. La casa crece hacia los lados y hacia el
--    fondo, pero el principio (Z0) se queda pegado a tu puerta.
local function px(x) return x * ESCALA end
local function pz(z) return Z0 + (z - Z0) * ESCALA end
local function py(y) return Y0 + (y - Y0) * ESCALA end

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

local GROSOR = 1 * ESCALA        -- lo gordas que son paredes y suelos

local function suelo(nombre, x1, x2, z1, z2, base, color, material)
	return bloque(nombre, Vector3.new((x2 - x1) * ESCALA, GROSOR, (z2 - z1) * ESCALA),
		Vector3.new(px((x1 + x2) / 2), py(base) - GROSOR / 2, pz((z1 + z2) / 2)),
		color or C.parquet, material)
end

local function sala(nombre, caja, base, color, material)
	return suelo(nombre, caja[1], caja[2], caja[3], caja[4], base, color, material)
end

local function techo(nombre, x1, x2, z1, z2, base)
	return bloque(nombre, Vector3.new((x2 - x1) * ESCALA, GROSOR, (z2 - z1) * ESCALA),
		Vector3.new(px((x1 + x2) / 2), py(base) + ALTO * ESCALA + GROSOR / 2, pz((z1 + z2) / 2)), C.techo)
end

local function paredX(nombre, x, z1, z2, base)
	return bloque(nombre, Vector3.new(GROSOR, ALTO * ESCALA, (z2 - z1) * ESCALA),
		Vector3.new(px(x), py(base) + ALTO * ESCALA / 2, pz((z1 + z2) / 2)), C.pared)
end

local function paredZ(nombre, z, x1, x2, base)
	return bloque(nombre, Vector3.new((x2 - x1) * ESCALA, ALTO * ESCALA, GROSOR),
		Vector3.new(px((x1 + x2) / 2), py(base) + ALTO * ESCALA / 2, pz(z)), C.pared)
end

-- Dintel: el trozo de pared que va encima del hueco de una puerta
local function dintelX(nombre, x, za, zb, base)
	local altoPuerta = 8 * ESCALA
	local resto = ALTO * ESCALA - altoPuerta
	return bloque(nombre, Vector3.new(GROSOR, resto, (zb - za) * ESCALA),
		Vector3.new(px(x), py(base) + altoPuerta + resto / 2, pz((za + zb) / 2)), C.pared)
end

local function marcoPuertaX(x, za, zb, base)
	local h = 8 * ESCALA
	local g = 0.5 * ESCALA
	bloque("MarcoA", Vector3.new(g, h, g), Vector3.new(px(x), py(base) + h / 2, pz(za)), C.oro, Enum.Material.Metal)
	bloque("MarcoB", Vector3.new(g, h, g), Vector3.new(px(x), py(base) + h / 2, pz(zb)), C.oro, Enum.Material.Metal)
	bloque("MarcoC", Vector3.new(g, g, (zb - za) * ESCALA), Vector3.new(px(x), py(base) + h, pz((za + zb) / 2)), C.oro, Enum.Material.Metal)
end

-- ✨ Los trazos bonitos de las paredes
local function decorarParedX(x, z1, z2, hacia, base)
	local xd = px(x) + hacia * 0.6 * ESCALA
	local largo = (z2 - z1) * ESCALA
	local zc0 = pz((z1 + z2) / 2)
	local e = ESCALA

	bloque("Zocalo", Vector3.new(0.3 * e, 1.6 * e, largo), Vector3.new(xd, py(base) + 0.8 * e, zc0), C.oro, Enum.Material.Metal)
	bloque("Moldura", Vector3.new(0.3 * e, 0.5 * e, largo), Vector3.new(xd, py(base) + (ALTO - 0.8) * e, zc0), C.oro, Enum.Material.Metal)

	local cuantos = math.max(1, math.floor((z2 - z1) / 7))
	for i = 1, cuantos do
		local zc = pz(z1 + (i - 0.5) * ((z2 - z1) / cuantos))
		bloque("Marco", Vector3.new(0.25 * e, 5 * e, 0.3 * e), Vector3.new(xd, py(base) + 5.5 * e, zc - 2 * e), C.oro, Enum.Material.Metal)
		bloque("Marco", Vector3.new(0.25 * e, 5 * e, 0.3 * e), Vector3.new(xd, py(base) + 5.5 * e, zc + 2 * e), C.oro, Enum.Material.Metal)
		bloque("Marco", Vector3.new(0.25 * e, 0.3 * e, 4 * e), Vector3.new(xd, py(base) + 3 * e, zc), C.oro, Enum.Material.Metal)
		bloque("Marco", Vector3.new(0.25 * e, 0.3 * e, 4 * e), Vector3.new(xd, py(base) + 8 * e, zc), C.oro, Enum.Material.Metal)
	end
end

local function cuadro(x, z, ancho, hacia, base)
	local e = ESCALA
	bloque("CuadroMarco", Vector3.new(0.4 * e, 5 * e, ancho * e), Vector3.new(px(x) + hacia * 0.8 * e, py(base) + 5.5 * e, pz(z)), C.oro, Enum.Material.Metal)
	bloque("CuadroLienzo", Vector3.new(0.2 * e, 4.2 * e, (ancho - 0.8) * e), Vector3.new(px(x) + hacia * 1.1 * e, py(base) + 5.5 * e, pz(z)), Color3.fromRGB(40, 34, 44))
end

-- 💡 Lámparas: crecen con la casa, y su luz también (si no, no llegaría)
local function lampara(nombre, x, z, base, brillo, alcance, color)
	local e = ESCALA
	local techoY = py(base) + ALTO * e

	bloque(nombre .. "Cable", Vector3.new(0.2 * e, 1.4 * e, 0.2 * e), Vector3.new(px(x), techoY - 0.7 * e, pz(z)), C.oro, Enum.Material.Metal)
	local bombilla = bloque(nombre, Vector3.new(2.2 * e, 1.2 * e, 2.2 * e), Vector3.new(px(x), techoY - 2 * e, pz(z)), C.bombilla, Enum.Material.Neon)

	local luz = Instance.new("PointLight")
	luz.Brightness = brillo
	luz.Range = math.min(60, alcance * e)          -- Roblox no deja pasar de 60
	luz.Color = color or Color3.fromRGB(255, 224, 170)
	luz.Shadows = true
	luz.Parent = bombilla

	table.insert(lamparas, { pieza = bombilla, luz = luz })
	return bombilla
end

local function lamparaArania(nombre, x, z, base)
	local e = ESCALA
	local techoY = py(base) + ALTO * e

	bloque(nombre .. "Cadena", Vector3.new(0.3 * e, 2 * e, 0.3 * e), Vector3.new(px(x), techoY - 1 * e, pz(z)), C.oro, Enum.Material.Metal)
	bloque(nombre .. "Centro", Vector3.new(1.8 * e, 1.4 * e, 1.8 * e), Vector3.new(px(x), techoY - 2.6 * e, pz(z)), C.oro, Enum.Material.Metal)

	for i = 1, 6 do
		local angulo = math.rad(i * 60)
		local bx = px(x) + math.cos(angulo) * 3 * e
		local bz = pz(z) + math.sin(angulo) * 3 * e

		bloque(nombre .. "Brazo", Vector3.new(0.22 * e, 0.22 * e, 0.22 * e), Vector3.new(bx, techoY - 2.6 * e, bz), C.oro, Enum.Material.Metal)
		local vela = bloque(nombre .. i, Vector3.new(0.8 * e, 1.4 * e, 0.8 * e), Vector3.new(bx, techoY - 3.3 * e, bz), C.bombilla, Enum.Material.Neon)

		local luz = Instance.new("PointLight")
		luz.Brightness = 1.6
		luz.Range = math.min(60, 26 * e)
		luz.Color = Color3.fromRGB(255, 220, 160)
		luz.Shadows = true
		luz.Parent = vela

		table.insert(lamparas, { pieza = vela, luz = luz })
	end
end

-- 💡 Una sala gigante necesita VARIAS lámparas: la luz de Roblox no llega
--    a más de 60 studs, así que ponemos una rejilla según lo grande que sea.
local function iluminarSala(nombre, caja, base, brillo)
	local cuantas = math.max(1, math.floor(ESCALA / 3))
	local anchoX = (caja[2] - caja[1]) / (cuantas + 1)
	local anchoZ = (caja[4] - caja[3]) / (cuantas + 1)

	for i = 1, cuantas do
		for j = 1, cuantas do
			lampara(nombre .. i .. j, caja[1] + i * anchoX, caja[3] + j * anchoZ, base, brillo or 1.5, 24)
		end
	end
end

-- 🪑 MUEBLES: van con su propia escala (ESCALA_MUEBLES), pero colocados
--    en el sitio que les toca de la casa grande.
local M = ESCALA_MUEBLES

local function mueble(nombre, x, z, tam, alturaCentro, base, color, material)
	return bloque(nombre, tam * M, Vector3.new(px(x), py(base) + alturaCentro * M, pz(z)), color, material)
end

local function mesa(nombre, x, z, ancho, fondo, altura, color, base)
	bloque(nombre, Vector3.new(ancho, 0.6, fondo) * M,
		Vector3.new(px(x), py(base) + altura * M, pz(z)), color, Enum.Material.Wood)

	local dx, dz = (ancho / 2 - 0.7) * M, (fondo / 2 - 0.7) * M
	for _, e in ipairs({ {dx, dz}, {-dx, dz}, {dx, -dz}, {-dx, -dz} }) do
		bloque(nombre .. "Pata", Vector3.new(0.6, altura - 0.3, 0.6) * M,
			Vector3.new(px(x) + e[1], py(base) + (altura - 0.3) / 2 * M, pz(z) + e[2]), color, Enum.Material.Wood)
	end
end

local function sofa(nombre, x, z, ancho, color, giro, base)
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
		local p = bloque(nombre .. "Parte", d[1] * M, Vector3.new(0, 0, 0), color, Enum.Material.Fabric)
		p.CFrame = CFrame.new(px(x), py(base), pz(z)) * giroCF * CFrame.new(d[2] * M)
		p.Parent = modelo
	end
	return modelo
end

local function armario(x, z, giro, base)
	local giroCF = CFrame.Angles(0, math.rad(giro), 0)
	local centro = CFrame.new(px(x), py(base), pz(z)) * giroCF

	local cuerpo = bloque("Armario", Vector3.new(3, 4, 2.6) * M, Vector3.new(0, 0, 0), C.madera, Enum.Material.Wood)
	cuerpo.CFrame = centro * CFrame.new(0, 2 * M, 0)

	local encimera = bloque("Encimera", Vector3.new(3.2, 0.5, 3) * M, Vector3.new(0, 0, 0), C.marmol, Enum.Material.Marble)
	encimera.CFrame = centro * CFrame.new(0, 4.2 * M, 0)

	for i = 0, 1 do
		local frente = bloque("Cajon", Vector3.new(2.6, 1.6, 0.2) * M, Vector3.new(0, 0, 0), Color3.fromRGB(92, 62, 42), Enum.Material.Wood)
		frente.CFrame = centro * CFrame.new(0, (1.1 + i * 1.9) * M, -1.45 * M)

		local tirador = bloque("Tirador", Vector3.new(1.4, 0.24, 0.24) * M, Vector3.new(0, 0, 0), C.oro, Enum.Material.Metal)
		tirador.CFrame = centro * CFrame.new(0, (1.1 + i * 1.9) * M, -1.7 * M)
	end
end

--==================================================================
-- 🧱 SUELOS Y FORJADOS
--==================================================================
suelo("SueloPasillo", PAS_X1, PAS_X2, PAS_Z1, PAS_Z2, Y0, C.marmol, Enum.Material.Marble)
sala("SueloSalon", SALON, Y0, C.parquet, Enum.Material.WoodPlanks)
sala("SueloComedor", COMEDOR, Y0, C.marmol, Enum.Material.Marble)
sala("SueloCocina", COCINA, Y0, C.marmol, Enum.Material.Marble)
sala("SueloEscalera", ESCALERA, Y0, C.marmol, Enum.Material.Marble)

-- El FORJADO es a la vez techo de abajo y suelo de arriba.
-- Encima de la escalera NO hay, para que se vea el hueco. 🕳️
suelo("ForjadoPasillo", PAS_X1, PAS_X2, PAS_Z1, PAS_Z2, Y1, C.parquet, Enum.Material.WoodPlanks)
sala("ForjadoDespacho", SALON, Y1, C.parquet, Enum.Material.WoodPlanks)
sala("ForjadoPadres", COMEDOR, Y1, C.parquet, Enum.Material.WoodPlanks)
sala("ForjadoBano", COCINA, Y1, C.bano, Enum.Material.Marble)
sala("ForjadoRellano", RELLANO, Y1, C.parquet, Enum.Material.WoodPlanks)

techo("Tejado", -25, 25, PAS_Z1, PAS_Z2, Y1)

--==================================================================
-- 🚪 PAREDES
--==================================================================
for _, base in ipairs({ Y0, Y1 }) do
	paredX("PasilloIzqA", PAS_X1, PAS_Z1, 22, base)
	dintelX("PasilloIzqDintel1", PAS_X1, 22, 28, base)
	paredX("PasilloIzqB", PAS_X1, 28, 42, base)
	dintelX("PasilloIzqDintel2", PAS_X1, 42, 48, base)
	paredX("PasilloIzqC", PAS_X1, 48, PAS_Z2, base)
	marcoPuertaX(PAS_X1, 22, 28, base)
	marcoPuertaX(PAS_X1, 42, 48, base)

	paredZ("PasilloFondo", PAS_Z2, PAS_X1, PAS_X2, base)
	decorarParedX(PAS_X1, 28, 42, 1, base)
	decorarParedX(PAS_X2, 28, 42, -1, base)
	cuadro(PAS_X1, 35, 4, 1, base)

	paredX("ParedIzqCasaA", -25, 15, 35, base)
	paredX("ParedIzqCasaB", -25, 35, 55, base)
	paredX("ParedDerCasaA", 25, 15, 35, base)
	paredX("ParedDerCasaB", 25, 35, 55, base)
	paredZ("ParedFrenteIzq", 15, -25, PAS_X1, base)
	paredZ("ParedFrenteDer", 15, PAS_X2, 25, base)
	paredZ("ParedFondoIzq", 55, -25, PAS_X1, base)
	paredZ("ParedFondoDer", 55, PAS_X2, 25, base)
	paredZ("ParedMediaIzq", 35, -25, PAS_X1, base)
	paredZ("ParedMediaDer", 35, PAS_X2, 25, base)
end

-- Pared derecha ABAJO (el hueco del comedor va de suelo a techo: cortinas)
paredX("PasilloDerA", PAS_X2, PAS_Z1, 22, Y0)
paredX("PasilloDerB", PAS_X2, 28, 42, Y0)
dintelX("PasilloDerDintel", PAS_X2, 42, 48, Y0)
paredX("PasilloDerC", PAS_X2, 48, PAS_Z2, Y0)
marcoPuertaX(PAS_X2, 42, 48, Y0)

-- Pared derecha ARRIBA (puerta de los padres + salida al rellano)
paredX("PasilloDerAltoA", PAS_X2, PAS_Z1, 22, Y1)
dintelX("PasilloDerAltoDintel1", PAS_X2, 22, 28, Y1)
paredX("PasilloDerAltoB", PAS_X2, 28, 48, Y1)
dintelX("PasilloDerAltoDintel2", PAS_X2, 48, 54, Y1)
paredX("PasilloDerAltoC", PAS_X2, 54, PAS_Z2, Y1)
marcoPuertaX(PAS_X2, 22, 28, Y1)
marcoPuertaX(PAS_X2, 48, 54, Y1)

paredZ("PasilloFrenteAlto", PAS_Z1, PAS_X1, PAS_X2, Y1)

--==================================================================
-- 🚪 LA PARED DE LA ENTRADA, con el agujerito de TU puerta
--    (tu cuarto no crece, así que aquí la casa gigante se "estrecha"
--     hasta una puerta de tu tamaño)
--==================================================================
local ANCHO_PAS = (PAS_X2 - PAS_X1) * ESCALA
local ALTO_PLANTA = ALTO * ESCALA
local Z_ENTRADA = 13.5

bloque("EntradaIzq", Vector3.new(ANCHO_PAS / 2 - 3, ALTO_PLANTA, 2),
	Vector3.new(-(ANCHO_PAS / 2 - 3) / 2 - 3, Y0 + ALTO_PLANTA / 2, Z_ENTRADA), C.pared)
bloque("EntradaDer", Vector3.new(ANCHO_PAS / 2 - 3, ALTO_PLANTA, 2),
	Vector3.new((ANCHO_PAS / 2 - 3) / 2 + 3, Y0 + ALTO_PLANTA / 2, Z_ENTRADA), C.pared)
bloque("EntradaArriba", Vector3.new(6, ALTO_PLANTA - 8, 2),
	Vector3.new(0, Y0 + 8 + (ALTO_PLANTA - 8) / 2, Z_ENTRADA), C.pared)
bloque("EntradaMarco", Vector3.new(7.5, 9.5, 1), Vector3.new(0, Y0 + 4.6, Z_ENTRADA - 1.2), C.oro, Enum.Material.Metal)

-- La cara de FUERA de tu puerta: aquí sale el cartel [E] Entrar
local puertaFuera = bloque("PuertaFuera", Vector3.new(6, 8, 0.4), Vector3.new(0, Y0 + 4, 15.4), C.pared)
puertaFuera.Transparency = 1
puertaFuera.CanCollide = false

-- 📍 Donde apareces al salir del cuarto (Opciones lo lee de aquí)
local llegada = bloque("LlegadaPasillo", Vector3.new(4, 1, 4), Vector3.new(0, Y0 + 3, 24), C.pared)
llegada.Transparency = 1
llegada.CanCollide = false
llegada.CFrame = CFrame.lookAt(Vector3.new(0, Y0 + 3, 24), Vector3.new(0, Y0 + 3, 60))

bloque("AlfombraPasillo", Vector3.new(6 * ESCALA, 0.4, 40 * ESCALA), Vector3.new(0, Y0 + 0.2, pz(33)), C.alfombra, Enum.Material.Fabric)

for i = 0, 3 do
	lampara("LamparaPasillo" .. i, 0, 18 + i * 11, Y0, 1.4, 24)
	lampara("LamparaPasilloAlto" .. i, 0, 18 + i * 11, Y1, 1.4, 24)
end

--==================================================================
-- 🪟 LAS CORTINAS (tapan la entrada del comedor)
--==================================================================
local e = ESCALA
bloque("BarraCortinas", Vector3.new(0.7 * e, 0.4 * e, 7 * e), Vector3.new(px(PAS_X2), py(Y0) + (ALTO - 0.4) * e, pz(25)), C.oro, Enum.Material.Metal)
bloque("CortinaIzq", Vector3.new(0.6 * e, (ALTO - 0.6) * e, 3 * e), Vector3.new(px(PAS_X2), py(Y0) + (ALTO - 0.6) / 2 * e, pz(23.5)), C.cortina, Enum.Material.Fabric)
bloque("CortinaDer", Vector3.new(0.6 * e, (ALTO - 0.6) * e, 3 * e), Vector3.new(px(PAS_X2), py(Y0) + (ALTO - 0.6) / 2 * e, pz(26.5)), C.cortina, Enum.Material.Fabric)

--==================================================================
-- 🪜 LA ESCALERA
--    Los escalones NO pueden crecer x8 (¡nadie podría subirlos!), así
--    que se calculan solos: cuantos más haga falta, más pone. 🧠
--==================================================================
local SUBIDA_TOTAL = (Y1 - Y0) * ESCALA
local LARGO_ESCALERA = 12.5 * ESCALA
local ESCALONES = math.ceil(SUBIDA_TOTAL / 1.6)      -- máximo 1,6 de alto por escalón
local SUBIDA = SUBIDA_TOTAL / ESCALONES
local FONDO = LARGO_ESCALERA / ESCALONES
local ANCHO_ESC = 10 * ESCALA
local X_ESC = px(20)
local Z_ESC = pz(35.5)

for i = 1, ESCALONES do
	local altura = SUBIDA * i
	local z = Z_ESC + (i - 0.5) * FONDO

	bloque("Escalon" .. i, Vector3.new(ANCHO_ESC, altura, FONDO),
		Vector3.new(X_ESC, Y0 + altura / 2, z), C.marmol, Enum.Material.Marble)

	if i % 6 == 0 then
		bloque("BarrotEscalera", Vector3.new(0.6, 6, 0.6), Vector3.new(X_ESC - ANCHO_ESC / 2 + 0.5, Y0 + altura + 3, z), C.oro, Enum.Material.Metal)
	end
end

local largoPasamanos = math.sqrt(SUBIDA_TOTAL ^ 2 + LARGO_ESCALERA ^ 2)
local pasamanos = bloque("PasamanosEscalera", Vector3.new(0.7, 0.7, largoPasamanos),
	Vector3.new(X_ESC - ANCHO_ESC / 2 + 0.5, Y0 + SUBIDA_TOTAL / 2 + 5, Z_ESC + LARGO_ESCALERA / 2), C.oro, Enum.Material.Metal)
pasamanos.CFrame = CFrame.new(pasamanos.Position) * CFrame.Angles(-math.atan2(SUBIDA_TOTAL, LARGO_ESCALERA), 0, 0)

-- Barandilla del rellano, para no caerse por el hueco 🕳️
local zBarandilla = pz(48)
for i = 0, 12 do
	bloque("BarrotRellano", Vector3.new(0.6, 6, 0.6), Vector3.new(px(5) + 2 + i * (ANCHO_ESC - 4) / 12, py(Y1) + 3, zBarandilla), C.oro, Enum.Material.Metal)
end
bloque("PasamanosRellano", Vector3.new(ANCHO_ESC, 0.7, 0.7), Vector3.new(px(5) + ANCHO_ESC / 2, py(Y1) + 6, zBarandilla), C.oro, Enum.Material.Metal)

iluminarSala("LuzEscalera", ESCALERA, Y0, 1.3)

--==================================================================
-- 🛋️ EL SALÓN
--==================================================================
lamparaArania("AraniaSalon", -15, 25, Y0)
iluminarSala("LuzSalon", SALON, Y0, 1.2)
bloque("AlfombraSalon", Vector3.new(12 * e, 0.4, 10 * e), Vector3.new(px(-15), Y0 + 0.2, pz(24)), Color3.fromRGB(78, 66, 62), Enum.Material.Fabric)

mueble("MuebleTele", -15, 16.8, Vector3.new(10, 2.2, 2.6), 1.1, Y0, C.madera, Enum.Material.Wood)
local pantalla = mueble("Tele", -15, 16.6, Vector3.new(9, 5, 0.5), 5, Y0, C.negro, Enum.Material.Glass)
pantalla.Reflectance = 0.25

local luzTele = Instance.new("PointLight")
luzTele.Brightness = 1.4 ; luzTele.Range = 40
luzTele.Color = Color3.fromRGB(120, 160, 255)
luzTele.Parent = pantalla
table.insert(lamparas, { pieza = pantalla, luz = luzTele, noBrillar = true })

sofa("SofaSalon", -15, 30, 9, C.tela, 180, Y0)
mesa("MesaCentro", -15, 24, 5, 3, 2.4, C.madera, Y0)
mesa("Estanteria", -23, 25, 2, 8, 6, C.madera, Y0)

--==================================================================
-- 🍽️ EL COMEDOR
--==================================================================
lamparaArania("AraniaComedor", 15, 25, Y0)
iluminarSala("LuzComedor", COMEDOR, Y0, 1.2)
mesa("MesaComedor", 15, 25, 12, 6, 5, C.madera, Y0)

mueble("Maceta", 15, 25, Vector3.new(2.2, 2, 2.2), 6.2, Y0, Color3.fromRGB(150, 92, 60), Enum.Material.Slate)
for _, sitio in ipairs({ {0, 2, 0}, {0.9, 1.5, 0.5}, {-0.9, 1.6, -0.4} }) do
	local hoja = bloque("Hojas", Vector3.new(2.2, 2.2, 2.2) * M,
		Vector3.new(px(15) + sitio[1] * M, py(Y0) + (6.2 + sitio[2]) * M, pz(25) + sitio[3] * M), C.planta, Enum.Material.Grass)
	hoja.Shape = Enum.PartType.Ball
end

for i = 1, 6 do
	local lado = (i <= 3) and -1 or 1
	local zs = 21 + ((i - 1) % 3) * 4
	local xs = 15 + lado * 4.6 * M / e     -- las sillas se pegan a la mesa
	mueble("SillaComedor", xs, zs, Vector3.new(2.4, 0.5, 2.4), 2.6, Y0, C.madera, Enum.Material.Wood)
	mueble("SillaRespaldo", xs, zs + lado * 1.1 * M / e, Vector3.new(2.4, 3.6, 0.4), 4.4, Y0, C.madera, Enum.Material.Wood)
end

mesa("Aparador", 15, 17.5, 10, 2.6, 4, C.madera, Y0)
cuadro(25, 25, 5, -1, Y0)

--==================================================================
-- 🍳 LA COCINA
--==================================================================
iluminarSala("LuzCocina", COCINA, Y0, 1.6)

for i = 0, 4 do armario(-22 + i * 3.2 * M / e, 53.4, 0, Y0) end
for i = 0, 4 do armario(-23.4, 38 + i * 3.2 * M / e, 90, Y0) end
for i = 0, 4 do
	mueble("ArmarioAlto", -22 + i * 3.2 * M / e, 53.6, Vector3.new(3, 3.4, 2), 7.2, Y0, C.madera, Enum.Material.Wood)
	mueble("TiradorAlto", -22 + i * 3.2 * M / e, 52.6, Vector3.new(1.4, 0.24, 0.24), 5.8, Y0, C.oro, Enum.Material.Metal)
end

mesa("Isla", -15, 45, 9, 4.5, 4.2, C.madera, Y0)
mueble("EncimeraIsla", -15, 45, Vector3.new(10, 0.5, 5.5), 4.5, Y0, C.marmol, Enum.Material.Marble)
for i = 0, 2 do lampara("LamparaIsla" .. i, -18 + i * 3, 45, Y0, 0.8, 14) end

-- 🧊 LA NEVERA
local nevera = mueble("Nevera", -8, 42, Vector3.new(4.5, 9, 6), 4.5, Y0, C.metal, Enum.Material.Metal)
nevera.Reflectance = 0.15
mueble("NeveraPuertaAlta", -8 - 2.3 * M / e, 42, Vector3.new(0.4, 5.2, 5.6), 6.2, Y0, Color3.fromRGB(176, 180, 188), Enum.Material.Metal)
mueble("NeveraPuertaBaja", -8 - 2.3 * M / e, 42, Vector3.new(0.4, 3.4, 5.6), 1.9, Y0, Color3.fromRGB(176, 180, 188), Enum.Material.Metal)
mueble("NeveraTirador1", -8 - 2.6 * M / e, 42 + 2.3 * M / e, Vector3.new(0.3, 3.6, 0.3), 6.2, Y0, C.oro, Enum.Material.Metal)

--==================================================================
-- 🖊️ EL DESPACHO (arriba)
--==================================================================
iluminarSala("LuzDespacho", SALON, Y1, 1.4)
mesa("Escritorio", -19, 20, 8, 4, 6, C.madera, Y1)
mueble("Flexo", -16.5, 20, Vector3.new(0.7, 1.8, 0.7), 7, Y1, C.oro, Enum.Material.Metal)
mesa("TabureteAlto", -19, 24.5, 2.2, 2.2, 4.2, C.madera, Y1)

sofa("SofaCama", -15, 31, 10, C.tela, 180, Y1)
mueble("MantaSofaCama", -15, 30, Vector3.new(5, 0.3, 3.5), 2.2, Y1, Color3.fromRGB(150, 150, 160), Enum.Material.Fabric)
mesa("EstanteriaDespacho", -23.5, 30, 2, 9, 7, C.madera, Y1)
cuadro(-25, 20, 5, 1, Y1)

--==================================================================
-- 🛁 EL BAÑO (arriba)
--==================================================================
iluminarSala("LuzBano", COCINA, Y1, 1.5)

mueble("Banera", -20, 50, Vector3.new(9, 3, 5), 1.5, Y1, C.bano)
mueble("AguaBanera", -20, 50, Vector3.new(8.2, 0.4, 4.2), 2.9, Y1, C.agua, Enum.Material.Glass)
mueble("Lavabo", -20, 38, Vector3.new(4, 1.2, 3), 4, Y1, C.bano)
mueble("PieLavabo", -20, 38, Vector3.new(1.4, 3.4, 1.4), 1.7, Y1, C.bano)
local espejo = mueble("Espejo", -20, 36.4, Vector3.new(3.6, 4, 0.3), 6.6, Y1, Color3.fromRGB(190, 210, 220), Enum.Material.Glass)
espejo.Reflectance = 0.6
mueble("Vater", -9, 50, Vector3.new(2.6, 2.4, 3), 1.2, Y1, C.bano)
mueble("VaterTapa", -9, 51.6, Vector3.new(2.6, 2.6, 0.6), 2.5, Y1, C.bano)

--==================================================================
-- 🔒 LA HABITACIÓN DE PAPÁ Y MAMÁ (arriba, CERRADA)
--    La puerta SÍ crece: es una puerta de la casa.
--==================================================================
bloque("PuertaPadres", Vector3.new(0.6 * e, 8 * e, 6 * e), Vector3.new(px(PAS_X2), py(Y1) + 4 * e, pz(25)), C.madera, Enum.Material.Wood)
bloque("PomoPadres", Vector3.new(0.7 * e, 0.7 * e, 0.7 * e), Vector3.new(px(PAS_X2) - 0.6 * e, py(Y1) + 4 * e, pz(22.8)), C.oro, Enum.Material.Metal)
bloque("CerraduraPadres", Vector3.new(0.5 * e, 1 * e, 0.5 * e), Vector3.new(px(PAS_X2) - 0.6 * e, py(Y1) + 3 * e, pz(22.8)), C.metal, Enum.Material.Metal)

mueble("CamaPadres", 18, 25, Vector3.new(10, 1.6, 8), 0.8, Y1, C.madera, Enum.Material.Wood)
mueble("ColchonPadres", 18, 25, Vector3.new(9.4, 1, 7.4), 2.1, Y1, Color3.fromRGB(180, 175, 165), Enum.Material.Fabric)
mesa("ArmarioPadres", 10, 18, 3, 6, 8, C.madera, Y1)
iluminarSala("LuzPadres", COMEDOR, Y1, 1)

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

casa:SetAttribute("Listo", true)

print("🏠 Casa construida con ESCALA = " .. ESCALA)
print("   Cada sala mide " .. (20 * ESCALA) .. " x " .. (20 * ESCALA) .. " studs (≈ "
	.. math.floor(20 * ESCALA * 0.28) .. " x " .. math.floor(20 * ESCALA * 0.28) .. " metros)")
print("   Escalera de " .. ESCALONES .. " escalones. Lámparas: " .. #lamparas)
