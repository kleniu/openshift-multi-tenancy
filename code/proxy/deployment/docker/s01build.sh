#!/bin/bash
[ -z $1 ] && INAME=proxy || INAME=$1

docker build -t "$INAME" -f . ../..
