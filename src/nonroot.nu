#!/usr/bin/env nu

# ==============================
# Config & Flags
# ==============================
let SERVER_TYPE = ($env.SERVER_TYPE? | default "fabric")
let MCDIR = ($env.MCDIR? | default ".")
let INSTALL_NEOFORGE_BETA = ($env.INSTALL_NEOFORGE_BETA? | default "false" | str lowercase)
let PATH_TEMP_FILE = (mktemp)

if $INSTALL_NEOFORGE_BETA != "false" and $INSTALL_NEOFORGE_BETA != "true" {
    print $"Invalid INSTALL_NEOFORGE_BETA: ($INSTALL_NEOFORGE_BETA)"
    exit 1
}

# ==============================
# JVM Args
# ==============================
let JVM_COMMON = "--add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=28 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1MixedGCCountTarget=3 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:SurvivorRatio=32 -XX:G1HeapWastePercent=5 -XX:MaxTenuringThreshold=1 -XX:+PerfDisableSharedMem -XX:G1SATBBufferEnqueueingThresholdPercent=30 -XX:G1ConcMarkStepDurationMillis=5 -XX:G1RSetUpdatingPauseTimePercent=0 -XX:+UseNUMA -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:NmethodSweepActivity=1 -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:AllocatePrefetchStyle=3 -XX:+AlwaysActAsServerClassMachine -XX:+UseTransparentHugePages -XX:LargePageSizeInBytes=2M -XX:+UseLargePages -XX:+EagerJVMCI -XX:+UseStringDeduplication -XX:+UseAES -XX:+UseAESIntrinsics -XX:+UseFMA -XX:+UseLoopPredicate -XX:+RangeCheckElimination -XX:+OptimizeStringConcat -XX:+UseCompressedOops -XX:+UseThreadPriorities -XX:+OmitStackTraceInFastThrow -XX:+RewriteBytecodes -XX:+RewriteFrequentPairs -XX:+UseFPUForSpilling -XX:+UseFastStosb -XX:+UseNewLongLShift -XX:+UseVectorCmov -XX:+UseXMMForArrayCopy -XX:+UseXmmI2D -XX:+UseXmmI2F -XX:+UseXmmLoadAndClearUpper -XX:+UseXmmRegToRegMoveAll -XX:+EliminateLocks -XX:+DoEscapeAnalysis -XX:+AlignVector -XX:+OptimizeFill -XX:+EnableVectorSupport -XX:+UseCharacterCompareIntrinsics -XX:+UseCopySignIntrinsic -XX:+UseVectorStubs -XX:UseAVX=2 -XX:UseSSE=4 -XX:+UseFastJNIAccessors -XX:+UseInlineCaches -XX:+SegmentedCodeCache -Djdk.nio.maxCachedBufferSize=262144 -Djdk.graal.UsePriorityInlining=true -Djdk.graal.Vectorization=true -Djdk.graal.OptDuplication=true -Djdk.graal.DetectInvertedLoopsAsCounted=true -Djdk.graal.LoopInversion=true -Djdk.graal.VectorizeHashes=true -Djdk.graal.EnterprisePartialUnroll=true -Djdk.graal.VectorizeSIMD=true -Djdk.graal.StripMineNonCountedLoops=true -Djdk.graal.SpeculativeGuardMovement=true -Djdk.graal.TuneInlinerExploration=1 -Djdk.graal.LoopRotation=true -Djdk.graal.CompilerConfiguration=enterprise"

# ==============================
# Install Logic
# ==============================
mut INSTALL_STATUS = 0
mut SHOULD_RUN_INSTALLER = 0
let MC_VERSION = ($env.MC_VERSION? | default "")
let SERVER_VERSION = ($env.SERVER_VERSION? | default "")

match $SERVER_TYPE {
    "fabric" => {
        print "Initializing Fabric..."
        if $MC_VERSION == "" { print "MC_VERSION required"; exit 1 }
        let r = (do { ^mc-helper install-fabric --minecraft-version $MC_VERSION --loader-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE } | complete)
        $INSTALL_STATUS = $r.exit_code
    }
    "paper" | "purpur" | "folia" => {
        print $"Initializing ($SERVER_TYPE)..."
        let ver = if $MC_VERSION != "" { $MC_VERSION } else { "latest" }
        let r = (do { ^mc-helper $"install-($SERVER_TYPE)" --version $ver --build 0 --output $MCDIR --write-path-to $PATH_TEMP_FILE } | complete)
        $INSTALL_STATUS = $r.exit_code
    }
    "forge" => {
        print "Initializing Forge..."
        if $MC_VERSION == "" { print "MC_VERSION required"; exit 1 }
        let r = (do { ^mc-helper install-forge --minecraft-version $MC_VERSION --forge-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE } | complete)
        $INSTALL_STATUS = $r.exit_code
    }
    "neoforge" => {
        print "Initializing NeoForge..."
        if $MC_VERSION == "" { print "MC_VERSION required"; exit 1 }
        let r = (do { ^mc-helper install-neoforge $"--install-beta=($INSTALL_NEOFORGE_BETA)" --minecraft-version $MC_VERSION --neoforge-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE } | complete)
        $INSTALL_STATUS = $r.exit_code
    }
    "quilt" => {
        print "Initializing Quilt..."
        if $MC_VERSION == "" { print "MC_VERSION required"; exit 1 }
        let r = (do { ^mc-helper install-quilt --minecraft-version $MC_VERSION --loader-version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE } | complete)
        $INSTALL_STATUS = $r.exit_code
    }
    "simple" => {
        let JAR = ($env.JAR? | default "")
        if $JAR == "" { print "JAR variable required"; exit 1 }
        $JAR | save -f $PATH_TEMP_FILE
        $INSTALL_STATUS = 0
    }
    "bungeecord" => {
        print "Initializing BungeeCord..."
        let r = (do { ^mc-helper install-bungeecord --version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE } | complete)
        $INSTALL_STATUS = $r.exit_code
    }
    "velocity" => {
        print "Initializing Velocity..."
        let r = (do { ^mc-helper install-velocity --version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE } | complete)
        $INSTALL_STATUS = $r.exit_code
    }
    "waterfall" => {
        print "Initializing Waterfall..."
        let r = (do { ^mc-helper install-waterfall --version $SERVER_VERSION --output $MCDIR --write-path-to $PATH_TEMP_FILE } | complete)
        $INSTALL_STATUS = $r.exit_code
    }
    _ => {
        print $"Unknown SERVER_TYPE: ($SERVER_TYPE)"
        exit 1
    }
}

