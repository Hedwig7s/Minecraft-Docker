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

# Install gosu.  https://github.com/tianon/gosu
ENV GOSU_VERSION=1.19
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

COPY src/*.fish /
COPY bin/mc-helper /usr/bin
RUN chmod +x /*.fish
RUN chmod +x /usr/bin/mc-helper

RUN microdnf update -y && microdnf install -y oracle-epel-release-el10
RUN microdnf install -y \
    unzip \
    findutils \
    dos2unix \
    curl \
    fish \
    bash \
    btrfs-progs \
    && microdnf clean all


RUN groupadd -g 1000 minecraft && \
    useradd -r -u 1000 -g minecraft -d /data -s /sbin/nologin minecraft

RUN chown -R minecraft:minecraft /data && chmod -R 755 /data
# USER minecraft

CMD ["/main.fish"]
