--[[
	NocheOscura
	-----------
	Pone el juego en plena noche: sol quitado, todo muy oscuro, niebla espesa
	y un cielo negro. Es el ambiente de terror.

	Dónde va: Explorer -> ServerScriptService -> ➕ -> Script
	Nómbralo: NocheOscura
]]

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
