variable "ALPINE_VERSION" {
  default = null
}

variable "S6_OVERLAY_GIT_URI" {
  default = null
}

variable "S6_OVERLAY_GIT_REF" {
  default = null
}

variable "S6_OVERLAY_SYMLINKS" {
  default = null
}

variable "SYSLOGD_OVERLAY" {
  default = null
}

target "default" {
  args = {
    ALPINE_VERSION      = ALPINE_VERSION
    S6_OVERLAY_GIT_URI  = S6_OVERLAY_GIT_URI
    S6_OVERLAY_GIT_REF  = S6_OVERLAY_GIT_REF
    S6_OVERLAY_SYMLINKS = S6_OVERLAY_SYMLINKS
    SYSLOGD_OVERLAY     = SYSLOGD_OVERLAY
  }

  output = ["type=docker,name=ohmer/alpine-s6-overlay"]
}

target "all" {
  inherits = ["default"]

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
