# Overview
[Gmail push notification](https://developers.google.com/gmail/api/guides/push)  is a feature provided by GSuite to monitor a Gmail account for any changes to the email box and send a push notification to a pubsub topic in the provided Google Cloud Platform project. This project is about setting up and monitoring multiple domains for gmail push notification and using dataflow to gather content of all those notification and pushing it to another pubsub topic so that analytics or threat detection could be performed.

There are 2 components involved in setting his up.

1. [App Script](code.gs) which can be scheduled to read from a worksheet with all the domain names for which the gmail push needs to be enabled.
2. [Dataflow job](src/main/java/com/google/cloud/pso/pipeline/GmailDataflow.java) which monitors the pubsub topic for the pusbusb event from gmail and reads all the email with that historyId and publishes all the messages to another pubsub topic.

# Setup Instructions

## App script setup

1. Goto [your scripts project page](https://script.google.com/home). 
2. Create a new project and copy-paste the [App Script](code.gs) content to that page.
3. Create a google sheet where you would provide the domain names to monitor.

    1. Create 2 tabs with names (domains, users).

    2. In the domains tab, create the first column with name (Domain) and from A2 you could add all the domain names that you would want to monitor.

    3. On the user tab on row 1 you could create these columns where the output of the app script will be stored after each run. The output are overwritten every time the script runs.

        1. User Name	

        2. Email	

        3. Date updated	

        4. User registration response	

        5. Registration expiration date time (EST)

4. Copy the sheet id from the URL bar of the google sheet you just created. 

    Example: 

    For a sheet: https://docs.google.com/spreadsheets/d/1SBB_xf7KudS4l5vkoSH-udFlbOmt--4W/edit#gid=0

    Sheet id: 1SBB_xf7KudS4l5vkoSH-udFlbOmt--4W

5. In the App script update the SHEET_ID variable with the sheet id of your sheet.

6. You need to setup a GCP project where the pubsub is hosted. You also need a service account with Domain wide delegation privilege so that the service account can impersonate each email accounts and pull their email for analytics. Follow the setup instruction for those provided earlier.

7. On the App script project, use the menu [Resource -> Cloud Platform project] and update the project number from your GCP project where the pubsub topic is hosted.

8. From the Google Cloud Platform project copy the "Private Key", "Client Email" of the service account which you have setup earlier and update the [PRIVATE_KEY] and [CLIENT_EMAIL] in the app script.

9. Copy the fully qualified topic name from the pubsub topic where the gmail push notification is received.

Topic name: projects/YOUR_PROJECT_ID/topics/TOPIC_NAME

10. From the app services project use the menu [Resources -> Advanced Google Services] and enable [Admin SDK].

11. Add the Oauth2 library. From the app services project use the menu [Resources -> Libraries] and on the [Add a library] seach box past the following id to add the Oauth2 library.

1B7FSrk5Zi6L1rSxxTDgDEUsPzlukDsi4KGuTMorsTQHhGBzBkMun4iDF

12. If you want to schedule this script to run on a schedule time use the [documentation](https://developers.google.com/apps-script/guides/triggers/installable#time-driven_triggers) provided.









