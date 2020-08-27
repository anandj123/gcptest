package bigtableprofile;

import com.google.cloud.bigtable.data.v2.BigtableDataClient;
import com.google.cloud.bigtable.data.v2.BigtableDataClientFactory;
import com.google.cloud.bigtable.data.v2.BigtableDataSettings;
import com.google.cloud.bigtable.data.v2.models.Query;
import com.google.cloud.bigtable.data.v2.models.Row;
import com.google.cloud.bigtable.data.v2.models.RowCell;
import com.google.cloud.bigtable.data.v2.models.RowMutation;
import java.io.IOException;

/**
 * To run the code use: 
 * mvn exec:java -Dexec.mainClass=bigtableprofile.App -Dexec.cleanupDaemonThreads=false
 * 
 * To clear the table use:
 * cbt deleteallrows table1
 */
public final class App {

  public App() {}

  /**
   * Says hello to the world.
   * @param args The arguments of the program.
   * @throws IOException
   * @throws InterruptedException
   */
  public static void main(String[] args)
    throws IOException, InterruptedException {
    App a = new App();
    MyThread1 thread1 = a.new MyThread1();
    MyThread2 thread2 = a.new MyThread2();
    thread1.start();
    thread2.start();

    thread1.join();
    thread2.join();
    
    // Instantiates a client
    String projectId = "anand-bq-test-2";
    String instanceId = "test-1";
    String tableId = "table1";
    String profileId = "profile-2";
    BigtableDataSettings defaultSettings = BigtableDataSettings
      .newBuilder()
      .setProjectId(projectId)
      .setInstanceId(instanceId)
      .build();
    BigtableDataClientFactory clientFactory = BigtableDataClientFactory.create(
      defaultSettings
    );
    BigtableDataClient dataClient = clientFactory.createForAppProfile(
      profileId
    );

    try {
      // Query a table
      Query query = Query.create(tableId);

      for (Row row : dataClient.readRows(query)) {
        System.out.println(row.getKey());
        for (RowCell cell : row.getCells()) {
          System.out.printf(
            "Family: %s    Qualifier: %s    Value: %s%n",
            cell.getFamily(),
            cell.getQualifier().toStringUtf8(),
            cell.getValue().toStringUtf8()
          );
        }
      }
    } finally {
      dataClient.close();
    }
  }

  public class MyThread1 extends Thread {

    public void run() {
      // Instantiates a client
      String projectId = "anand-bq-test-2";
      String instanceId = "test-1";
      String tableId = "table1";
      String profileId = "profile-1";

      String ROW_KEY_PREFIX = "ROW";
      String COLUMN_FAMILY = "col1";
      String COLUMN_QUALIFIER = "cell1";

      String[] greetings = { "Hello World!", "Hello Bigtable!", "Hello Java!" };

      BigtableDataSettings defaultSettings = BigtableDataSettings
        .newBuilder()
        .setProjectId(projectId)
        .setInstanceId(instanceId)
        .build();
      BigtableDataClientFactory clientFactory;
      BigtableDataClient dataClient;
      try {
        clientFactory = BigtableDataClientFactory.create(defaultSettings);
        dataClient = clientFactory.createForAppProfile(profileId);
        for (int i = 0; i < greetings.length; i++) {
          RowMutation rowMutation = RowMutation
            .create(tableId, ROW_KEY_PREFIX + i)
            .setCell(COLUMN_FAMILY, COLUMN_QUALIFIER, greetings[i]);
          dataClient.mutateRow(rowMutation);
          //System.out.println(greetings[i]);
        }
        dataClient.close();
      } catch (IOException e) {
        e.printStackTrace();
      }
      
    }
  }

  public class MyThread2 extends Thread {

    public void run() {
      // Instantiates a client
      String projectId = "anand-bq-test-2";
      String instanceId = "test-1";
      String tableId = "table1";
      String profileId = "profile-2";

      String ROW_KEY_PREFIX = "ROW";
      String COLUMN_FAMILY = "col1";
      String COLUMN_QUALIFIER = "cell1";

      String[] greetings = { "Hello World!", "Hello Bigtable!", "Hello Java!" };

      BigtableDataSettings defaultSettings = BigtableDataSettings
        .newBuilder()
        .setProjectId(projectId)
        .setInstanceId(instanceId)
        .build();
      BigtableDataClientFactory clientFactory;
      BigtableDataClient dataClient;
      try {
        clientFactory = BigtableDataClientFactory.create(defaultSettings);
        dataClient = clientFactory.createForAppProfile(profileId);
        for (int i = 0; i < greetings.length; i++) {
          RowMutation rowMutation = RowMutation
            .create(tableId, ROW_KEY_PREFIX + i)
            .setCell(COLUMN_FAMILY, COLUMN_QUALIFIER, greetings[i]);
          dataClient.mutateRow(rowMutation);
          //System.out.println(greetings[i]);
        }
        dataClient.close();
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }
}
