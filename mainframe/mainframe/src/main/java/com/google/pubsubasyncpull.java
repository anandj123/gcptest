package com.google;

import com.google.cloud.pubsub.v1.AckReplyConsumer;
import com.google.cloud.pubsub.v1.MessageReceiver;
import com.google.cloud.pubsub.v1.Subscriber;
import com.google.pubsub.v1.ProjectSubscriptionName;
import com.google.pubsub.v1.PubsubMessage;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class pubsubasyncpull {
    public void subscribeAsyncExample(String projectId, String subscriptionId) {
        
        System.out.println("project id: " + projectId + " \nsubscription id : " + subscriptionId + "\n");
        ProjectSubscriptionName subscriptionName =
            ProjectSubscriptionName.of(projectId, subscriptionId);
    
        // Instantiate an asynchronous message receiver.
        MessageReceiver receiver =

        new MessageReceiver() {
            @Override
            public void receiveMessage(PubsubMessage message, AckReplyConsumer consumer) {
                // Handle incoming message, then ack the received message.
                System.out.println("Id: " + message.getMessageId());
                System.out.println("Data: " + message.getData().toStringUtf8());
                consumer.ack();
              }
          };

        Subscriber subscriber = null;
        try {
          subscriber = Subscriber.newBuilder(subscriptionName, receiver).build();
          // Start the subscriber.
          subscriber.startAsync().awaitRunning();
          System.out.printf("Listening for messages on %s:\n", subscriptionName.toString());
          // Allow the subscriber to run for 30s unless an unrecoverable error occurs.
          subscriber.awaitTerminated(30, TimeUnit.SECONDS);
        } catch (TimeoutException timeoutException) {
          System.out.println("Time out excepion");
            // Shut down the subscriber after 30s. Stop receiving messages.
          subscriber.stopAsync();
        }
      }
}
