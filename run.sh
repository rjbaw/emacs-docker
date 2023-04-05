#!/bin/bash
set -a

ARCHTYPE=$(uname -m)
DUSER=docker-user
DGROUP=docker-user
DGID=$(id -g)
DUID=$(id -u)

print_usage() {
    printf "Usage:"
    printf "-f non-cache"
    printf "-b build"
}

nocache=''
build=''
while getopts 'bf' flag; do
  case "${flag}" in
    b) build='true' ;;
    f) nocache='true' ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [[ "$build" == 'true' ]]; then
    ARGS='';
    if [[ "$nocache" == 'true' ]]; then
	ARGS+='--no-cache';
    fi
    docker compose build $ARGS;
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    DISPLAY=unix$DISPLAY;
    docker compose up -d;
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285?permalink_comment_id=3477013#gistcomment-3477013
    xhost +localhost;
    DISPLAY=host.docker.internal:0;
    docker compose up -d;
else
    echo "not supported";
    exit 1
fi

docker exec -it emacs-latex bash

