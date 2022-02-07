package org.example;

import java.io.*;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
        try {
            File myObj = new File("utf16.test.txt");

            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(new FileInputStream(myObj), "UTF-16"));
            String line = reader.readLine();
            while (line!=null) {
//                System.out.println("UTF-16 string: " + line);
                byte[] utf8 = line.getBytes("UTF-8");
                String line2 = new String(utf8, "UTF-8");
                System.out.println("UTF-16 : [" + line + "] UTF-8 : [" + line2 + "]");

                line = reader.readLine();
            }

        } catch (UnsupportedEncodingException | FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
