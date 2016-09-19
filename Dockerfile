FROM ubuntu
EXPOSE 8080
RUN sed -i.bak 's/deb-src/#deb-src/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install sudo procps wget unzip curl &&\
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user && \
    echo "secret\nsecret" | passwd user && \
    apt-get update && \
    apt-get clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /opt/groovy

USER user

LABEL server:8080:ref=java


ENV JAVA_VERSION=8u102 \
    JAVA_VERSION_PREFIX=1.8.0_102 \
    GROOVY_VERSION=2.4.5.4

ENV JAVA_HOME=/opt/jdk$JAVA_VERSION_PREFIX \
    PATH=$JAVA_HOME/bin:$PATH

RUN wget \
  --no-cookies \
  --no-check-certificate \
  --header "Cookie: oraclelicense=accept-securebackup-cookie" \
  -qO- \
  "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-b14/jdk-$JAVA_VERSION-linux-x64.tar.gz" | sudo tar -zx -C /opt/

RUN sudo wget "--output-document=/opt/groovy/groovy-grape-aether-$GROOVY_VERSION.jar" "https://repo1.maven.org/maven2/com/github/igor-suhorukov/groovy-grape-aether/$GROOVY_VERSION/groovy-grape-aether-$GROOVY_VERSION.jar"


ENV TERM xterm

ENV LANG en_GB.UTF-8
ENV LANG en_US.UTF-8
RUN echo "export JAVA_HOME=/opt/jdk$JAVA_VERSION_PREFIX\nexport PATH=$JAVA_HOME/bin:$PATH" >> /home/user/.bashrc && \
    sudo locale-gen en_US.UTF-8

WORKDIR /projects

RUN echo "export PATH=$JAVA_HOME/bin:$PATH" | sudo tee -a /etc/profile

CMD $JAVA_HOME/bin/java -jar /opt/groovy/groovy-grape-aether-$GROOVY_VERSION.jar $GROOVY_SCRIPT
