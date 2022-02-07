package org.example;

import java.io.*;
import java.util.Scanner;

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
                System.out.println("UTF-16 string: " + line);
                byte[] utf8 = line.getBytes("UTF-8");
                line = new String(utf8, "UTF-8");
                System.out.println( "UTF-8 Converted string : " + line );

                line= reader.readLine();
            }
            // Convert from Unicode to UTF-8
            String string = "\u013d";
            byte[] utf8 = string.getBytes("UTF-8");

            // Convert from UTF-8 to Unicode
            string = new String(utf8, "UTF-8");
            System.out.println( "Converted string : " + string );
        } catch (UnsupportedEncodingException | FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
