#!/bin/bash
[ -z $1 ] && CNAME=proxy || CNAME=$1
[ -z $2 ] && INAME=proxy || INAME=$1

docker run -d --name "$CNAME" -P "$INAME" 
