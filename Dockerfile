FROM ubuntu:24.04

RUN \
  set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get -qq update; \
  apt-get -y --no-install-recommends install \
    build-essential \
    libsqlite3-dev \
    zlib1g-dev;

WORKDIR /tippecanoe

COPY . .

RUN \
	make; \
  make install; \
  rm -rf *; \
  mkdir -p ./data; \
  apt-get -y --purge autoremove; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*;

VOLUME /tippecanoe/data
