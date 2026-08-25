# ✅ Los scripts que tiene que haber (y NINGUNO más)

Si aparece algo que no está en esta lista, **sobra y hay que borrarlo**.
Casi todos los líos raros ("la casa vuelve a la de antes", "no funciona la
tecla E") vienen de un script viejo que se quedó ahí y pisa al nuevo.

## 📂 ServerScriptService  (todos son **Script**)

| Nombre | Qué hace |
|---|---|
| `NocheOscura` | Pone el mundo de noche cerrada, con niebla |
| `ConstruirCuarto` | Monta tu cuarto (cama, silla, puerta, ventana) |
| `ConstruirCasa` | Monta la MANSIÓN de 4 niveles y sube tu cuarto al piso 2 |
| `ConstruirJardin` | Césped, piscina con luces, farolas y muros invisibles |
| `LucesDeSuelo` | Reparte balizas de luz por los suelos |
| `Opciones` | Todas las teclas [E]: dormir, salir, cortinas, nevera... |
| `ConstruirMonstruo` | Monta el cuerpo del monstruo con sus articulaciones |
| `MonstruoPersigue` | Hace que el monstruo te persiga por la casa |

## 📂 StarterPlayer → StarterPlayerScripts  (los dos son **LocalScript**)

| Nombre | Qué hace |
|---|---|
| `Interfaz` | El texto blanco de abajo y el panel de la nevera |
| `MonstruoAnimacion` | Mueve los brazos y las piernas del monstruo, a 60 fps |

## 🚨 Cómo saber si hay un intruso

En la **Command Bar**, en modo edición:

```lua
for _, s in ipairs(game:GetService("ServerScriptService"):GetDescendants()) do if s:IsA("LuaSourceContainer") then print(s.ClassName .. "  " .. s.Name) end end
```

Y para saber cuál de las casas se está montando, con el juego en marcha (Play):

```lua
print(workspace.Casa:FindFirstChild("Matricula") and "MANSION NUEVA" or "CASA VIEJA")
```

La mansión nueva tiene un coche con matrícula. La vieja no. 🚗
