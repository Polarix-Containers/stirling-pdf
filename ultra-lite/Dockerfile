ARG UID=200013
ARG GID=200013
ARG VERSION=1.0.2

# Build the application
FROM gradle:8.14-jdk21 AS build
ARG VERSION

WORKDIR /install

# Copy the entire project to the working directory
ADD https://github.com/Stirling-Tools/Stirling-PDF.git#v${VERSION} .

# Delete proprietary code
RUN rm -rf app/proprietary

RUN DISABLE_ADDITIONAL_FEATURES=true \
    STIRLING_PDF_DESKTOP_UI=false \
    ./gradlew clean build -x spotlessApply -x spotlessCheck -x test -x sonarqube


FROM alpine:latest

LABEL maintainer="Thien Tran contact@tommytran.io"

ARG UID
ARG GID
ARG VERSION

# Set Environment Variables
ENV DISABLE_ADDITIONAL_FEATURES=true \
    DISABLE_PIXEL=true \
    JAVA_BASE_OPTS="-XX:+UnlockExperimentalVMOptions -XX:MaxRAMPercentage=75 -XX:InitiatingHeapOccupancyPercent=20 -XX:+G1PeriodicGCInvokesConcurrent -XX:G1PeriodicGCInterval=10000 -XX:+UseStringDeduplication -XX:G1PeriodicGCSystemLoadThreshold=70" \
    STIRLING_TEMPFILES_DIRECTORY=/tmp/stirling-pdf \
    TMPDIR=/tmp/stirling-pdf \
    TEMP=/tmp/stirling-pdf \
    TMP=/tmp/stirling-pdf \
    ENDPOINTS_GROUPS_TO_REMOVE=CLI

# Copy necessary files
RUN mkdir /scripts
COPY init-without-ocr.sh /scripts
ADD https://github.com/Stirling-Tools/Stirling-PDF.git#v${VERSION}:pipeline /pipeline
COPY --from=build /install/stirling-pdf/build/libs/*.jar app.jar

RUN apk -U upgrade \
    && apk add ca-certificates curl libstdc++ openjdk21-jre tini tzdata \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /configs /logs /customFiles /usr/share/fonts/opentype/noto \
    && chmod +x /scripts/init-without-ocr.sh

RUN --network=none \
    addgroup -g ${GID} stirlingpdfgroup \
    && adduser -u ${UID} --ingroup stirlingpdfgroup --disabled-password --system stirlingpdfuser \
    && chown -R stirlingpdfuser:stirlingpdfgroup /app.jar /configs /customFiles /logs /pipeline /scripts /usr/share/fonts/opentype/noto \
    && chmod -R 755 /app.jar /configs /customFiles /logs /pipeline /scripts /usr/share/fonts/opentype/noto

USER stirlingpdfuser

COPY --from=ghcr.io/polarix-containers/hardened_malloc:latest /install /usr/local/lib/
ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc.so"

EXPOSE 8080/tcp

# Run the application
ENTRYPOINT ["tini", "--", "/scripts/init-without-ocr.sh"]
CMD ["java", "-Dfile.encoding=UTF-8", "-Djava.io.tmpdir=/tmp/stirling-pdf", "-jar", "/app.jar"]
