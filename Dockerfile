ARG image=ubuntu-24.04
FROM $image

LABEL maintainer="rjbaw"
LABEL org.opencontainers.image.source=https://github.com/rjbaw/org-latex-docker
ENV DEBIAN_FRONTEND=noninteractive 
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ARG DUSER
ARG DGROUP
ARG DGID
ARG DUID
ARG WITH_GPU=false
ARG TARGETPLATFORM
ARG BUILDPLATFORM

ENV DUID=$DUID
ENV DUSER=$DUSER
ENV DGID=$DGID
ENV DGROUP=$DGROUP

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    devscripts \
    software-properties-common \
    git \
    python3 \
    python3-pip \
    python3-dev \
    python3-tk \
    python3-venv \
    python3-setuptools \
    python3-wheel \
    sudo \
    unzip \
    tmux \
    tar \
    build-essential \
    vim \
    apt-transport-https \
    gnupg \
    apt-utils \
    dialog \
    wget \
    curl \
    cmake \
    dvipng \
    texlive-science \
    texlive-latex-extra \
    texlive-plain-generic \
    texlive-fonts-extra \
    texlive-bibtex-extra \
    texinfo \
    texlive-xetex \
    texlive-luatex \
    latexmk \
    imagemagick \
    libjansson-dev \
    libxpm-dev \
    libgif-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libx11-dev \
    libncurses5-dev \
    libgtk-3-dev \
    libgtk-4-dev \
    libtree-sitter-dev \
    libvterm-dev \
    libgccjit-13-dev \
    libmagickcore-dev \
    libmagick++-dev \
    tk-dev \
    libreadline-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libsqlite3-dev \
    libffi-dev \
    liblzma-dev \
    xz-utils \
    gnutls-dev \
    dvisvgm \
    automake \
    autoconf \
    clang-format \
    libtool \
    xclip \
    scrot \
    xournalpp \
    libglibmm-2.4-dev \
    libboost-all-dev \
    libcppunit-dev \
    liblcms2-dev \
    fontconfig \
    librsvg2-dev \
    libglade2-dev \
    nodejs \
    npm \
    fzf \
    bash-completion \
    iproute2 \
    iputils-ping \
    ispell \
    hunspell \
    libosmesa6-dev \
    libgl1 \
    libglfw3 \
    patchelf \
    bear \
    clangd \
    clang-tidy \
    tree-sitter-cli \
    cmake-format \
    lldb && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

RUN npm install -g n && \
    n stable && \
    npm install -g pyright && \
    npm cache clean --force && \
    n prune || true

