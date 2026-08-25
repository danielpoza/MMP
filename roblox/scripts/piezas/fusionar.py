#!/usr/bin/env python3
"""
Junta las piezas sueltas en los dos scripts que se pegan en Roblox Studio.

    python3 roblox/scripts/piezas/fusionar.py

Cada pieza se mete dentro de su propia funcion, asi no chocan los nombres
locales (varias definen 'bloque') ni los 'return' de salida rapida.
"""
import os

RAIZ = os.path.join(os.path.dirname(__file__), '..')
PIEZAS = os.path.join(RAIZ, 'piezas')


def cuerpo(nombre):
    s = open(os.path.join(PIEZAS, nombre), encoding='utf-8').read()
    if s.lstrip().startswith('--[['):
        s = s[s.index(']]') + 2:]
    return s.strip('\n')


def envolver(funcion, fichero, titulo):
    return (
        "--==================================================================\n"
        f"-- {titulo}\n"
        "--==================================================================\n"
        f"local function {funcion}()\n" + cuerpo(fichero) + "\nend\n"
    )


SERVIDOR = [
    ("ambiente", "NocheOscura.server.lua", "🌙 1. LA NOCHE"),
    ("construirCuarto", "ConstruirCuarto.server.lua", "🛏️ 2. TU CUARTO"),
    ("construirCasa", "ConstruirCasa.server.lua", "🏰 3. LA MANSIÓN"),
    ("construirJardin", "ConstruirJardin.server.lua", "🌿 4. EL JARDÍN"),
    ("construirMonstruo", "ConstruirMonstruo.server.lua", "👹 5. EL MONSTRUO"),
    ("lucesDeSuelo", "LucesDeSuelo.server.lua", "💡 6. BALIZAS DE SUELO"),
    ("opciones", "Opciones.server.lua", "🅴 7. LAS OPCIONES (tecla E)"),
    ("monstruoPersigue", "MonstruoPersigue.server.lua", "🏃 8. LA PERSECUCIÓN"),
]

CLIENTE = [
    ("interfaz", "Interfaz.client.lua", "✍️ 1. TEXTOS Y NEVERA"),
    ("animacionMonstruo", "MonstruoAnimacion.client.lua", "🎬 2. ANIMACIÓN DEL MONSTRUO"),
]

CABECERA_SERVIDOR = '''--[[
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

'''

CIERRE_SERVIDOR = '''
--==================================================================
-- ▶️ AQUÍ SE EJECUTA TODO, EN ORDEN
--==================================================================
ambiente()              -- 1. primero la noche
construirCuarto()       -- 2. el cuarto (la mansión lo coloca luego)
construirCasa()         -- 3. la mansión, que cuelga el cuarto en el piso 2
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
'''

CABECERA_CLIENTE = '''--[[
	LA NOCHE  ·  TODO LO DE TU PANTALLA EN UN SOLO SCRIPT   ⚠️ LocalScript
	======================================================================
	  1. El texto blanco de abajo y el panel de la nevera
	  2. La animación del monstruo (brazos y piernas, a 60 fps)

	🎬 La animación va aquí, en TU ordenador, y no en el servidor. Si la
	   hiciera el servidor la verías a tirones, porque solo manda los
	   cambios unas 20 veces por segundo y tu pantalla dibuja 60. 🧈

	Dónde va: StarterPlayer -> StarterPlayerScripts -> ➕ -> LocalScript
	Nómbralo: LaNocheCliente
]]

if _G.LaNocheClienteYaArranco then
	warn("⛔ Hay un LocalScript DUPLICADO en StarterPlayerScripts. Bórralo.")
	return
end

_G.LaNocheClienteYaArranco = true

'''

CIERRE_CLIENTE = '''
-- ▶️ Las dos cosas funcionan a la vez, cada una por su lado
task.spawn(interfaz)
task.spawn(animacionMonstruo)

print("🎬 Pantalla lista (textos, nevera y animación del monstruo).")
'''


def escribir(destino, cabecera, partes, cierre):
    texto = cabecera + "\n".join(envolver(*p) for p in partes) + cierre
    ruta = os.path.join(RAIZ, destino)
    open(ruta, 'w', encoding='utf-8').write(texto)
    print(f"{destino}: {len(texto.splitlines())} lineas")


escribir('ServerScriptService/LaNoche.server.lua', CABECERA_SERVIDOR, SERVIDOR, CIERRE_SERVIDOR)
escribir('StarterPlayer/StarterPlayerScripts/LaNocheCliente.client.lua', CABECERA_CLIENTE, CLIENTE, CIERRE_CLIENTE)
