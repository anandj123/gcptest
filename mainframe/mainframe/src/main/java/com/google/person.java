package com.google;

import java.util.*;

public class person {

    String ssn;
    String name;
    String address;
    int zip;
    String state;
    int score;
    boolean hasBankruptcy;

    public person(){
        setId();
        setState();
        setZip();
        setScore();
        setHasBankruptcy();
        setName();
        setAddress();
    }

    private void setId(){
        int n1, n2, n3;
        n1 = (int)(Math.random()*(999-111) + 111);
        n2 = (int)(Math.random()*(99-11) + 11);
        n3 = (int)(Math.random()*(999-111)+111);
        ssn = String.valueOf(n1) + "-" + String.valueOf(n2) + "-" + String.valueOf(n3);
    
    }
    private void setState(){
        int n1 = (int)(Math.random()*50);
        String[] stateList = {"AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","MD","MA","MI","MN","MS","MO","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"};
        state = stateList[n1];
    }
    private void setZip(){
        int n1 = (int)(Math.random()*(80000-12345) + 12345);
        zip = n1;
    }
    private void setScore(){
        int n1 = (int)(Math.random()*(800-450) + 450);
        score = n1;
    }
    public void setHasBankruptcy() {
        hasBankruptcy = (Math.random()>=.5?true:false);
    }
    public void setName(){
        int n1 = (int) (Math.random() *(6-3) + 3);

        name = getAlphaNumericString(n1);
        n1 = (int) (Math.random() *(10-3) + 3);
        name = name + " " + getAlphaNumericString(n1);

    }

    public void setAddress(){
        int n1 = (int) (Math.random() *(999-123) + 123);

        address = String.valueOf(n1);
        n1 = (int) (Math.random() *(10-3) + 3);
        address = address + " " + getAlphaNumericString(n1);
        n1 = (int) (Math.random() *(10-3) + 3);
        address = address + " " + getAlphaNumericString(n1);
    }

    static String getAlphaNumericString(int n) 
    { 
        int lowerLimit = 97; // lower limit for LowerCase Letters
        int upperLimit = 122; // higher limit for LowerCase Letters
  
        Random random = new Random(); 
        StringBuffer r = new StringBuffer(n); 
  
        for (int i = 0; i < n; i++) { 
            // take a random value between 97 and 122 
            int nextRandomChar = lowerLimit 
                                + (int)(random.nextFloat() 
                                * (upperLimit - lowerLimit + 1)); 
            r.append((char)nextRandomChar); 
        } 
        return r.toString(); 
    } 

}
