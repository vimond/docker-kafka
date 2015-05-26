# Builds an image for Apache Kafka 0.7.2 from binary distribution.
#
# Runs on Oracle Java 7 and a base of Ubuntu 14.04, currently.
#
# TODO: This base image needs tags :-P
FROM vimond/vimond-base-java-7
MAINTAINER Olve Hansen <olve@vimond.com> 

RUN mkdir -p /kafka /data /logs

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV KAFKA_RELEASE_ARCHIVE kafka-0.7.2-incubating-src.tgz

# Download Kafka binary distribution
ADD https://archive.apache.org/dist/kafka/old_releases/kafka-0.7.2-incubating/${KAFKA_RELEASE_ARCHIVE} /tmp/
ADD https://archive.apache.org/dist/kafka/old_releases/kafka-0.7.2-incubating/${KAFKA_RELEASE_ARCHIVE}.md5 /tmp/

WORKDIR /tmp

# Check artifact digest integrity
RUN echo VERIFY CHECKSUM: && \
  gpg --print-md MD5 ${KAFKA_RELEASE_ARCHIVE} 2>/dev/null && \
  cat ${KAFKA_RELEASE_ARCHIVE}.md5

# Install Kafka to /kafka
RUN tar -zx -C /kafka --strip-components=1 -f ${KAFKA_RELEASE_ARCHIVE} && \
  rm -rf kafka_*

WORKDIR /kafka  

RUN /kafka/sbt update package  

ADD http://repo1.maven.org/maven2/org/slf4j/slf4j-log4j12/1.7.6/slf4j-log4j12-1.7.6.jar /kafka/libs/
ADD config /kafka/config
ADD start.sh /start.sh

# Set up a user to run Kafka
RUN groupadd kafka && \
  useradd -d /kafka -g kafka -s /bin/false kafka && \
  chown -R kafka:kafka /kafka /data /logs
USER kafka
ENV PATH /kafka/bin:$PATH
WORKDIR /kafka

# primary, jmx
EXPOSE 9092 7203
VOLUME [ "/data", "/logs" ]

CMD ["/start.sh"]

