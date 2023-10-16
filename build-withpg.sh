#!/bin/bash -x

set -e

rm -rf lib && mkdir -p lib
rm -rf vendor

docker build -t ruby32-pg-builder -f Dockerfile .

CONTAINER=$(docker run -d ruby32-pg-builder false)

docker cp \
  $CONTAINER:/usr/lib64/libpq.so.5.14 \
  lib/libpq.so.5

docker cp \
  $CONTAINER:/usr/lib64/libldap_r-2.4.so.2.10.7 \
  lib/libldap_r-2.4.so.2

docker cp \
  $CONTAINER:/usr/lib64/liblber-2.4.so.2.10.7 \
  lib/liblber-2.4.so.2

docker cp \
  $CONTAINER:/usr/lib64/libsasl2.so.3.0.0 \
  lib/libsasl2.so.3

docker cp \
  $CONTAINER:/usr/lib64/libssl3.so \
  lib/

docker cp \
  $CONTAINER:/usr/lib64/libsmime3.so \
  lib/

docker cp \
  $CONTAINER:/usr/lib64/libnss3.so \
  lib/

docker cp \
  $CONTAINER:/usr/lib64/libnssutil3.so \
  lib/

docker cp \
  $CONTAINER:/var/task/vendor \
  vendor

docker stop $CONTAINER
docker rm $CONTAINER