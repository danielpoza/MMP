--[[
	ConstruirCuarto
	---------------
	Construye tu cuarto entero con código: suelo, 4 paredes, techo, la PUERTA,
	la VENTANA, la CAMA, la SILLA de vigilar y una mesita con lámpara.
	También pone el punto de aparición dentro del cuarto.

	Dónde va: Explorer -> ServerScriptService -> ➕ -> Script
	Nómbralo: ConstruirCuarto

	Los nombres CAMA, PUERTA y SILLA son importantes: los siguientes scripts
	los van a buscar por ese nombre para las 3 opciones del juego.

	¿Quieres el cuarto más grande o de otro color? Cambia los números de aquí
	abajo y vuelve a darle a Play. ¡Es tuyo!
]]

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
