# 🌙 Diseño de "La Noche"

Esto es el esqueleto del juego: cómo funciona por dentro. Lo vamos construyendo
por trozos, y cada trozo se puede probar solo.

## ⏰ El reloj de la noche

La partida va **por horas**, de la **00:00 a las 06:00**. Son **6 turnos**.
Cada vez que eliges una acción, **pasa una hora**. Si llegas a las 6:00 vivo,
**ganas**.

## 📊 Las 3 barras

| Barra | Empieza en | Sube sola cada hora | Cómo se baja |
|-------|-----------|---------------------|--------------|
| 🍗 **Hambre** | 20 | +15 | Comiendo en la nevera (−60) |
| 😴 **Sueño**  | 10 | +12 | Durmiendo (−50) |
| 😨 **Estrés** | 0  | +8  | Durmiendo (−15) |

Si alguna llega a **100**, pierdes. Cuanto más alto el **estrés**, más cosas
raras se oyen y se ven (la pantalla tiembla, se oyen pasos que no existen).

## 🎮 Las 3 acciones (el corazón del juego)

En el cuarto hay **3 sitios** donde acercarte y pulsar **E**:

| Sitio | Acción | Qué pasa |
|-------|--------|----------|
| 🚪 La puerta | **Salir a por comida** | Se abre el pasillo. Hay que llegar a la nevera y volver. El monstruo te persigue. Si vuelves: hambre −60. Si te pilla: **pierdes**. |
| 🛏️ La cama | **Dormir** | Pantalla a negro → **pesadilla** (unos segundos raros) → despiertas. Sueño −50, estrés −15. Pero mientras duermes el monstruo se acerca más. |
| 🪑 La silla | **Quedarte despierto** | Vigilas la puerta. Se oyen ruidos. Estrés +18, sueño +12, pero el monstruo se aleja. |

## 👹 El monstruo

Tiene un número escondido: **cómo de cerca está** (0 = lejos, 100 = en la puerta).

- Si **duermes** → se acerca (+25).
- Si **vigilas despierto** → se aleja (−20).
- Si **sales del cuarto** → te ve y te persigue.
- Si llega a 100 estando tú dormido → **entra**. 😰

## 🧩 Orden en el que lo construimos

1. **El cuarto** (paredes, cama, puerta, silla, ventana) ← estamos aquí
2. **La noche oscura** (luz, niebla, lámpara)
3. Las **3 opciones** con la tecla **E** (que solo escriban en la Output)
4. Las **barras** de hambre/sueño/estrés en pantalla
5. El **reloj** de la noche y la victoria a las 6:00
6. El **pasillo y la cocina** con la nevera
7. El **monstruo** que persigue
8. La **pesadilla** al dormir
9. **Sonidos** (pasos, puerta, corazón latiendo)
10. Finales y publicar
