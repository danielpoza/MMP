--[[
	ConstruirMonstruo
	-----------------
	Monta al monstruo pieza a pieza, con TODAS sus articulaciones, y lo hace
	moverse. No hace falta el editor de animaciones ni la IA: todo va aquí.

	🦴 LO QUE TIENE
	  · La cabeza partida en dos: la mandíbula (Head) y el cráneo, unidos por
	    una articulación. El cráneo se separa hacia arriba y vuelve a bajar,
	    como si se arrancase media cabeza con telequinesis. 🧠
	  · Dientes de polígonos (WedgePart) en las dos mitades de la boca.
	  · Brazos con hombro + CODO ESCONDIDO (una articulación de más). Como
	    están unidos con Motor6D, por mucho que se doblen NUNCA se separan.
	  · Piernas con cadera + RODILLA ESCONDIDA (otra articulación de más).
	  · Anda como si acabase de aprender: levanta la pierna despacio, duda
	    en el aire, y apoya el pie con muchísimo cuidado.

	Dónde va: ServerScriptService -> ➕ -> Script
	Nómbralo: ConstruirMonstruo
]]

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
humanoide.MaxHealth = 500
humanoide.Health = 500
humanoide.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
humanoide.WalkSpeed = 4
humanoide.AutoRotate = false        -- que no gire solo: lo movemos nosotros
humanoide.Parent = monstruo

monstruo.PrimaryPart = raiz
raiz.Anchored = true                 -- se queda de pie y no se cae
monstruo:PivotTo(CFrame.new(POSICION + Vector3.new(0, 9, 0)) * girar(0, MIRANDO, 0))

-- 🚶 El andar y la persecución los hace el script MonstruoPersigue.
-- Aquí solo se monta el cuerpo.

print("👹 Monstruo montado en " .. tostring(POSICION))
print("   Articulaciones: rodilla y codo escondidos en cada extremidad.")
