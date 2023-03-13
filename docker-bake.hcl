variable "ALPINE_VERSION" {
  default = "latest"
}

variable "S6_OVERLAY_GIT_URI" {
  default = "https://github.com/just-containers/s6-overlay.git"
}

variable "S6_OVERLAY_GIT_TAG" {
  default = "master"
}

variable "S6_OVERLAY_SYMLINKS" {
  default = ""
}

variable "SYSLOGD_OVERLAY" {
  default = ""
}

group "default" {
  targets = ["alpine-base"]
}

target "alpine-base" {
  args = {
    ALPINE_VERSION      = ALPINE_VERSION
    S6_OVERLAY_GIT_URI  = S6_OVERLAY_GIT_URI
    S6_OVERLAY_GIT_TAG  = S6_OVERLAY_GIT_TAG
    S6_OVERLAY_SYMLINKS = S6_OVERLAY_SYMLINKS
    SYSLOGD_OVERLAY     = SYSLOGD_OVERLAY
  }

  output = ["type=local,dest=output"]

  platforms = [
    "linux/386",
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v7",
    "linux/arm/v6",
    "linux/ppc64le",
    "linux/s390x",
  ]
}
