# syntax=docker/dockerfile:1.4

ARG ALPINE_VERSION

# https://github.com/just-containers/s6-overlay#which-architecture-to-use-depending-on-your-targetarch
FROM alpine:${ALPINE_VERSION} AS builder-amd64
ENV ARCH=x86_64
ENV MAKE_ARCH=${ARCH}-linux-musl

FROM alpine:${ALPINE_VERSION} AS builder-arm64
ENV ARCH=aarch64
ENV MAKE_ARCH=${ARCH}-linux-musl

FROM alpine:${ALPINE_VERSION} AS builder-armv7
ENV ARCH=arm
ENV MAKE_ARCH=arm-linux-musleabi

FROM alpine:${ALPINE_VERSION} AS builder-armv6
ENV ARCH=armhf
ENV MAKE_ARCH=arm-linux-musleabihf

FROM alpine:${ALPINE_VERSION} AS builder-386
ENV ARCH=i686
ENV MAKE_ARCH=${ARCH}-linux-musl

FROM alpine:${ALPINE_VERSION} AS builder-ppc64le
ENV ARCH=powerpc64le
ENV MAKE_ARCH=${ARCH}-linux-musl

FROM alpine:${ALPINE_VERSION} AS builder-s390x
ENV ARCH=s390x
ENV MAKE_ARCH=${ARCH}-linux-musl

# hadolint ignore=DL3006
FROM builder-${TARGETARCH}${TARGETVARIANT} AS builder

ARG TARGETARCH
ARG TARGETVARIANT
ARG S6_OVERLAY_GIT_TAG
ARG S6_OVERLAY_GIT_URI

# hadolint ignore=DL3003,DL3018,SC2086
RUN --mount=type=cache,target=/var/cache/apk,sharing=locked,id=var-cache-apk-${TARGETARCH}${TARGETVARIANT} \
	set -eux; \
	apk add --update-cache --virtual builder binutils curl git make tar xz; \
	\
	git -c advice.detachedHead=false clone --depth 1 --branch "${S6_OVERLAY_GIT_TAG}" "${S6_OVERLAY_GIT_URI}" /work; \
	make -C /work ARCH="${MAKE_ARCH}" DL_CMD="curl -fsSLO"; \
	\
	mkdir /output; \
	mv \
	/work/output/s6-overlay-noarch.tar.xz \
	/work/output/s6-overlay-${ARCH}.tar.xz \
	/work/output/s6-overlay-symlinks-noarch.tar.xz \
	/work/output/s6-overlay-symlinks-arch.tar.xz \
	/work/output/syslogd-overlay-noarch.tar.xz \
	/output \
	; \
	mv /output/s6-overlay-${ARCH}.tar.xz /output/s6-overlay-arch.tar.xz; \
	rm -rf /work; \
	\
	apk del builder


FROM alpine:${ALPINE_VERSION} AS alpine-s6-overlay

ARG S6_OVERLAY_SYMLINKS
ARG SYSLOGD_OVERLAY

WORKDIR /
RUN --mount=type=bind,from=builder,source=/output/s6-overlay-noarch.tar.xz,target=/s6-overlay-noarch.tar.xz \
	--mount=type=bind,from=builder,source=/output/s6-overlay-arch.tar.xz,target=/s6-overlay-arch.tar.xz \
	--mount=type=bind,from=builder,source=/output/s6-overlay-symlinks-noarch.tar.xz,target=/s6-overlay-symlinks-noarch.tar.xz \
	--mount=type=bind,from=builder,source=/output/s6-overlay-symlinks-arch.tar.xz,target=/s6-overlay-symlinks-arch.tar.xz \
	--mount=type=bind,from=builder,source=/output/syslogd-overlay-noarch.tar.xz,target=/syslogd-overlay-noarch.tar.xz \
	\
	set -eux; \
	tar -Jxpf /s6-overlay-noarch.tar.xz; \
	tar -Jxpf /s6-overlay-arch.tar.xz; \
	test -z "${S6_OVERLAY_SYMLINKS}" || tar -Jxpf /s6-overlay-symlinks-noarch.tar.xz; \
	test -z "${S6_OVERLAY_SYMLINKS}" || tar -Jxpf /s6-overlay-symlinks-arch.tar.xz; \
	test -z "${SYSLOGD_OVERLAY}" || tar -Jxpf /syslogd-overlay-noarch.tar.xz

ENV PATH="/command:$PATH"
ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ "
ENV HOME="/root"
ENV TERM="xterm"
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME="0"
ENV S6_VERBOSITY="1"

ENTRYPOINT ["/init"]
CMD ["with-contenv", "/bin/sh"]
