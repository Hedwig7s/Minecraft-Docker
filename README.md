Lazily combined version of my docker images using ChatGPT
ChatGPT Readme:

# Minecraft Server Docker Container

This repository provides a Docker container for running a Minecraft server or proxy using a unified startup script that supports various server types (e.g., FabricMC, PurpurMC, SpongeVanilla, NeoForge, BungeeCord, Velocity, Waterfall, or a generic jar-based server). The container is based on the Oracle GraalVM JDK 25 image.

## Features

- **Multiple Server Types:**  
  Configure your server type by setting the `SERVER_TYPE` environment variable.  
  Supported server values: `fabric`, `purpur`, `paper`, `forge`, `neoforge`, `quilt`, and `simple`.  
  Supported proxy values: `bungeecord`, `velocity`, and `waterfall`.

- **Unified Startup Script:**  
  A single fish script (`main.fish` and `nonroot.fish`) handles server initialization, file downloads, configuration, and server launch.

- **Default Environment Variables:**  
  Set default server settings (Minecraft version, RAM allocation, EULA acceptance, etc.) using environment variables.

- **Volume Support:**  
  The `/data` directory is declared as a volume for persistent server data.

## Environment Variables

Below are the default environment variables that can be overridden at runtime:

### Common Variables

| Variable                  | Default Value  | Description |
| ------------------------- | -------------- | ----------- |
| `MC_EULA`                 | `true`         | Accept Minecraft's EULA (`true` or `false`). |
| `MC_RAM_XMS`              | `1536M`        | Preallocated RAM for the server. |
| `MC_RAM_XMX`              | `2048M`        | Maximum RAM for the server. |
| `MC_PRE_JAR_ARGS`         | `""`           | Additional arguments to prepend before the jar in the launch command. |
| `MC_POST_JAR_ARGS`        | `""`           | Additional arguments to append after the jar in the launch command. |
| `MC_URL_ZIP_SERVER_FIILES`| `""`           | URL to a ZIP file with extra server files. |
| `FORCE_INSTALL`           | `""`           | Force the installation of a server jar/installer if set. |
| `SERVER_TYPE`             | `fabric`       | Server type to run: `fabric`, `purpur`, `paper`, `forge`, `neoforge`, `quilt`, `simple`, `bungeecord`, `velocity`, or `waterfall`. |
| `SERVER_VERSION`          | `latest`       | Server/loader version to install (used for all server types and proxies). |

### Optional Variables

| Variable                  | Default Value  | Description |
| ------------------------- | -------------- | ----------- |
| `MC_VERSION`              | `1.21.11`      | Minecraft server version (used for fabric, paper, purpur, forge, neoforge, quilt). |
| `SPONGE_TYPE`             | `spongevanilla`| Sponge server type. |
| `JAR`                     | `""`           | Name of the jar file to use in simple mode. |

## Dockerfile Overview

The Dockerfile uses the Oracle GraalVM JDK 25 image, exposes the necessary ports, installs required packages, and sets up a non-root `minecraft` user. The startup command executes the unified `main.fish` script.

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) must be installed on your system.

### Building the Docker Image

Clone the repository and navigate to its directory. Then run:

```bash
docker build -t minecraft-server .
```

This command builds the Docker image with the tag `minecraft-server`.

### Running the Container

You can run the container with:

```bash
docker run -d \
  -p 25565:25565/tcp \
  -p 8100:8100/tcp \
  -v /path/to/your/server/data:/data \
  -e MC_VERSION=1.21.11 \
  -e MC_EULA=true \
  -e MC_RAM_XMS=1536M \
  -e MC_RAM_XMX=2048M \
  -e SERVER_TYPE=fabric \
  minecraft-server
```

Adjust the environment variables and volume mapping as necessary.

## Server Type Examples

### Fabric Server

```bash
docker run -d \
  -p 25565:25565/tcp \
  -v /path/to/your/server/data:/data \
  -e MC_VERSION=1.21.11 \
  -e MC_EULA=true \
  -e SERVER_TYPE=fabric \
  minecraft-server
```

### Paper/Purpur Server

```bash
docker run -d \
  -p 25565:25565/tcp \
  -v /path/to/your/server/data:/data \
  -e MC_VERSION=1.21.11 \
  -e MC_EULA=true \
  -e SERVER_TYPE=paper \
  minecraft-server
```

### Forge Server

```bash
docker run -d \
  -p 25565:25565/tcp \
  -v /path/to/your/server/data:/data \
  -e MC_VERSION=1.21.11 \
  -e SERVER_VERSION=latest \
  -e MC_EULA=true \
  -e SERVER_TYPE=forge \
  minecraft-server
```

### NeoForge Server

```bash
docker run -d \
  -p 25565:25565/tcp \
  -v /path/to/your/server/data:/data \
  -e MC_VERSION=1.21.11 \
  -e SERVER_VERSION=latest \
  -e MC_EULA=true \
  -e SERVER_TYPE=neoforge \
  minecraft-server
```

### Simple JAR Server

```bash
docker run -d \
  -p 25565:25565/tcp \
  -v /path/to/your/server/data:/data \
  -e SERVER_TYPE=simple \
  -e JAR=server.jar \
  minecraft-server
```

## Proxy Type Examples

### BungeeCord Proxy

```bash
docker run -d \
  -p 25565:25565/tcp \
  -v /path/to/your/proxy/data:/data \
  -e SERVER_VERSION=latest \
  -e MC_RAM_XMS=512M \
  -e MC_RAM_XMX=1024M \
  -e SERVER_TYPE=bungeecord \
  minecraft-server
```

### Velocity Proxy

```bash
docker run -d \
  -p 25565:25565/tcp \
  -v /path/to/your/proxy/data:/data \
  -e SERVER_VERSION=latest \
  -e MC_RAM_XMS=512M \
  -e MC_RAM_XMX=1024M \
  -e SERVER_TYPE=velocity \
  minecraft-server
```

### Waterfall Proxy

```bash
docker run -d \
  -p 25565:25565/tcp \
  -v /path/to/your/proxy/data:/data \
  -e SERVER_VERSION=latest \
  -e MC_RAM_XMS=512M \
  -e MC_RAM_XMX=1024M \
  -e SERVER_TYPE=waterfall \
  minecraft-server
```

## Port Mapping

- **25565/tcp** - Default Minecraft server/proxy port
- **8100/tcp** - Used for additional services (varies by server type)
- **8080/tcp** - Web interface port (if applicable)

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues](#) or open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Feel free to modify this README to better suit your project's needs. Enjoy running your Minecraft server or proxy in Docker!
