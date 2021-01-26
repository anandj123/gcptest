package com.google.bqavro;

import example.avro.*;
import org.apache.avro.io.DatumWriter;
import org.apache.avro.file.DataFileWriter;
import org.apache.avro.specific.SpecificDatumWriter;
import java.io.File;
import java.io.IOException;
/**
 * 
 * Build:
 *    mvn clean compile exec:java -Dexec.mainClass=com.google.bqavro.App
 * Read the avro file as json:
 *    java -jar avro-tools-1.10.1.jar tojson -pretty users.avro
 * Download avro-tool from avro website:
 *    https://apache.claz.org/avro/avro-1.10.1/java/
 */
public class App 
{
    public static void main( String[] args )
    {
        
        
        User user1 = new User();
        user1.setName("Anand");
        user1.setFavoriteNumber(256);

        // Leave favorite color null

        // Alternate constructor
        User user2 = new User("Ben", 7, "red");

        // Construct via builder
        User user3 = User.newBuilder()
                    .setName("Charlie")
                    .setFavoriteColor("blue")
                    .setFavoriteNumber(null)
                    .build();

        // Serialize user1, user2 and user3 to disk
        DatumWriter<User> userDatumWriter = new SpecificDatumWriter<User>(User.class);
        DataFileWriter<User> dataFileWriter = new DataFileWriter<User>(userDatumWriter);
        try {
            dataFileWriter.create(user1.getSchema(), new File("users.avro"));
            dataFileWriter.append(user1);
            dataFileWriter.append(user2);
            dataFileWriter.append(user3);
            dataFileWriter.close();
		} catch (IOException e) {
			e.printStackTrace();
        }
        
        System.out.println("Generated avro file with records");
        
    }
}
