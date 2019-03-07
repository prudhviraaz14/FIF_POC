FROM ubuntu:trusty


# Install Java.
RUN \
  apt-get update && \
  apt-get install -y openjdk-6-jdk && \
  apt-get install -y wget && \
  rm -rf /var/lib/apt/lists/*

# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-6-openjdk-amd64

# Installs Ant
ENV ANT_VERSION 1.8.4
RUN cd && \
    wget -q https://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    tar -xzf apache-ant-${ANT_VERSION}-bin.tar.gz && \
    mv apache-ant-${ANT_VERSION} /opt/ant && \
    rm apache-ant-${ANT_VERSION}-bin.tar.gz
ENV ANT_HOME /opt/ant
ENV PATH ${PATH}:/opt/ant/bin
