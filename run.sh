#!/bin/bash
set -ae

ARCHTYPE=$(uname -m)
DUSER=docker-user
DGROUP=docker-user
DGID=$(id -g)
DUID=$(id -u)

print_usage() {
    printf "Usage:"
    printf "-b build"
    printf "   -f no cache"
    printf "   -p push to remote"
    printf "   -m multiarch"
    printf "-c clean"
    printf "   -f clean all"
}

while getopts 'bfpmc' flag; do
  case "${flag}" in
    b) build='true' ;;
    f) nocache='true' ;;
    p) push='true' ;;
    m) multi='true' ;;
    c) clean='true' ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [[ "$build" == 'true' ]]; then
    ARGS='';
    if [[ "$nocache" == 'true' ]]; then
	ARGS+='--no-cache ';
    fi
    if [[ "$push" == 'true' ]]; then
	ARGS+='--push ';
    fi
    if [[ "$multi" == 'true' ]]; then
        docker buildx bake --set *.platform=linux/arm64,linux/amd64 $ARGS;
    else
        docker compose build $ARGS;
    fi
elif [[ "$clean" == 'true' ]]; then
    if [[ "$nocache" == 'true' ]]; then
        yes | docker buildx prune -a;
        yes | docker system prune -a;
    else
        yes | docker buildx prune;
        yes | docker system prune;
    fi
else
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
fi


