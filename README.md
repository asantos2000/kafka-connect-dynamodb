# Using Kafka connect to sink to AWS DynamoDB

## Building the connector
Ref: <https://github.com/shikhar/kafka-connect-dynamodb>

Run `build-dyno-connect.sh`
> Requires Java8

or

```bash
git clone https://github.com/shikhar/kafka-connect-dynamodb.git kafka-connect-dynamodb

cd $PWD/kafka-connect-dynamodb

# Standalone
mvn -P standalone clean package
```

## Creating the dynamodb table
Go to [dynamoDB console](https://console.aws.amazon.com/dynamodb) and create `alunos` table.

## Starting kafka cluster for development
Ref: <https://github.com/Landoop/fast-data-dev>

```bash
start-kafka.sh
``` 
Follow start up progress through UI <http://localhost:3030/>

![landoop kafka ui](images/kafka-ui.png)

The default ports are:

* `9092` : Kafka Broker (9581 : JMX)
* `8081` : Schema Registry (9582 : JMX)
* `8082` : Kafka REST Proxy (9583 : JMX)
* `8083` : Kafka Connect Distributed (9584 : JMX)
* `2181` : ZooKeeper (9585 : JMX)
* `3030` : Web Server

An example of access the JMX console (java required): 

`jconsole localhost:9581`

![jsonsole broker ui](images/jconsole-ui.png)

or run docker directly

```bash
docker run \
 --rm \
 --name kafka \
 -p 2181:2181 \
 -p 3030:3030 \
 -p 8081-8083:8081-8083 \
 -p 9581-9585:9581-9585 \
 -p 9092:9092 \
 -e ADV_HOST=127.0.0.1 \
 -e RUNTESTS=0 \
 -v $PWD/kafka-connect-dynamodb/target/kafka-connect-dynamodb-0.3.0-SNAPSHOT-standalone.jar:/connectors/dynamodb.jar \
 -v $PWD/myfiles:/myfiles \
 -v $PWD/myfiles/data:/data \
 landoop/fast-data-dev
```
After a minute or so, kafka is ready.

## Configuring the connector

Open the UI, and choose [Connectors](http://localhost:3030/kafka-connect-ui)

![landoop connector ui](images/connector-ui.png)

Hit the [New](http://localhost:3030/kafka-connect-ui/#/cluster/fast-data-dev/select-connector) button and copy and paste the following configuration:

Edit your AWS credentials.

```ini
name=DynamoDbSinkConnector
connector.class=dynamok.sink.DynamoDbSinkConnector
topics=aluno
tasks.max=1
region=us-east-1
access.key.id=[your key with permission to put on dynamodb]
secret.key=[your secret key]]
ignore.record.key=true
```
> `connect-dynamo-config.ini` file

Hit [Create] if there are no red error messages.

Or use curl (or postman) to send the configuration:

```bash
curl -X POST \
  http://localhost:3030/api/kafka-connect/connectors \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{
  "name": "DynamoDbSinkConnector",
  "config": {
    "name": "DynamoDbSinkConnector",
    "connector.class": "dynamok.sink.DynamoDbSinkConnector",
    "topics": "alunos",
    "tasks.max": 1,
    "region": "us-east-1",
    "access.key.id": "[your key with permission to put on dynamodb]",
    "secret.key": "[your secret key]]",
    "ignore.record.key": "true"
  }
}'
```

return HTTP status 201 (Created) and body below.

```json
{
    "name": "DynamoDbSinkConnector",
    "config": {
        "name": "DynamoDbSinkConnector",
        "connector.class": "dynamok.sink.DynamoDbSinkConnector",
        "topics": "alunos",
        "tasks.max": "1",
        "region": "us-east-1",
        "access.key.id": "[your key with permission to put on dynamodb]",
        "secret.key": "[your secret key]",
        "ignore.record.key": "true"
    },
    "tasks": [],
    "type": null
}
```

## Producing some messages

Run `shell.sh` or `docker exec -it kafka bash` to get in the container and run:

```bash
# Producer
kafka-avro-console-producer --broker-list localhost:9092 --topic alunos --property value.schema='{"type":"record","name":"aluno","fields":[{"name":"id","type":"string"},{"name":"nome", "type": "string"}]}'

# Copy and paste
{"id":"1","nome":"Anderson"}
{"id":"2","nome":"Stela"}
{"id":"3","nome":"Gabriel"}
{"id":"4","nome":"Margot"}
{"id":"5","nome":"Oliver"}
{"id":"6","nome":"Lune"}
{"id":"7","nome":"Kate"}
{"id":"8","nome":"Any"}
{"id":"9","nome":"Dimitri"}

# Consumer
kafka-avro-console-consumer --bootstrap-server localhost:9092 --topic alunos --from-beginning
```

To send a batch of messages, put those messages in a file and run:

```bash
cd /myfiles

cat messages.txt | kafka-avro-console-producer --broker-list localhost:9092 --topic alunos --property value.schema='{"type":"record","name":"aluno","fields":[{"name":"id","type":"string"},{"name":"nome", "type": "string"}]}'
```

On Kafka UI Topics

![kafka topics ui](images/kafka-topics-ui.png)

Go to Dynamodb table, tab Items to see your records.

> If something goes wrong, check the Connector UI, hit on DynamoDbSinkConnector and TASKS to see the log.

![AWS DynamoDB table](images/dynamodb-table.png)

## Let's talk about topics

After configuring the connector, it'll create the topic listed on topics key at the config. If you need to customize this topic (for instance, to match the number of tasks) use the kafka-topic command before or after configure the connector.

```bash
# Create topic
kafka-topic --zookeeper localhost:2181 --topic alunos --partitions 1 --replication-factor 1
```

Enjoy!!