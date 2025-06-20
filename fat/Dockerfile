ARG UID=200013
ARG GID=200013
ARG VERSION=0.46.2

# Build the application
FROM gradle:8.14-jdk21 AS build
ARG VERSION

ADD https://raw.githubusercontent.com/Stirling-Tools/Stirling-PDF/refs/tags/v${VERSION}/build.gradle .
ADD https://raw.githubusercontent.com/Stirling-Tools/Stirling-PDF/refs/tags/v${VERSION}/settings.gradle .
ADD https://raw.githubusercontent.com/Stirling-Tools/Stirling-PDF/refs/tags/v${VERSION}/gradlew .
ADD https://github.com/Stirling-Tools/Stirling-PDF.git#v${VERSION}:gradle gradle
RUN ./gradlew build -x spotlessApply -x spotlessCheck -x test -x sonarqube || return 0

# Set the working directory
WORKDIR /app

# Copy the entire project to the working directory
COPY . .

# Build the application with DOCKER_ENABLE_SECURITY=false
RUN DOCKER_ENABLE_SECURITY=true \
    STIRLING_PDF_DESKTOP_UI=false \
    ./gradlew clean build -x spotlessApply -x spotlessCheck -x test -x sonarqube


FROM ghcr.io/stirling-tools/stirling-pdf:latest-fat

LABEL maintainer="Thien Tran contact@tommytran.io"

ARG UID
ARG GID
ARG VERSION

# Copy necessary files
ADD https://github.com/Stirling-Tools/Stirling-PDF.git#v${VERSION}:scripts /scripts
ADD https://github.com/Stirling-Tools/Stirling-PDF.git#v${VERSION}:pipeline /pipeline
ADD https://raw.githubusercontent.com/Stirling-Tools/Stirling-PDF/refs/tags/v${VERSION}/src/main/resources/static/fonts/*.ttf /usr/share/fonts/opentype/noto/
COPY --from=build /app/build/libs/*.jar app.jar

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
