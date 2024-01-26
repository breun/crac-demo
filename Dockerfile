FROM debian:12-slim

ENV JAVA_HOME /opt/jdk
ENV PATH $JAVA_HOME/bin:$PATH

ADD "https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-crac-jdk21.0.2-linux_aarch64.tar.gz" /tmp/jdk.tar.gz

RUN mkdir -p "${JAVA_HOME}" && \
    mkdir -p /app && \
    mkdir -p /crac-files && \
    tar --extract --file /tmp/jdk.tar.gz --directory "$JAVA_HOME" --strip-components 1 && \
    rm /tmp/jdk.tar.gz

COPY target/crac-demo-0.0.1-SNAPSHOT.jar /app/crac-demo.jar