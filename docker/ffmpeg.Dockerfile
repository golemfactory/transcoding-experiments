# Dockerfile for tasks requiring ffmpeg.

FROM golemfactory/base:1.4

MAINTAINER Artur Zawłocki <artur.zawlocki@imapp.pl>

RUN	set -x \ 
	&& apt-get update \
	&& apt-get install -y ffmpeg \
	&& apt-get clean \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/*
	
COPY ffmpeg-scripts/ /golem/scripts/

# RUN /golem/install_py_libs.sh append libs as params to be installed with pip, example below
# RUN /golem/install_py_libs.sh pillow typing

WORKDIR /golem/work/
