ARG UBUNTU_VERSION=22.04
FROM amd64/ubuntu:${UBUNTU_VERSION}

LABEL maintainer="rjbaw"
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && apt-get dist-upgrade -y 
RUN apt-get install -y --no-install-recommends \
    devscripts \
    checkinstall \
    software-properties-common \
    git \
    python3 \
    python3-pip \
    python3-dev \
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
    texinfo \
    texlive-xetex \
    texlive-luatex \
    imagemagick \
    libjansson-dev \
    libxpm-dev \
    libgif-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libx11-dev \
    libncurses5-dev \
    libgtk2.0-dev \
    gnutls-dev \
    dvisvgm \
    automake \
    autoconf \
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
    jupyter

COPY fonts /tmp/fonts/
RUN cp /tmp/fonts/* /usr/local/share/fonts/
RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml

#    git clone git://git.savannah.gnu.org/emacs.git &&
#    cd emacs && \
#    git checkout emacs-28 \

RUN cd /tmp && \
    curl https://gnu.mirror.constant.com/emacs/emacs-28.1.tar.gz -so emacs.tar.gz &&\
    tar xf emacs.tar.gz &&\
    cd emacs* \
    ./configure \
    -C \
    --with-cairo \
    --with-modules \
    --with-x-toolkit=lucid \
    --with-native-compilation \
    --with-image-magick \
    --with-json \
    --with-rsvg \
    --with-xwidgets \
    --with-harfbuzz \
    CFLAGS='-O3 -march=native' \
    make -j $(nproc) &&\
    checkinstall

RUN cd /tmp &&\
    curl https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.1-linux-x86_64.tar.gz -so julia.tar.gz &&\
    tar xf julia.tar.gz &&\
    cd julia* &&\
    cp -r * /usr/ &&\
    julia -e 'import Pkg; Pkg.add("IJulia")'

#    --with-x-toolkit=gtk3 \

RUN cd /usr/local/bin &&\
    ln -s /usr/bin/python3 python &&\
    ln -s /usr/bin/pip3 pip &&\
    pip install -U pip jupyter numpy matplotlib scipy sympy

# Note change USER_ID=1000 to your own userid
RUN groupadd -g 1000 docker-user
RUN useradd -r -m -d /workspace -s /bin/bash -g docker-user -G sudo -u 1000 docker-user
RUN passwd -d docker-user
#RUN mkdir -p /workspace

RUN echo "export JULIA_NUM_THREADS=`nproc`" >> /workspace/.bashrc &&\
    echo "alias em='emacsclient -c -n -a \"\"'" >> /workspace/.bashrc &&\
    echo "source \"/workspace/.cargo/env\"" >> /workspace/.bashrc
COPY emacs_config /workspace/.emacs.d
RUN chown -R docker-user. /workspace
RUN su docker-user bash -c "echo 'y' | emacs --daemon"
RUN su docker-user bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

RUN apt-get -y autoremove &&\
    apt-get -y autoclean
RUN rm -rf /var/cache/apt
RUN rm -r /tmp/*

USER docker-user
WORKDIR /workspace

RUN ["/bin/bash"]
