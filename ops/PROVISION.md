# How to provision the system

1. git clone repo into `/opt/oq/repo`
2. build docker images (takes a quite time) `/opt/oq/repo/ops/bin/compose build`
3. setup domain certificate `cd /opt/oq/repo && bash ops/lib/create_ssl_cert.sh`
4. setup DB
5. deploy `/opt/oq/repo/ops/bin/update`


# Details

## Domain
domain needs to be explicitly set in these places:
* `ops/config/nginx_app.conf` for ssl_certificate & ssl_certificate_key
* `ops/lib/create_ssl_cert.sh` variable $domain

After that you need to purge certbot dir (`/opt/oq/certbot`) and run again that `create_ssl_cert.sh`
