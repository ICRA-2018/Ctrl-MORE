FROM ubuntu:16.04

################################## JUPYTERLAB ##################################

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -yq dist-upgrade \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
	locales python-pip cmake \
	python3-pip python3-setuptools git build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install jupyterlab bash_kernel \
 && python3 -m bash_kernel.install

ENV SHELL=/bin/bash \
	NB_USER=jovyan \
	NB_UID=1000 \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8

ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password \
	--gecos "Default user" \
	--uid ${NB_UID} \
	${NB_USER}

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''"]

##################################### APT ######################################

RUN apt-get -o Acquire::ForceIPv4=true update \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
    libeigen3-dev \
    liborocos-kdl-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

################################### SOURCE #####################################

RUN git clone https://github.com/oyranos-cms/libxcm.git /libxcm \
 && cd /libxcm \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ../ \
 && make -j4 install \
 && rm -fr /libxcm

##################################### COPY #####################################

RUN mkdir ${HOME}/ctrl-more

COPY . ${HOME}/ctrl-more

#################################### CMAKE #####################################

RUN mkdir ${HOME}/ctrl-more/build \
 && cd ${HOME}/ctrl-more/build \
 && cmake -DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig .. \
 && make -j2

##################################### TAIL #####################################

RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}

WORKDIR ${HOME}/ctrl-more
