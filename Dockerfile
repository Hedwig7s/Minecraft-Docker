FROM container-registry.oracle.com/graalvm/jdk:25

EXPOSE 25565/tcp
EXPOSE 8100/tcp
EXPOSE 8080/tcp

# Default environment variables
ENV MC_VERSION=1.21.11 \
    MC_EULA=true \
    MC_RAM_XMS=1536M \
    MC_RAM_XMX=2048M \
    MC_PRE_JAR_ARGS="" \
    MC_POST_JAR_ARGS="" \
    MC_URL_ZIP_SERVER_FIILES="" \
    FORCE_INSTALL="" \
    FABRIC_INSTALLVER=1.1.1 \
    FABRIC_VERSION="" \
    SPONGE_TYPE=spongevanilla \
    SPONGE_VERSION=13.0.0 \
    NEOFORGE_VERSION=21.11.42 \
    LEAF_VERSION=498 \
    JAR=""

VOLUME /data

USER root
WORKDIR /data 

COPY src/main.sh /main.sh

RUN microdnf update -y && microdnf install -y \
    unzip \
    findutils \
    dos2unix \
    curl \
    bash \
    && microdnf clean all

RUN chmod +x /main.sh

RUN groupadd -g 1000 minecraft && \
    useradd -r -u 1000 -g minecraft -d /data -s /sbin/nologin minecraft

RUN chown -R minecraft:minecraft /data && chmod -R 755 /data
USER minecraft

CMD ["/main.sh"]
