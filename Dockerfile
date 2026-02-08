# syntax=docker/dockerfile:1

############################
# Build stage
############################
FROM maven:3.9.9-eclipse-temurin-17 AS build

ARG WR_REPO=https://github.com/OHDSI/WhiteRabbit.git
ARG WR_REF=master
# Allow override of Maven goals/args
ARG WR_MVN_ARGS="-DskipTests package"

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src

# WhiteRabbit
RUN git clone --depth 1 --branch "${WR_REF}" "${WR_REPO}" WhiteRabbit
RUN cd WhiteRabbit && mvn -q ${WR_MVN_ARGS}

# Collect jar (search entire repo for target/*.jar)
RUN mkdir -p /out && \
    WR_JAR="$(find /src/WhiteRabbit -type f -path '*/target/*.jar' \
      ! -name '*sources*' ! -name '*javadoc*' ! -name '*original*' \
      | head -n 1)" && \
    if [ -z "$WR_JAR" ]; then \
      echo "ERROR: No WhiteRabbit JAR found under /src/WhiteRabbit" >&2; \
      echo "DEBUG: target dirs:" >&2; \
      find /src/WhiteRabbit -type d -name target -maxdepth 6 -print >&2; \
      echo "DEBUG: any jars:" >&2; \
      find /src/WhiteRabbit -type f -name '*.jar' -maxdepth 6 -print >&2; \
      exit 1; \
    fi && \
    cp "$WR_JAR" /out/WhiteRabbit.jar

############################
# Runtime stage
############################
FROM eclipse-temurin:17-jre

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    APP_HOME=/opt/ohdsi

# Optional GUI dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      xvfb x11vnc fluxbox \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${APP_HOME}

COPY --from=build /out/WhiteRabbit.jar ${APP_HOME}/WhiteRabbit.jar

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5900

ENTRYPOINT ["/entrypoint.sh"]
