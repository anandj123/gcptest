/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * To compile and run the program use the following:
 * Create a table in spanner 
 *      NumberRange(
 *           Next INT64 NOT NULL, 
 *           Value INT64 NOT NULL)
 * For running the program use the following command
 * mvn clean compile exec:java -Dexec.mainClass=com.example.spanner.ReadWriteTransactionMultiThreadTest -Dexec.args="demo test atomic 30" -Dexec.cleanupDaemonThreads=false
 */

package com.example.spanner;

// [START spanner_quickstart]
// Imports the Google Cloud client library
import static com.google.cloud.spanner.TransactionRunner.TransactionCallable;
import com.google.cloud.spanner.TransactionContext;
import com.google.cloud.spanner.Struct;
import com.google.cloud.spanner.Key;
import com.google.cloud.spanner.Mutation;
import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

import com.google.cloud.spanner.DatabaseClient;
import com.google.cloud.spanner.DatabaseId;
import com.google.cloud.spanner.ResultSet;
import com.google.cloud.spanner.Spanner;
import com.google.cloud.spanner.SpannerOptions;
import com.google.cloud.spanner.Statement;

import io.opencensus.common.Scope;
import io.opencensus.contrib.grpc.metrics.RpcViews;
import io.opencensus.exporter.stats.stackdriver.StackdriverStatsExporter;
import io.opencensus.exporter.trace.stackdriver.StackdriverExporter;
import io.opencensus.trace.Tracing;
import io.opencensus.trace.samplers.Samplers;

/**
 * Demonstrate how read-write transactions behave in a multi-threaded environment
 */
public class ReadWriteTransactionMultiThreadTest extends Thread{
  static String instanceId = "";
  static String databaseId = "";
  static String test = "";
  private static String parentSpanName = "create-players";
  public void run() {
    SpannerOptions options = SpannerOptions.newBuilder().build();
    Spanner spanner = options.getService();
    try {
      DatabaseClient dbClient = spanner.getDatabaseClient(DatabaseId.of(options.getProjectId(), instanceId, databaseId));
      

      if (test.equals("atomic")) {
        // Atomic transaction demo
        writeWithTransaction(dbClient);
      } else {
        // Non-atomic transaction demo
        update(dbClient);
      }
    } catch (Exception e) {
      e.printStackTrace();
      System.err.println(e);
    } finally {
      spanner.close();
    }
  }
  
  public static void main(String... args) throws Exception {
    if (args.length != 4) {
      System.err.println("Usage: ReadWriteTransactionMultiThreadTest <instance_id> <database_id> <atomic/nonatomic> <threads:10/20>");
      return;
    }
    // Instantiates a client
    SpannerOptions options = SpannerOptions.newBuilder().build();
    Spanner spanner = options.getService();

    // Name of your instance & database.
    instanceId = args[0];
    databaseId = args[1];
    test = args[2];
    int nthreads = Integer.parseInt(args[3]);

    try {
      // Creates a database client
      DatabaseClient dbClient = spanner.getDatabaseClient(DatabaseId.of(options.getProjectId(), instanceId, databaseId));
      
      // Next up let's  install the exporter for Stackdriver tracing.
      StackdriverExporter.createAndRegister();
      Tracing.getExportComponent().getSampledSpanStore().registerSpanNamesForCollection(
      Arrays.asList(parentSpanName));

      // Then the exporter for Stackdriver monitoring/metrics.
      StackdriverStatsExporter.createAndRegister();
      RpcViews.registerAllCumulativeViews();

      try (Scope ss = Tracing.getTracer()
      .spanBuilderWithExplicitParent(parentSpanName, null)
      // Enable the trace sampler.
      //  We are always sampling for demo purposes only: this is a very high sampling
      // rate, but sufficient for the purpose of this quick demo.
      // More realistically perhaps tracing 1 in 10,000 might be more useful
      .setSampler(Samplers.alwaysSample())
      .startScopedSpan()) {
        // Update the table to initial value of 1
        List<Mutation> mutations = Arrays.asList(              
                Mutation.newUpdateBuilder("NumberRange")
                    .set("Next")
                    .to(1)
                    .set("Value")
                    .to(0)
                    .build());
        // This writes all the mutations to Cloud Spanner atomically.
        dbClient.write(mutations);
      }
      // Create 5 threads and write simultaneously to spanner.
      List<Thread> threads = new ArrayList<>();
      for (int i=0;i<nthreads;i++) {
        Thread t1 = new ReadWriteTransactionMultiThreadTest();
        t1.start();
        threads.add(t1);
      }

      // Wait for the threads to finish
      for (Thread thread : threads) {
        thread.join();
      }
      //Thread.sleep(3000);

      // Queries the database
      ResultSet resultSet = dbClient.singleUse().executeQuery(Statement.of("SELECT Value from NumberRange"));
      System.out.printf("\nValue after the update : ");
      // Prints the results
      while (resultSet.next()) {
        System.out.printf("%d\n\n", resultSet.getLong(0));
      }
      resultSet.close();
    } finally {
      // Closes the client which will free up the resources used
      spanner.close();
    }
  }
  
