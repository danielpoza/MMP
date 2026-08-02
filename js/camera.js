/* =========================================================
   camera.js  —  La cámara superior
   ---------------------------------------------------------
   El mundo es más grande que la pantalla. La cámara decide
   qué trozo del mundo se ve. Sigue al personaje y se queda
   centrada en él, sin salirse de los bordes del mapa.
   ========================================================= */

class Camera {
  constructor(anchoVista, altoVista) {
    this.x = 0;                 // esquina superior-izquierda de lo que vemos
    this.y = 0;
    this.ancho = anchoVista;    // tamaño de la "ventana" (el canvas)
    this.alto = altoVista;
  }

  // Centra la cámara en un objetivo (el jugador), sin salir del mapa
  seguir(objetivo, mundoAncho, mundoAlto) {
    // Queremos al objetivo en el centro de la pantalla
    let objetivoX = objetivo.x + objetivo.ancho / 2 - this.ancho / 2;
    let objetivoY = objetivo.y + objetivo.alto / 2 - this.alto / 2;

    // No dejar ver "fuera" del mapa: limitamos a los bordes
    objetivoX = clamp(objetivoX, 0, Math.max(0, mundoAncho - this.ancho));
    objetivoY = clamp(objetivoY, 0, Math.max(0, mundoAlto - this.alto));

    this.x = objetivoX;
    this.y = objetivoY;
  }
}

// Ayuda: devuelve "valor" pero sin pasar de min ni de max
function clamp(valor, min, max) {
  return Math.max(min, Math.min(max, valor));
}
