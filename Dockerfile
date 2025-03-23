FROM eclipse-temurin:21-jre

EXPOSE 25565/tcp
EXPOSE 8100/tcp
EXPOSE 8080/tcp

# Default environment variables
ENV MC_VERSION=1.20.1 \
    MC_EULA=true \
    MC_RAM_XMS=1536M \
    MC_RAM_XMX=2048M \
    MC_PRE_JAR_ARGS="" \
    MC_POST_JAR_ARGS="" \
    MC_URL_ZIP_SERVER_FIILES="" \
    FORCE_INSTALL="" \
    FABRIC_INSTALLVER=1.0.1 \
    FABRIC_VERSION="" \
    SPONGE_TYPE=spongevanilla \
    SPONGE_VERSION=13.0.0 \
    NEOFORGE_VERSION=20.4.190 \
    JAR=""

VOLUME /data

USER root
WORKDIR /data

COPY src/main.sh /main.sh

# Update and install required packages
RUN apt-get update && \
    apt-get install -y unar findutils curl && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /main.sh

RUN id ubuntu > /dev/null 2>&1 && deluser ubuntu
RUN addgroup --gid 1000 minecraft
RUN adduser --system --shell /bin/false --uid 1000 --ingroup minecraft --home /data minecraft
RUN chown -R minecraft:minecraft /data && chmod -R 755 /data
USER minecraft

CMD ["/main.sh"]
