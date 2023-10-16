#!/bin/bash -x

set -e

rm -rf layer && mkdir -p layer/lib

docker build -t ruby32-pg-builder -f Dockerfile .

CONTAINER=$(docker run -d ruby32-pg-builder false)

docker cp \
  $CONTAINER:/usr/lib64/libpq.so.5.14 \
  layer/lib/libpq.so.5

docker cp \
  $CONTAINER:/usr/lib64/libldap_r-2.4.so.2.10.7 \
  layer/lib/libldap_r-2.4.so.2

docker cp \
  $CONTAINER:/usr/lib64/liblber-2.4.so.2.10.7 \
  layer/lib/liblber-2.4.so.2

docker cp \
  $CONTAINER:/usr/lib64/libsasl2.so.3.0.0 \
  layer/lib/libsasl2.so.3

docker cp \
  $CONTAINER:/usr/lib64/libssl3.so \
  layer/lib/

docker cp \
  $CONTAINER:/usr/lib64/libsmime3.so \
  layer/lib/

docker cp \
  $CONTAINER:/usr/lib64/libnss3.so \
  layer/lib/

docker cp \
  $CONTAINER:/usr/lib64/libnssutil3.so \
  lib/

docker cp \
  $CONTAINER:/var/task/vendor \
  vendor
docker stop $CONTAINER
docker rm $CONTAINER