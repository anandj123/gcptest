package com.google.cloud.pso.pipeline;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.HttpRequestInitializer;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.services.gmail.Gmail;
import com.google.api.services.gmail.GmailScopes;
import com.google.api.services.gmail.model.Label;
import com.google.api.services.gmail.model.ListHistoryResponse;
import com.google.api.services.gmail.model.ListLabelsResponse;
import com.google.api.services.gmail.model.Message;
import com.google.api.services.gmail.model.Thread;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.gson.Gson;

import java.io.FileInputStream;
import java.io.IOException;
import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class test {
    private static final String APPLICATION_NAME = "Gmail API Java Quickstart";
    private static final JsonFactory JSON_FACTORY = JacksonFactory.getDefaultInstance();
    

    /**
     * Global instance of the scopes required by this quickstart.
     * If modifying these scopes, delete your previously saved tokens/ folder.
     */
    private static final List<String> SCOPES = Collections.singletonList(GmailScopes.MAIL_GOOGLE_COM);
    //private static final String CREDENTIALS_FILE_PATH = "/Users/anandjain/Downloads/client_secret.json";
    
    
    

    /*
    */
    /** Email of the Service Account */
    
    //private static final String SERVICE_ACCOUNT_EMAIL = "anandj@eqxdemo.com";

    /** Path to the Service Account's Private Key file */
    private static final String SERVICE_ACCOUNT_PKCS12_FILE_PATH = "anand-1-sa.json";

    private static HttpRequestInitializer getCredentialsSA() throws IOException,GeneralSecurityException {
        GoogleCredentials credentials = GoogleCredentials
                            .fromStream(new FileInputStream(SERVICE_ACCOUNT_PKCS12_FILE_PATH))
                            .createScoped(SCOPES).createDelegated("anandj@eqxdemo.com");
        //credentials.refreshIfExpired();
        HttpRequestInitializer requestInitializer = new HttpCredentialsAdapter(credentials);
        return requestInitializer;
    }
    public Map<String,String> printMessage(String user, int historyId){
        HashMap<String,String> retval = new HashMap<String,String>();
        try{
            final NetHttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
            Gmail service = new Gmail.Builder(HTTP_TRANSPORT, JSON_FACTORY, getCredentialsSA())
                    .setApplicationName(APPLICATION_NAME)
                    .build();
            
            BigInteger startHistoryId = BigInteger.valueOf(historyId);
            ListHistoryResponse response = service.users().history().list(user)                
                            .setStartHistoryId(startHistoryId)
                            //.setMaxResults(Long.valueOf(100))
                            .execute();
            List<com.google.api.services.gmail.model.History> hi = response.getHistory();
            
            
            if (hi== null || hi.isEmpty()) {
                System.out.println("No labels found.");
            } else {
                System.out.println("threads:");
                for (com.google.api.services.gmail.model.History h : hi) {
                    List<Message> messages = h.getMessages();
                    for(Message m : messages){
                        String m3 =  m.get("id").toString();
                        System.out.printf("Message ID %s\n", m3);

                        Message m2 = service.users().messages().get(user, m3).execute();
                        String m4 = new Gson().toJson(m2);
                        
                        //System.out.printf("Email raw - %s\n", m4);
                        retval.put(m3, m4);
                        
                    }
                }
            } 
        } catch(IOException  | GeneralSecurityException e){
            e.printStackTrace();
        } 
        return retval;
    }
    public static void main(String[] args)   {
        test t = new test();
        t.printMessage("anandj@eqxdemo.com", 2608);
          
    }
    
    
}
