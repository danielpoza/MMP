--[[
	LA NOCHE  ·  versión corta, TODO en un solo script
	==================================================
	La mansión se construye centrada en el SPAWNER que ya haya en tu mundo,
	y tu cuarto queda justo ENCIMA de él, en el piso 2. 🎯

	Dónde va: ServerScriptService -> ➕ -> Script -> se llama LaNoche
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

--==================================================================
-- 📏 LAS MEDIDAS (cámbialas y se rehace todo)
--==================================================================
local ALTO = 16                     -- alto de cada piso (4,5 metros)
local GROSOR = 1                    -- grosor de suelos y paredes
local ANCHO, FONDO = 100, 80        -- la mansión de lado a lado
local CUARTO = 24                   -- tu cuarto es cuadrado: 24 x 24

local function base(p) return 1 + p * (ALTO + GROSOR) end   -- 1, 18, 35, 52
local AZOTEA = base(4)

local X1, X2 = -ANCHO / 2, ANCHO / 2
local Z1, Z2 = -FONDO / 2, FONDO / 2
local M = CUARTO / 2                -- media medida del cuarto

local EX1, EX2 = 26, 48             -- el hueco de la escalera
local EZ1, EZ2 = -34, -6

--==================================================================
-- 🎯 EL CENTRO: encima del spawner que ya hay en el mundo
--==================================================================
local spawner
for _, cosa in ipairs(workspace:GetDescendants()) do
	if cosa:IsA("SpawnLocation") then spawner = cosa break end
end

local CX = spawner and spawner.Position.X or 0
local CZ = spawner and spawner.Position.Z or 0

local function px(x) return CX + x end        -- pasar del plano al mundo
local function pz(z) return CZ + z end

--==================================================================
-- 🌙 LA NOCHE
--==================================================================
Lighting.ClockTime = 0
Lighting.Brightness = 0.35
Lighting.Ambient = Color3.fromRGB(28, 28, 40)          -- luz de fondo suave
Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 32)
Lighting.ExposureCompensation = -0.4                   -- baja el "brillo" general
Lighting.GlobalShadows = true
Lighting.FogColor = Color3.fromRGB(8, 8, 12)
Lighting.FogStart = 20
Lighting.FogEnd = 400

--==================================================================
-- 🧰 HERRAMIENTAS
--==================================================================
local vieja = workspace:FindFirstChild("Mansion")
if vieja then vieja:Destroy() end

local casa = Instance.new("Model")
casa.Name = "Mansion"
casa.Parent = workspace

local C = {
	pared = Color3.fromRGB(206, 198, 182), suelo = Color3.fromRGB(108, 72, 44),
	marmol = Color3.fromRGB(230, 226, 218), oro = Color3.fromRGB(200, 166, 92),
	madera = Color3.fromRGB(84, 54, 32), tela = Color3.fromRGB(92, 100, 116),
	cortina = Color3.fromRGB(112, 26, 38), negro = Color3.fromRGB(26, 26, 30),
	metal = Color3.fromRGB(196, 198, 204), luz = Color3.fromRGB(255, 236, 200),
}

local function bloque(nombre, tam, x, y, z, color, material)
	local p = Instance.new("Part")
	p.Name = nombre
	p.Size = tam
	p.Position = Vector3.new(px(x), y, pz(z))
	p.Color = color or C.pared
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = casa
	return p
end

-- Suelo: la cara de arriba queda justo en la altura "y"
local function losa(nombre, x1, x2, z1, z2, y, color, material)
	return bloque(nombre, Vector3.new(x2 - x1, GROSOR, z2 - z1),
		(x1 + x2) / 2, y - GROSOR / 2, (z1 + z2) / 2, color or C.suelo, material)
end

-- Suelo con el AGUJERO de la escalera: cuatro trozos, como un marco 🖼️
local function losaConHueco(nombre, y, color, material)
	losa(nombre .. "A", X1, X2, Z1, EZ1, y, color, material)
	losa(nombre .. "B", X1, X2, EZ2, Z2, y, color, material)
	losa(nombre .. "C", X1, EX1, EZ1, EZ2, y, color, material)
	losa(nombre .. "D", EX2, X2, EZ1, EZ2, y, color, material)
end

local function paredX(nombre, x, z1, z2, b, alto)
	return bloque(nombre, Vector3.new(GROSOR, alto or ALTO, z2 - z1),
		x, b + (alto or ALTO) / 2, (z1 + z2) / 2, C.pared)
end

local function paredZ(nombre, z, x1, x2, b, alto)
	return bloque(nombre, Vector3.new(x2 - x1, alto or ALTO, GROSOR),
		(x1 + x2) / 2, b + (alto or ALTO) / 2, z, C.pared)
end

local function mueble(nombre, x, z, tam, altura, b, color, material)
	return bloque(nombre, tam, x, b + altura, z, color or C.madera, material or Enum.Material.Wood)
end

-- 💡 OJO CON LA LUZ: en Roblox, si juntas muchas luces fuertes la imagen se
--    "quema" y se ve todo blanco. Por eso van flojitas y con poco alcance.
--    Y el material Neon SIEMPRE brilla a tope, así que su color va oscuro.
local function lampara(nombre, x, z, b, alcance)
	local bombilla = bloque(nombre, Vector3.new(3, 1.2, 3), x, b + ALTO - 2, z,
		Color3.fromRGB(190, 160, 105), Enum.Material.Neon)

	local luz = Instance.new("PointLight")
	luz.Brightness = 0.8              -- antes 2: cegaba
	luz.Range = alcance or 30         -- antes 55
	luz.Color = Color3.fromRGB(255, 220, 170)
	luz.Parent = bombilla
	return bombilla
end

--==================================================================
-- 🧱 SUELOS, FACHADAS Y AZOTEA
--==================================================================
losa("SueloBajo", X1, X2, Z1, Z2, base(0), C.marmol, Enum.Material.Marble)
for piso = 1, 3 do
	losaConHueco("Suelo" .. piso, base(piso), C.suelo, Enum.Material.WoodPlanks)
end
losaConHueco("SueloAzotea", AZOTEA, C.marmol, Enum.Material.Marble)

for piso = 0, 3 do
	local b = base(piso)

	if piso == 0 then
		-- la fachada de abajo tiene el hueco del GARAJE (de -34 a -14)
		paredZ("FachadaA", Z1, X1, -34, b)
		paredZ("FachadaB", Z1, -14, X2, b)
		bloque("DintelGaraje", Vector3.new(20, ALTO - 12, GROSOR), -24, b + 12 + (ALTO - 12) / 2, Z1, C.pared)
	else
		paredZ("Fachada" .. piso, Z1, X1, X2, b)
	end

	paredZ("Fondo" .. piso, Z2, X1, X2, b)
	paredX("Izq" .. piso, X1, Z1, Z2, b)
	paredX("Der" .. piso, X2, Z1, Z2, b)
end

-- Pretil de la azotea, para no caerse
paredZ("PretilA", Z1, X1, X2, AZOTEA, 6)
paredZ("PretilB", Z2, X1, X2, AZOTEA, 6)
paredX("PretilC", X1, Z1, Z2, AZOTEA, 6)
paredX("PretilD", X2, Z1, Z2, AZOTEA, 6)

--==================================================================
-- 🪜 LA ESCALERA (en zigzag: los tramos NO quedan uno encima de otro)
--==================================================================
local Z_ABAJO, Z_ARRIBA = EZ1 + 2, EZ2 - 2
local LARGO = Z_ARRIBA - Z_ABAJO
local COL_A, COL_B = 31, 43            -- las dos columnas, una al lado de otra

for piso = 0, 3 do
	local b = base(piso)
	local subida = base(piso + 1) - b
	local escalones = math.ceil(subida / 1.5)
	local alturaPaso, fondoPaso = subida / escalones, LARGO / escalones

	local par = (piso % 2 == 0)
	local x = par and COL_A or COL_B

	for i = 1, escalones do
		local h = alturaPaso * i
		local avance = (i - 0.5) * fondoPaso
		local z = par and (Z_ABAJO + avance) or (Z_ARRIBA - avance)
		bloque("Escalon", Vector3.new(10, h, fondoPaso), x, b + h / 2, z, C.marmol, Enum.Material.Marble)
	end

	lampara("LuzEscalera" .. piso, (EX1 + EX2) / 2, (EZ1 + EZ2) / 2, b)

	-- barandilla alrededor del agujero
	if piso > 0 then
		for i = 0, 6 do
			local z = EZ1 + (i + 0.5) * (EZ2 - EZ1) / 7
			bloque("Barrote", Vector3.new(0.5, 5, 0.5), EX1, b + 2.5, z, C.oro, Enum.Material.Metal)
		end
	end
end

--==================================================================
-- 🚗 PISO BAJO: EL GARAJE
--==================================================================
local b0 = base(0)
lampara("LuzGaraje1", -25, -10, b0)
lampara("LuzGaraje2", 5, 20, b0)

local CX_COCHE, CZ_COCHE = -24, -12

mueble("CocheCuerpo", CX_COCHE, CZ_COCHE, Vector3.new(14, 5, 30), 4, b0, C.negro, Enum.Material.Metal)
mueble("CocheCabina", CX_COCHE, CZ_COCHE + 1, Vector3.new(12, 4, 13), 8.5, b0, C.negro, Enum.Material.Metal)

for _, lx in ipairs({ -1, 1 }) do
	for _, lz in ipairs({ -1, 1 }) do
		local rueda = mueble("Rueda", CX_COCHE + lx * 7, CZ_COCHE + lz * 9.5, Vector3.new(3, 6, 6), 3, b0, C.negro, Enum.Material.SmoothPlastic)
		rueda.Shape = Enum.PartType.Cylinder
		rueda.CFrame = CFrame.new(rueda.Position) * CFrame.Angles(0, 0, math.rad(90))
	end
	mueble("Faro", CX_COCHE + lx * 4.5, CZ_COCHE - 15, Vector3.new(3.5, 1.6, 0.6), 4.5, b0, Color3.fromRGB(180, 175, 140), Enum.Material.Neon)
end

-- 🔢 LA MATRÍCULA
local matricula = mueble("Matricula", CX_COCHE, CZ_COCHE + 15.2, Vector3.new(9, 2.6, 0.4), 2.6, b0,
	Color3.fromRGB(245, 245, 235), Enum.Material.SmoothPlastic)

local cartel = Instance.new("SurfaceGui")
cartel.Face = Enum.NormalId.Back
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
-- 🛋️ PISO 1: SALÓN Y CORTINAS
--==================================================================
local b1 = base(1)
lampara("LuzSalon1", -25, -15, b1)
lampara("LuzSalon2", -25, 20, b1)
lampara("LuzSalon3", 10, 20, b1)

-- Un muro parte el piso, con el hueco que tapan las cortinas
paredX("MuroSalonA", 0, Z1, -9, b1)
paredX("MuroSalonB", 0, 9, Z2, b1)

bloque("BarraCortinas", Vector3.new(1.2, 0.8, 18), 0, b1 + ALTO - 1, 0, C.oro, Enum.Material.Metal)
bloque("CortinaIzq", Vector3.new(1.2, ALTO - 1.4, 9), 0, b1 + (ALTO - 1.4) / 2, -4.5, C.cortina, Enum.Material.Fabric)
bloque("CortinaDer", Vector3.new(1.2, ALTO - 1.4, 9), 0, b1 + (ALTO - 1.4) / 2, 4.5, C.cortina, Enum.Material.Fabric)

mueble("Sofa", -30, -10, Vector3.new(20, 3, 8), 1.5, b1, C.tela, Enum.Material.Fabric)
mueble("SofaRespaldo", -30, -14, Vector3.new(20, 5, 1.5), 2.5, b1, C.tela, Enum.Material.Fabric)
mueble("MesaCentro", -30, 0, Vector3.new(12, 1, 6), 3, b1)
local tele = mueble("Tele", -30, 14, Vector3.new(20, 10, 0.8), 9, b1, C.negro, Enum.Material.Glass)
tele.Reflectance = 0.3
mueble("MesaComedor", 25, 5, Vector3.new(18, 1, 9), 5, b1)

--==================================================================
-- 🛏️ PISO 2: NUESTRO CUARTO, JUSTO ENCIMA DEL SPAWNER
--==================================================================
local b2 = base(2)
lampara("LuzPiso2", -30, 20, b2)
lampara("LuzPiso2b", 10, 25, b2)

-- Las cuatro paredes del cuarto. La de delante lleva el hueco de la puerta.
paredX("CuartoIzq", -M, -M, M, b2)
paredX("CuartoDer", M, -M, M, b2)
paredZ("CuartoFondo", -M, -M, M, b2)
paredZ("CuartoFrenteA", M, -M, -3, b2)
paredZ("CuartoFrenteB", M, 3, M, b2)
bloque("CuartoDintel", Vector3.new(6, ALTO - 8, GROSOR), 0, b2 + 8 + (ALTO - 8) / 2, M, C.pared)

-- 🚪 LA PUERTA (aquí sale [E] Salir)
bloque("Puerta", Vector3.new(6, 8, 0.6), 0, b2 + 4, M, C.madera, Enum.Material.Wood)
bloque("Pomo", Vector3.new(0.7, 0.7, 0.7), 2, b2 + 4, M - 0.6, C.oro, Enum.Material.Metal)

-- Muebles del cuarto
mueble("Cama", -6, -4, Vector3.new(7, 2, 11), 1, b2)
mueble("Colchon", -6, -4, Vector3.new(6.4, 1.2, 10.4), 2.6, b2, Color3.fromRGB(186, 182, 172), Enum.Material.Fabric)
mueble("Almohada", -6, -8.4, Vector3.new(5, 1, 2.4), 3.6, b2, Color3.fromRGB(228, 224, 214), Enum.Material.Fabric)
mueble("Silla", 7, 6, Vector3.new(3.4, 0.8, 3.4), 3, b2)
mueble("SillaRespaldo", 7, 7.6, Vector3.new(3.4, 4, 0.6), 5, b2)
mueble("Mesita", -1, -9, Vector3.new(3, 4, 3), 2, b2)

local lamparita = mueble("Lamparita", -1, -9, Vector3.new(1.6, 1.6, 1.6), 5, b2, Color3.fromRGB(190, 150, 95), Enum.Material.Neon)
local luzMesita = Instance.new("PointLight")
luzMesita.Brightness = 1
luzMesita.Range = 20
luzMesita.Color = Color3.fromRGB(255, 200, 140)
luzMesita.Parent = lamparita

-- 📍 El punto de aparición se sube AQUÍ DENTRO
if not spawner then
	spawner = Instance.new("SpawnLocation")
	spawner.Parent = workspace
end
spawner.Size = Vector3.new(6, 0.4, 6)
spawner.Position = Vector3.new(px(6), b2 + 0.3, pz(0))
spawner.Anchored = true
spawner.CanCollide = false
spawner.Transparency = 1
spawner.Neutral = true

--==================================================================
-- 🔒 PISO 3: LA HABITACIÓN DE PAPÁ Y MAMÁ (cerrada con llave)
--==================================================================
local b3 = base(3)
lampara("LuzPiso3", -20, 20, b3)

-- El muro de su cuarto, partido para dejar el hueco de la puerta
paredX("PadresIzqA", -20, Z1, -18, b3)
paredX("PadresIzqB", -20, -10, 0, b3)
bloque("PadresDintel", Vector3.new(GROSOR, ALTO - 10, 8), -20, b3 + 10 + (ALTO - 10) / 2, -14, C.pared)
paredZ("PadresFrente", 0, X1, -20, b3)

bloque("PuertaPadres", Vector3.new(1.2, 10, 8), -20, b3 + 5, -14, C.madera, Enum.Material.Wood)
bloque("CerraduraPadres", Vector3.new(1, 1.6, 1), -21, b3 + 4, -11, C.metal, Enum.Material.Metal)

mueble("CamaPadres", -34, -22, Vector3.new(20, 3, 16), 1.5, b3)
mueble("ColchonPadres", -34, -22, Vector3.new(19, 2, 15), 4, b3, Color3.fromRGB(190, 186, 176), Enum.Material.Fabric)

-- Y una tumbona en la azotea
mueble("Tumbona", 0, 20, Vector3.new(8, 1.4, 18), 1, AZOTEA, Color3.fromRGB(232, 228, 218), Enum.Material.Fabric)

for _, lado in ipairs({ -25, 25 }) do
	bloque("Farola", Vector3.new(1.5, 14, 1.5), lado, AZOTEA + 7, 0, C.metal, Enum.Material.Metal)
	local foco = bloque("FocoAzotea", Vector3.new(3, 2, 3), lado, AZOTEA + 14, 0, Color3.fromRGB(190, 160, 105), Enum.Material.Neon)
	local luz = Instance.new("PointLight")
	luz.Brightness = 0.8
	luz.Range = 28
	luz.Color = Color3.fromRGB(255, 220, 170)
	luz.Parent = foco
end

--==================================================================
-- 💡 BALIZAS DE LUZ EN EL SUELO (si no, no se ve nada)
--==================================================================
local balizas = 0
for _, pieza in ipairs(casa:GetChildren()) do
	if pieza:IsA("BasePart") and pieza.Name:sub(1, 5) == "Suelo" then
		local tam = pieza.Size
		local arriba = pieza.Position.Y + tam.Y / 2

		local filas = math.max(1, math.floor(tam.X / 45))       -- antes 30: sobraban
		local columnas = math.max(1, math.floor(tam.Z / 45))

		for i = 1, filas do
			for j = 1, columnas do
				local baliza = Instance.new("Part")
				baliza.Name = "Baliza"
				baliza.Size = Vector3.new(5, 0.3, 5)
				baliza.Position = Vector3.new(
					pieza.Position.X - tam.X / 2 + (i - 0.5) * tam.X / filas,
					arriba + 0.2,
					pieza.Position.Z - tam.Z / 2 + (j - 0.5) * tam.Z / columnas)
				baliza.Color = Color3.fromRGB(80, 115, 175)     -- azul oscuro: brilla poco
				baliza.Material = Enum.Material.Neon
				baliza.Anchored = true
				baliza.CanCollide = false
				baliza.Parent = casa

				local luz = Instance.new("PointLight")
				luz.Brightness = 0.5              -- antes 2
				luz.Range = 22                    -- antes 45
				luz.Color = Color3.fromRGB(130, 180, 240)
				luz.Shadows = false
				luz.Parent = baliza

				balizas += 1
			end
		end
	end
end

--==================================================================
-- 🅴 LAS OPCIONES (tecla E)
--==================================================================
local SITIO_FUERA = CFrame.lookAt(Vector3.new(px(0), b2 + 4, pz(M + 10)), Vector3.new(px(0), b2 + 4, pz(M + 30)))
local SITIO_DENTRO = CFrame.lookAt(Vector3.new(px(0), b2 + 4, pz(M - 6)), Vector3.new(px(0), b2 + 4, pz(-M)))

-- El texto blanco de abajo (lo crea el servidor en tu pantalla)
local function avisar(jugador, texto)
	local pantalla = jugador:FindFirstChild("PlayerGui")
	if not pantalla then return end

	local viejo = pantalla:FindFirstChild("AvisoNoche")
	if viejo then viejo:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "AvisoNoche"
	gui.ResetOnSpawn = false
	gui.Parent = pantalla

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0.7, 0, 0, 70)
	t.Position = UDim2.new(0.15, 0, 0.75, 0)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.Gotham
	t.TextSize = 22
	t.TextWrapped = true
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.TextStrokeTransparency = 0.4
	t.Text = texto
	t.Parent = gui

	task.delay(6, function() if gui then gui:Destroy() end end)
