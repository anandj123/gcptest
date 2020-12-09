package com.google;

public class data {
    
    public void printAscii(byte[] input)  {
        try{
            System.out.println(input);
            System.out.println();            
            String s = new String(input, "cp1047");
            System.out.println(s);

            input = new byte[] {(byte)0xc1,(byte)0xc2,(byte)0xc3};

            System.out.println(new String(input,"cp1047"));
            
        } catch(Exception e) {
            System.out.println("Could not convert!!");
        }
        
    }
}