  // Before executing this method, a new column MarketingBudget has to be added to the Albums
  // table by applying the DDL statement "ALTER TABLE Albums ADD COLUMN MarketingBudget INT64".
  // [START spanner_update_data]
  public void update(DatabaseClient dbClient) {
    System.out.println("In non-atomic update routine.");
    try{
      ResultSet resultSet = dbClient.singleUse().executeQuery(Statement.of("SELECT Value from NumberRange"));
      resultSet.next();
      long next2 = resultSet.getLong(0);
      resultSet.close();
      next2++;
      System.out.println("Updating value to : " + next2);
      //Thread.sleep(2000); //wait for simulating overwriting transactions
      List<Mutation> mutations =
          Arrays.asList(
              Mutation.newUpdateBuilder("NumberRange")
                  .set("Next")
                  .to(1)
                  .set("Value")
                  .to(next2)
                  .build());
      // This writes all the mutations to Cloud Spanner atomically.
      dbClient.write(mutations);
      
    } catch(Exception e) {
      System.out.println(e);
    }
  }
  // [END spanner_update_data]

  // [START spanner_read_write_transaction]
  public void writeWithTransaction(DatabaseClient dbClient) {
    try (Scope ss = Tracing.getTracer()
      .spanBuilderWithExplicitParent(parentSpanName, null)
      // Enable the trace sampler.
      //  We are always sampling for demo purposes only: this is a very high sampling
      // rate, but sufficient for the purpose of this quick demo.
      // More realistically perhaps tracing 1 in 10,000 might be more useful
      .setSampler(Samplers.alwaysSample())
      .startScopedSpan()) {
      System.out.println("In atomic update routine.");
      dbClient
        .readWriteTransaction()
        .run(
            new TransactionCallable<Void>() {
              @Override
              public Void run(TransactionContext transaction) throws Exception {
                
                Struct row = transaction.readRow("NumberRange", Key.of(1), Arrays.asList("Next"));
                long next = row.getLong(0);
                
                // Transaction will only be committed if this condition still holds at the time of
                // commit. Otherwise it will be aborted and the callable will be rerun by the
                // client library.
                long next2 = transaction.readRow("NumberRange", Key.of(1), Arrays.asList("Value"))
                          .getLong(0);
                next2 ++;
                System.out.println("Updating value to : " + next2);
                transaction.buffer(
                      Mutation.newUpdateBuilder("NumberRange")
                      .set("Next")
                      .to(1)
                      .set("Value")
                      .to(next2)
                      .build());      
                return null;
              }
            }
          );
      }
  } // [END spanner_read_write_transaction]

}
// [END spanner_quickstart]
