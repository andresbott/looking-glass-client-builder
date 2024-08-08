#!/bin/bash

IMG="looking-glass-builder:latest"
id=$(docker create ${IMG})
docker cp $id:/out ./
docker rm -v $id

