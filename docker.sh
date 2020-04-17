#/bin/bash

sha=$(git rev-parse HEAD)

docker build -t oestrich/heycake:${sha} .
docker push oestrich/heycake:${sha}
