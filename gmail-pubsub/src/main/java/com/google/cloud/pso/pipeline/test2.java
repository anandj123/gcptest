package com.google.cloud.pso.pipeline;

import com.google.api.core.ApiFuture;
import com.google.cloud.pubsub.v1.stub.GrpcSubscriberStub;
import com.google.cloud.pubsub.v1.stub.SubscriberStub;
import com.google.cloud.pubsub.v1.stub.SubscriberStubSettings;
import com.google.cloud.pubsub.v1.Publisher;
import com.google.common.collect.ImmutableMap;
import com.google.protobuf.ByteString;
import com.google.pubsub.v1.AcknowledgeRequest;
import com.google.pubsub.v1.ProjectSubscriptionName;
import com.google.pubsub.v1.PubsubMessage;
import com.google.pubsub.v1.PullRequest;
import com.google.pubsub.v1.PullResponse;
import com.google.pubsub.v1.ReceivedMessage;
import com.google.pubsub.v1.TopicName;
import org.json.JSONObject;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.Map;
public class test2 {

  public static void main(String... args) throws Exception {
    String projectId = "anand-1-291314";
    String subscriptionId = "gmail-push-sub";
    Integer numOfMessages = 10;
    while(true) {
      subscribeSyncExample(projectId, subscriptionId, numOfMessages);
      Thread.sleep(5000);
    }
    
  }

  public static void subscribeSyncExample(String projectId, String subscriptionId, Integer numOfMessages) throws IOException {
        test t = new test();
        SubscriberStubSettings subscriberStubSettings =
        SubscriberStubSettings.newBuilder()
            .setTransportChannelProvider(
                SubscriberStubSettings.defaultGrpcTransportProviderBuilder()
                    .setMaxInboundMessageSize(20 * 1024 * 1024) // 20MB (maximum message size).
                    .build())
            .build();

    try (SubscriberStub subscriber = GrpcSubscriberStub.create(subscriberStubSettings)) {
      String subscriptionName = ProjectSubscriptionName.format(projectId, subscriptionId);
      PullRequest pullRequest =
          PullRequest.newBuilder()
              .setMaxMessages(numOfMessages)
              .setSubscription(subscriptionName)
              .build();

      // Use pullCallable().futureCall to asynchronously perform this operation.
      PullResponse pullResponse = subscriber.pullCallable().call(pullRequest);
      List<String> ackIds = new ArrayList<>();
      for (ReceivedMessage message : pullResponse.getReceivedMessagesList()) {
        // Handle received message
        // ...
        String m = message.getMessage().getData().toStringUtf8();
        //m=m.replace("\"", "");
        //m = m.replace("\\", "");
        JSONObject email = new JSONObject(m);
        System.out.println(email.get("emailAddress"));
        System.out.println(email.get("historyId"));
        Thread.sleep(2000);
        Map<String, String> m4 = t.printMessage((String)email.get("emailAddress"), (int) email.get("historyId"));

        String targetTopicId = "gmail-messages";
        publishWithCustomAttributesExample(projectId, targetTopicId, m4);

        ackIds.add(message.getAckId());
      }

      if (!ackIds.isEmpty()){
        // Acknowledge received messages.
        AcknowledgeRequest acknowledgeRequest =
        AcknowledgeRequest.newBuilder()
            .setSubscription(subscriptionName)
            .addAllAckIds(ackIds)
            .build();

        // Use acknowledgeCallable().futureCall to asynchronously perform this operation.
        subscriber.acknowledgeCallable().call(acknowledgeRequest);
      }
    } catch(Exception e){
      e.printStackTrace();
    }
  }


  public static void publishWithCustomAttributesExample(String projectId, String topicId, Map<String,String>m4){
    
    TopicName topicName = TopicName.of(projectId, topicId);
    Publisher publisher = null;

    try {
      // Create a publisher instance with default settings bound to the topic
      publisher = Publisher.newBuilder(topicName).build();
      for(String m : m4.values()){
        
        ByteString data = ByteString.copyFromUtf8(m);
        PubsubMessage pubsubMessage =
            PubsubMessage.newBuilder()
                .setData(data)
                .putAllAttributes(ImmutableMap.of("year", "2020", "author", "unknown"))
                .build();

        // Once published, returns a server-assigned message id (unique within the topic)
        ApiFuture<String> messageIdFuture = publisher.publish(pubsubMessage);
        String messageId = messageIdFuture.get();
        System.out.println("Published a message with custom attributes: " + messageId);
      }
      

    } catch(Exception e) {} finally {
      try {
        if (publisher != null) {
          // When finished with the publisher, shutdown to free up resources.
          publisher.shutdown();
          publisher.awaitTermination(1, TimeUnit.MINUTES);
        }
      } catch(Exception e2){}
      
    }
  }

}