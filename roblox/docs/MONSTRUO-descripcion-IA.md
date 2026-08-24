# 👹 El Monstruo

## Opción A — Manual (recomendada)
El script `scripts/ServerScriptService/ConstruirMonstruo.server.lua` lo monta
entero: huesos, articulaciones escondidas, dientes y animación. Se puede borrar
y rehacer las veces que haga falta.

## Opción B — Descripción para la IA de Roblox Studio
Pégala en el **Assistant** de Roblox Studio (pestaña View → Assistant).
Va en inglés porque la IA entiende mucho mejor las descripciones en inglés.

```text
Create a tall, gaunt humanoid horror character rig for a Roblox game, about
13 studs tall, pale grey-beige skin, dark grey joints, no clothing details.

HEAD — split in two:
- The head is cut horizontally at mouth level into two separate parts: a lower
  jaw part named "Head" and an upper skull part named "Craneo".
- Join them with a Motor6D named "JuntaCraneo" so the upper skull can slide
  straight up 1 to 3 studs and drop back down, like the creature is ripping
  half its own head off with telekinesis and putting it back on.
- Line the cut with a row of sharp low-poly wedge teeth (WedgePart), pointing
  up from the lower jaw and down from the upper skull, in alternating sizes,
  off-white. They must stay attached to their own half so the mouth opens
  like a jagged trap.
- Two small glowing pale-yellow neon eyes on the upper skull, each with a
  PointLight.

ARMS — one extra hidden joint each:
- Each arm is TWO parts: an upper arm and a forearm.
- Motor6D "Hombro" (shoulder) joins torso to upper arm, and an EXTRA Motor6D
  "Codo" (elbow) joins upper arm to forearm.
- Hide each elbow inside a dark sphere part welded over the joint, so the seam
  never shows and the limb can never look detached from the body.

LEGS — one extra hidden joint each:
- Each leg is TWO parts: a thigh and a shin, plus a flat foot.
- Motor6D "Cadera" (hip) joins torso to thigh, an EXTRA Motor6D "Rodilla"
  (knee) joins thigh to shin, and "Tobillo" (ankle) joins shin to foot.
- Hide each knee inside a dark sphere kneecap part.

REQUIRED STRUCTURE: a Model containing a Humanoid, a part named
HumanoidRootPart set as the PrimaryPart, a part named "Head", a "Torso", and
every limb connected with Motor6D joints so nothing can ever separate.

WALK ANIMATION — like it just learned to walk:
- Very slow and unsteady, as if testing the floor for the first time.
- Each step: lean the torso to the opposite side, raise the leg slowly while
  bending the hidden knee, hesitate and wobble in mid-air for a moment, then
  lower the foot very carefully and pause before the next step.
- Arms held out and half-bent at the hidden elbows for balance, like a toddler.
- No smooth cycle: it should look hesitant, heavy and wrong.
```

### Consejo
La IA te dará la forma, pero **no** las articulaciones escondidas ni la
animación (eso casi nunca lo hace bien). Si el resultado no te convence, usa
el script manual: hace exactamente esto y lo puedes retocar número a número.
