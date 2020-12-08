package com.google;


import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.Channels;
import java.nio.channels.WritableByteChannel;

import com.google.cloud.ReadChannel;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import com.google.gson.Gson;

public class App 
{
    private static final int BUFFER_SIZE = 64 * 1024; // 100 MB pull at one time
    public static void main(String args[]){
        // Instantiates a Storage client
        Storage storage = StorageOptions.getDefaultInstance().getService();

        // The name for the GCS bucket
        String bucketName = "anand-bq-test-2";
        // The path of the blob (i.e. GCS object) within the GCS bucket.
        String blobPath = "random100m.txt";
        try{

            //printBlob(storage, bucketName, blobPath);
            pubsubasyncpull p = new pubsubasyncpull();
            p.subscribeAsyncExample("anand-bq-test-2", "mfdemo-sub");
        } catch(Exception ex) {
            ex.printStackTrace();
            System.out.println("Found exception calling pubsub");
        }
    }
         

        // Reads from the specified blob present in the GCS bucket and prints the contents to STDOUT.
    private static void printBlob(Storage storage, String bucketName, String blobPath) throws IOException {
        try (ReadChannel reader = storage.reader(bucketName, blobPath)) {
            WritableByteChannel outChannel = Channels.newChannel(System.out);
            ByteBuffer bytes = ByteBuffer.allocate(BUFFER_SIZE);
            int cnt =0;
            while (reader.read(bytes) > 0) {
                bytes.flip();
                //outChannel.write(bytes);
                bytes.clear();
                cnt++;
                if(cnt % 10 == 0) System.out.println("Batches processed " + cnt);
            }
        }
    }

    public void readEbcdic(){
        data d = new data();
            d.id = 1;
            d.count =2;
            d.address = "Address 101";
    
            Gson gson = new Gson();
    
            String jsonString = gson.toJson(d);
            System.out.println(jsonString);
            
            try {
                // create a reader
                FileInputStream fis = new FileInputStream(
                    new File("ctest_1k.dat"));
            
                // read one byte at a time
                int ch;
                int cnt=0;
                byte[] b = new byte[2];
                while ((ch = fis.read()) != -1) {
                    b[cnt] = (byte) ch;
                    if(++cnt == 2) break;
                }
    
                ByteBuffer wrapped = ByteBuffer.wrap(b); // big-endian by default
                short num = wrapped.getShort(); // 1
                System.out.println("\n" + num + "\n");
    
                b = new byte[num];
                for(int i=0;i<num;i++) {
                    b[i] = (byte) ch;
                }
    
                d.printAscii(b);
                
                // close the reader
                fis.close();
            
            } catch (IOException ex) {
                ex.printStackTrace();
            }
    }
}
