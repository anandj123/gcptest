# Overview
[Gmail push notification](https://developers.google.com/gmail/api/guides/push)  is a feature provided by GSuite to monitor a Gmail account for any changes to the email box and send a push notification to a pubsub topic in the provided Google Cloud Platform project. This project is about setting up and monitoring multiple domains for gmail push notification and using dataflow to gather content of all those notification and pushing it to another pubsub topic so that analytics or threat detection could be performed.

There are 2 components involved in setting his up.

1. [App Script](code.gs) which can be scheduled to read from a worksheet with all the domain names for which the gmail push needs to be enabled.
2. [Dataflow job](src/main/java/com/google/cloud/pso/pipeline/GmailDataflow.java) which monitors the pubsub topic for the pusbusb event from gmail and reads all the email with that historyId and publishes all the messages to another pubsub topic.

# Setup Instruction

