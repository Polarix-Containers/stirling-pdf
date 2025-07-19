#!/bin/sh

mkdir -p /tmp/stirling-pdf

export JAVA_TOOL_OPTIONS="${JAVA_BASE_OPTS} ${JAVA_CUSTOM_OPTS}"
echo "running with JAVA_TOOL_OPTIONS ${JAVA_BASE_OPTS} ${JAVA_CUSTOM_OPTS}"
exec "$@"
