FROM nginx:base

COPY app/ops/docker/nginx.entrypoint.sh entrypoint
COPY app/ops/lib/nginx/update_certificate.sh update_certificate
RUN chmod +x entrypoint && chmod +x update_certificate && mkdir /opt/certs

COPY app/ops/lib/nginx/app.conf /etc/nginx/conf.d/default.conf

COPY www/* /var/www/app/
COPY assets/* /var/www/app/assets/
COPY frontend/build /var/www/app/

ENTRYPOINT [ "./entrypoint" ]
