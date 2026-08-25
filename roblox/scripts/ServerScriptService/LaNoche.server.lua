--[[
	LA NOCHE  ·  TODO EL JUEGO EN UN SOLO SCRIPT (servidor)
	=======================================================
	Aquí dentro está TODO lo que hace el servidor, y en el ORDEN correcto:

	   1. La noche       5. El monstruo
	   2. Tu cuarto      6. Las balizas de luz del suelo
	   3. La mansión     7. Las opciones de la tecla [E]
	   4. El jardín      8. La persecución

	🛡️ POR QUÉ ESTÁ TODO JUNTO
	   Antes había ocho scripts sueltos, y Roblox no los arranca siempre en
	   el mismo orden. Como cada uno borraba y volvía a montar la casa, en
	   cada partida ganaba uno distinto: por eso la casa cambiaba sola. 😤
	   Aquí eso no puede pasar: se ejecuta todo seguido, en orden, siempre.

	🚨 Y ADEMÁS: si por lo que sea acaba habiendo DOS copias de este script,
	   la segunda se apaga sola y te avisa en la Output. Nunca más se pelean.

	Dónde va: ServerScriptService -> ➕ -> Script
	Nómbralo: LaNoche
]]

--==================================================================
-- 🛡️ EL GUARDIÁN: que no se ejecute dos veces
--==================================================================
if _G.LaNocheYaArranco then
	warn("⛔ ¡Este script ya se estaba ejecutando! Tienes un DUPLICADO en")
	warn("   ServerScriptService. Búscalo y bórralo. Esta copia se apaga sola.")
	return
end

_G.LaNocheYaArranco = true

print("═══════════════════════════════════")
print("🌙 LA NOCHE — arrancando el juego...")
print("═══════════════════════════════════")

--==================================================================
-- 🌙 1. LA NOCHE
--==================================================================
local function ambiente()
local Lighting = game:GetService("Lighting")

-- La hora del mundo: 0 = medianoche, 12 = mediodía
Lighting.ClockTime = 0

-- Brillo general del sol/luna (cuanto más bajo, más oscuro)
Lighting.Brightness = 0.4

-- Ambient = la luz que hay "por todas partes" aunque no haya lámparas.
-- Casi negro con un puntito azul = noche fría y siniestra.
Lighting.Ambient = Color3.fromRGB(12, 12, 22)
Lighting.OutdoorAmbient = Color3.fromRGB(14, 14, 26)

-- Quitamos la luz de relleno del cielo: si no, nunca está oscuro del todo
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.GlobalShadows = true      -- que las cosas hagan sombra
Lighting.ExposureCompensation = 0

-- Niebla: no ves más allá de unos pocos metros. Da mucho miedo. 👻
-- (Si el juego trae un "Atmosphere", manda ese; así que lo ajustamos también.)
Lighting.FogColor = Color3.fromRGB(6, 6, 10)
Lighting.FogStart = 8
Lighting.FogEnd = 70

local atmosfera = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosfera then
	atmosfera = Instance.new("Atmosphere")
	atmosfera.Parent = Lighting
end
atmosfera.Density = 0.55       -- 0 = aire limpio, 1 = niebla total
atmosfera.Offset = 0
atmosfera.Color = Color3.fromRGB(20, 20, 30)
atmosfera.Decay = Color3.fromRGB(8, 8, 14)
atmosfera.Glare = 0
atmosfera.Haze = 2.5

print("🌙 Ha caído la noche...")
end

--==================================================================
-- 🛏️ 2. TU CUARTO
--==================================================================
local function construirCuarto()
print("▶️ ConstruirCuarto arrancando...")

-- ⚙️ MEDIDAS QUE PUEDES CAMBIAR (en "studs", 1 stud ≈ 30 cm)
local ANCHO = 24       -- de pared a pared (eje X)
local LARGO = 24       -- de la ventana a la puerta (eje Z)
local ALTO  = 12       -- altura del techo

-- 🎨 COLORES
local COLOR_SUELO  = Color3.fromRGB(84, 55, 36)    -- madera
local COLOR_PARED  = Color3.fromRGB(58, 54, 62)    -- gris azulado
local COLOR_TECHO  = Color3.fromRGB(40, 38, 46)
local COLOR_MADERA = Color3.fromRGB(92, 62, 40)

-- Si ya existía un cuarto de una partida anterior, lo borramos primero
local anterior = workspace:FindFirstChild("Cuarto")
if anterior then
	anterior:Destroy()
end

-- El cuarto entero va dentro de un Model, para tenerlo ordenado
local cuarto = Instance.new("Model")
cuarto.Name = "Cuarto"
cuarto.Parent = workspace

-- 🧱 Función de ayuda: crea un bloque. La usamos para TODO.
--    tam = tamaño (ancho, alto, largo)   pos = posición (x, altura, z)
local function bloque(nombre, tam, pos, color, material)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.Position = pos
	p.Color = color
	p.Material = material or Enum.Material.Concrete
	p.Anchored = true          -- no se cae ni se mueve
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = cuarto
	return p
end

local mitadX = ANCHO / 2      -- 12
local mitadZ = LARGO / 2      -- 12

--------------------------------------------------------------------
-- SUELO Y TECHO
--------------------------------------------------------------------
bloque("Suelo", Vector3.new(ANCHO, 1, LARGO), Vector3.new(0, 0.5, 0),
	COLOR_SUELO, Enum.Material.WoodPlanks)

bloque("Techo", Vector3.new(ANCHO, 1, LARGO), Vector3.new(0, ALTO + 1.5, 0),
	COLOR_TECHO, Enum.Material.Concrete)

--------------------------------------------------------------------
-- PAREDES
-- El suelo llega hasta la altura 1, así que las paredes van de 1 a 13.
-- Su centro está a la altura 1 + ALTO/2 = 7
--------------------------------------------------------------------
local centroPared = 1 + ALTO / 2

-- Pared del fondo (entera)
bloque("ParedFondo", Vector3.new(ANCHO, ALTO, 1),
	Vector3.new(0, centroPared, -mitadZ), COLOR_PARED)

-- Pared derecha (entera)
bloque("ParedDerecha", Vector3.new(1, ALTO, LARGO),
	Vector3.new(mitadX, centroPared, 0), COLOR_PARED)

-- Pared de la PUERTA: la hacemos en 3 trozos para dejar el hueco de la puerta
-- (hueco de 6 de ancho por 8 de alto, en el centro)
bloque("ParedPuertaIzq", Vector3.new(9, ALTO, 1),
	Vector3.new(-7.5, centroPared, mitadZ), COLOR_PARED)
bloque("ParedPuertaDer", Vector3.new(9, ALTO, 1),
	Vector3.new(7.5, centroPared, mitadZ), COLOR_PARED)
bloque("ParedPuertaArriba", Vector3.new(6, 4, 1),
	Vector3.new(0, 11, mitadZ), COLOR_PARED)

-- Pared de la VENTANA: 4 trozos para dejar el hueco (8 de ancho, 5 de alto)
bloque("ParedVentanaAbajo", Vector3.new(1, 4, LARGO),
	Vector3.new(-mitadX, 3, 0), COLOR_PARED)
bloque("ParedVentanaArriba", Vector3.new(1, 3, LARGO),
	Vector3.new(-mitadX, 11.5, 0), COLOR_PARED)
bloque("ParedVentanaLado1", Vector3.new(1, 5, 8),
	Vector3.new(-mitadX, 7.5, -8), COLOR_PARED)
bloque("ParedVentanaLado2", Vector3.new(1, 5, 8),
	Vector3.new(-mitadX, 7.5, 8), COLOR_PARED)

-- El cristal de la ventana (se ve a través, pero no se puede pasar)
local cristal = bloque("Ventana", Vector3.new(0.4, 5, 8),
	Vector3.new(-mitadX, 7.5, 0), Color3.fromRGB(150, 190, 210),
	Enum.Material.Glass)
cristal.Transparency = 0.75
cristal.Reflectance = 0.15

