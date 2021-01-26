mvn clean compile exec:java -Dexec.mainClass=com.google.bqavro.App
java -jar avro-tools-1.10.1.jar tojson -pretty users.avro