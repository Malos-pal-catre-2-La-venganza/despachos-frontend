# Despacho — Frontend

Interfaz web para la gestión de ventas y despachos de Innovatech Chile, construida con **React + Vite**, contenedorizada con Docker y desplegada en un clúster **Amazon EKS**.

Este repositorio forma parte de la Evaluación Final Transversal de ISY1101 (Introducción a Herramientas DevOps). El backend (2 microservicios) vive en un repositorio separado: [despachos-backend](https://github.com/Malos-pal-catre-2-La-venganza/despachos-backend).

## Funcionalidad

- Consultar órdenes de compra (ventas)
- Consultar y gestionar órdenes de despacho
- Registrar el cierre de un despacho, actualizando el estado de la venta asociada

## Stack técnico

- **React 18** + **Vite**
- **Tailwind CSS**
- **Axios** para consumo de las APIs REST
- **Docker** multietapa (build con Node → servido con Nginx, usuario no-root)
- **Kubernetes** (Amazon EKS) para orquestación
- **GitHub Actions** para CI/CD

## Estructura del repositorio

frontend/
├── src/
│   ├── config/api.js               # URLs de los backends (vía variables de entorno)
│   ├── componentes/CrudAdmin/      # Tablas y formularios (ventas, despachos)
│   └── componentes/Layouts/        # Navbar, Footer, etc.
├── k8s/frontend.yaml               # Manifest de Kubernetes (Deployment + Service)
├── .github/workflows/
│   └── deploy-frontend.yml         # Pipeline CI/CD
├── Dockerfile
├── nginx.conf
└── docker-compose.yml              # Levanta el frontend en local

## Conexión con el backend

Las URLs de los 2 microservicios de backend (Ventas y Despachos) **no están hardcodeadas**: se inyectan en tiempo de build mediante variables de entorno de Vite (`VITE_API_VENTAS_URL`, `VITE_API_DESPACHOS_URL`), definidas en `src/config/api.js`. Esto permite usar el mismo código en local, Docker y AWS, cambiando solo el valor de las variables — no el código fuente.

## Cómo correr en local

Requiere que el backend esté corriendo aparte (ver repo `despachos-backend`).

```bash
cp .env.example .env
docker compose up --build
```

La app queda disponible en `http://localhost`.

## CI/CD

El workflow `.github/workflows/deploy-frontend.yml` se dispara en cada `push` a `main` que modifique el código fuente, el Dockerfile o los manifests de Kubernetes:

1. **build-and-push**: construye la imagen Docker (inyectando las URLs de producción de los backends como `--build-arg`) y la sube a Amazon ECR con 2 tags: el hash del commit y `latest`.
2. **deploy**: aplica el manifest de Kubernetes y actualiza el `Deployment` con la imagen recién construida, esperando a que el rollout termine.

## Infraestructura

Se sirve mediante Nginx dentro de un contenedor, desplegado en Amazon EKS con 2 réplicas y expuesto a través de un `Service` tipo `LoadBalancer` (Elastic Load Balancer público de AWS).

## Seguridad

- Contenedor corre con usuario no-root
- Sin credenciales ni secretos en el código (las URLs de backend no son información sensible)
- Credenciales de AWS para el pipeline gestionadas vía GitHub Secrets

