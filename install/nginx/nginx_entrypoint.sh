#!/bin/bash
sed -i "s/<django_host>/${DJANGO_HOST}/g" /etc/nginx/conf.d/default.conf
exec nginx -g 'daemon off;'