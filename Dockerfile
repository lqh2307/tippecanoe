FROM ubuntu:24.04
# FROM quanghuy2307/gdal:1.0.0

RUN \
  set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get -qq update; \
  apt-get -y --no-install-recommends install \
  build-essential \
  libsqlite3-dev \
  zlib1g-dev;

WORKDIR /data

COPY . .

RUN \
  make; \
  make install; \
  rm -rf *; \
  apt-get -y --purge autoremove; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*;

VOLUME /data
