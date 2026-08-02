/* Servidor estático mínimo para desarrollo (sin dependencias).
   Uso:  node server.js     ->  http://localhost:8080          */
const http = require("http");
const fs = require("fs");
const path = require("path");

const PORT = 8080;
const ROOT = __dirname;
const TIPOS = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".json": "application/json",
};

http.createServer((req, res) => {
  let ruta = decodeURIComponent(req.url.split("?")[0]);
  if (ruta === "/") ruta = "/index.html";
  const archivo = path.join(ROOT, ruta);

  // Seguridad: no salir de la carpeta del proyecto
  if (!archivo.startsWith(ROOT)) { res.writeHead(403); return res.end("Prohibido"); }

  fs.readFile(archivo, (err, data) => {
    if (err) { res.writeHead(404); return res.end("No encontrado: " + ruta); }
    res.writeHead(200, { "Content-Type": TIPOS[path.extname(archivo)] || "application/octet-stream" });
    res.end(data);
  });
}).listen(PORT, () => console.log("Servidor en http://localhost:" + PORT));
