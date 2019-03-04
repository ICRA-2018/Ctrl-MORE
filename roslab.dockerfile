FROM ubuntu:16.04

################################## JUPYTERLAB ##################################

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -yq dist-upgrade \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
	locales cmake git build-essential \
    python-pip \
	python3-pip python3-setuptools \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install jupyterlab==0.35.4 bash_kernel==0.7.1 tornado==5.1.1 \
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

###################################### ROS #####################################

# install packages
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -o Acquire::ForceIPv4=true install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -o Acquire::ForceIPv4=true install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    python-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO kinetic
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -o Acquire::ForceIPv4=true install -y \
    ros-kinetic-ros-base=1.3.2-0* \
    && rm -rf /var/lib/apt/lists/*

# setup entrypoint
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]

##################################### APT ######################################

RUN apt-get -o Acquire::ForceIPv4=true update \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
    libeigen3-dev \
    liborocos-kdl-dev \
    libmatio-dev \
    libyaml-cpp-dev \
    ros-kinetic-orocos-kdl \
    ros-kinetic-eigen-conversions \
    liburdfdom-model0.4 \
    liburdfdom-world0.4 \
    ros-kinetic-kdl-parser \
    ros-kinetic-urdf \
    libpcl-surface1.7 \
    libpcl-filters1.7 \
    libpcl-common1.7 \
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

RUN git clone https://github.com/robotology/ycm.git /YCM \
 && cd /YCM \
 && mkdir build \
 && cd build \
 && cmake  ../ \
 && make -j4 install \
 && rm -fr /YCM

RUN git clone -b master https://github.com/gabime/spdlog.git /spdlog \
 && cd /spdlog \
 && mkdir build \
 && cd build \
 && cmake  ../ \
 && make -j4 install \
 && rm -fr /spdlog

##################################### COPY #####################################

RUN mkdir ${HOME}/ctrl-more

COPY . ${HOME}/ctrl-more

################################### CUSTOM #####################################

RUN ln /usr/lib/x86_64-linux-gnu/cmake/xcm/XcmConfig.cmake /usr/lib/x86_64-linux-gnu/cmake/xcm/XCMConfig.cmake \
 && apt-get update && apt-get install -yq --no-install-recommends wget && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && wget https://github.com/ADVRHumanoids/XBotControl/releases/download/v1.0.1/XBotControl_1.0-1.deb && dpkg -i XBotControl_1.0-1.deb && rm XBotControl_1.0-1.deb

##################################### TAIL #####################################

RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}

WORKDIR ${HOME}/ctrl-more
