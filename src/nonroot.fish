#!/usr/bin/env fish

# ==============================
# Configuration & Flags
# ==============================
set -q SERVER_TYPE; or set SERVER_TYPE fabric
set -q MCDIR; or set MCDIR "."

# Check for updates before proceeding?
# Set CHECK_UPDATES=true in your environment to enable this automatically
if set -q CHECK_UPDATES; and test "$CHECK_UPDATES" = "true"
    echo "Checking for updates for $SERVER_TYPE..."
    # Map 'simple' to an empty loader check or skip it
    if test "$SERVER_TYPE" != "simple"
        mc-helper check-updates --loader $SERVER_TYPE --server-dir $MCDIR
    end
end

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
        mc-helper install-fabric --auto-update --minecraft-version $MC_VERSION --loader-version (set -q FABRIC_VERSION; and echo $FABRIC_VERSION; or echo latest) --output $MCDIR; or exit 1
        set MCJAR (ls fabric-server-mc*.jar | head -n1)
    case paper purpur
        echo "Initializing $SERVER_TYPE..."
        mc-helper install-$SERVER_TYPE --auto-update --version (set -q MC_VERSION; and echo $MC_VERSION; or echo latest) --build 0 --output $MCDIR; or exit 1
        set MCJAR (ls $SERVER_TYPE-*.jar | head -n1)
    case forge
        echo "Initializing Forge..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-forge --auto-update --minecraft-version $MC_VERSION --forge-version (set -q FORGE_VERSION; and echo $FORGE_VERSION; or echo latest) --output $MCDIR; or exit 1
        set MCJAR (ls forge-*.jar | head -n1)
    case neoforge
        echo "Initializing NeoForge..."
        if not set -q MC_VERSION; or not set -q NEOFORGE_VERSION; echo "MC_VERSION/NEOFORGE_VERSION required"; exit 1; end
        mc-helper install-neoforge --auto-update --minecraft-version $MC_VERSION --neoforge-version $NEOFORGE_VERSION --output $MCDIR; or exit 1
        set MCJAR (ls neoforge-*.jar | head -n1)
    case quilt
        echo "Initializing Quilt..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-quilt --auto-update --minecraft-version $MC_VERSION --loader-version (set -q QUILT_VERSION; and echo $QUILT_VERSION; or echo latest) --output $MCDIR; or exit 1
        set MCJAR (ls quilt-server-*.jar | head -n1)
    case simple
        set -q JAR; or begin; echo "JAR variable required"; exit 1; end
        set MCJAR $JAR
    case '*'
        echo "Unknown SERVER_TYPE: $SERVER_TYPE"; exit 1
end

# ==============================
# Final Checks & Execution
# ==============================
if test -z "$MCJAR"; or not test -f "$MCJAR"
    echo "Error: Server JAR file not found."
    exit 1
end

if test "$MC_EULA" = "true"
    echo "eula=true" > eula.txt
else
    echo "Warning: MC_EULA not set to true."
end

set -q MC_RAM_XMS; or set MC_RAM_XMS 1G
set -q MC_RAM_XMX; or set MC_RAM_XMX 1G
set JAVA_OPTS (string split " " "-Xms$MC_RAM_XMS -Xmx$MC_RAM_XMX $JVM_COMMON $MC_PRE_JAR_ARGS")
set POST_ARGS (string split " " "$MC_POST_JAR_ARGS")

echo "Starting server with: $MCJAR"
exec java $JAVA_OPTS -jar $MCJAR $POST_ARGS --nogui