COPY fonts /tmp/fonts/
RUN cp /tmp/fonts/* /usr/local/share/fonts/
RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml

RUN PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH &&\
    cd /tmp && \
    curl -L https://ftp.gnu.org/gnu/emacs/emacs-30.1.tar.gz -so emacs.tar.gz &&\
    tar xf emacs.tar.gz &&\
    cd emacs* &&\
    ./configure \
    -C \
    --with-cairo \
    --with-modules \
    --with-x-toolkit=gtk3 \
    --with-native-compilation \
    --with-imagemagick \
    --with-json \
    --with-rsvg \
    --with-harfbuzz \
    --with-tree-sitter \
    CFLAGS='-O3 -march=native' &&\
    make -j "$(nproc)" &&\
    make install

RUN emacs -Q --batch \
    --eval "(setq treesit-language-source-alist '((c   \"https://github.com/tree-sitter/tree-sitter-c\" \"v0.23.4\") (cpp \"https://github.com/tree-sitter/tree-sitter-cpp\" \"v0.23.4\")))" \
    --eval "(mapc #'treesit-install-language-grammar '(c cpp))"

RUN userdel "$(id -nu "$DUID")" || true
RUN groupadd -g $DGID $DGROUP || true;
RUN useradd -r -m -d /workspace -s /bin/bash -g "$DGID" -G sudo -u "$DUID" "$DUSER";
RUN passwd -d $DUSER
# Removed ulimit; not effective at build-time

WORKDIR /usr/local/bin
RUN ln -s /usr/bin/python3 python && ln -s /usr/bin/pip3 pip 
WORKDIR /

COPY emacs_config /workspace/.emacs.d
RUN chown -R $DUSER. /workspace

RUN apt-get -y autoremove &&\
    apt-get -y autoclean
RUN rm -rf /var/cache/apt
RUN rm -r /tmp/*

USER $DUSER
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl https://pyenv.run | bash

RUN echo "export JULIA_NUM_THREADS=$(nproc)" >> $HOME/.bashrc &&\
    echo "export TERM=xterm-256color" >> $HOME/.bashrc &&\
    echo "alias em='emacsclient -c -n -a \"\"'" >> $HOME/.bashrc &&\
    echo "alias et='emacsclient -t -nw -a \"\"'" >> $HOME/.bashrc &&\
    echo "alias jb='jupyter-lab --ip=0.0.0.0 --NotebookApp.allow_credentials=True'" >> $HOME/.bashrc &&\
    echo "export PYENV_ROOT=\"\$HOME/.pyenv\"" >> $HOME/.bashrc &&\
    echo "[[ -d \$PYENV_ROOT/bin ]] && export PATH=\"\$PYENV_ROOT/bin:\$PATH\"" >> $HOME/.bashrc &&\
    echo "eval \"\$(pyenv init -)\"" >> $HOME/.bashrc &&\
    echo "eval \"\$(pyenv virtualenv-init -)\"" >> $HOME/.bashrc &&\
    echo "source \"/workspace/.cargo/env\"" >> $HOME/.bashrc

COPY requirements.txt /tmp/

RUN export PYENV_ROOT="$HOME/.pyenv" && \
    export PATH="$PYENV_ROOT/bin:$PATH" && \
    eval "$(pyenv init -)" && \
    eval "$(pyenv virtualenv-init -)" && \
    export CONDA_PLUGINS_AUTO_ACCEPT_TOS=yes && \
    pyenv install miniconda3-latest && \
    pyenv virtualenv base && \
    export PYENV_VERSION=base && \
    pyenv activate base && \
    if [ "$WITH_GPU" = "true" ]; then \
      pip install --no-cache-dir --force-reinstall torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128; \
    else \
      pip install --no-cache-dir --force-reinstall torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu; \
    fi && \
    pip install --no-cache-dir -r /tmp/requirements.txt && \
    pip cache purge || true && \
    conda clean -afy || true && \
    rm -rf "$PYENV_ROOT/cache"/* || true

ENV PYENV_VERSION=base

RUN curl -fsSL https://install.julialang.org | sh -s -- -y && \
    . /workspace/.bashrc &&\
    . /workspace/.profile &&\
    julia -e 'import Pkg; Pkg.add("IJulia"); Pkg.gc()'

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . /workspace/.cargo/env && \
    rustup component add rust-analyzer
RUN /workspace/.cargo/bin/cargo install texlab && \
    rm -rf /workspace/.cargo/registry /workspace/.cargo/git || true
RUN curl -LsSf https://astral.sh/ruff/install.sh | sh

RUN printf "%s\n" \
    "(advice-add 'yes-or-no-p :override (lambda (&rest _) t))" \
    "(advice-add 'y-or-n-p :override (lambda (&rest _) t))" \
    "(setq use-short-answers t package-check-signature nil)" \
    > /tmp/ci.el
RUN printf "%s\n" \
    "(load-file \"/workspace/.emacs.d/init.el\")" \
    "(require 'package)" \
    "(package-initialize)" \
    "(ignore-errors (package-refresh-contents))" \
    > /tmp/ci-run.el
RUN emacs --batch -Q -l /tmp/ci.el -l /tmp/ci-run.el && \
    emacs --daemon && emacsclient -e '(kill-emacs)'
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    cd /workspace/.emacs.d/elpa/zmq*/src && \
    ./configure && \
    make -j "$(nproc)"; fi 
RUN (cd /workspace/.emacs.d/elpa/zmq* && make -j "$(nproc)") || true

WORKDIR /workspace