end

local function teletransportar(jugador, destino)
	local personaje = jugador.Character
	local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
	if not humanoide or humanoide.Health <= 0 then return false end

	humanoide.Sit = false
	personaje:PivotTo(destino)
	return true
end

local function opcion(pieza, accion, objeto, alPulsar)
	if not pieza then return nil end

	local cartel = Instance.new("ProximityPrompt")
	cartel.ActionText = accion
	cartel.ObjectText = objeto
	cartel.KeyboardKeyCode = Enum.KeyCode.E
	cartel.MaxActivationDistance = math.max(14, pieza.Size.Magnitude * 0.7)
	cartel.RequiresLineOfSight = false
	cartel.Parent = pieza

	cartel.Triggered:Connect(alPulsar)
	print("   ✔ [E] " .. accion .. " en " .. pieza.Name)
	return cartel
end

opcion(casa.Cama, "Dormir", "Cama", function(jugador)
	avisar(jugador, "Cierras los ojos. Solo un ratito...")
end)

opcion(casa.Silla, "Vigilar", "Silla", function(jugador)
	avisar(jugador, "Te sientas frente a la puerta. No parpadees.")
end)

-- La puerta invisible de fuera, para poder volver a entrar
local puertaFuera = bloque("PuertaFuera", Vector3.new(6, 8, 0.4), 0, b2 + 4, M + 1.4, C.pared)
puertaFuera.Transparency = 1
puertaFuera.CanCollide = false

