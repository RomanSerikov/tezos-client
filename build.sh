#! /usr/bin/env bash

docker build --tag tezos-client .
container_id="$(docker create tezos-client)"
docker cp "$container_id:/tezos/tezos-client" tezos-client
