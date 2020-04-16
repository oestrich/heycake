#!/bin/bash
set -e

rm -rf tmp/build
mkdir -p tmp/build
git archive --format=tar master | tar x -C tmp/build/
cd tmp/build

docker build -f Dockerfile.releaser -t hey_cake:releaser .

DOCKER_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
docker run -ti --name hey_cake_releaser_${DOCKER_UUID} hey_cake:releaser /bin/true
docker cp hey_cake_releaser_${DOCKER_UUID}:/opt/hey_cake.tar.gz ../
docker rm hey_cake_releaser_${DOCKER_UUID}
