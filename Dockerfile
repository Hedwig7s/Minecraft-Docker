FROM container-registry.oracle.com/graalvm/jdk:25

EXPOSE 25565/tcp
EXPOSE 8100/tcp
EXPOSE 8080/tcp

# Default environment variables
ENV MC_VERSION=1.21.11 \
    SERVER_VERSION=latest \
    MC_EULA=true \
    MC_RAM_XMS=1536M \
    MC_RAM_XMX=2048M \
    MC_PRE_JAR_ARGS="" \
    MC_POST_JAR_ARGS="" \
    MC_URL_ZIP_SERVER_FIILES="" \
    FORCE_INSTALL="" \
    SPONGE_TYPE=spongevanilla \
    JAR=""


VOLUME /data

USER root
WORKDIR /data

# Install gosu.  https://github.com/tianon/gosu
ENV GOSU_VERSION=1.19
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

COPY src/*.nu /
COPY bin/mc-helper /usr/bin
RUN chmod +x /*.nu
RUN chmod +x /usr/bin/mc-helper

RUN microdnf update -y && microdnf install -y oracle-epel-release-el10
RUN echo "[gemfury-nushell]" > /etc/yum.repos.d/fury-nushell.repo && \
    echo "name=Gemfury Nushell Repo" >> /etc/yum.repos.d/fury-nushell.repo && \
    echo "baseurl=https://yum.fury.io/nushell/" >> /etc/yum.repos.d/fury-nushell.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/fury-nushell.repo && \
    echo "gpgcheck=0" >> /etc/yum.repos.d/fury-nushell.repo && \
    echo "gpgkey=https://yum.fury.io/nushell/gpg.key" >> /etc/yum.repos.d/fury-nushell.repo
RUN microdnf install -y \
    unzip \
    findutils \
    dos2unix \
    curl \
    nushell \
    bash \
    btrfs-progs \
    && microdnf clean all


RUN groupadd -g 1000 minecraft && \
    useradd -r -u 1000 -g minecraft -d /data -s /sbin/nologin minecraft

RUN chown -R minecraft:minecraft /data && chmod -R 755 /data
# USER minecraft

CMD ["/main.nu"]
