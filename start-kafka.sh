# Ref: https://github.com/Landoop/fast-data-dev
# Start UI at: http://localhost:3030/
# Default ports
# 9092 : Kafka Broker                   9581 : JMX
# 8081 : Schema Registry                9582 : JMX
# 8082 : Kafka REST Proxy               9583 : JMX
# 8083 : Kafka Connect Distributed      9584 : JMX
# 2181 : ZooKeeper                      9585 : JMX
# 3030 : Web Server
#
# Example (requires java): jconsole localhost:9581

docker run \
 --rm \
 --name kafka
 --net=host \
 -e ADV_HOST=127.0.0.1 \
 -e RUNTESTS=0 \
 -v $PWD/connect/kafka-connect-dynamodb/target/kafka-connect-dynamodb-0.3.0-SNAPSHOT-standalone.jar:/connectors/dynamodb.jar \
 landoop/fast-data-dev
