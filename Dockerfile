FROM vimond/vimond-base-java-7

RUN apt-get update && apt-get install -y \
  ca-certificates wget

RUN mkdir /data /logs /kafka

RUN wget --progress=dot:mega -O - http://apache.uib.no/kafka/0.8.2.1/kafka_2.11-0.8.2.1.tgz | tar -zx -C /kafka --strip-components=1

# RUN cd kafka && ./gradlew jar

VOLUME [ "/data", "/logs" ]

# primary, jmx
EXPOSE 9092 7203

ADD http://repo1.maven.org/maven2/org/slf4j/slf4j-log4j12/1.7.6/slf4j-log4j12-1.7.6.jar /kafka/lib/slf4j-log4j12.jar
ADD config /kafka/config
ADD start.sh /start.sh

CMD ["/start.sh"]
