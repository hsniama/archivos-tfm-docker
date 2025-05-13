# === PASO 1: Crear un Dockerfile para Nginx ===
# === PASO 2: Usar una versión estable de Nginx ===
FROM nginx:1.28-alpine

# === PASO 3: Crear usuario y grupo no-root ===
# - Los nombres deben ser consistentes (sin números ni caracteres especiales).
RUN addgroup -S nginx-group && \
    adduser -S nginx-user -G nginx-group && \
    # Permisos para directorios críticos
    mkdir -p /var/run/nginx && \
    chown -R nginx-user:nginx-group /var/run/nginx /var/cache/nginx && \
    chmod -R 755 /var/log/nginx /var/run/nginx

# === PASO 4: Eliminar paquetes vulnerables ===
# Con el siguiente comando se eliminan los paquetes vulnerables:
# - libxml2: CVE-2022-49043 (HIGH)
# - krb5: CVE-2022-49043 (HIGH)
# - perl: CVE-2022-49043 (HIGH)
# - libtiff: CVE-2022-49043 (HIGH) - Ya no aparece en nginx:1.28-alpine
RUN apk --no-cache del libxml2 krb5 perl

# === PASO 5: Configuración segura de Nginx ===
# - El archivo 'nginx-hardened.conf' debe existir en el mismo directorio.
COPY nginx-hardened.conf /etc/nginx/nginx.conf
# Asegurar permisos de configuración
RUN chown nginx-user:nginx-group /etc/nginx/nginx.conf && \
    chmod 644 /etc/nginx/nginx.conf

# === PASO 6: Actualizar y limpiar ===
RUN apk update && apk upgrade --no-cache && \
    rm -rf /var/cache/apk/* /tmp/*

# === PASO 7: HEALTHCHECK ===
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8080/ || exit 1

    
# === PASO Final: Usuario no-root y puerto ===
#El contenedor se ejecutará como nginx-user en lugar del usuario 
#por defecto root y se declara que se utilizará el puerto 8080.

# Variables de entorno para scripts de entrada.
# Reduce mensajes de warning innecesarios:
ENV NGINX_ENTRYPOINT_QUIET_LOGS=1
# Puerto no privilegiado
EXPOSE 8080
# Usuario no-root
USER nginx-user

