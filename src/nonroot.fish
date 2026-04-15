#!/usr/bin/env fish

# ==============================
# Configuration & Flags
# ==============================
set -q SERVER_TYPE; or set SERVER_TYPE fabric
set -q MCDIR; or set MCDIR "."
# Define a temporary file to capture the path from mc-helper
set PATH_TEMP_FILE (mktemp)

# ==============================
# JVM Arguments
# ==============================
set JVM_COMMON "-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
-XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 \
-XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
-XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
-XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 \
-XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20"

# ==============================
# Installation Logic
# ==============================
switch $SERVER_TYPE
    case fabric
        echo "Initializing Fabric..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-fabric --minecraft-version $MC_VERSION --loader-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE; or exit 1
    case paper purpur
        echo "Initializing $SERVER_TYPE..."
        mc-helper install-$SERVER_TYPE --version (set -q MC_VERSION; and echo $MC_VERSION; or echo latest) --build 0 --output $MCDIR --write-path-to $PATH_TEMP_FILE; or exit 1
    case forge
        echo "Initializing Forge..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-forge --minecraft-version $MC_VERSION --forge-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE; or exit 1
    case neoforge
        echo "Initializing NeoForge..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-neoforge --minecraft-version $MC_VERSION --neoforge-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE; or exit 1
    case quilt
        echo "Initializing Quilt..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-quilt --minecraft-version $MC_VERSION --loader-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE; or exit 1
    case simple
        set -q JAR; or begin; echo "JAR variable required"; exit 1; end
        echo $JAR > $PATH_TEMP_FILE
    case bungeecord
        echo "Initializing BungeeCord..."
        mc-helper install-bungeecord --version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE; or exit 1
    case velocity
        echo "Initializing Velocity..."
        mc-helper install-velocity --version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE; or exit 1
    case waterfall
        echo "Initializing Waterfall..."
        mc-helper install-waterfall --version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE; or exit 1
    case '*'
        echo "Unknown SERVER_TYPE: $SERVER_TYPE"; exit 1
end

# ==============================
# Path Retrieval & Cleanup
# ==============================
if test -f "$PATH_TEMP_FILE"
    set MC_START_PATH (cat $PATH_TEMP_FILE)
    rm $PATH_TEMP_FILE # Clean up the temp file
end

# Final validation
if test -z "$MC_START_PATH"; or not test -f "$MC_START_PATH"
    echo "Error: MC_START_PATH was not written or file does not exist."
    exit 1
end

# ==============================
# Final Checks & Execution
# ==============================
if test "$MC_EULA" = "true"
    echo "eula=true" > eula.txt
else
    echo "Warning: MC_EULA not set to true."
end

set -q MC_RAM_XMS; or set MC_RAM_XMS 2G
set -q MC_RAM_XMX; or set MC_RAM_XMX 2G
set JAVA_OPTS "-Xms$MC_RAM_XMS -Xmx$MC_RAM_XMX $JVM_COMMON $MC_PRE_JAR_ARG"

echo "Starting server via: $MC_START_PATH"

# Execute based on file type
if string match -q "*.sh" "$MC_START_PATH"
    # Execute Forge/NeoForge run scripts
    exec bash "$MC_START_PATH" $MC_POST_JAR_ARGS
else
    # Standard JAR execution
    exec sh -c "java $JAVA_OPTS -jar $MC_START_PATH $MC_POST_JAR_ARGS --nogui"
end
