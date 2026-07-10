# =============================================
# STAGE 1 - BUILD
# Compila la app React con Vite
# =============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar package.json primero para cachear dependencias
COPY package.json package-lock.json ./
RUN npm ci --silent

# Copiar el código fuente y construir
COPY . .

# Las URLs de los backends se inyectan en build time como ARG
ARG VITE_API_VENTAS_URL=http://localhost:8080/api/v1/ventas
ARG VITE_API_DESPACHOS_URL=http://localhost:8081/api/v1/despachos
ENV VITE_API_VENTAS_URL=$VITE_API_VENTAS_URL
ENV VITE_API_DESPACHOS_URL=$VITE_API_DESPACHOS_URL

RUN npm run build

# =============================================
# STAGE 2 - RUNTIME
# Nginx liviano para servir los estáticos
# =============================================
FROM nginx:1.25-alpine

# Crear usuario no root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar el build generado en stage 1
COPY --from=builder /app/dist /usr/share/nginx/html

# Copiar configuración nginx personalizada
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Ajustar permisos para usuario no root
RUN chown -R appuser:appgroup /usr/share/nginx/html \
    && chown -R appuser:appgroup /var/cache/nginx \
    && chown -R appuser:appgroup /var/log/nginx \
    && touch /var/run/nginx.pid \
    && chown appuser:appgroup /var/run/nginx.pid

USER appuser

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
