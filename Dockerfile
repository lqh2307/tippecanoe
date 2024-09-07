ARG BUILDER_IMAGE=ubuntu:24.04
ARG TARGET_IMAGE=ubuntu:24.04
# ARG TARGET_IMAGE=quanghuy2307/gdal:1.0.0

FROM $BUILDER_IMAGE AS builder

RUN \
  set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get -y update; \
  apt-get -y install \
    build-essential \
    libsqlite3-dev \
    zlib1g-dev; \
  apt-get -y --purge autoremove; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*;

WORKDIR /tippecanoe

ADD . .

RUN make


FROM $TARGET_IMAGE AS final

RUN \
  set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get -y update; \
  apt-get -y install \
    libsqlite3-0 \
    zlib1g; \
  apt-get -y --purge autoremove; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*;

COPY --from=builder /tippecanoe/tippecanoe /usr/local/bin/tippecanoe
COPY --from=builder /tippecanoe/tippecanoe-enumerate /usr/local/bin/tippecanoe-enumerate
COPY --from=builder /tippecanoe/tippecanoe-decode /usr/local/bin/tippecanoe-decode
COPY --from=builder /tippecanoe/tippecanoe-json-tool /usr/local/bin/tippecanoe-json-tool
COPY --from=builder /tippecanoe/tile-join /usr/local/bin/tile-join
COPY --from=builder /tippecanoe/man/tippecanoe /usr/local/share/man/tippecanoe

VOLUME /data
