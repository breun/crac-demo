# CRaC Demo

## How this project was set up

1. Create a new Spring Boot 3.2.2 WebMVC project.
2. Add `org.crac:crac` dependency.
3. Add a simple REST controller.

## Build image

Build application:

    ./mvnw clean verify 

Build application image:

    docker build -t crac-demo .

## Create checkpoint

Start container for checkpoint:

    docker run -it --cap-add=CHECKPOINT_RESTORE --cap-add=SYS_PTRACE --rm --name crac-checkpoint crac-demo

Start application:

    java -XX:CRaCCheckpointTo=/crac-files -jar /app/crac-demo.jar

Optionally interact with the application to warm it up.

Open another shell:

    docker exec -it crac-checkpoint sh

Trigger a checkpoint:

    jcmd `pidof java` JDK.checkpoint && exit

The application will be stopped, and you should see the checkpoint files in `/crac-files`.

Find the container ID of the container that ran the application:

    docker ps -a

Commit the current state of the container:

    docker commit ${CONTAINER_ID} crac-demo:checkpoint

Exit the application container.

## Restore from checkpoint

Start a new container:

    docker run -it --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --rm --name crac-demo crac-demo:checkpoint java -XX:CRaCRestoreFrom=/crac-files

## CRIU check

You can let CRIU check if all capabilities/privileges are ok using the `criu check` command.

Example with only the `SYS_RESOURCE` capability:

    ❯ docker run -it --cap-add=SYS_RESOURCE --rm --name crac-demo-axle crac-demo-axle:checkpoint /opt/jdk/lib/criu check
    Warn  (criu/tun.c:85): tun: Unable to create tun: No such file or directory
    Warn  (criu/sk-unix.c:224): unix: Unable to open a socket file: Operation not permitted
    Warn  (criu/net.c:3714): Unable create a network namespace: Operation not permitted
    Warn  (criu/net.c:3770): NSID isn't reported for network links
    Warn  (criu/net.c:3430): Unable to get socket network namespace
    Warn  (criu/kerndat.c:1466): CRIU was built without libnftables support
    Warn  (criu/kerndat.c:1009): Fail to mount tmfps to /tmp/.criu.move_mount_set_group.Tm0iCH: Operation not permitted
    Error (criu/cr-check.c:157): sys/kernel/ns_last_pid sysctl is inaccessible: Read-only file system
    Warn  (criu/cr-check.c:1432): Does not look good.

Example with `--privileged`:

    ❯ docker run -it --privileged --rm --name crac-demo crac-demo:checkpoint /opt/jdk/lib/criu check
    Warn  (criu/kerndat.c:1466): CRIU was built without libnftables support
    Looks good.
