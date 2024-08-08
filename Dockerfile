FROM debian:stable-slim AS build-layer

RUN  apt-get update && apt-get -y upgrade

RUN  apt-get install -y binutils-dev cmake fonts-dejavu-core libfontconfig-dev \
     gcc g++ pkg-config libegl-dev libgl-dev libgles-dev libspice-protocol-dev \
     nettle-dev libx11-dev libxcursor-dev libxi-dev libxinerama-dev \
     libxpresent-dev libxss-dev libxkbcommon-dev libwayland-dev wayland-protocols \
     libpipewire-0.3-dev libpulse-dev libsamplerate0-dev git
RUN  apt-get install -y wget joe aptitude

ARG NFMP_URL="https://github.com/goreleaser/nfpm/releases/download/v2.1.0/nfpm_amd64.deb"
RUN wget -O /tmp/nfpm_amd64.deb ${NFMP_URL} && \
    dpkg -i "/tmp/nfpm_amd64.deb"

FROM build-layer AS source

ARG WINE_BRANCH="B7-rc1"
WORKDIR /build
RUN git clone -b ${WINE_BRANCH} --recursive  https://github.com/gnif/LookingGlass.git

FROM source AS build

WORKDIR /build/LookingGlass
RUN mkdir client/build
WORKDIR /build/LookingGlass/client/build
RUN cmake ../
RUN make
RUN mkdir /out && cp -r /build/LookingGlass/client/build/looking-glass-client /out/ && \
    chmod 0755 -R /out

FROM build AS package

WORKDIR /package
ARG LG_VERSION="0+B7-rc1.build1"
COPY nfpm.tpl.yaml ./nfpm.yaml
RUN sed -i 's/#LG_VERSION#/'"${LG_VERSION}"'/g' nfpm.yaml && \
    cat nfpm.yaml
RUN nfpm pkg --packager deb --target /out/

# make world readable before copying
RUN chmod 777 -R /out