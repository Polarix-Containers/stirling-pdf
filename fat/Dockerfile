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
ADD https://github.com/Stirling-Tools/Stirling-PDF.git#v${VERSION} .

# Build the application with DOCKER_ENABLE_SECURITY=false
RUN DOCKER_ENABLE_SECURITY=true \
    STIRLING_PDF_DESKTOP_UI=false \
    ./gradlew clean build -x spotlessApply -x spotlessCheck -x test -x sonarqube


FROM alpine:latest

LABEL maintainer="Thien Tran contact@tommytran.io"

ARG UID
ARG GID
ARG VERSION

RUN apk -U upgrade \
    && apk add git libstdc++ \
    && rm -rf /var/cache/apk/*

# Copy necessary files

RUN git clone --branch v${VERSION} https://github.com/Stirling-Tools/Stirling-PDF.git \
    && mv Stirling-PDF/scripts /scripts \
    && mv Stirling-PDF/pipeline /pipeline \
    && mkdir -p /usr/share/fonts/opentype/noto/ \
    && mv Stirling-PDF/src/main/resources/static/fonts/*.ttf /usr/share/fonts/opentype/noto/
COPY --from=build /app/build/libs/*.jar app.jar

# Set Environment Variables
ENV DOCKER_ENABLE_SECURITY=false \
    VERSION_TAG=$VERSION_TAG \
    JAVA_BASE_OPTS="-XX:+UnlockExperimentalVMOptions -XX:MaxRAMPercentage=75 -XX:InitiatingHeapOccupancyPercent=20 -XX:+G1PeriodicGCInvokesConcurrent -XX:G1PeriodicGCInterval=10000 -XX:+UseStringDeduplication -XX:G1PeriodicGCSystemLoadThreshold=70" \
    JAVA_CUSTOM_OPTS="" \
    HOME=/home/stirlingpdfuser \
    PUID=${UID} \
    PGID=${GID} \
    UMASK=022 \
    FAT_DOCKER=true \
    INSTALL_BOOK_AND_ADVANCED_HTML_OPS=false \
    PYTHONPATH=/usr/lib/libreoffice/program:/opt/venv/lib/python3.12/site-packages \
    UNO_PATH=/usr/lib/libreoffice/program \
    URE_BOOTSTRAP=file:///usr/lib/libreoffice/program/fundamentalrc \
    PATH=$PATH:/opt/venv/bin


# JDK for app
RUN echo "@main https://dl-cdn.alpinelinux.org/alpine/edge/main" | tee -a /etc/apk/repositories && \
    echo "@community https://dl-cdn.alpinelinux.org/alpine/edge/community" | tee -a /etc/apk/repositories && \
    echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" | tee -a /etc/apk/repositories && \
    apk upgrade --no-cache -a && \
    apk add --no-cache \
    ca-certificates \
    tzdata \
    tini \
    bash \
    curl \
    shadow \
    su-exec \
    openssl \
    openssl-dev \
    openjdk21-jre \
    # Doc conversion
    gcompat \
    libc6-compat \
    libreoffice \
    # pdftohtml
    poppler-utils \
    # OCR MY PDF (unpaper for descew and other advanced featues)
    qpdf \
    tesseract-ocr-data-eng \
    tesseract-ocr-data-chi_sim \
	tesseract-ocr-data-deu \
	tesseract-ocr-data-fra \
	tesseract-ocr-data-por \
    font-terminus font-dejavu font-noto font-noto-cjk font-awesome font-noto-extra font-liberation font-linux-libertine \
    # CV
    py3-opencv \
    python3 \
    py3-pip \
    py3-pillow@testing \
    py3-pdf2image@testing && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade unoserver weasyprint && \
    ln -s /usr/lib/libreoffice/program/uno.py /opt/venv/lib/python3.12/site-packages/ && \
    ln -s /usr/lib/libreoffice/program/unohelper.py /opt/venv/lib/python3.12/site-packages/ && \
    ln -s /usr/lib/libreoffice/program /opt/venv/lib/python3.12/site-packages/LibreOffice && \
    mv /usr/share/tessdata /usr/share/tessdata-original && \
    mkdir -p $HOME /configs /logs /customFiles /pipeline/watchedFolders /pipeline/finishedFolders && \
    fc-cache -f -v && \
    chmod +x /scripts/* && \
    chmod +x /scripts/init.sh

RUN --network=none \
    addgroup -g ${GID} stirlingpdfgroup \
    && adduser -u ${UID} --ingroup stirlingpdfgroup --disabled-password --system stirlingpdfuser \
    && chown -R stirlingpdfuser:stirlingpdfgroup $HOME /scripts /usr/share/fonts/opentype/noto /configs /customFiles /pipeline && \
    && chown stirlingpdfuser:stirlingpdfgroup /app.jar
    
USER stirlingpdfuser

COPY --from=ghcr.io/polarix-containers/hardened_malloc:latest /install /usr/local/lib/
ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc.so"
