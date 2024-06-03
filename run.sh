#!/bin/bash
set -ae

DUSER=docker-user
DGROUP=docker-user
DGID=$(id -g)
DUID=$(id -u)
PLATFORM=$(uname -m)

print_usage() {
    printf \
"Usage:
    -b build
	-f no cache
	-p push to remote
	-m multiarch
    -c clean
	-f clean all
    -g gpu
    -d close instance
    \n"
}

while getopts 'hbfpmcdg' flag; do
  case "${flag}" in
    b) build='true' ;;
    f) nocache='true' ;;
    p) push='true' ;;
    m) multi='true' ;;
    c) clean='true' ;;
    d) down='true' ;;
    g) gpu='true' ;;
    h | *) print_usage
       exit 1 ;;
  esac
done

if [[ "$gpu" == "true" ]]; then 
    dc='docker compose -f docker-compose-gpu.yml';
else
    dc='docker compose';
fi

if [[ "$build" == 'true' ]]; then
    ARGS='';
    if [[ "$nocache" == 'true' ]]; then
	ARGS+='--no-cache ';
    fi
    if [[ "$gpu" == 'true' ]]; then
	#ARGS+='--build-arg image=nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 ';
	ARGS+='--build-arg image=nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04 ';
    else
	ARGS+='--build-arg image=ubuntu:22.04 ';
    fi
    if [[ "$push" == 'true' ]]; then
   	    ARGS+='--push ';
    fi
    if [[ "$multi" == 'true' ]]; then
        docker buildx bake --set *.platform=linux/arm64,linux/amd64 $ARGS;
    else
        $dc build $ARGS;
    fi
elif [[ "$clean" == 'true' ]]; then
    if [[ "$nocache" == 'true' ]]; then
       	yes | docker system prune -a;
        yes | docker buildx prune -a;
    else
       	yes | docker system prune;
        yes | docker buildx prune;
    fi
else
    if [[ "$down" == "true" ]]; then 
        $dc down;
	exit;
    fi
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xhost +localhost;
        DISPLAY=$DISPLAY;
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285?permalink_comment_id=3477013#gistcomment-3477013
        xhost +localhost;
        DISPLAY=host.docker.internal:0;
    else
        echo "not supported";
        exit 1
    fi
    $dc up -d;
    if [[ "$gpu" == "true" ]]; then 
        docker exec -it emacs-latex-gpu bash
    else
        docker exec -it emacs-latex bash
    fi
fi

