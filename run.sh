#!/bin/bash
set -ae

DUSER=docker-user
DGROUP=docker-user
DGID=$(id -g)
DUID=$(id -u)
PLATFORM=$(uname -m)
REPO="rjbaw/emacs-latex"

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

if [[ "$build" == 'true' ]]; then
    ARGS='';
    if [[ "$nocache" == 'true' ]]; then
	ARGS+='--no-cache ';
    fi
    if [[ "$multi" == 'true' ]]; then
        if [[ "$push" == 'true' ]]; then
       	    ARGS+='--push ';
        fi
        docker buildx bake --set *.platform=linux/arm64,linux/amd64 $ARGS;
    else
        docker compose build $ARGS;
        if [[ "$push" == 'true' ]]; then
	    docker tag "$REPO:latest" "$REPO:manifest-$PLATFORM";
    	    docker push "$REPO:manifest-$PLATFORM";
	    docker manifest create -a "$REPO:latest" \
		    "$REPO:manifest-x86_64" \
		    "$REPO:manifest-aarch64";
    	    docker manifest push "$REPO:latest";
	fi
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
        docker compose down;
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
    if [[ "$gpu" == "true" ]]; then 
        docker compose -f docker-compose-gpu.yml up -d;
    else
        docker compose up -d;
    fi
    docker exec -it emacs-latex bash
fi

