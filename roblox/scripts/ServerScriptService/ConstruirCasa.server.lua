--[[
	ConstruirCasa  ·  LA MANSIÓN
	----------------------------
	🏰 CUATRO NIVELES, como las mansiones de Roblox:

	   AZOTEA      ← terraza con vistas
	   PISO 3      ← habitación de papá y mamá 🔒
	   PISO 2      ← NUESTRA habitación (se coloca aquí sola)
	   PISO 1      ← salón, comedor y cocina. Aquí están las CORTINAS 🪟
	   PISO BAJO   ← recibidor y GARAJE con el coche 🚗
	   JARDÍN      ← lo monta el script ConstruirJardin (piscina, muros...)

	Las escaleras suben por el mismo hueco en todos los pisos, y ese hueco
	se ve desde arriba (doble altura). 🕳️

	⚠️ Este script MUEVE tu cuarto al piso 2 él solo. No toques
	   ConstruirCuarto: sigue igual que siempre.

	Dónde va: ServerScriptService -> ➕ -> Script -> se llama ConstruirCasa
]]

--==================================================================
-- 📐 MEDIDAS DE LA MANSIÓN
--==================================================================
local ALTURA = 20                  -- alto de cada piso (unos 5,6 metros)
local GROSOR = 1                   -- lo gordos que son suelos y paredes

local X1, X2 = -60, 60             -- la mansión, de lado a lado
local Z1, Z2 = -45, 45             -- de la fachada al fondo

local EX1, EX2 = 30, 58            -- el hueco de la escalera
local EZ1, EZ2 = -40, -2
local HUECO_Z2 = -8                -- hasta dónde llega el agujero del suelo

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
	local color = (piso == 1) and C.parquet or C.parquet
	losaConHueco("Suelo" .. piso, X1, X2, Z1, Z2, EX1, EX2, EZ1, HUECO_Z2, base(piso), color, Enum.Material.WoodPlanks)
end

-- La azotea: aquí el hueco se tapa con una casetilla de salida
losaConHueco("SueloAzotea", X1, X2, Z1, Z2, EX1, EX2, EZ1, HUECO_Z2, AZOTEA, C.marmol, Enum.Material.Marble)

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
-- 🪜 LA ESCALERA (sube por el mismo hueco en todos los pisos)
--==================================================================
local ANCHO_ESC = EX2 - EX1 - 4
local X_ESC = (EX1 + EX2) / 2
local LARGO_ESC = 30

for piso = 0, 3 do
	local b = base(piso)
	local subida = base(piso + 1) - b
	local escalones = math.ceil(subida / 1.5)          -- que ninguno pase de 1,5
	local alturaPaso = subida / escalones
	local fondoPaso = LARGO_ESC / escalones

	for i = 1, escalones do
		local h = alturaPaso * i
		bloque("Escalon", Vector3.new(ANCHO_ESC, h, fondoPaso),
			Vector3.new(X_ESC, b + h / 2, EZ1 + 2 + (i - 0.5) * fondoPaso), C.marmol, Enum.Material.Marble)
	end

	-- barandilla dorada del lado abierto
	for i = 0, 6 do
		bloque("Barrote", Vector3.new(0.4, 5, 0.4),
			Vector3.new(EX1 + 1, base(piso + 1) + 2.5, HUECO_Z2 + i * 1.5), C.oro, Enum.Material.Metal)
	end
	bloque("Pasamanos", Vector3.new(0.6, 0.6, 9),
		Vector3.new(EX1 + 1, base(piso + 1) + 5, HUECO_Z2 + 4.5), C.oro, Enum.Material.Metal)

	iluminar("LuzEscalera" .. piso, EX1, EX2, EZ1, EZ2, b, 1.4)
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
bloque("CasetaAzotea", Vector3.new(EX2 - EX1 + 4, 12, 12), Vector3.new(X_ESC, AZOTEA + 6, -4), C.marmol, Enum.Material.Marble)

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
