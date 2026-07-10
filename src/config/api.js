// Config centralizada de URLs de los backends.
// Los valores salen de variables de entorno (Vite las expone solo si
// empiezan con VITE_). Si no existen, cae a localhost para desarrollo.
export const API_VENTAS_URL =
  import.meta.env.VITE_API_VENTAS_URL || "http://localhost:8080/api/v1/ventas";

export const API_DESPACHOS_URL =
  import.meta.env.VITE_API_DESPACHOS_URL || "http://localhost:8081/api/v1/despachos";
