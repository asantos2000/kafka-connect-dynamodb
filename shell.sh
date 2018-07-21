docker exec -it kafka bash

# Create topic
kafka-topic --zookeeper localhost:2181 --topic alunos --partitions 1 --replication-factor 1

# Producer
kafka-avro-console-producer --broker-list localhost:9092 --topic alunos --property value.schema='{"type":"record","name":"aluno","fields":[{"name":"id","type":"string"},{"name":"nome", "type": "string"}]}'
{"id":"1","nome":"Anderson"}
{"id":"2","nome":"Stela"}
{"id":"3","nome":"Gabriel"}

# Consumer
kafka-avro-console-consumer --bootstrap-server localhost:9092 --topic alunos --from-beginning