#!/usr/bin/env bash
# Unified Minecraft Server Starter Script
#
# Supported server types:
#   fabric    - FabricMC server
#   purpur    - PurpurMC server
#   leaf      - LeafMC server
#   sponge    - SpongeVanilla server
#   neoforge  - NeoForge server
#   simple    - Generic jar server (set JAR variable)
#
# Set SERVER_TYPE to choose the server:
#   export SERVER_TYPE=fabric

##############################
# Global Configurations
##############################

# Directory settings
MCDIR="/data"
MCTEMP="/server_tmp"

# Which server to run (fabric, purpur, leaf, sponge, neoforge, simple)
: "${SERVER_TYPE:=fabric}"

##############################
# Helper Function
##############################
function GetFile {
    # Downloads a file given URL ($1) to destination ($2)
    [ -n "$1" ] && curl -s -C - -o "$2" "$1" || return 1
    if [ $? -eq 0 ]; then
        echo "Downloaded $1"
        return 0
    else
        echo "Could not get $1"
        return 1
    fi
}

##############################
# Server-Type Specific Setup
##############################
cd "$MCDIR" || exit 1

case "$SERVER_TYPE" in
    fabric)
        echo "###############################################"
        echo "#   FabricMC - $(date)   #"
        echo "###############################################"
        echo "Initializing FabricMC server..."
        # Fabric-specific defaults
        : "${FABRIC_INSTALLVER:=1.0.1}"
        : "${FABRIC_VERSION:=}"
        MCJAR="$MCDIR/fabric-server-launch.jar"
        # JVM arguments common to all variants plus Fabric-specific jar and args
        MCARGS="-Xms${MC_RAM_XMS} -Xmx${MC_RAM_XMX} --add-modules=jdk.incubator.vector \
-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
-XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 \
-XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
-XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs \
-Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \
-XX:G1ReservePercent=20 ${MC_PRE_JAR_ARGS} -jar ${MCJAR} ${MC_POST_JAR_ARGS} --nogui"

        if [[ ! -e "$MCJAR" || -n "$FORCE_INSTALL" ]]; then
            echo "Downloading and installing Fabric..."
            GetFile "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLVER}/fabric-installer-${FABRIC_INSTALLVER}.jar" "$MCDIR/fabric-installer.jar"
            java -jar "$MCDIR/fabric-installer.jar" server ${MC_VERSION:+-mcversion "$MC_VERSION"} -dir "$MCDIR" -downloadMinecraft ${FABRIC_VERSION:+-loader "$FABRIC_VERSION"}
            [ $? -eq 0 ] && rm "$MCDIR/fabric-installer.jar"
        fi
        ;;
    purpur)
        echo "###############################################"
        echo "#   PurpurMC - $(date)   #"
        echo "###############################################"
        echo "Initializing PurpurMC server..."
        MCJAR="$MCDIR/purpur_${MC_VERSION}.jar"
        MCARGS="-Xms${MC_RAM_XMS} -Xmx${MC_RAM_XMX} --add-modules=jdk.incubator.vector \
-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
-XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 \
-XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
-XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs \
-Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \
-XX:G1ReservePercent=20 ${MC_PRE_JAR_ARGS} -jar ${MCJAR} ${MC_POST_JAR_ARGS} --nogui"

        if [ ! -e "$MCJAR" ]; then
            echo "Downloading Purpur jar..."
            GetFile "https://api.purpurmc.org/v2/purpur/${MC_VERSION}/latest/download" "$MCJAR"
        fi
        # Remove other jar files in the folder
        find "$MCDIR" -maxdepth 1 -type f -name "*.jar" ! -wholename "$MCJAR" -exec rm {} +
        ;;
    leaf)
        echo "###############################################"
        echo "#   LeafMC - $(date)   #"
        echo "###############################################"
        echo "Initializing LeafMC server..."
        MCJAR="$MCDIR/leafmc_${MC_VERSION}.jar"
        MCARGS="-Xms${MC_RAM_XMS} -Xmx${MC_RAM_XMX} --add-modules=jdk.incubator.vector \
-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
-XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 \
-XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
-XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs \
-Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \
-XX:G1ReservePercent=20 ${MC_PRE_JAR_ARGS} -jar ${MCJAR} ${MC_POST_JAR_ARGS} --nogui"

        if [ ! -e "$MCJAR" ]; then
            echo "Downloading LeafMC jar..."
            GetFile "https://api.leafmc.one/v2/projects/leaf/versions/$MC_VERSION/builds/$LEAF_VERSION/downloads/leaf-$MC_VERSION-$LEAF_VERSION.jar" "$MCJAR"
        fi
        # Remove other jar files in the folder
        find "$MCDIR" -maxdepth 1 -type f -name "*.jar" ! -wholename "$MCJAR" -exec rm {} +
        ;;
    sponge)
        echo "###############################################"
        echo "#   SpongeVanilla - $(date)   #"
        echo "###############################################"
        echo "Initializing Sponge server..."
        # Sponge-specific defaults
        : "${SPONGE_TYPE:=spongevanilla}"
        : "${SPONGE_VERSION:=13.0.0}"
        MCJAR="$MCDIR/${SPONGE_TYPE}-${MC_VERSION}-${SPONGE_VERSION}-universal.jar"
        MCARGS="-Xms${MC_RAM_XMS} -Xmx${MC_RAM_XMX} --add-modules=jdk.incubator.vector \
-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
-XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 \
-XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
-XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs \
-Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \
-XX:G1ReservePercent=20 ${MC_PRE_JAR_ARGS} -jar ${MCJAR} ${MC_POST_JAR_ARGS} --nogui"

        if [[ ! -e "$MCJAR" || -n "$FORCE_INSTALL" ]]; then
            echo "Downloading and installing Sponge..."
            GetFile "https://repo.spongepowered.org/repository/maven-releases/org/spongepowered/${SPONGE_TYPE}/${MC_VERSION}-${SPONGE_VERSION}/${SPONGE_TYPE}-${MC_VERSION}-${SPONGE_VERSION}-universal.jar" "$MCJAR"
        fi
        # Clean up any other jar files
        find "$MCDIR" -maxdepth 1 -type f -name "*.jar" ! -wholename "$MCJAR" -exec rm {} +
        ;;
    neoforge)
        echo "###############################################"
        echo "#   NeoForge - $(date)   #"
        echo "###############################################"
        echo "Initializing NeoForge server..."
        : "${NEOFORGE_VERSION:=20.4.190}"
        INSTALLER_JAR="neoforge-${NEOFORGE_VERSION}-installer.jar"
        JVM_ARGS="-Xms${MC_RAM_XMS} -Xmx${MC_RAM_XMX} --add-modules=jdk.incubator.vector \
-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch \
-XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 \
-XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 \
-XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs \
-Daikars.new.flags=true -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M \
-XX:G1ReservePercent=20 ${MC_PRE_JAR_ARGS}"
        # NeoForge uses its own run.sh so MCJAR is not used directly here.
        if [[ ! -e "$MCDIR/run.sh" || "$INSTALLER_JAR" != "$(find . -name "neoforge-*-installer.jar" -printf "%f\n" 2>/dev/null | sort -V | tail -n 1)" || -n "$FORCE_INSTALL" ]]; then
            echo "Downloading and installing NeoForge..."
            rm -f "$MCDIR"/neoforge-*-installer.jar
            GetFile "https://maven.neoforged.net/releases/net/neoforged/neoforge/${NEOFORGE_VERSION}/${INSTALLER_JAR}" "$MCDIR/${INSTALLER_JAR}"
            java -jar "$MCDIR/${INSTALLER_JAR}" --installServer
            if [ $? -ne 0 ]; then
                echo "NeoForge installation failed!"
                exit 1
            fi
        fi
        # Write JVM args to file
        echo "$JVM_ARGS" > "$MCDIR/user_jvm_args.txt"
        ;;
    simple)
        echo "###############################################"
        echo "#   Simple Server Starter - $(date)   #"
        echo "###############################################"
        echo "Initializing simple server..."
        # For a simple server the jar file must be specified in the variable JAR.
        if [ -z "$JAR" ]; then
            echo "Error: For simple server mode, please set the JAR variable (e.g. export JAR=server.jar)"
            exit 1
        fi
        MCJAR="$MCDIR/$JAR"
        MCARGS="-Xms${MC_RAM_XMS} -Xmx${MC_RAM_XMX} ${MC_PRE_JAR_ARGS} -jar ${MCJAR} ${MC_POST_JAR_ARGS} --nogui"
        ;;
    *)
        echo "Unknown server type: $SERVER_TYPE"
        exit 1
        ;;
