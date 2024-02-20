# CRaC Demo

## How this project was set up

1. Create a new Spring Boot 3.2.2 WebMVC project.
2. Add `org.crac:crac` dependency.
3. Add a simple REST controller.

## Build image

Build application:

    ./mvnw clean verify

Build application image:

    docker build --file Dockerfile-checkpoint-image --tag crac-demo:checkpoint .

## Create checkpoint

Create a fresh directory for the CRaC checkpoint files:

    mkdir -p crac-files

Start container for checkpoint:

    docker run \
        --cap-add=CHECKPOINT_RESTORE \
        --cap-add=SYS_PTRACE \
        --rm \
        --name crac-demo-checkpoint \
        --publish 8080:8080 \
        --volume $PWD/crac-files:/crac-files \
        crac-demo:checkpoint \
        java -XX:CRaCCheckpointTo=/crac-files -jar /app/crac-demo.jar

Optionally interact with the application at http://localhost:8080/hello to warm it up.

Trigger a checkpoint:

    docker exec crac-demo-checkpoint jcmd /app/crac-demo.jar JDK.checkpoint

The application and its container will be stopped, and you should see the checkpoint files in `crac-files`.

Create a restore image:

    docker build --file Dockerfile-restore-image --tag crac-demo:restore .

You can remove the local `crac-files` now:

    rm -rf crac-files

## Restore from checkpoint

Start a new container that restores the application from the checkpoint:

    docker run \
        --cap-add=SYS_RESOURCE \
        --rm \
        --name crac-demo \
        --publish 8080:8080 \
        crac-demo:restore \
        java -XX:CRaCRestoreFrom=/crac-files

This should start up really quickly. 🚀