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
import com.google.api.services.gmail.model.ListLabelsResponse;
import com.google.auth.oauth2.GoogleCredentials;

import java.io.FileInputStream;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.List;

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
        credentials.refreshIfExpired();
        HttpRequestInitializer requestInitializer = new HttpCredentialsAdapter(credentials);
        return requestInitializer;
    }
    public static void main(String[] args) throws IOException, GeneralSecurityException {
        
        final NetHttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
        Gmail service = new Gmail.Builder(HTTP_TRANSPORT, JSON_FACTORY, getCredentialsSA())
                .setApplicationName(APPLICATION_NAME)
                .build();

        // Print the labels in the user's account.
        String user = "anandj@eqxdemo.com";
        ListLabelsResponse listResponse = service.users().labels().list(user).execute();
        List<Label> labels = listResponse.getLabels();
        if (labels.isEmpty()) {
            System.out.println("No labels found.");
        } else {
            System.out.println("Labels:");
            for (Label label : labels) {
                System.out.printf("- %s\n", label.getName());
            }
        }
    }
    
    
}
