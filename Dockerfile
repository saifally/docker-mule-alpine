FROM java:8-jre-alpine

# Define environment variables.
ENV MULE_HOME /opt/mule
ENV MULE_VERSION 3.8.0
ENV MULE_DOWNLOAD_URL https://repository-master.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz

ENV GLIBC_VERSION=2.23-r3

# Install NTPD for time synchronization.
RUN apk --no-cache add --virtual build-dependencies wget ca-certificates curl && \
    update-ca-certificates && \
# Create the /opt directory in which software in the container is installed.
    mkdir -p /opt && \
    cd /opt && \
# Install Mule ESB.
    wget ${MULE_DOWNLOAD_URL} && \
    tar xvzf mule-standalone-*.tar.gz && \
    rm mule-standalone-*.tar.gz && \
    mv mule-standalone-* mule && \
    rm -rf /tmp/* && \
    apk del --purge build-dependencies

RUN apk upgrade --update && \
    apk add --no-cache --virtual=build-dependencies libstdc++ curl ca-certificates unzip && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib

# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

# Define working directory.
WORKDIR /opt/mule

CMD [ "/opt/mule/bin/mule" ]

# Default http port
EXPOSE 8081
# JMX port.
EXPOSE 1099
