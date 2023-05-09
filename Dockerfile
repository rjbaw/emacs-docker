ARG UBUNTU_VERSION=22.04
FROM ubuntu:${UBUNTU_VERSION}

LABEL maintainer="rjbaw"
ENV DEBIAN_FRONTEND=noninteractive 

ARG DUSER
ARG DGROUP
ARG DGID
ARG DUID
ARG TARGETPLATFORM
ARG BUILDPLATFORM

ENV DUID=$DUID
ENV DUSER=$DUSER
ENV DGID=$DGID
ENV DGROUP=$DGROUP

RUN apt-get update && apt-get dist-upgrade -y 
RUN apt-get install -y --no-install-recommends \
    devscripts \
    checkinstall \
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
    libgtk-4-dev \
    libwebkit2gtk-4.0-dev \
    webkit2gtk-driver \
    libvterm-dev \
    libgccjit-11-dev \
    libmagickcore-dev \
    libmagick++-dev \
    gnutls-dev \
    dvisvgm \
    automake \
    autoconf \
    libtool \
    xclip \
    scrot \
    xournalpp \
    libglibmm-2.4-dev \
    libboost-all-dev \
    libcppunit-dev \
    liblcms2-dev \
    libjpeg-dev \
    fontconfig \
    librsvg2-dev \
    libglade2-dev \
    nodejs \
    npm \
    fzf \
    bash-completion \
    jupyter

COPY fonts /tmp/fonts/
RUN cp /tmp/fonts/* /usr/local/share/fonts/
RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml

#    git clone git://git.savannah.gnu.org/emacs.git &&
#    cd emacs && \
#    git checkout emacs-28.2 \

RUN cd /tmp && \
    curl https://gnu.mirror.constant.com/emacs/emacs-28.2.tar.gz -so emacs.tar.gz &&\
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
    --with-xwidgets \
    --with-harfbuzz \
    CFLAGS='-O3 -march=native' &&\
    make -j $(nproc) &&\
    checkinstall

RUN cd /usr/local/bin &&\
    ln -s /usr/bin/python3 python &&\
    ln -s /usr/bin/pip3 pip &&\
    python3 -m venv /opt/emacs &&\                                             
    chmod +x /opt/emacs/bin/activate  &&\                                      
    . /opt/emacs/bin/activate &&\  
    pip install -U pip jupyter numpy matplotlib scipy sympy cvxpy

RUN userdel `id -nu $DUID` || true
RUN groupadd -g $DGID $DGROUP || true;
RUN useradd -r -m -d /workspace -s /bin/bash -g $DGID -G sudo -u $DUID $DUSER;
RUN passwd -d $DUSER
RUN chown -R $DUID:$DGID /opt/emacs/

RUN echo "export JULIA_NUM_THREADS=`nproc`" >> /workspace/.bashrc &&\
    echo "export TERM=xterm-256color" >> /workspace/.bashrc &&\
    echo "alias em='emacsclient -c -n -a \"\"'" >> /workspace/.bashrc &&\
    echo "alias et='emacsclient -t -nw -a \"\"'" >> /workspace/.bashrc &&\
    echo "alias jb='jupyter notebook --ip=0.0.0.0'" >> /workspace/.bashrc &&\
    echo "source \"/opt/emacs/bin/activate\"" >> /workspace/.bashrc &&\
    echo "source \"/workspace/.cargo/env\"" >> /workspace/.bashrc
COPY emacs_config /workspace/.emacs.d
RUN chown -R $DUSER. /workspace

RUN apt-get -y autoremove &&\
    apt-get -y autoclean
RUN rm -rf /var/cache/apt
RUN rm -r /tmp/*

USER $DUSER

RUN curl -fsSL https://install.julialang.org | sh -s -- -y && \
    . /workspace/.bashrc &&\
    . /workspace/.profile &&\
    julia -e 'import Pkg; Pkg.add("IJulia")'

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . /workspace/.cargo/env && \
    rustup component add rls

RUN yes | emacs --daemon | cat
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    cd /workspace/.emacs.d/elpa/zmq*/src && \
    ./configure && \
    make -j $(nproc); fi 
RUN (cd /workspace/.emacs.d/elpa/zmq* && make -j $(nproc)) || true

WORKDIR /workspace

RUN ["bash"]