local salir, entrar

salir = opcion(casa.Puerta, "Salir", "Puerta", function(jugador)
	if not teletransportar(jugador, SITIO_FUERA) then return end
	avisar(jugador, "Sales al piso 2. La mansión está en silencio...")
	salir.Enabled = false
	entrar.Enabled = true
end)

entrar = opcion(puertaFuera, "Entrar", "Puerta", function(jugador)
	if not teletransportar(jugador, SITIO_DENTRO) then return end
	avisar(jugador, "Cierras la puerta. Estás a salvo... de momento.")
	entrar.Enabled = false
	salir.Enabled = true
end)

entrar.Enabled = false

-- 🪟 Las cortinas
local cortinasAbiertas = false
local abrirCortinas

abrirCortinas = opcion(casa.CortinaIzq, "Abrir cortinas", "Cortinas", function(jugador)
	if cortinasAbiertas then return end
	cortinasAbiertas = true

	local suave = TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(casa.CortinaIzq, suave, {
		Size = Vector3.new(2.6, ALTO - 1.4, 2), Position = casa.CortinaIzq.Position + Vector3.new(0, 0, -3.5) }):Play()
	TweenService:Create(casa.CortinaDer, suave, {
		Size = Vector3.new(2.6, ALTO - 1.4, 2), Position = casa.CortinaDer.Position + Vector3.new(0, 0, 3.5) }):Play()

	avisar(jugador, "Descorres las cortinas... y algo, en alguna parte, se ha movido.")
	abrirCortinas.Enabled = false
end)

