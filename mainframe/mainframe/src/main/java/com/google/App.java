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
        
        //Storage storage = StorageOptions.getDefaultInstance().getService();
        String bucketName = "anand-bq-test-2";
        String blobPath = "";
        long start = 0;
        long finish = 0;
        long timeElapsed = 0;
        if (args.length < 1) {
            System.out.println("Please pass action argument.");
            return;
        }
        if (args[0].equals("process")) {
            if(args.length < 3) {
                System.out.println("Please provide the DB file name.");
                System.out.println("Please provide the query file name.");
                return;
            }
            //blobPath = "efx-mf-test-data/"+args[1];
            String DBFile = args[1];
            System.out.println("Processing DB file : " + DBFile);
            String qFile = args[2];
            try{
                start = System.currentTimeMillis();
                //loadGCS(storage, bucketName, blobPath);
                //finish = System.currentTimeMillis();
                //timeElapsed = (finish - start)/1000;
                //System.out.println("Time elapsed Download GCS: " + timeElapsed + " seconds.");
                //start = System.currentTimeMillis();
                processData(DBFile, qFile);
                finish = System.currentTimeMillis();
                timeElapsed = (finish - start)/1000;
                System.out.println("Time elapsed Query Local: " + timeElapsed + " seconds.");
                //pubsubasyncpull p = new pubsubasyncpull();
                //p.subscribeAsyncExample("anand-bq-test-2", "mfdemo-sub");
    
            } catch(Exception ex) {
                ex.printStackTrace();
                System.out.println("Found exception calling process query file : " + qFile);
            }
        } else if (args[0].equals("generate")) {
            System.out.println("Generating data.");
            if (args.length < 3) {
                System.out.println("Please provide number of records and output file name.");
                return;
            }
            int nRecords = Integer.parseInt(args[1]);
            String fileName = args[2];
            createTestData(nRecords, fileName);
        }
    }
    private static void loadGCS(Storage storage, String bucketName, String blobPath) throws IOException {
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

    public static void processData(String DBFile, String qFile) throws Exception{
        query1 q;
        String qString = "";
        try {
            BufferedReader reader = new BufferedReader(new FileReader(qFile));
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
        // System.out.println(qString);
        // System.out.println(q.sortOrder.get(0) + " " + q.limit+ " "+ q.filter.state.get(0)+ " "+ q.filter.score);
        
        ArrayList<person> out = new ArrayList<person>();
        BufferedReader reader = new BufferedReader(new FileReader(DBFile));
        String line = reader.readLine();

        while(line != null) {
            line = reader.readLine();
            person p;
            try{
                p = gson.fromJson(line, person.class);
            } catch(Exception ex) {
                System.out.println("Malformed data file...Exiting.");
                break;
            }
            
            for(int j=0;j<q.filter.state.size();j++) {
                if(p!= null && p.state !=null && p.state.equals(q.filter.state.get(j)) ) {
                    if (p.score > q.filter.score){
                        out.add(p);
                        break;
                    }
                }
            }
        }
        reader.close();
        Collections.sort(out, new Comparator<person>(){
            @Override
            public int compare(person p1, person p2) {
                return  p2.score - p1.score;
            }
        });

        
        int cnt =-1;
        while(true) {
            cnt++;
            if (cnt > q.limit || cnt >= out.size()) break;
            person p = out.get(cnt);
            System.out.println(gson.toJson(p, person.class));
        }
    }

    public static void createTestData(int nRecords, String fileName){
        Gson gson = new Gson();
        FileWriter myWriter;
		try {
                //myWriter = new FileWriter("test"+fileN+".data");
                myWriter = new FileWriter(fileName);
                for(int i=0;i<nRecords;i++){
                    person p = new person();
                    //System.out.println(gson.toJson(p));
                    myWriter.write(gson.toJson(p)+"\n");
                }
                myWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    public void readEbcdic(){
        data d = new data();
        try {
            FileInputStream fis = new FileInputStream(new File("ctest_1k.dat"));
        
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
            for(int i=0;i<num;i++) b[i] = (byte) ch;
            d.printAscii(b);
            fis.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
}