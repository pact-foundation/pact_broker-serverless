#!/bin/bash -x

set -e

rm -rf lib && mkdir -p lib
rm -rf vendor

docker build -t ruby27-pg-builder -f Dockerfile .

CONTAINER=$(docker run -d ruby27-pg-builder false)

docker cp \
    $CONTAINER:/usr/lib64/libpq.so.5.5 \
    lib/libpq.so.5

docker cp \
    $CONTAINER:/var/task/vendor \
    vendor

docker stop $CONTAINER
docker rm $CONTAINER