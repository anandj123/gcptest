// Copyright 2018 Google Inc. All rights reserved.
// Use of this source code is governed by the Apache 2.0
// license that can be found in the LICENSE file.

// Sample contains a simple program that
// uses Google Spanner Go client, and reports metrics
// and traces for the outgoing requests.
package main

import (
	"fmt"
	"log"
	"cloud.google.com/go/spanner"
	"contrib.go.opencensus.io/exporter/stackdriver"
	"github.com/google/uuid"
	"go.opencensus.io/plugin/ocgrpc"
	"cloud.google.com/go/logging"
	"go.opencensus.io/stats/view"
	"go.opencensus.io/trace"
	"golang.org/x/net/context"
)

// Parent log name
const LOGNAME string = "chc-spannerlab"

func main() {
	ctx := context.Background()
	projectID := "anand-bq-test-2"
	exporter, err := stackdriver.NewExporter(stackdriver.Options{
		ProjectID: projectID,
		MetricPrefix: "spanner-oc-test",
	})
	if err != nil {
		log.Fatal(err)
	}

	// Export to Stackdriver Trace.
	trace.RegisterExporter(exporter)
	view.RegisterExporter(exporter)

	if err := view.Register(ocgrpc.DefaultClientViews...); err != nil {
		log.Fatal(err)
	}

	// By default, traces will be sampled relatively rarely. To change the
	// sampling frequency for your entire program, call ApplyConfig. Use a
	// ProbabilitySampler to sample a subset of traces, or use AlwaysSample to
	// collect a trace on every run.
	//
	// Be careful about using trace.AlwaysSample in a production application
	// with significant traffic: a new trace will be started and exported for
	// every request.

	trace.ApplyConfig(trace.Config{DefaultSampler: trace.AlwaysSample()})
	
	ctx, span := trace.StartSpan(ctx, LOGNAME)

	// This database must exist.
	databaseName := fmt.Sprintf("projects/%s/instances/test-1/databases/db1",projectID)

	

	// Creates a logging client.
	lgclient, err := logging.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer lgclient.Close()

	sCtx := span.SpanContext()
	tr := sCtx.TraceID.String()
	lg := lgclient.Logger(LOGNAME)
	trace := fmt.Sprintf("projects/%s/traces/%s", projectID, tr)
                
	client, err := spanner.NewClient(ctx, databaseName)
	if err != nil {
		log.Fatalf("Failed to create client %v", err)
	}
	defer client.Close()			
	for i := 1; i <= 5; i++ {

		val := fmt.Sprintf("anand %v", i)
		_, err = client.Apply(ctx, []*spanner.Mutation{
			spanner.Insert("Singers",
				[]string{"SingerID", "FirstName"},
				[]interface{}{uuid.New().String(), val})})

		lg.Log(logging.Entry{
			Severity: logging.Info,
			Payload:  fmt.Sprintf("Inserted a record to Singers table %s",val),
			Trace:    trace,
			SpanID:   sCtx.SpanID.String(),
		})

		if err != nil {
			log.Printf("Failed to insert: %v", err)
		}
	}

	defer span.End()

	// Make sure data is uploaded before program finishes.
	defer exporter.Flush()

	/**
	References:

	https://cloud.google.com/trace/docs/viewing-details
	https://cloud.google.com/solutions/troubleshooting-app-latency-with-cloud-spanner-and-opencensus
	https://cloud.google.com/trace/docs/trace-export-configure#svcmon_list_services-gcloud

	**/

	/**
	To export trace to Bigquery:

	gcloud auth application-default login
	gcloud components update
	gcloud alpha trace sinks list
	gcloud alpha trace sinks create chcsink bigquery.googleapis.com/projects/701417641712/datasets/traceexport
	gcloud projects add-iam-policy-binding anand-bq-test-2 --member serviceAccount:export-000000a34fbfd6f0-3447@gcp-sa-cloud-trace.iam.gserviceaccount.com --role roles/bigquery.dataEditor
	gcloud alpha trace sinks desc chcsink

	**/
}