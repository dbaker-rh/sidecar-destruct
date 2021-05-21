FROM docker.io/library/alpine:3
MAINTAINER Dave Baker <dbaker@redhat.com>

# Install kubectl to simply interacting with kube API
#
# I note that most public kubectl container images are amd64 only, and we need
# at least amd64 and arm64
#
# If I ever find an official kubernetes "kubectl" container that's multi-arch
# we should switch to that one and use a configmap to drop our script in.
#

RUN apk add --no-cache bash curl    && \
    apkArch=$( apk --print-arch )   && \
    case "$apkArch" in \
# Note: does *NOT* work on rPi Zero W
      "armhf")  KUBEARCH=arm   ;; \
# Note: need to capture output for rPi 4
      "xxx")    KUBEARCH=arm64 ;; \
      "x86_64") KUBEARCH=amd64 ;; \
      "*")      KUBEARCH=amd64 ;; \
    esac                            && \
    cd /usr/bin                     && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$KUBEARCH/kubectl" && \
    chmod a+x kubectl


COPY start.sh  /
RUN  chmod 755 /start.sh

# Allow runAsNonRoot: true
USER 1024

ENTRYPOINT ["/start.sh"]