--------------------------------------------------------------------
-- 🚪 LA PUERTA (cerrada). Aquí elegirás "salir a por comida".
--------------------------------------------------------------------
local puerta = bloque("Puerta", Vector3.new(6, 8, 0.6),
	Vector3.new(0, 5, mitadZ), COLOR_MADERA, Enum.Material.Wood)

-- El pomo, para que se vea que es una puerta
bloque("Pomo", Vector3.new(0.6, 0.6, 0.6),
	Vector3.new(2, 5, mitadZ - 0.5), Color3.fromRGB(200, 170, 60),
	Enum.Material.Metal)

--------------------------------------------------------------------
-- 🛏️ LA CAMA. Aquí elegirás "dormir".
--------------------------------------------------------------------
local cama = bloque("Cama", Vector3.new(6, 1.5, 10),
	Vector3.new(-7, 1.75, -4), COLOR_MADERA, Enum.Material.Wood)

bloque("Colchon", Vector3.new(5.6, 1, 9.6),
	Vector3.new(-7, 3, -4), Color3.fromRGB(180, 175, 165),
	Enum.Material.Fabric)

bloque("Almohada", Vector3.new(4.5, 0.8, 2),
	Vector3.new(-7, 3.8, -7.8), Color3.fromRGB(225, 220, 210),
	Enum.Material.Fabric)

--------------------------------------------------------------------
-- 🪑 LA SILLA junto a la puerta. Aquí elegirás "quedarte despierto".
--------------------------------------------------------------------
local silla = bloque("Silla", Vector3.new(3, 0.6, 3),
	Vector3.new(7, 3, 6), COLOR_MADERA, Enum.Material.Wood)

bloque("SillaRespaldo", Vector3.new(3, 3, 0.6),
	Vector3.new(7, 4.5, 7.3), COLOR_MADERA, Enum.Material.Wood)

bloque("SillaPata1", Vector3.new(0.5, 2.4, 0.5), Vector3.new(5.8, 1.7, 4.9), COLOR_MADERA, Enum.Material.Wood)
bloque("SillaPata2", Vector3.new(0.5, 2.4, 0.5), Vector3.new(8.2, 1.7, 4.9), COLOR_MADERA, Enum.Material.Wood)
bloque("SillaPata3", Vector3.new(0.5, 2.4, 0.5), Vector3.new(5.8, 1.7, 7.1), COLOR_MADERA, Enum.Material.Wood)
bloque("SillaPata4", Vector3.new(0.5, 2.4, 0.5), Vector3.new(8.2, 1.7, 7.1), COLOR_MADERA, Enum.Material.Wood)

--------------------------------------------------------------------
-- 💡 MESITA CON LÁMPARA (la única luz del cuarto)
--------------------------------------------------------------------
bloque("Mesita", Vector3.new(2.5, 3, 2.5),
	Vector3.new(-2, 2.5, -8), COLOR_MADERA, Enum.Material.Wood)

local lampara = bloque("Lampara", Vector3.new(1.4, 1.4, 1.4),
	Vector3.new(-2, 4.7, -8), Color3.fromRGB(255, 210, 140),
	Enum.Material.Neon)

-- La luz de verdad va DENTRO de la lámpara
local luz = Instance.new("PointLight")
luz.Brightness = 2.5
luz.Range = 26                             -- hasta dónde llega la luz
luz.Color = Color3.fromRGB(255, 190, 120)  -- amarilla, de bombilla vieja
luz.Shadows = true
luz.Parent = lampara

--------------------------------------------------------------------
-- 📍 PUNTO DE APARICIÓN dentro del cuarto
--------------------------------------------------------------------
-- Quitamos los puntos de aparición que hubiera por ahí sueltos
for _, cosa in ipairs(workspace:GetDescendants()) do
	if cosa:IsA("SpawnLocation") then
		cosa:Destroy()
	end
end

local aparicion = Instance.new("SpawnLocation")
aparicion.Name = "AparicionCuarto"
aparicion.Size = Vector3.new(6, 0.4, 6)
aparicion.Position = Vector3.new(2, 1.2, 0)
aparicion.Anchored = true
aparicion.CanCollide = false
aparicion.Transparency = 1     -- invisible, es solo la marca
aparicion.Neutral = true
aparicion.Parent = cuarto

-- El PrimaryPart es "el centro" del Model, hace falta para moverlo entero
cuarto.PrimaryPart = puerta

-- 🚩 Bandera: avisa a los demás scripts de que el cuarto ya está terminado
cuarto:SetAttribute("Listo", true)

print("🏠 Cuarto construido. Cama, puerta y silla listas.")
print("   (Nombres para los próximos scripts: Cama / Puerta / Silla)")
end

--==================================================================
-- 🏰 3. LA MANSIÓN
--==================================================================
local function construirCasa()
print("▶️ ConstruirCasa — MANSIÓN v3 arrancando...")

--==================================================================
-- 📐 MEDIDAS DE LA MANSIÓN
--==================================================================
local ALTURA = 20                  -- alto de cada piso (unos 5,6 metros)
local GROSOR = 1                   -- lo gordos que son suelos y paredes

local X1, X2 = -60, 60             -- la mansión, de lado a lado
local Z1, Z2 = -45, 45             -- de la fachada al fondo

-- 🪜 EL HUECO DE LA ESCALERA
--    Los tramos van en DOS COLUMNAS, una al lado de otra, y suben en
--    zigzag: subes por la izquierda, cruzas el rellano, y sigues por la
--    derecha. Como en las escaleras de verdad. 🔁
local EX1, EX2 = 30, 58            -- el hueco entero, de lado a lado
local HZ1, HZ2 = -36, -12          -- el agujero del suelo (deja rellanos)
local Z_ABAJO, Z_ARRIBA = -38, -10 -- dónde empieza y acaba cada tramo

local COL_A = 37                   -- centro de la columna IZQUIERDA
local COL_B = 51                   -- centro de la columna DERECHA
local ANCHO_TRAMO = 12

-- La altura del suelo de cada piso. base(0) = planta baja, base(4) = azotea
local function base(p) return 1 + p * (ALTURA + GROSOR) end
local AZOTEA = base(4)