# ==============================
# Handle mc-helper Exit Codes
# ==============================
if $INSTALL_STATUS == 1 {
    print "Error: mc-helper failed with exit code 1"
    exit 1
} else if $INSTALL_STATUS == 0 {
    print "Info: Download completed successfully (exit code 0)"
    if $SERVER_TYPE == "forge" or $SERVER_TYPE == "neoforge" {
        $SHOULD_RUN_INSTALLER = 1
    }
} else if $INSTALL_STATUS == 2 {
    print "Info: Jar is already up to date (exit code 2) - skipping installer"
    $SHOULD_RUN_INSTALLER = 0
} else {
    print $"Error: mc-helper failed with unexpected exit code ($INSTALL_STATUS)"
    exit 1
}

# ==============================
# Path Retrieval & Cleanup
# ==============================
$env.MC_START_PATH = ""
if ($PATH_TEMP_FILE | path exists) {
    $env.MC_START_PATH = (open $PATH_TEMP_FILE | str trim)
    rm $PATH_TEMP_FILE
}

if $env.MC_START_PATH == "" or not ($env.MC_START_PATH | path exists) {
    print "Error: MC_START_PATH was not written or file does not exist."
    exit 1
}

# ==============================
# Installer for Forge/NeoForge
# ==============================
if $SERVER_TYPE == "forge" or $SERVER_TYPE == "neoforge" {
    if ($env.MC_START_PATH | str contains "installer") and ($env.MC_START_PATH | str ends-with ".jar") {
        mut NEED_INSTALL = 0

        if $SHOULD_RUN_INSTALLER == 1 {
            print $"Running ($SERVER_TYPE) installer \(fresh download\): ($env.MC_START_PATH)"
            $NEED_INSTALL = 1
        } else {
            if not ($"($MCDIR)/run.sh" | path exists) {
                print "Jar already up to date, but run.sh not found - attempting install..."
                $NEED_INSTALL = 1
            }
        }

        if $NEED_INSTALL == 1 {
            let r = (do { ^java -jar $env.MC_START_PATH --install-server $MCDIR } | complete)
            if $r.exit_code != 0 {
                print $"Error: ($SERVER_TYPE) installer failed"
                exit 1
            }
            print "Installer completed successfully"
        }

        if ($"($MCDIR)/run.sh" | path exists) {
            $env.MC_START_PATH = $"($MCDIR)/run.sh"
            print $"Server path set to: ($env.MC_START_PATH)"
        } else {
            print "Warning: run.sh not found after installation, searching for server jar..."
            let jar_file = (ls $"($MCDIR)/*.jar" | where name !~ "installer" | get name | first)
            if $jar_file != null {
                $env.MC_START_PATH = $jar_file
                print $"Using server jar: ($env.MC_START_PATH)"
            } else {
                print "Error: No server jar or run script found"
                exit 1
            }
        }
    }
}

# ==============================
# Final Checks & Execution
# ==============================
if ($env.MC_EULA? | default "") == "true" {
    "eula=true" | save -f eula.txt
} else {
    print "Warning: MC_EULA not set to true."
}

let MC_RAM_XMS = ($env.MC_RAM_XMS? | default "2G")
let MC_RAM_XMX = ($env.MC_RAM_XMX? | default "2G")
let MC_PRE_JAR_ARG = ($env.MC_PRE_JAR_ARG? | default "")
let MC_POST_JAR_ARGS = ($env.MC_POST_JAR_ARGS? | default "")
let JAVA_OPTS = $"-Xms($MC_RAM_XMS) -Xmx($MC_RAM_XMX) ($JVM_COMMON) ($MC_PRE_JAR_ARG)"

print $"Starting server via: ($env.MC_START_PATH)"

if ($env.MC_START_PATH | str ends-with ".sh") {
    ^bash $env.MC_START_PATH ...(($MC_POST_JAR_ARGS | split row " "))
} else {
    if $SERVER_TYPE in ["bungeecord" "velocity" "waterfall" "nanolimbo"] {
        ^sh -c $"java ($JAVA_OPTS) -jar ($env.MC_START_PATH) ($MC_POST_JAR_ARGS)"
    } else {
        ^sh -c $"java ($JAVA_OPTS) -jar ($env.MC_START_PATH) ($MC_POST_JAR_ARGS) --nogui"
    }
}