opcion(casa.PuertaPadres, "Abrir", "Puerta", function(jugador)
	avisar(jugador, jugador.Name .. ": Es la habitación de papá y mamá, pero está cerrada con llave.")
end)

Players.PlayerAdded:Connect(function(jugador)
	jugador.CharacterAdded:Connect(function()
		salir.Enabled = true
		entrar.Enabled = false
	end)
end)

--==================================================================
-- 📏 LAS MEDIDAS, PARA QUE LAS COMPRUEBES
--==================================================================
print("═════════════════════════════════════════")
print("🏰 MANSIÓN LISTA. Medidas (1 stud ≈ 0,28 m):")
print(string.format("   Centro (encima del spawner): x = %.0f , z = %.0f", CX, CZ))
print(string.format("   Planta: %d x %d studs  =  %.0f x %.0f metros", ANCHO, FONDO, ANCHO * 0.28, FONDO * 0.28))
print(string.format("   Cada piso: %d studs de alto = %.1f metros", ALTO, ALTO * 0.28))
print(string.format("   Tu cuarto: %d x %d studs = %.0f m² , en el piso 2 (altura %d)", CUARTO, CUARTO, CUARTO * CUARTO * 0.0784, base(2)))
print(string.format("   Altura total hasta la azotea: %d studs = %.0f metros", AZOTEA, AZOTEA * 0.28))
print("   Balizas de luz: " .. balizas)
print("═════════════════════════════════════════")