esac

##############################
# Common Post-Setup Steps
##############################
# If a ZIP URL is provided, download and extract additional server files
if GetFile "$MC_URL_ZIP_SERVER_FIILES" "$MCDIR/ZIP_SERVER_FILES"; then
    unar "$MCDIR/ZIP_SERVER_FILES" -f
fi

# Accept the EULA if requested
if [ "$MC_EULA" == "true" ]; then
    echo "Setting EULA to true"
    printf "eula=true" > "$MCDIR/eula.txt"
fi

# Display configuration info
echo "###############################################"
echo " MC_VERSION: $MC_VERSION"
echo " MC_EULA: $MC_EULA"
echo " MC_RAM_XMS: $MC_RAM_XMS"
echo " MC_RAM_XMX: $MC_RAM_XMX"
echo " MC_PRE_JAR_ARGS: $MC_PRE_JAR_ARGS"
echo " MC_POST_JAR_ARGS: $MC_POST_JAR_ARGS"
echo " MC_URL_ZIP_SERVER_FIILES: $MC_URL_ZIP_SERVER_FIILES"
echo "###############################################"
echo "Start command: java $MCARGS"
echo "Starting Server..."
echo

##############################
# Launch the Server
##############################
# For NeoForge, use its run.sh; for all others, execute java with our arguments.
if [ "$SERVER_TYPE" == "neoforge" ]; then
    dos2unix "$MCDIR/run.sh"
    chmod +x "$MCDIR/run.sh"
    exec "$MCDIR/run.sh" ${MC_POST_JAR_ARGS} --nogui
else
    exec java $MCARGS
fi
