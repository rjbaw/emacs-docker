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

get_build_args() {
    local args=""
    if [[ "$nocache" == 'true' ]]; then
        args+="--no-cache "
    fi

    if [[ "$gpu" == 'true' ]]; then
        args+="--build-arg image=nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04 "
    else
        args+="--build-arg image=ubuntu:24.04 "
    fi

    if [[ "$push" == 'true' ]]; then
        args+="--push "
    fi

    echo "$args"
}

build() {
    local args
    args=$(get_build_args)

    if [[ "$multi" == 'true' ]]; then
        docker buildx bake --set *.platform=linux/arm64,linux/amd64 $args
    else
        $dc build $args
    fi
}

clean() {
    if [[ "$nocache" == 'true' ]]; then
        yes | docker system prune -a
        yes | docker buildx prune -a
    else
        yes | docker system prune
        yes | docker buildx prune
    fi
}


if [[ "$build" == 'true' ]]; then
    build
elif [[ "$clean" == 'true' ]]; then
    clean
else
    if [[ "$down" == "true" ]]; then 
        $dc down;
	exit
    fi

    case "$OSTYPE" in
        linux-gnu*)
            xhost +localhost
            DISPLAY=$DISPLAY
            ;;
        darwin*)
	    # https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285?permalink_comment_id=3477013#gistcomment-3477013
            xhost +localhost
            DISPLAY=host.docker.internal:0
            ;;
        *)
            echo "Platform not supported."
            exit 1
            ;;
    esac

    $dc up -d;

    if [[ "$gpu" == "true" ]]; then 
        docker exec -it emacs-latex-gpu bash
    else
        docker exec -it emacs-latex bash
    fi
fi
