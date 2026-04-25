#!/usr/bin/env fish

# ==============================
# Configuration & Flags
# ==============================
set -q SERVER_TYPE; or set SERVER_TYPE fabric
set -q MCDIR; or set MCDIR "."
set -q INSTALL_NEOFORGE_BETA; or set INSTALL_NEOFORGE_BETA "false"
set INSTALL_NEOFORGE_BETA (string lower $INSTALL_NEOFORGE_BETA)
set PATH_TEMP_FILE (mktemp)

if test "$INSTALL_NEOFORGE_BETA" != "false"; and test "$INSTALL_NEOFORGE_BETA" != "true"
    echo "Invalid INSTALL_NEOFORGE_BETA: $INSTALL_NEOFORGE_BETA"
    exit 1
end

# ==============================
# JVM Arguments
# ==============================
set JVM_COMMON "--add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=28 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1MixedGCCountTarget=3 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:SurvivorRatio=32 -XX:G1HeapWastePercent=5 -XX:MaxTenuringThreshold=1 -XX:+PerfDisableSharedMem \
-XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:+UseNUMA -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:NmethodSweepActivity=1 -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:AllocatePrefetchStyle=3 -XX:+AlwaysActAsServerClassMachine \
-XX:UseTransparentHugePages -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -XX:+EagerJVMCI -XX:+UseStringDeduplication -XX:+UseAES -XX:+UseAESIntrinsics -XX:+UseFMA -XX:+UseLoopPredicate -XX:+RangeCheckElimination -XX:+OptimizeStringConcat -XX:+UseCompressedOops -XX:+UseThreadPriorities -XX:+OmitStackTraceInFastThrow -XX:+RewriteBytecodes -XX:+RewriteFrequentPairs -XX:+UseFPUForSpilling -XX:+UseFastStosb -XX:+UseNewLongLShift -XX:+UseVectorCmov -XX:+UseXMMForArrayCopy -XX:+UseXmmI2D -XX:+UseXmmI2F \
-XX:+UseXmmLoadAndClearUpper -XX:+UseXmmRegToRegMoveAll -XX:+EliminateLocks -XX:+DoEscapeAnalysis -XX:+AlignVector -XX:+OptimizeFill -XX:+EnableVectorSupport -XX:+UseCharacterCompareIntrinsics -XX:+UseCopySignIntrinsic -XX:+UseVectorStubs -XX:UseAVX=2 -XX:UseSSE=4 -XX:+UseFastJNIAccessors -XX:+UseInlineCaches -XX:+SegmentedCodeCache -Djdk.nio.maxCachedBufferSize=262144 -Djdk.graal.UsePriorityInlining=true -Djdk.graal.Vectorization=true -Djdk.graal.OptDuplication=true \
-Djdk.graal.DetectInvertedLoopsAsCounted=true -Djdk.graal.LoopInversion=true -Djdk.graal.VectorizeHashes=true -Djdk.graal.EnterprisePartialUnroll=true -Djdk.graal.VectorizeSIMD=true -Djdk.graal.StripMineNonCountedLoops=true -Djdk.graal.SpeculativeGuardMovement=true -Djdk.graal.TuneInlinerExploration=1 -Djdk.graal.LoopRotation=true -Djdk.graal.CompilerConfiguration=enterprise"

# ==============================
# Installation Logic
# ==============================
set INSTALL_STATUS 0
set SHOULD_RUN_INSTALLER 0

switch $SERVER_TYPE
    case fabric
        echo "Initializing Fabric..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-fabric --minecraft-version $MC_VERSION --loader-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE
        set INSTALL_STATUS $status
    case paper purpur folia
        echo "Initializing $SERVER_TYPE..."
        mc-helper install-$SERVER_TYPE --version (set -q MC_VERSION; and echo $MC_VERSION; or echo latest) --build 0 --output $MCDIR --write-path-to $PATH_TEMP_FILE
        set INSTALL_STATUS $status
    case forge
        echo "Initializing Forge..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-forge --minecraft-version $MC_VERSION --forge-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE
        set INSTALL_STATUS $status
    case neoforge
        echo "Initializing NeoForge..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-neoforge --install-beta=$INSTALL_NEOFORGE_BETA --minecraft-version $MC_VERSION --neoforge-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE
        set INSTALL_STATUS $status
    case quilt
        echo "Initializing Quilt..."
        set -q MC_VERSION; or begin; echo "MC_VERSION required"; exit 1; end
        mc-helper install-quilt --minecraft-version $MC_VERSION --loader-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE
        set INSTALL_STATUS $status
    case simple
        set -q JAR; or begin; echo "JAR variable required"; exit 1; end
        echo $JAR > $PATH_TEMP_FILE
        set INSTALL_STATUS 0
    case bungeecord
        echo "Initializing BungeeCord..."
        mc-helper install-bungeecord --version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE
        set INSTALL_STATUS $status
    case velocity
        echo "Initializing Velocity..."
        mc-helper install-velocity --version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE
        set INSTALL_STATUS $status
    case waterfall
        echo "Initializing Waterfall..."
        mc-helper install-waterfall --version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE
        set INSTALL_STATUS $status
    case '*'
        echo "Unknown SERVER_TYPE: $SERVER_TYPE"; exit 1
