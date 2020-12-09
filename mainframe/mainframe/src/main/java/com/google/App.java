package com.google;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import com.google.cloud.ReadChannel;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import com.google.gson.Gson;

public class App 
{
    private static final int BUFFER_SIZE = 256*1024*1024 ; // 100 MB pull at one time
    private static String[] data;
    static final Gson gson = new Gson();

    public static void main(String args[]){
        
        // Instantiates a Storage client
        Storage storage = StorageOptions.getDefaultInstance().getService();
        // The name for the GCS bucket
        String bucketName = "anand-bq-test-2";
        // The path of the blob (i.e. GCS object) within the GCS bucket.
        
        //String blobPath = "efx-mf-test-data/testL.data";
        
        String blobPath = "efx-mf-test-data/"+args[0];
        System.out.println("Processing file : " + blobPath);
        
        long start = System.currentTimeMillis();
        long finish = 0;
        long timeElapsed = 0;
        try{

            //createTestData();

            printBlob(storage, bucketName, blobPath);
            finish = System.currentTimeMillis();
            timeElapsed = (finish - start)/1000;
            System.out.println("Time elapsed Download GCS: " + timeElapsed + " seconds.");
            start = System.currentTimeMillis();
            processData();

            //pubsubasyncpull p = new pubsubasyncpull();
            //p.subscribeAsyncExample("anand-bq-test-2", "mfdemo-sub");

        } catch(Exception ex) {
            ex.printStackTrace();
            System.out.println("Found exception calling pubsub");
        }
        finish = System.currentTimeMillis();
        timeElapsed = (finish - start)/1000;
        System.out.println("Time elapsed Query Local: " + timeElapsed + " seconds.");
        
    }
    private static void printBlob(Storage storage, String bucketName, String blobPath) throws IOException {
        try (ReadChannel reader = storage.reader(bucketName, blobPath)) {
            //WritableByteChannel outChannel = Channels.newChannel(System.out);
            ByteBuffer bytes = ByteBuffer.allocate(BUFFER_SIZE);
            String line = "";
            int cnt=0;
            while (reader.read(bytes) >0) {
                cnt++;
                //bytes.flip();
                line += new String(bytes.array());
                ((Buffer)bytes).clear();
            }
            System.out.println("Downloaded " + (cnt * BUFFER_SIZE/(1024*1024)) + " MB of data from GCS");

            data = line.split("\n");

            /*
            for(int i=0;i<data.length;i++) System.out.println("line : " + i + " " + data[i]);
            */
        }
    }

    public static void processData() throws Exception{
        query1 q;
        String qString = "";
        try {
            BufferedReader reader = new BufferedReader(new FileReader("query.json"));
            String line = "";

            while(true) {
                line = reader.readLine();
                if (line == null) break;
                qString += line;
            }
            
            q = gson.fromJson(qString, query1.class);
            reader.close();
        } catch(Exception ex) {
            ex.printStackTrace();
            return;
        }
        //System.out.println(qString);

        // System.out.println(q.sortOrder.get(0) 
        // + " " 
        // + q.limit
        // + " "
        // + q.filter.state.get(0)
        // + " "
        // + q.filter.score
        // );
        
        // 
        // ArrayList<String> data = new ArrayList<String>();
        // int nRecords = 1*5000;
        // for(int i=0;i<nRecords;i++){
        //     person p = new person();
        //     data.add(gson.toJson(p));
        // }
        

        ArrayList<String> out = new ArrayList<String>();

        for(int i = 0;i<data.length;i++){
            person p;
            try{
                p = gson.fromJson(data[i], person.class);
            } catch(Exception ex) {break;}
            for(int j=0;j<q.filter.state.size();j++) {
                if(p.state.equals(q.filter.state.get(j))  ) {
                    if (p.score > q.filter.score){
                        out.add(data[i]);
                        break;
                    }
                }
            }
        }

        Collections.sort(out, new Comparator<String>(){
            @Override
            public int compare(String j1, String j2) {
                person p1 = gson.fromJson(j1,person.class);
                person p2 = gson.fromJson(j2,person.class);
                return  p2.score - p1.score;
            }
        });
        int cnt =-1;
        while(true) {
            cnt++;
            if (cnt > q.limit || cnt >= out.size()) break;

            person p = gson.fromJson(out.get(cnt), person.class);
            System.out.println("Score: " + p.score + " State :" + p.state);
        }
    }
    

    public static void createTestData(){
        Gson gson = new Gson();
        FileWriter myWriter;
        int nRecords = 2 * 1000 * 1000;
        int nFiles = 5;
		try {
            for(int j=0;j<nFiles;j++){
                int fileN = j+1;
                myWriter = new FileWriter("test"+fileN+".data");
                for(int i=0;i<nRecords;i++){
                    person p = new person();
                    //System.out.println(gson.toJson(p));
                    myWriter.write(gson.toJson(p)+"\n");
                }
                myWriter.close();
            }
            
		} catch (IOException e) {
			e.printStackTrace();
		}
    }
    

    public void readEbcdic(){
        data d = new data();
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
