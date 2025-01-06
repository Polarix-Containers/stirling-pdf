ARG UID=200013
ARG GID=200013

FROM ghcr.io/stirling-tools/stirling-pdf:latest-fat

LABEL maintainer="Thien Tran contact@tommytran.io"

ARG UID
ARG GID

RUN apk -U upgrade \
    && apk add libstdc++ \
    && rm -rf /var/cache/apk/*

RUN --network=none \
    usermod -u ${UID} stirlingpdfuser \
    && groupmod -g ${GID} stirlingpdfgroup \
    && find / -user 1000 -exec chown -h stirlingpdfuser {} \; \
    && find / -group 1000 -exec chgrp -h stirlingpdfgroup {} \;
    
USER stirlingpdfuser

COPY --from=ghcr.io/polarix-containers/hardened_malloc:latest /install /usr/local/lib/
ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc.so"