end

# ==============================
# Handle mc-helper Exit Codes
# ==============================
if test $INSTALL_STATUS -eq 1
    echo "Error: mc-helper failed with exit code 1"
    exit 1
else if test $INSTALL_STATUS -eq 0
    echo "Info: Download completed successfully (exit code 0)"
    # Only run installer for forge/neoforge when there's a fresh download
    if test "$SERVER_TYPE" = "forge" -o "$SERVER_TYPE" = "neoforge"
        set SHOULD_RUN_INSTALLER 1
    end
else if test $INSTALL_STATUS -eq 2
    echo "Info: Jar is already up to date (exit code 2) - skipping installer"
    set SHOULD_RUN_INSTALLER 0
else
    echo "Error: mc-helper failed with unexpected exit code $INSTALL_STATUS"
    exit 1
end

# ==============================
# Path Retrieval & Cleanup
# ==============================
if test -f "$PATH_TEMP_FILE"
    set MC_START_PATH (cat $PATH_TEMP_FILE)
    rm $PATH_TEMP_FILE # Clean up the temp file
end

if test -z "$MC_START_PATH"; or not test -f "$MC_START_PATH"
    echo "Error: MC_START_PATH was not written or file does not exist."
    exit 1
end

# ==============================
# Handle Installer for Forge/NeoForge
# ==============================
if test "$SERVER_TYPE" = "forge" -o "$SERVER_TYPE" = "neoforge"
    if string match -q "*installer*.jar" "$MC_START_PATH"
        # Determine if we need to run the installer
        set NEED_INSTALL 0

        # Run installer on fresh download (exit code 0)
        if test $SHOULD_RUN_INSTALLER -eq 1
            echo "Running $SERVER_TYPE installer (fresh download): $MC_START_PATH"
            set NEED_INSTALL 1
        else
            # Jar already up to date, but check if run.sh exists
            if not test -f "$MCDIR/run.sh"
                echo "Jar already up to date, but run.sh not found - attempting install..."
                set NEED_INSTALL 1
            end
        end

        # Execute installer if needed
        if test $NEED_INSTALL -eq 1
            java -jar "$MC_START_PATH" --install-server "$MCDIR"

            if test $status -ne 0
                echo "Error: $SERVER_TYPE installer failed"
                exit 1
            end

            echo "Installer completed successfully"
        end

        # Update server path to run.sh if it exists
        if test -f "$MCDIR/run.sh"
            set MC_START_PATH "$MCDIR/run.sh"
            echo "Server path set to: $MC_START_PATH"
        else
            echo "Warning: run.sh not found after installation, searching for server jar..."
            set -l jar_file (find "$MCDIR" -maxdepth 1 -name "*.jar" -type f | grep -v installer | head -n 1)
            if test -n "$jar_file"
                set MC_START_PATH "$jar_file"
                echo "Using server jar: $MC_START_PATH"
            else
                echo "Error: No server jar or run script found"
                exit 1
            end
        end
    end
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

if string match -q "*.sh" "$MC_START_PATH"
    # Execute Forge/NeoForge run scripts
    exec bash "$MC_START_PATH" $MC_POST_JAR_ARGS
else
    if test "$SERVER_TYPE" = "bungeecord" -o \
            "$SERVER_TYPE" = "velocity" -o \
            "$SERVER_TYPE" = "waterfall" -o \
            "$SERVER_TYPE" = "nanolimbo"
        exec sh -c "java $JAVA_OPTS -jar $MC_START_PATH $MC_POST_JAR_ARGS"
    else
        exec sh -c "java $JAVA_OPTS -jar $MC_START_PATH $MC_POST_JAR_ARGS --nogui"
    end
end