local C = {
	marmol = Color3.fromRGB(232, 228, 220), pared = Color3.fromRGB(214, 206, 192),
	oro = Color3.fromRGB(200, 166, 92), madera = Color3.fromRGB(88, 56, 34),
	parquet = Color3.fromRGB(112, 74, 44), techo = Color3.fromRGB(240, 238, 234),
	cristal = Color3.fromRGB(150, 190, 210), oscuro = Color3.fromRGB(38, 36, 40),
	tela = Color3.fromRGB(92, 100, 116), cortina = Color3.fromRGB(112, 26, 38),
	metal = Color3.fromRGB(196, 198, 204), coche = Color3.fromRGB(24, 26, 32),
	bombilla = Color3.fromRGB(255, 238, 205), planta = Color3.fromRGB(58, 120, 52),
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

-- Una losa (suelo o techo) con la cara de arriba justo en la altura "y"
local function losa(nombre, x1, x2, z1, z2, y, color, material)
	return bloque(nombre, Vector3.new(x2 - x1, GROSOR, z2 - z1),
		Vector3.new((x1 + x2) / 2, y - GROSOR / 2, (z1 + z2) / 2), color or C.parquet, material)
end

-- Una losa con un AGUJERO (para que se vea la escalera). Se hace con
-- cuatro trozos alrededor del agujero, como un marco de fotos. 🖼️
local function losaConHueco(nombre, x1, x2, z1, z2, hx1, hx2, hz1, hz2, y, color, material)
	if hz1 > z1 then losa(nombre .. "A", x1, x2, z1, hz1, y, color, material) end
	if hz2 < z2 then losa(nombre .. "B", x1, x2, hz2, z2, y, color, material) end
	if hx1 > x1 then losa(nombre .. "C", x1, hx1, hz1, hz2, y, color, material) end
	if hx2 < x2 then losa(nombre .. "D", hx2, x2, hz1, hz2, y, color, material) end
end

local function paredX(nombre, x, z1, z2, b, alto)
	return bloque(nombre, Vector3.new(GROSOR, alto or ALTURA, z2 - z1),
		Vector3.new(x, b + (alto or ALTURA) / 2, (z1 + z2) / 2), C.pared)
end

local function paredZ(nombre, z, x1, x2, b, alto)
	return bloque(nombre, Vector3.new(x2 - x1, alto or ALTURA, GROSOR),
		Vector3.new((x1 + x2) / 2, b + (alto or ALTURA) / 2, z), C.pared)
end

-- 🪟 Fachada de mansión: murete abajo, ventanales grandes y pilares
local function fachadaZ(nombre, z, x1, x2, b)
	local largo = x2 - x1

	bloque(nombre .. "Bajo", Vector3.new(largo, 4, GROSOR), Vector3.new((x1 + x2) / 2, b + 2, z), C.pared)
	bloque(nombre .. "Alto", Vector3.new(largo, 6, GROSOR), Vector3.new((x1 + x2) / 2, b + 17, z), C.pared)

	local cristal = bloque(nombre .. "Cristal", Vector3.new(largo, 10, 0.4),
		Vector3.new((x1 + x2) / 2, b + 9, z), C.cristal, Enum.Material.Glass)
	cristal.Transparency = 0.72
	cristal.Reflectance = 0.2

	local cuantos = math.max(1, math.floor(largo / 16))
	for i = 0, cuantos do
		bloque(nombre .. "Pilar", Vector3.new(2.4, 10, 1.6),
			Vector3.new(x1 + i * (largo / cuantos), b + 9, z), C.pared)
	end
end

local function fachadaX(nombre, x, z1, z2, b)
	local largo = z2 - z1

	bloque(nombre .. "Bajo", Vector3.new(GROSOR, 4, largo), Vector3.new(x, b + 2, (z1 + z2) / 2), C.pared)
	bloque(nombre .. "Alto", Vector3.new(GROSOR, 6, largo), Vector3.new(x, b + 17, (z1 + z2) / 2), C.pared)

	local cristal = bloque(nombre .. "Cristal", Vector3.new(0.4, 10, largo),
		Vector3.new(x, b + 9, (z1 + z2) / 2), C.cristal, Enum.Material.Glass)
	cristal.Transparency = 0.72
	cristal.Reflectance = 0.2

	local cuantos = math.max(1, math.floor(largo / 16))
	for i = 0, cuantos do
		bloque(nombre .. "Pilar", Vector3.new(1.6, 10, 2.4),
			Vector3.new(x, b + 9, z1 + i * (largo / cuantos)), C.pared)
	end
end

-- 💡 Lámpara de techo (se apunta a la lista del parpadeo)
local function lampara(nombre, x, z, b, brillo, alcance, color)
	local techoY = b + ALTURA
	bloque(nombre .. "Cable", Vector3.new(0.3, 2, 0.3), Vector3.new(x, techoY - 1, z), C.oro, Enum.Material.Metal)

	local bombilla = bloque(nombre, Vector3.new(3, 1.4, 3), Vector3.new(x, techoY - 2.7, z),
		C.bombilla, Enum.Material.Neon)

	local luz = Instance.new("PointLight")
	luz.Brightness = brillo or 1.6
	luz.Range = alcance or 45
	luz.Color = color or Color3.fromRGB(255, 228, 180)
	luz.Shadows = true
	luz.Parent = bombilla

	table.insert(lamparas, { pieza = bombilla, luz = luz })
	return bombilla
end

-- Reparte lámparas por una sala grande
local function iluminar(nombre, x1, x2, z1, z2, b, brillo)
	local filas = math.max(1, math.round((x2 - x1) / 45))
	local columnas = math.max(1, math.round((z2 - z1) / 45))

	for i = 1, filas do
		for j = 1, columnas do
			lampara(nombre .. i .. j,
				x1 + (i - 0.5) * (x2 - x1) / filas,
				z1 + (j - 0.5) * (z2 - z1) / columnas, b, brillo)
		end
	end
end

local function mesa(nombre, x, z, ancho, fondo, altura, b, color)
	bloque(nombre, Vector3.new(ancho, 0.8, fondo), Vector3.new(x, b + altura, z), color or C.madera, Enum.Material.Wood)
	local dx, dz = ancho / 2 - 1, fondo / 2 - 1
	for _, e in ipairs({ {dx, dz}, {-dx, dz}, {dx, -dz}, {-dx, -dz} }) do
		bloque(nombre .. "Pata", Vector3.new(0.8, altura - 0.4, 0.8),
			Vector3.new(x + e[1], b + (altura - 0.4) / 2, z + e[2]), color or C.madera, Enum.Material.Wood)
	end
end

local function sofa(nombre, x, z, ancho, b, giro)
	local giroCF = CFrame.Angles(0, math.rad(giro or 0), 0)
	local piezas = {
		{ Vector3.new(ancho, 2, 8), Vector3.new(0, 1.8, 0) },
		{ Vector3.new(ancho, 4, 1.6), Vector3.new(0, 4, -3.8) },
		{ Vector3.new(1.6, 3, 8), Vector3.new(-ancho / 2 + 0.8, 3.2, 0) },
		{ Vector3.new(1.6, 3, 8), Vector3.new(ancho / 2 - 0.8, 3.2, 0) },
	}
	for _, d in ipairs(piezas) do
		local p = bloque(nombre, d[1], Vector3.new(0, 0, 0), C.tela, Enum.Material.Fabric)
		p.CFrame = CFrame.new(x, b, z) * giroCF * CFrame.new(d[2])
	end
end

--==================================================================
-- 🧱 LOS SUELOS DE CADA PISO (con el agujero de la escalera)
--==================================================================
losa("SueloBajo", X1, X2, Z1, Z2, base(0), C.marmol, Enum.Material.Marble)

for piso = 1, 3 do
	losaConHueco("Suelo" .. piso, X1, X2, Z1, Z2, EX1, EX2, HZ1, HZ2, base(piso), C.parquet, Enum.Material.WoodPlanks)
end

-- La azotea: aquí el hueco se tapa con una casetilla de salida
losaConHueco("SueloAzotea", X1, X2, Z1, Z2, EX1, EX2, HZ1, HZ2, AZOTEA, C.marmol, Enum.Material.Marble)

--==================================================================
-- 🏛️ LAS FACHADAS (con ventanales de mansión)
--==================================================================
for piso = 0, 3 do
	local b = base(piso)

	if piso == 0 then
		-- Planta baja: puerta principal y puerta del garaje en la fachada
		paredZ("FachadaBajoA", Z1, X1, -50, b)
		paredZ("FachadaBajoB", Z1, -20, -10, b)
		paredZ("FachadaBajoC", Z1, 10, X2, b)
		bloque("DintelPuerta", Vector3.new(20, 6, GROSOR), Vector3.new(0, b + 17, Z1), C.pared)
		bloque("DintelGaraje", Vector3.new(30, 4, GROSOR), Vector3.new(-35, b + 18, Z1), C.pared)

		-- La puerta del garaje (subida, como si estuviera abierta)
		bloque("PuertaGaraje", Vector3.new(30, 1.4, 1.2), Vector3.new(-35, b + 15.5, Z1 - 0.8), C.metal, Enum.Material.Metal)
		for i = 0, 5 do
			bloque("MarcoGaraje", Vector3.new(30, 0.5, 0.8), Vector3.new(-35, b + 14.6 - i * 0.9, Z1 - 0.8), C.metal, Enum.Material.Metal)
		end
	else
		fachadaZ("FachadaFrente" .. piso, Z1, X1, X2, b)
	end

	fachadaZ("FachadaFondo" .. piso, Z2, X1, X2, b)
	fachadaX("FachadaIzq" .. piso, X1, Z1, Z2, b)
	fachadaX("FachadaDer" .. piso, X2, Z1, Z2, b)
end

-- La barandilla de la azotea
for _, lado in ipairs({ {Z1, "frente"}, {Z2, "fondo"} }) do
	bloque("PretilAzotea" .. lado[2], Vector3.new(X2 - X1, 6, 1.4), Vector3.new(0, AZOTEA + 3, lado[1]), C.marmol, Enum.Material.Marble)
end
for _, lado in ipairs({ {X1, "izq"}, {X2, "der"} }) do
	bloque("PretilAzotea" .. lado[2], Vector3.new(1.4, 6, Z2 - Z1), Vector3.new(lado[1], AZOTEA + 3, 0), C.marmol, Enum.Material.Marble)
end

--==================================================================
-- 🪜 LA ESCALERA EN ZIGZAG
--    Pisos pares (0 y 2) -> columna IZQUIERDA, subiendo hacia el fondo.
--    Pisos impares (1 y 3) -> columna DERECHA, subiendo hacia la fachada.
--    Así ningún tramo queda encima de otro: quedan al lado. 🔁
--==================================================================
local X_ESC = (COL_A + COL_B) / 2
local LARGO_ESC = Z_ARRIBA - Z_ABAJO

for piso = 0, 3 do
	local b = base(piso)
	local subida = base(piso + 1) - b
	local escalones = math.ceil(subida / 1.5)          -- que ninguno pase de 1,5
	local alturaPaso = subida / escalones
	local fondoPaso = LARGO_ESC / escalones

	-- ¿Le toca la columna de la izquierda o la de la derecha?
	local par = (piso % 2 == 0)
	local x = par and COL_A or COL_B
	local ladoBarandilla = par and 1 or -1

	for i = 1, escalones do
		local h = alturaPaso * i
		local avance = (i - 0.5) * fondoPaso

		-- los pares suben hacia el fondo, los impares hacia la fachada
		local z = par and (Z_ABAJO + avance) or (Z_ARRIBA - avance)

		bloque("Escalon", Vector3.new(ANCHO_TRAMO, h, fondoPaso),
			Vector3.new(x, b + h / 2, z), C.marmol, Enum.Material.Marble)

		-- barandilla por el lado abierto del tramo, cada tres escalones
		if i % 3 == 0 then
			bloque("Barrote", Vector3.new(0.4, 5, 0.4),
				Vector3.new(x + ladoBarandilla * (ANCHO_TRAMO / 2 - 0.4), b + h + 2.5, z),
				C.oro, Enum.Material.Metal)
		end
	end

	-- Barandilla alrededor del agujero, para no caerse al vacío 🕳️
	if piso > 0 then
		for i = 0, 7 do
			local z = HZ1 + (i + 0.5) * (HZ2 - HZ1) / 8
			bloque("BarroteHueco", Vector3.new(0.4, 5, 0.4), Vector3.new(EX1, b + 2.5, z), C.oro, Enum.Material.Metal)
			bloque("BarroteHueco", Vector3.new(0.4, 5, 0.4), Vector3.new(EX2, b + 2.5, z), C.oro, Enum.Material.Metal)
		end
		bloque("PasamanosHueco", Vector3.new(0.6, 0.6, HZ2 - HZ1), Vector3.new(EX1, b + 5, (HZ1 + HZ2) / 2), C.oro, Enum.Material.Metal)
		bloque("PasamanosHueco", Vector3.new(0.6, 0.6, HZ2 - HZ1), Vector3.new(EX2, b + 5, (HZ1 + HZ2) / 2), C.oro, Enum.Material.Metal)
	end

	iluminar("LuzEscalera" .. piso, EX1, EX2, Z_ABAJO, Z_ARRIBA, b, 1.4)
end

--==================================================================
-- 🚗 PLANTA BAJA: recibidor y GARAJE
--==================================================================
local b0 = base(0)
iluminar("LuzBajo", X1, 20, Z1, Z2, b0, 1.5)

paredX("MuroGaraje", -5, Z1, 5, b0)      -- separa el garaje del recibidor

-- El coche 🚗
local COCHE_X, COCHE_Z = -33, -22

bloque("CocheCuerpo", Vector3.new(14, 4.5, 30), Vector3.new(COCHE_X, b0 + 4, COCHE_Z), C.coche, Enum.Material.Metal)
bloque("CocheCabina", Vector3.new(12, 4, 13), Vector3.new(COCHE_X, b0 + 8, COCHE_Z + 1), C.coche, Enum.Material.Metal)

local lunas = bloque("CocheLunas", Vector3.new(12.2, 3, 12.4), Vector3.new(COCHE_X, b0 + 8.2, COCHE_Z + 1), C.cristal, Enum.Material.Glass)
lunas.Transparency = 0.6

for _, lado in ipairs({ -1, 1 }) do
	for _, largo in ipairs({ -1, 1 }) do
		local rueda = bloque("Rueda", Vector3.new(3, 6, 6),
			Vector3.new(COCHE_X + lado * 7, b0 + 3, COCHE_Z + largo * 9.5), C.oscuro, Enum.Material.SmoothPlastic)
		rueda.Shape = Enum.PartType.Cylinder
		rueda.CFrame = CFrame.new(rueda.Position) * CFrame.Angles(0, 0, math.rad(90))
	end
end

for _, lado in ipairs({ -1, 1 }) do
	local faro = bloque("Faro", Vector3.new(3.5, 1.6, 0.6),
		Vector3.new(COCHE_X + lado * 4.5, b0 + 4.5, COCHE_Z - 15), Color3.fromRGB(255, 250, 220), Enum.Material.Neon)

	local luzFaro = Instance.new("PointLight")
	luzFaro.Brightness = 1.2 ; luzFaro.Range = 22
	luzFaro.Color = Color3.fromRGB(255, 245, 210)
	luzFaro.Parent = faro

	bloque("Piloto", Vector3.new(3, 1.4, 0.6),
		Vector3.new(COCHE_X + lado * 4.5, b0 + 4.5, COCHE_Z + 15), Color3.fromRGB(200, 30, 30), Enum.Material.Neon)
end

-- 🔢 LA MATRÍCULA
local matricula = bloque("Matricula", Vector3.new(9, 2.6, 0.4),
	Vector3.new(COCHE_X, b0 + 2.6, COCHE_Z + 15.2), Color3.fromRGB(245, 245, 235), Enum.Material.SmoothPlastic)

local cartel = Instance.new("SurfaceGui")
cartel.Face = Enum.NormalId.Back          -- la parte de atrás del coche
cartel.CanvasSize = Vector2.new(450, 130)
cartel.Parent = matricula

local texto = Instance.new("TextLabel")
texto.Size = UDim2.fromScale(1, 1)
texto.BackgroundTransparency = 1
texto.Font = Enum.Font.GothamBold
texto.TextScaled = true
texto.TextColor3 = Color3.fromRGB(20, 20, 25)
texto.Text = "Y 75689 HM3"
texto.Parent = cartel

--==================================================================
-- 🛋️ PISO 1: salón, comedor, cocina... y LAS CORTINAS
--==================================================================
local b1 = base(1)
iluminar("LuzPiso1", X1, 25, Z1, Z2, b1, 1.4)

-- Un muro parte el piso en dos, con el hueco que tapan las cortinas
paredX("MuroSalonA", 0, Z1, 4, b1)
paredX("MuroSalonB", 0, 22, Z2, b1)

bloque("BarraCortinas", Vector3.new(1.2, 0.8, 20), Vector3.new(0, b1 + ALTURA - 1, 13), C.oro, Enum.Material.Metal)
bloque("CortinaIzq", Vector3.new(1.2, ALTURA - 1.4, 9), Vector3.new(0, b1 + (ALTURA - 1.4) / 2, 8.5), C.cortina, Enum.Material.Fabric)
bloque("CortinaDer", Vector3.new(1.2, ALTURA - 1.4, 9), Vector3.new(0, b1 + (ALTURA - 1.4) / 2, 17.5), C.cortina, Enum.Material.Fabric)

-- Salón (delante de las cortinas)
sofa("SofaSalon", -30, -20, 20, b1, 0)
sofa("SofaSalon2", -30, -5, 20, b1, 180)
mesa("MesaCentro", -30, -12, 12, 7, 3.5, b1)
bloque("AlfombraSalon", Vector3.new(34, 0.3, 26), Vector3.new(-30, b1 + 0.15, -12), Color3.fromRGB(84, 70, 66), Enum.Material.Fabric)

bloque("MuebleTele", Vector3.new(24, 4, 4), Vector3.new(-30, b1 + 2, -36), C.madera, Enum.Material.Wood)
local tele = bloque("Tele", Vector3.new(22, 11, 0.8), Vector3.new(-30, b1 + 10, -36), C.oscuro, Enum.Material.Glass)
tele.Reflectance = 0.3

-- Comedor (detrás de las cortinas)
mesa("MesaComedor", 15, 13, 22, 10, 6, b1)
bloque("Maceta", Vector3.new(4, 3.5, 4), Vector3.new(15, b1 + 8, 13), Color3.fromRGB(150, 92, 60), Enum.Material.Slate)
for _, sitio in ipairs({ Vector3.new(0, 3.4, 0), Vector3.new(1.8, 2.6, 1), Vector3.new(-1.6, 2.8, -0.8) }) do
	local hoja = bloque("Hojas", Vector3.new(4.4, 4.4, 4.4), Vector3.new(15, b1 + 8, 13) + sitio, C.planta, Enum.Material.Grass)
	hoja.Shape = Enum.PartType.Ball
end

for i = 1, 6 do
	local lado = (i <= 3) and -1 or 1
	local z = 5 + ((i - 1) % 3) * 8
	bloque("Silla", Vector3.new(5, 1, 5), Vector3.new(15 + lado * 9, b1 + 4.5, z), C.madera, Enum.Material.Wood)
	bloque("SillaRespaldo", Vector3.new(5, 7, 0.8), Vector3.new(15 + lado * 9, b1 + 8, z + lado * 2.2), C.madera, Enum.Material.Wood)
end

-- Cocina, al fondo del piso 1
bloque("Encimera", Vector3.new(40, 1, 8), Vector3.new(-25, b1 + 6, 38), C.marmol, Enum.Material.Marble)
for i = 0, 6 do
	bloque("Armario", Vector3.new(5.4, 6, 8), Vector3.new(-43 + i * 6, b1 + 3, 38), C.madera, Enum.Material.Wood)
	bloque("Tirador", Vector3.new(3, 0.5, 0.5), Vector3.new(-43 + i * 6, b1 + 3, 33.8), C.oro, Enum.Material.Metal)
	bloque("ArmarioAlto", Vector3.new(5.4, 6, 5), Vector3.new(-43 + i * 6, b1 + 14, 40), C.madera, Enum.Material.Wood)
end
mesa("IslaCocina", -25, 26, 22, 9, 6, b1)

local nevera = bloque("Nevera", Vector3.new(8, 15, 9), Vector3.new(-3, b1 + 7.5, 38), C.metal, Enum.Material.Metal)
nevera.Reflectance = 0.15
bloque("NeveraPuerta", Vector3.new(0.6, 14, 8.4), Vector3.new(-7.2, b1 + 7.5, 38), Color3.fromRGB(178, 182, 190), Enum.Material.Metal)
bloque("NeveraTirador", Vector3.new(0.5, 8, 0.5), Vector3.new(-7.8, b1 + 9, 41), C.oro, Enum.Material.Metal)

--==================================================================
-- 🛏️ PISO 2: NUESTRA HABITACIÓN
--    El cuarto se construye en su script y aquí lo COLOCAMOS.
--==================================================================
local b2 = base(2)
iluminar("LuzPiso2", X1, 25, Z1, Z2, b2, 1.2)

local CUARTO_X, CUARTO_Z = -30, -20        -- dónde va nuestro cuarto

local cuarto = workspace:WaitForChild("Cuarto", 20)
if cuarto then
	-- Lo subimos entero al piso 2. El 0.05 es para que su suelo no se pelee
	-- con el suelo de la mansión (si no, parpadean los dos).
	local desplazamiento = Vector3.new(CUARTO_X, b2 - 1 + 0.05, CUARTO_Z)
	cuarto:PivotTo(CFrame.new(desplazamiento) * cuarto:GetPivot())
	print("🛏️ Cuarto colocado en el piso 2.")
else
	warn("⚠️ No encuentro el Cuarto. ¿Está ConstruirCuarto en ServerScriptService?")
end

-- La cara de FUERA de la puerta del cuarto (aquí sale el cartel [E] Entrar)
local puertaFuera = bloque("PuertaFuera", Vector3.new(6, 8, 0.4),
	Vector3.new(CUARTO_X, b2 + 4, CUARTO_Z + 13.2), C.pared)
puertaFuera.Transparency = 1
puertaFuera.CanCollide = false

-- Donde apareces al salir del cuarto
local llegada = bloque("LlegadaPasillo", Vector3.new(4, 1, 4),
	Vector3.new(CUARTO_X, b2 + 3, CUARTO_Z + 22), C.pared)
llegada.Transparency = 1
llegada.CanCollide = false
llegada.CFrame = CFrame.lookAt(llegada.Position, llegada.Position + Vector3.new(0, 0, 1))

-- Una salita en el piso 2, para que no esté vacío
sofa("SofaPiso2", 5, 25, 18, b2, 180)
mesa("EscritorioAlto", 5, 5, 16, 8, 7, b2)
bloque("AlfombraPiso2", Vector3.new(28, 0.3, 22), Vector3.new(5, b2 + 0.15, 18), Color3.fromRGB(70, 66, 78), Enum.Material.Fabric)

--==================================================================
-- 🔒 PISO 3: LA HABITACIÓN DE PAPÁ Y MAMÁ
--==================================================================
local b3 = base(3)
iluminar("LuzPiso3", X1, 25, Z1, Z2, b3, 1.1)

-- Su cuarto ocupa media planta, con la puerta cerrada con llave
paredX("MuroPadres", -10, Z1, -6, b3)
paredX("MuroPadres2", -10, 2, Z2, b3)

local puertaPadres = bloque("PuertaPadres", Vector3.new(1.2, 12, 8),
	Vector3.new(-10, b3 + 6, -2), C.madera, Enum.Material.Wood)
bloque("PomoPadres", Vector3.new(1, 1, 1), Vector3.new(-11, b3 + 6, -5), C.oro, Enum.Material.Metal)
bloque("CerraduraPadres", Vector3.new(0.8, 1.6, 0.8), Vector3.new(-11, b3 + 4.4, -5), C.metal, Enum.Material.Metal)

bloque("CamaPadres", Vector3.new(22, 3, 18), Vector3.new(-35, b3 + 1.5, -10), C.madera, Enum.Material.Wood)
bloque("ColchonPadres", Vector3.new(21, 2, 17), Vector3.new(-35, b3 + 4, -10), Color3.fromRGB(190, 186, 176), Enum.Material.Fabric)
mesa("ArmarioPadres", -52, 10, 6, 16, 14, b3)

-- Baño del piso 3
bloque("Banera", Vector3.new(16, 5, 9), Vector3.new(10, b3 + 2.5, 34), Color3.fromRGB(240, 244, 248))
local agua = bloque("AguaBanera", Vector3.new(15, 0.6, 8), Vector3.new(10, b3 + 4.8, 34), Color3.fromRGB(120, 190, 220), Enum.Material.Glass)
agua.Transparency = 0.35

--==================================================================
-- ☀️ LA AZOTEA
--==================================================================
bloque("CasetaAzotea", Vector3.new(EX2 - EX1 + 4, 12, 10), Vector3.new(X_ESC, AZOTEA + 6, HZ2 + 4), C.marmol, Enum.Material.Marble)

for i = -1, 1 do
	local farol = bloque("FarolAzotea", Vector3.new(2, 8, 2), Vector3.new(i * 30, AZOTEA + 4, 20), C.oro, Enum.Material.Metal)
	local bombilla = bloque("BombillaAzotea", Vector3.new(3, 2, 3), Vector3.new(i * 30, AZOTEA + 9, 20), C.bombilla, Enum.Material.Neon)

	local luz = Instance.new("PointLight")
	luz.Brightness = 1.4 ; luz.Range = 40
	luz.Color = Color3.fromRGB(255, 232, 190)
	luz.Parent = bombilla

	table.insert(lamparas, { pieza = bombilla, luz = luz })

	bloque("Tumbona", Vector3.new(8, 1.4, 18), Vector3.new(i * 22, AZOTEA + 2, -25), Color3.fromRGB(232, 228, 218), Enum.Material.Fabric)
end

--==================================================================
-- 💡 QUE PARPADEEN LAS LUCES
--==================================================================
for _, lamp in ipairs(lamparas) do
	task.spawn(function()
		while lamp.pieza.Parent do
			task.wait(math.random(40, 180) / 10)
			for _ = 1, math.random(2, 6) do
				lamp.luz.Enabled = false
				lamp.pieza.Material = Enum.Material.SmoothPlastic
				task.wait(math.random(3, 14) / 100)
				lamp.luz.Enabled = true
				lamp.pieza.Material = Enum.Material.Neon
				task.wait(math.random(4, 22) / 100)
			end
		end
	end)
end

casa:SetAttribute("Listo", true)

print("🏰 Mansión construida: garaje, piso 1, tu cuarto en el 2, padres en el 3 y azotea.")
print("   Altura total: " .. math.floor(AZOTEA + 6) .. " studs. Lámparas: " .. #lamparas)
end

--==================================================================
-- 🌿 4. EL JARDÍN
--==================================================================
local function construirJardin()
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
end

--==================================================================
-- 👹 5. EL MONSTRUO
--==================================================================
local function construirMonstruo()
print("▶️ ConstruirMonstruo arrancando...")

-- ⚙️ AJUSTES
local POSICION = Vector3.new(0, 1, 60)     -- dónde aparece (en el pasillo)
local MIRANDO = 180                        -- hacia dónde mira, en grados
local COLOR_PIEL = Color3.fromRGB(158, 152, 140)
local COLOR_OSCURO = Color3.fromRGB(52, 48, 46)
local COLOR_DIENTE = Color3.fromRGB(228, 222, 200)

local anterior = workspace:FindFirstChild("Monstruo")
if anterior then anterior:Destroy() end

local monstruo = Instance.new("Model")
monstruo.Name = "Monstruo"
monstruo.Parent = workspace

--==================================================================
-- 🧰 HERRAMIENTAS
--==================================================================
-- Todas las piezas se crean en su sitio del mundo, y luego las unimos.
local function pieza(nombre, tam, y, x, color, material)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.Position = POSICION + Vector3.new(x or 0, y, 0)
	p.Color = color or COLOR_PIEL
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = false            -- las mueven las articulaciones, no la física
	p.CanCollide = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = monstruo
	return p
end

--[[
	unir() es LO IMPORTANTE de todo esto.
	Un Motor6D es una articulación: agarra dos piezas por un punto y ya no se
	sueltan nunca, por mucho que gires una. Le decimos:
	  p0 = la pieza que manda (el padre)
	  p1 = la pieza que cuelga (el hijo)
	  altura = a qué altura está el punto por el que se agarran
]]
local juntas = {}      -- aquí guardamos todas, y su posición de reposo

local function unir(nombre, p0, p1, altura, x)
	local punto = CFrame.new(POSICION + Vector3.new(x or 0, altura, 0))

	local m = Instance.new("Motor6D")
	m.Name = nombre
	m.Part0 = p0
	m.Part1 = p1
	m.C0 = p0.CFrame:Inverse() * punto      -- dónde está el punto para el padre
	m.C1 = p1.CFrame:Inverse() * punto      -- dónde está el punto para el hijo
	m.Parent = p0

	juntas[nombre] = { junta = m, reposo = m.C0 }
	return m
end

-- Poner una articulación en una postura (girada y/o movida)
local function postura(nombre, cframe)
	local j = juntas[nombre]
	if j then
		j.junta.C0 = j.reposo * cframe
	end
end

-- Llevar una articulación a una postura POCO A POCO (esto es la animación)
local function mover(nombre, cframe, segundos)
	local j = juntas[nombre]
	if not j then return end

	local desde = j.junta.C0
	local hasta = j.reposo * cframe
	local pasado = 0

	while pasado < segundos do
		pasado += task.wait()
		j.junta.C0 = desde:Lerp(hasta, math.min(1, pasado / segundos))
	end
	j.junta.C0 = hasta
end

local function girar(x, y, z)          -- grados -> CFrame, para escribir menos
	return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end

--==================================================================
-- 🦴 EL CUERPO (de abajo arriba)
--==================================================================
-- Pies
local pieDer = pieza("PieDerecho", Vector3.new(1.3, 0.7, 2.4), 0.35, 1, COLOR_OSCURO)
local pieIzq = pieza("PieIzquierdo", Vector3.new(1.3, 0.7, 2.4), 0.35, -1, COLOR_OSCURO)

-- Piernas de abajo (de la rodilla al pie)
local espinillaDer = pieza("EspinillaDerecha", Vector3.new(1, 3, 1), 2.2, 1)
local espinillaIzq = pieza("EspinillaIzquierda", Vector3.new(1, 3, 1), 2.2, -1)

-- Piernas de arriba (de la cadera a la rodilla)
local musloDer = pieza("MusloDerecho", Vector3.new(1.2, 3, 1.2), 5.2, 1)
local musloIzq = pieza("MusloIzquierdo", Vector3.new(1.2, 3, 1.2), 5.2, -1)

-- Las "rótulas": bolitas que TAPAN la articulación escondida de la rodilla
local rotulaDer = pieza("RotulaDerecha", Vector3.new(1.3, 1.3, 1.3), 3.7, 1, COLOR_OSCURO)
local rotulaIzq = pieza("RotulaIzquierda", Vector3.new(1.3, 1.3, 1.3), 3.7, -1, COLOR_OSCURO)
rotulaDer.Shape = Enum.PartType.Ball
rotulaIzq.Shape = Enum.PartType.Ball

-- Tronco
local torso = pieza("Torso", Vector3.new(3, 4.6, 1.7), 9)
local raiz = pieza("HumanoidRootPart", Vector3.new(3, 4.6, 1.7), 9)
raiz.Transparency = 1

-- Brazos: de arriba (hombro-codo) y de abajo (codo-mano)
local brazoDer = pieza("BrazoDerecho", Vector3.new(0.9, 2.6, 0.9), 9.7, 2.1)
local brazoIzq = pieza("BrazoIzquierdo", Vector3.new(0.9, 2.6, 0.9), 9.7, -2.1)
local antebrazoDer = pieza("AntebrazoDerecho", Vector3.new(0.8, 3, 0.8), 6.9, 2.1)
local antebrazoIzq = pieza("AntebrazoIzquierdo", Vector3.new(0.8, 3, 0.8), 6.9, -2.1)

-- Bolitas que esconden el codo
local codoDerBola = pieza("CodoDerechoBola", Vector3.new(1.1, 1.1, 1.1), 8.4, 2.1, COLOR_OSCURO)
local codoIzqBola = pieza("CodoIzquierdoBola", Vector3.new(1.1, 1.1, 1.1), 8.4, -2.1, COLOR_OSCURO)
codoDerBola.Shape = Enum.PartType.Ball
codoIzqBola.Shape = Enum.PartType.Ball

-- 👄 LA CABEZA, partida en dos
local head = pieza("Head", Vector3.new(2.2, 1.1, 2), 11.9)          -- la mandíbula
local craneo = pieza("Craneo", Vector3.new(2.2, 1.9, 2), 13.4)      -- la media cabeza que se arranca

-- Los ojos, pegados al cráneo con una soldadura (WeldConstraint = pegamento)
for _, lado in ipairs({ -0.55, 0.55 }) do
	local ojo = pieza("Ojo", Vector3.new(0.4, 0.4, 0.3), 13.6, lado, Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
	ojo.Position = ojo.Position + Vector3.new(0, 0, -1)

	local brillo = Instance.new("PointLight")
	brillo.Brightness = 1.5
	brillo.Range = 12
	brillo.Color = Color3.fromRGB(255, 230, 180)
	brillo.Parent = ojo

	local pegamento = Instance.new("WeldConstraint")
	pegamento.Part0 = craneo
	pegamento.Part1 = ojo
	pegamento.Parent = ojo
end

-- 🦷 LOS DIENTES DE POLÍGONOS (arriba y abajo de la boca)
local dientes = {}

local function diente(x, altura, delAireArriba)
	local d = Instance.new("WedgePart")
	d.Name = "Diente"
	d.Size = Vector3.new(0.28, 0.5 + math.random() * 0.5, 0.9)
	d.Color = COLOR_DIENTE
	d.Material = Enum.Material.SmoothPlastic
	d.Anchored = false
	d.CanCollide = false
	d.Massless = true
	d.Parent = monstruo

	local giro = delAireArriba and girar(180, 0, 0) or girar(0, 0, 0)
	d.CFrame = CFrame.new(POSICION + Vector3.new(x, altura, 0)) * giro

	table.insert(dientes, { pieza = d, arriba = delAireArriba })
	return d
end

for i = -3, 3 do
	diente(i * 0.32, 12.55, false)     -- los de abajo, apuntando hacia arriba
	diente(i * 0.32, 12.75, true)      -- los de arriba, apuntando hacia abajo
end

--==================================================================
-- 🔗 LAS ARTICULACIONES (aquí es donde nada se separa nunca)
--==================================================================
unir("RootJoint", raiz, torso, 9)

-- Piernas: cadera -> RODILLA ESCONDIDA -> tobillo
unir("CaderaDerecha", torso, musloDer, 6.7, 1)
unir("CaderaIzquierda", torso, musloIzq, 6.7, -1)
unir("RodillaDerecha", musloDer, espinillaDer, 3.7, 1)        -- ⬅️ la extra
unir("RodillaIzquierda", musloIzq, espinillaIzq, 3.7, -1)     -- ⬅️ la extra
unir("TobilloDerecho", espinillaDer, pieDer, 0.7, 1)
unir("TobilloIzquierdo", espinillaIzq, pieIzq, 0.7, -1)
unir("TapaRodillaDer", musloDer, rotulaDer, 3.7, 1)
unir("TapaRodillaIzq", musloIzq, rotulaIzq, 3.7, -1)

-- Brazos: hombro -> CODO ESCONDIDO -> mano
unir("HombroDerecho", torso, brazoDer, 11, 2.1)
unir("HombroIzquierdo", torso, brazoIzq, 11, -2.1)
unir("CodoDerecho", brazoDer, antebrazoDer, 8.4, 2.1)         -- ⬅️ la extra
unir("CodoIzquierdo", brazoIzq, antebrazoIzq, 8.4, -2.1)      -- ⬅️ la extra
unir("TapaCodoDer", brazoDer, codoDerBola, 8.4, 2.1)
unir("TapaCodoIzq", brazoIzq, codoIzqBola, 8.4, -2.1)

-- Cabeza: cuello -> y la junta del cráneo, que es la de la telequinesia
unir("Neck", torso, head, 11.35)
unir("JuntaCraneo", head, craneo, 12.65)

for _, d in ipairs(dientes) do
	local m = Instance.new("Motor6D")
	m.Name = "JuntaDiente"
	m.Part0 = d.arriba and craneo or head
	m.Part1 = d.pieza
	m.C0 = m.Part0.CFrame:Inverse() * d.pieza.CFrame
	m.C1 = CFrame.new()
	m.Parent = m.Part0
end

--==================================================================
-- 🧠 EL HUMANOID (el "cerebro": sin esto no es un personaje de Roblox)
--==================================================================
local humanoide = Instance.new("Humanoid")
humanoide.DisplayName = "???"
humanoide.MaxHealth = math.huge
humanoide.Health = math.huge
humanoide.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
humanoide.WalkSpeed = 0
humanoide.AutoRotate = false          -- que no gire solo: lo movemos nosotros

-- ⚠️ ESTO ES IMPORTANTÍSIMO ⚠️
-- Cuando un Humanoid "se muere", Roblox ROMPE TODAS LAS ARTICULACIONES del
-- personaje (por eso los muñecos se desmontan al morir). Si eso le pasa al
-- monstruo, el cuerpo se queda atrás mientras la raíz invisible se va sola,
-- y parece que no se mueve nada. Con esto no puede pasar nunca:
humanoide.RequiresNeck = false        -- que no se muera si el cuello es raro
humanoide.BreakJointsOnDeath = false  -- que NO rompa las articulaciones
humanoide.Parent = monstruo

humanoide:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
humanoide:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
humanoide:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
pcall(function() humanoide.EvaluateStateMachine = false end)

monstruo.PrimaryPart = raiz
raiz.Anchored = true                 -- se queda de pie y no se cae
monstruo:PivotTo(CFrame.new(POSICION + Vector3.new(0, 9, 0)) * girar(0, MIRANDO, 0))

-- 🚶 El andar y la persecución los hace el script MonstruoPersigue.
-- Aquí solo se monta el cuerpo.

--==================================================================
-- ✅ COMPROBACIÓN: ¿está todo bien enganchado?
--    Si una pieza no comparte "assembly" con la raíz, es que su
--    articulación no funciona y se quedaría atrás al moverse.
--==================================================================
task.wait(0.2)

local sueltas = 0
for _, cosa in ipairs(monstruo:GetChildren()) do
	if cosa:IsA("BasePart") and cosa ~= raiz and cosa.AssemblyRootPart ~= raiz then
		sueltas += 1
		warn("⚠️ Pieza suelta (no engancha con la raíz): " .. cosa.Name)
	end
end

-- 🚩 Bandera: le dice al LocalScript de la animación que ya puede empezar
monstruo:SetAttribute("Listo", true)

print("👹 Monstruo montado en " .. tostring(POSICION))
print("   Piezas sueltas: " .. sueltas .. " (tiene que poner 0)")
print("   Articulaciones: rodilla y codo escondidos en cada extremidad.")
end

--==================================================================
-- 💡 6. BALIZAS DE SUELO
--==================================================================
local function lucesDeSuelo()
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
end

--==================================================================
-- 🅴 7. LAS OPCIONES (tecla E)
--==================================================================
local function opciones()
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
	print("   ✔ Punto de llegada del pasillo encontrado en la casa.")
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
end

--==================================================================
-- 🏃 8. LA PERSECUCIÓN
--==================================================================
local function monstruoPersigue()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

--==================================================================
-- ⚙️ AJUSTES
--==================================================================
local VELOCIDAD = 11                -- studs por segundo. Tú corres a 16.
local DISTANCIA_VISION = 1000       -- enorme aposta: que te persiga siempre
local DISTANCIA_PILLAR = 8          -- a esta distancia se para y te mira
local ALTURA_RAIZ = 9               -- del suelo al centro del monstruo
local USAR_MAPA = true              -- false = línea recta atravesando paredes
local CHIVATO = true                -- que cuente en la Output lo que hace

task.wait(1.5)

local monstruo = workspace:WaitForChild("Monstruo", 20)
if not monstruo then
	warn("❌ No encuentro al Monstruo. ¿Está el script ConstruirMonstruo puesto?")
	return
end

local raiz = monstruo:WaitForChild("HumanoidRootPart")

if not raiz.Anchored then
	warn("⚠️ El HumanoidRootPart no está anclado. Lo anclo yo.")
	raiz.Anchored = true
end

-- Si el Humanoid se muere, Roblox rompe TODAS las articulaciones y el cuerpo
-- se queda atrás mientras la raíz invisible se mueve sola.
local humanoide = monstruo:FindFirstChildOfClass("Humanoid")
if humanoide then
	pcall(function() humanoide.BreakJointsOnDeath = false end)
	pcall(function() humanoide.RequiresNeck = false end)
	pcall(function() humanoide.MaxHealth = math.huge end)
	pcall(function() humanoide.Health = math.huge end)
	pcall(function() humanoide.EvaluateStateMachine = false end)
	pcall(function() humanoide:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
end

-- ✅ ¿Está el cuerpo bien enganchado a la raíz?
task.wait(0.2)
local sueltas = 0
for _, cosa in ipairs(monstruo:GetChildren()) do
	if cosa:IsA("BasePart") and cosa ~= raiz and cosa.AssemblyRootPart ~= raiz then
		sueltas += 1
	end
end

if sueltas > 0 then
	warn("⚠️ ¡" .. sueltas .. " piezas sueltas! El cuerpo NO seguirá a la raíz al moverse.")
else
	print("✅ Cuerpo bien enganchado: se moverá entero.")
end

--==================================================================
-- 🎯 A quién persigue
--==================================================================
local function jugadorMasCerca()
	local mejor, mejorDistancia

	for _, jugador in ipairs(Players:GetPlayers()) do
		local personaje = jugador.Character
		local cuerpo = personaje and personaje:FindFirstChild("HumanoidRootPart")
		local hum = personaje and personaje:FindFirstChildOfClass("Humanoid")

		if cuerpo and hum and hum.Health > 0 then
			local d = (cuerpo.Position - raiz.Position).Magnitude
			if not mejorDistancia or d < mejorDistancia then
				mejor, mejorDistancia = cuerpo, d
			end
		end
	end

	return mejor, mejorDistancia
end

--==================================================================
-- 🦶 Que pise el suelo siempre (rayo hacia abajo)
--==================================================================
local rayo = RaycastParams.new()
rayo.FilterType = Enum.RaycastFilterType.Exclude
rayo.FilterDescendantsInstances = { monstruo }

local function refrescarFiltro()
	local fuera = { monstruo }
	for _, jugador in ipairs(Players:GetPlayers()) do
		if jugador.Character then
			table.insert(fuera, jugador.Character)
		end
	end
	rayo.FilterDescendantsInstances = fuera
end

local function alturaDelSuelo(x, z, yAhora)
	local golpe = workspace:Raycast(Vector3.new(x, yAhora + 12, z), Vector3.new(0, -300, 0), rayo)
	return golpe and golpe.Position.Y or nil
end

--==================================================================
-- 🗺️ El camino
--==================================================================
local puntos = {}
local siguiente = 1
local estadoMapa = "sin empezar"

local camino = PathfindingService:CreatePath({
	AgentRadius = 2,
	AgentHeight = 6,
	AgentCanJump = false,
	WaypointSpacing = 6,
})

task.spawn(function()
	while monstruo.Parent do
		task.wait(0.6)
		refrescarFiltro()

		local objetivo, distancia = jugadorMasCerca()

		if not objetivo or distancia > DISTANCIA_VISION then
			puntos = {}
			estadoMapa = "no te veo"

		elseif not USAR_MAPA then
			puntos = { objetivo.Position }
			siguiente = 1
			estadoMapa = "linea recta"

		else
			local desde = raiz.Position - Vector3.new(0, ALTURA_RAIZ, 0)
			local hasta = objetivo.Position - Vector3.new(0, 2.5, 0)

			local salioBien = pcall(function()
				camino:ComputeAsync(desde, hasta)
			end)

			if salioBien and camino.Status == Enum.PathStatus.Success then
				puntos = {}
				for _, w in ipairs(camino:GetWaypoints()) do
					table.insert(puntos, w.Position)
				end
				siguiente = 2
				estadoMapa = "camino de " .. #puntos .. " puntos"
			else
				puntos = { hasta }
				siguiente = 1
				estadoMapa = "SIN RUTA -> linea recta"
			end
		end
	end
end)

--==================================================================
-- 🏃 MOVERSE
--==================================================================
local andando = false
local ultimoAviso = 0

-- El "cartelito" que lee tu pantalla para saber si mover las piernas
local function avisarSiAnda(valor)
	if andando ~= valor then
		andando = valor
		monstruo:SetAttribute("Andando", valor)
	end
end

monstruo:SetAttribute("Andando", false)

RunService.Heartbeat:Connect(function(dt)
	local objetivo, distancia = jugadorMasCerca()

	-- ¿Te ha pillado?
	if objetivo and distancia and distancia < DISTANCIA_PILLAR then
		avisarSiAnda(false)

		local haciaTi = (objetivo.Position - raiz.Position) * Vector3.new(1, 0, 1)
		if haciaTi.Magnitude > 0.1 then
			raiz.CFrame = CFrame.lookAt(raiz.Position, raiz.Position + haciaTi.Unit)
		end

		if os.clock() - ultimoAviso > 3 then
			ultimoAviso = os.clock()
			print("👹 ¡TE HA PILLADO!")
			-- 👉 Aquí irá el final de la partida
		end
		return
	end

	-- ¿No hay camino o se han acabado los puntos? Pues a por ti en recto.
	local destino = puntos[siguiente]
	if not destino and objetivo then
		destino = objetivo.Position - Vector3.new(0, 2.5, 0)
	end

	if not destino then
		avisarSiAnda(false)
		return
	end

	local desde = raiz.Position
	local plano = Vector3.new(destino.X - desde.X, 0, destino.Z - desde.Z)

	if plano.Magnitude < 4 then
		siguiente += 1              -- punto alcanzado, al siguiente
		return
	end

	avisarSiAnda(true)

	local direccion = plano.Unit
	local avance = math.min(VELOCIDAD * dt, plano.Magnitude)
	local x = desde.X + direccion.X * avance
	local z = desde.Z + direccion.Z * avance

	-- La altura la decide el SUELO que haya debajo
	local suelo = alturaDelSuelo(x, z, desde.Y)
	local y = desde.Y

	if suelo then
		local quiero = suelo + ALTURA_RAIZ
		y = desde.Y + (quiero - desde.Y) * math.min(1, dt * 6)
	end

	local sitio = Vector3.new(x, y, z)
	raiz.CFrame = CFrame.lookAt(sitio, sitio + direccion)
end)

--==================================================================
-- 🔎 EL CHIVATO
--==================================================================
if CHIVATO then
	task.spawn(function()
		while monstruo.Parent do
			task.wait(1)

			local objetivo, distancia = jugadorMasCerca()
			local p = raiz.Position

			print(string.format(
				"👹 %s | dist: %s | mapa: %s | punto %d/%d | andando: %s | está en %.0f, %.0f, %.0f",
				objetivo and "te veo" or "NO HAY JUGADOR",
				distancia and string.format("%.0f", distancia) or "-",
				estadoMapa,
				siguiente, #puntos,
				tostring(andando),
				p.X, p.Y, p.Z
			))
		end
	end)
end

print("👹 Persecución activada (la animación la hace MonstruoAnimacion).")
end

--==================================================================
-- ▶️ AQUÍ SE EJECUTA TODO, EN ORDEN
--==================================================================
ambiente()              -- 1. primero la noche
construirCuarto()       -- 2. el cuarto (la mansión lo sube al piso 2)
construirCasa()         -- 3. la mansión
construirJardin()       -- 4. el jardín con la piscina
construirMonstruo()     -- 5. el cuerpo del monstruo

-- Estos tres se quedan funcionando todo el rato, así que los lanzamos
-- "en paralelo" con task.spawn: si no, el primero no dejaría empezar
-- a los demás. 🧵
task.spawn(lucesDeSuelo)
task.spawn(opciones)
task.spawn(monstruoPersigue)

print("═══════════════════════════════════")
print("✅ LA NOCHE lista. ¡Que empiece el miedo!")
print("═══════════════════════════════════")
