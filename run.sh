#!/bin/bash
set -ae

DUSER=${DUSER:-docker-user}
DGROUP=${DGROUP:-docker-user}
DGID=${DGID:-$(id -g)}
DUID=${DUID:-$(id -u)}
export DUSER DGROUP DGID DUID
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
    -n dry run (print commands)
    -d close instance
    \n"
}

while getopts 'hbfpmcdgn' flag; do
  case "${flag}" in
    b) build='true' ;;
    f) nocache='true' ;;
    p) push='true' ;;
    m) multi='true' ;;
    c) clean='true' ;;
    d) down='true' ;;
    g) gpu='true' ;;
    n) dryrun='true' ;;
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
        args+="--build-arg image=nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 "
        args+="--build-arg WITH_GPU=true "
    else
        args+="--build-arg image=ubuntu:24.04 "
        args+="--build-arg WITH_GPU=false "
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
        local compose_file target bake_args
        target="emacs-latex"
        if [[ "$gpu" == 'true' ]]; then
            compose_file="docker-compose-gpu.yml"
            bake_args="--set ${target}.args.image=nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 --set ${target}.args.WITH_GPU=true "
        else
            compose_file="docker-compose.yml"
            bake_args="--set ${target}.args.image=ubuntu:24.04 --set ${target}.args.WITH_GPU=false "
        fi

        bake_args+="--set ${target}.platform=linux/amd64 --set ${target}.platform=linux/arm64 "

        if [[ "$nocache" == 'true' ]]; then
            bake_args+="--no-cache "
        fi
        if [[ "$push" == 'true' ]]; then
            bake_args+="--push "
        fi

        if [[ "$dryrun" == 'true' ]]; then
            echo docker buildx bake -f "$compose_file" $target $bake_args
        else
            docker buildx bake -f "$compose_file" $target $bake_args
        fi
    else
        if [[ "$push" == 'true' ]]; then
            local compose_file target bake_args
            target="emacs-latex"
            if [[ "$gpu" == 'true' ]]; then
                compose_file="docker-compose-gpu.yml"
                bake_args="--set ${target}.args.image=nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 --set ${target}.args.WITH_GPU=true "
            else
                compose_file="docker-compose.yml"
                bake_args="--set ${target}.args.image=ubuntu:24.04 --set ${target}.args.WITH_GPU=false "
            fi
            bake_args+="--set ${target}.platform=linux/amd64 --push "
            if [[ "$nocache" == 'true' ]]; then
                bake_args+="--no-cache "
            fi
            if [[ "$dryrun" == 'true' ]]; then
                echo docker buildx bake -f "$compose_file" $target $bake_args
            else
                docker buildx bake -f "$compose_file" $target $bake_args
            fi
        else
            if [[ "$dryrun" == 'true' ]]; then
                echo $dc build $args
            else
                $dc build $args
            fi
        fi
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
