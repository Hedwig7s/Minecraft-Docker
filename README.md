Lazily combined version of my docker images using ChatGPT
ChatGPT Readme:

# Minecraft Server Docker Container

This repository provides a Docker container for running a Minecraft server using a unified startup script that supports various server types (e.g., FabricMC, PurpurMC, SpongeVanilla, NeoForge, or a generic jar-based server). The container is based on the Ubuntu‑based `eclipse-temurin:21-jre` image.

## Features

- **Multiple Server Types:**  
  Configure your server type by setting the `SERVER_TYPE` environment variable.  
  Supported values: `fabric`, `purpur`, `sponge`, `neoforge`, and `simple`.

- **Unified Startup Script:**  
  A single bash script (`main.sh`) handles server initialization, file downloads, configuration, and server launch.

- **Default Environment Variables:**  
  Set default server settings (Minecraft version, RAM allocation, EULA acceptance, etc.) using environment variables.

- **Volume Support:**  
  The `/data` directory is declared as a volume for persistent server data.

## Environment Variables

Below are the default environment variables that can be overridden at runtime:

| Variable                  | Default Value  | Description |
| ------------------------- | -------------- | ----------- |
| `MC_VERSION`              | `1.20.1`       | Minecraft server version. |
| `MC_EULA`                 | `true`         | Accept Minecraft's EULA (`true` or `false`). |
| `MC_RAM_XMS`              | `1536M`        | Preallocated RAM for the server. |
| `MC_RAM_XMX`              | `2048M`        | Maximum RAM for the server. |
| `MC_PRE_JAR_ARGS`         | `""`           | Additional arguments to prepend before the jar in the launch command. |
| `MC_POST_JAR_ARGS`        | `""`           | Additional arguments to append after the jar in the launch command. |
| `MC_URL_ZIP_SERVER_FIILES`| `""`           | URL to a ZIP file with extra server files. |
| `FORCE_INSTALL`           | `""`           | Force the installation of a server jar/installer if set. |
| `FABRIC_INSTALLVER`       | `1.0.1`        | Fabric installer version (used in FabricMC mode). |
| `FABRIC_VERSION`          | `""`           | Fabric loader version. |
| `SPONGE_TYPE`             | `spongevanilla`| Sponge server type (for SpongeVanilla mode). |
| `SPONGE_VERSION`          | `13.0.0`       | Sponge server version. |
| `NEOFORGE_VERSION`        | `20.4.190`     | NeoForge server version. |
| `JAR`                     | `""`           | Name of the jar file to use in simple mode. |
| `SERVER_TYPE`             | `fabric`       | Server type to run: `fabric`, `purpur`, `sponge`, `neoforge`, or `simple`. |

## Dockerfile Overview

The Dockerfile uses the `eclipse-temurin:21-jre` image, exposes the necessary ports, installs required packages (like `unar`, `findutils`, and `curl`), and sets up a non-root `minecraft` user. The startup command executes the unified `main.sh` script.

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
  -e MC_VERSION=1.20.1 \
  -e MC_EULA=true \
  -e MC_RAM_XMS=1536M \
  -e MC_RAM_XMX=2048M \
  -e SERVER_TYPE=fabric \
  minecraft-server
```

Adjust the environment variables and volume mapping as necessary.

### Using Other Server Types

To switch the server type, simply set the `SERVER_TYPE` variable. For example, to run a PurpurMC server:

```bash
docker run -d \
  -p 25565:25565/tcp \
  -p 8100:8100/tcp \
  -v /path/to/your/server/data:/data \
  -e MC_VERSION=1.20.1 \
  -e SERVER_TYPE=purpur \
  minecraft-server
```

For a simple jar-based server, ensure you set the `JAR` variable to the name of your server jar file:

```bash
docker run -d \
  -p 25565:25565/tcp \
  -p 8100:8100/tcp \
  -v /path/to/your/server/data:/data \
  -e SERVER_TYPE=simple \
  -e JAR=server.jar \
  minecraft-server
```

## Script Overview

The `main.sh` script inside the container:

1. **Initializes Environment Variables:** Uses defaults or provided values.
2. **Performs Server-Specific Setup:** Downloads and installs necessary files based on the `SERVER_TYPE`.
3. **Handles Additional Files:** Downloads and extracts extra server files if `MC_URL_ZIP_SERVER_FIILES` is provided.
4. **EULA Setup:** Automatically accepts the EULA if `MC_EULA` is set to `true`.
5. **Launches the Server:** Executes the server using `java` with the specified JVM and jar arguments.

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues](#) or open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Feel free to modify this README to better suit your project's needs. Enjoy running your Minecraft server in Docker!
