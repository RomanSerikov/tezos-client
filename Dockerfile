# ---------------------------------------------------------------------
#  The first stage container, for building the tezos-client
# ---------------------------------------------------------------------
FROM alpine:3.11 as tezos_builder
RUN apk update
RUN apk --no-cache --virtual add rsync git m4 build-base patch unzip \
  bubblewrap wget pkgconfig gmp-dev libev-dev hidapi-dev eudev-dev perl opam libusb-dev bash \
  autoconf automake libtool linux-headers libffi-dev libgcc
RUN git clone --single-branch --branch v1.0.23 https://github.com/libusb/libusb.git --depth 1
RUN cd libusb && autoreconf -fvi && ./configure && make && make install
RUN git clone --single-branch --branch hidapi-0.9.0 https://github.com/libusb/hidapi.git --depth 1
RUN cd hidapi && autoreconf -fvi && ./bootstrap && ./configure && make && make install
RUN rm -rf libusb hidapi

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH=/root/.cargo/bin:$PATH
RUN rustup set profile minimal
RUN rustup toolchain install 1.39.0
RUN rustup default 1.39.0

COPY static_libs.patch /static.patch
RUN git clone --single-branch --branch master https://gitlab.com/tezos/tezos.git --depth 1
RUN git checkout b1f564b445bcf1921c0e8c6a0ebfb2e93eb2a1f0
WORKDIR /tezos
RUN git apply /static.patch
RUN export OPAMYES="true" && opam init --bare --disable-sandboxing && make build-deps
RUN eval "$(opam env)" && make
