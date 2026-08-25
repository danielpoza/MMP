# ✅ Los scripts que tiene que haber (¡solo DOS!)

## 📂 ServerScriptService
| Nombre | Tipo |
|---|---|
| `LaNoche` | **Script** |

## 📂 StarterPlayer → StarterPlayerScripts
| Nombre | Tipo |
|---|---|
| `LaNocheCliente` | **LocalScript** |

**Y nada más.** Si aparece cualquier otro script, sobra y hay que borrarlo.

## 🧹 Limpieza total (Command Bar, en modo edición)

```lua
local n = 0 for _, s in ipairs(game:GetService("ServerScriptService"):GetDescendants()) do if s:IsA("LuaSourceContainer") then s:Destroy() n += 1 end end for _, s in ipairs(game:GetService("StarterPlayer").StarterPlayerScripts:GetDescendants()) do if s:IsA("LuaSourceContainer") then s:Destroy() n += 1 end end for _, m in ipairs({"Casa","Cuarto","Jardin","Monstruo","Pasillo"}) do local x = workspace:FindFirstChild(m) if x then x:Destroy() end end print("🧹 Borrados " .. n .. " scripts. Todo limpio.")
```

## 🛡️ El guardián

Los dos scripts llevan un guardián: si acabase habiendo una copia de más, la
segunda **se apaga sola** y avisa en la Output con un ⛔. Nunca más se pelean
dos scripts por montar la casa.

## 🔎 Qué tiene que salir en la Output al dar a ▶ Play

```
═══════════════════════════════════
🌙 LA NOCHE — arrancando el juego...
═══════════════════════════════════
▶️ ConstruirCuarto arrancando...
▶️ ConstruirCasa — MANSIÓN v3 arrancando...
▶️ ConstruirJardin arrancando...
▶️ ConstruirMonstruo arrancando...
✅ LA NOCHE lista. ¡Que empiece el miedo!
```

Cada línea **una sola vez**. Si alguna se repite, hay un duplicado.
