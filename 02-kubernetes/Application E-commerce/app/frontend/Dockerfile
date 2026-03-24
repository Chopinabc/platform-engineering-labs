FROM nginxinc/nginx-unprivileged:alpine

# Copier la config Nginx
COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers statiques
COPY --chown=nginx:nginx index.html app.js /usr/share/nginx/html/

# User non-root
USER nginx

# Exposer le port 80
EXPOSE 8080
