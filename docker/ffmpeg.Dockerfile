# Dockerfile for tasks requiring ffmpeg.

FROM golemfactory/base:1.4

MAINTAINER Artur Zawłocki <artur.zawlocki@imapp.pl>

COPY ffmpeg-scripts/ /golem/scripts/
	
# Build ffmpeg
RUN set -x \
	# get dependencies 
	&& apt-get update  \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt-get install -y tzdata \
	&& ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime \
	&& dpkg-reconfigure --frontend noninteractive tzdata \
	&& apt-get -y install \
		yasm \
		vim \
		libchromaprint-dev \
		frei0r-plugins-dev \
		libgnutls28-dev \
		ladspa-sdk \
		libiec61883-dev \
		libavc1394-dev \ 
		libass-dev \
		libbluray-dev \
		libbs2b-dev \
		libcaca-dev \
		libdc1394-22-dev \
		flite-dev \
		libgme-dev \
		libgsm1-dev \
		libmp3lame-dev \
		libmysofa-dev \
		libopencv-dev \
		libbs2b-dev \
		libopenjp2-7-dev \
		libopenmpt-dev \
		librsvg2-dev \
		librubberband-dev \
		libshine-dev \
		libsnappy-dev \
		libsoxr-dev \
		libssh-dev \
		libspeex-dev \
		libtwolame-dev \
		libwavpack-dev \
		libx264-dev \
		libx265-dev \
		libnuma-dev \
		libxvidcore-dev \
		libzmq3-dev \
		libzvbi-dev \
		libomxil-bellagio-dev \
		libcdio-paranoia-dev \
		libsdl2-dev \
		frei0r-plugins-dev \
		libgnutls28-dev \
		libunistring-dev \
		libopencv-dev \
		libopus-dev \
		librsvg2-dev \
		libselinux1-dev \
		libmount-dev \
		libtheora-dev \
		libvpx-dev \
		libwebp-dev \
		libsodium-dev \
		libpgm-dev \
		libnorm-dev \
		libopenal-dev \ 
		libffi-dev \
	#build VMAF
	&& cd /usr/local \
	&& wget -O vmaf-1.3.9.tar.gz https://codeload.github.com/Netflix/vmaf/tar.gz/v1.3.9 \
	&& tar -xzf vmaf-1.3.9.tar.gz \
	&& rm vmaf-1.3.9.tar.gz \
	&& cd vmaf-1.3.9 \
	&& make \ 
	&& make install \
	# build FFMPEG
	&& cd /usr/local \
	&& wget -O ffmpeg-4.1.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2 \
	&& tar xjvf ffmpeg-4.1.tar.bz2 \
	&& rm ffmpeg-4.1.tar.bz2 \
	&& cd ffmpeg-4.1 \
	# fix bug in opencv
	# https://github.com/yoshimoto/opencv/commit/0b015cbb4204a46d7c171d2b9d36a5510d1677cd
	&& ex -s -c '60i|#include "opencv2/core/fast_math.hpp"' -c x /usr/include/opencv2/core/types_c.h \
	# configure
	&& ./configure \
	--extra-version=0ubuntu0.18.04.1 \
	--toolchain=hardened \
	--enable-gpl \
	--disable-stripping \
	--enable-avresample \
	--enable-avisynth \
	--enable-gnutls \
	--enable-ladspa \
	--enable-libass \
	--enable-libbluray \
	--enable-libbs2b \
	--enable-libcaca \
	--enable-libcdio \
	--enable-libflite \
	--enable-libfontconfig \
	--enable-libfreetype \
	--enable-libfribidi \
	--enable-libgme \
	--enable-libgsm \
	--enable-libmp3lame \
	--enable-libmysofa \
	--enable-libopenjpeg \
	--enable-libopenmpt \
	--enable-libopus \
	--enable-libpulse \
	--enable-librubberband \
	--enable-librsvg \
	--enable-libshine \
	--enable-libsnappy \
	--enable-libsoxr \
	--enable-libspeex \
	--enable-libssh \
	--enable-libtheora \
	--enable-libtwolame \
	--enable-libvorbis \
	--enable-libvpx \
	--enable-libwavpack \
	--enable-libwebp \
	--enable-libx265 \
	--enable-libxml2 \
	--enable-libxvid \
	--enable-libzmq \
	--enable-libzvbi \
	--enable-omx \
	--enable-openal \
	--enable-opengl \
	--enable-sdl2 \
	--enable-libdc1394 \
	--enable-libdrm \
	--enable-libiec61883 \
	--enable-chromaprint \
	--enable-frei0r \
	--enable-libopencv \
	--enable-libx264 \
	--enable-shared \
	--enable-libvmaf \
	--enable-version3 \
	&& make \
	&& make install \
	&& ldconfig \
	# remove installed dependencies 
	&& apt-get remove -y \
		yasm \
		vim \
		# libchromaprint-dev \
		# frei0r-plugins-dev \
		# libgnutls28-dev \
		# ladspa-sdk \
		# libiec61883-dev \
		# libavc1394-dev \ 
		# libass-dev \ 
		# libbluray-dev \
		# libbs2b-dev \
		# libcaca-dev \
		# libdc1394-22-dev \
		# flite-dev \
		# libgme-dev \
		# libgsm1-dev \
		# libmp3lame-dev \
		# libmysofa-dev \
		# libopencv-dev \
		# libbs2b-dev \
		# libopenjp2-7-dev \
		# libopenmpt-dev \
		# librsvg2-dev \
		# librubberband-dev \
		# libshine-dev \
		# libsnappy-dev \
		# libsoxr-dev \
		# libssh-dev \
		# libspeex-dev \
		# libtwolame-dev \
		# libwavpack-dev \
		# libx264-dev \
		# libx265-dev \
		# libnuma-dev \
		# libxvidcore-dev \
		# libzmq3-dev \
		# libzvbi-dev \
		# libomxil-bellagio-dev \
		# libcdio-paranoia-dev \
		# libsdl2-dev \ 
		# frei0r-plugins-dev \
		# libgnutls28-dev \
		# libunistring-dev \
		# libopencv-dev \
		# libopus-dev \
		# librsvg2-dev \
		# libselinux1-dev \
		# libmount-dev \
		# libtheora-dev \
		# libvpx-dev \
		# libwebp-dev \
		# libsodium-dev \
		# libpgm-dev \
		# libnorm-dev \
		# libopenal-dev \
		# libffi-dev \
	&& apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
	&& rm -rf /usr/local/vmaf-1.3.9 \
	&& rm -rf /usr/local/ffmpeg-4.1

WORKDIR /golem/work/
