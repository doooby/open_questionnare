FROM nginx:base

COPY src/ops/lib/nginx/release_entrypoint.sh entrypoint
COPY src/ops/lib/nginx/update_certificate.sh update_certificate
COPY src/ops/etc/nginx/app.conf /etc/nginx/conf.d/default.conf

COPY src/public /var/www/app
COPY var/assets_backend /var/www/app/assets
COPY var/assets_frontend /var/www/app

RUN chmod +x entrypoint && \
    chmod +x update_certificate && \
    mkdir certs

ENTRYPOINT [ "./entrypoint" ]
