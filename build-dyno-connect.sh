#Ref: https://github.com/shikhar/kafka-connect-dynamodb

git clone https://github.com/shikhar/kafka-connect-dynamodb.git kafka-connect-dynamodb

cd $PWD/kafka-connect-dynamodb

# Plugin
mvn clean package

# Standalone
mvn -P standalone clean package