FROM debian:bullseye-slim AS builder

RUN \
  echo "# INSTALL DEPENDENCIES ##########################################" && \
  apt-get update && \
  apt upgrade -y && apt dist-upgrade && \
  apt-get install -y build-essential "linux-headers-*-common" libcurl4-gnutls-dev curl gcc git make  && \
  mkdir -p /tmp/build
RUN \
  echo "# FETCH INSTALLATION FILES ######################################" && \
  cd /tmp/build && \
  git clone --progress https://github.com/ioquake/ioq3.git && \
  cd /tmp/build/ioq3
RUN \
  echo "# BUILD NATIVE SERVER ##########################################" && \
  cd /tmp/build/ioq3 && \
  make BUILD_CLIENT=0 BUILD_BASEGAME=0 BUILD_MISSIONPACK=0

FROM alpine:latest AS server
COPY --from=builder /tmp/build/ioq3/build/release-linux-x86_64/ioq3ded.x86_64 /ioq3ded
RUN adduser -D ioq3ded
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
USER ioq3ded
EXPOSE 27960/udp
ENTRYPOINT ["/ioq3ded"]