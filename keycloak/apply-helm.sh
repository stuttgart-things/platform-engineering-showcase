#!/bin/sh

for cmd in apply sync; do
  for i in $(seq 1 8); do
    helmfile -f prov.yaml $cmd && break
    [ "$i" -eq 8 ] && exit 1
    sleep 15
  done
done
