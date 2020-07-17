// Sample datastore-quickstart fetches an entity from Google Cloud Datastore.
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"time"

	"cloud.google.com/go/bigquery"
	"cloud.google.com/go/datastore"
	"google.golang.org/api/iterator"
)

type Task struct {
	Description string
}
type Reservation struct {
	Reservation_Id   string
	Project_Id       string
	Reservation_Slot int64
}

//Job structure holds the job object
type Job struct {
	Name      JobName
	UserEmail string
	Stats     JobStatistics
	Detail    JobDetail
}

//JobName structure to hold jobid, location, project id
type JobName struct {
	JobId     string `datastore:"jobId"`
	Location  string `datastore:"location"`
	ProjectId string `datastore:"projectId"`
}

func (j JobName) String() string {
	return fmt.Sprintf("[%s] %s:%s", j.Location, j.ProjectId, j.JobId)
}

//JobStatistics structure hold job statistics
type JobStatistics struct {
	CreateTime time.Time `datastore:"createTime"`
	EndTime    time.Time `datastore:"endTime"`
	StartTime  time.Time `datastore:"startTime"`
}

//JobDetail structure hold job details
type JobDetail struct {
	Type          string `datastore:"createTime"`
	State         string
	Error         string
	Email         string
	Src           string
	Dst           string
	Priority      string
	StatementType string
	Query         string
	Timeline      []TimelineSample
	Updated       time.Time
	ReservationID string
	Slots         int64
}

//TimelineSample structure hold job timeline data
type TimelineSample struct {
	ActiveUnits    int64
	CompletedUnits int64
	Elapsed        int64
	PendingUnits   int64
	SlotMillis     int64
}

//StateString retuns state of job
func StateString(s bigquery.State) string {
	switch s {
	case bigquery.Running:
		return "Running"
	case bigquery.Pending:
		return "Pending"
	case bigquery.Done:
		return "Done"
	default:
		return "Unknown"
	}
}

//JobKey formats JobKey
func JobKey(l string, p string, j string) string {
	return fmt.Sprintf("[%s] %s:%s", l, p, j)
}
func BqJobKey(j *bigquery.Job, p string) string {
	return JobKey(j.Location(), p, j.ID())
}
func convertTimeline(samples []*bigquery.QueryTimelineSample) []TimelineSample {
	timeline := make([]TimelineSample, len(samples))
	for i, sample := range samples {
		timeline[i] = TimelineSample{
			ActiveUnits:    sample.ActiveUnits,
			CompletedUnits: sample.CompletedUnits,
			Elapsed:        int64(sample.Elapsed),
			PendingUnits:   sample.PendingUnits,
			SlotMillis:     sample.SlotMillis,
		}
	}
	return timeline
}

//GetDetail returns job details
func (j *Job) GetDetail(ctx context.Context, bqj *bigquery.Job, bqc *bigquery.Client) error {
	status := bqj.LastStatus()
	fmt.Printf("bgj.Email(): %+v\n", bqj.Email())

	/*
		if bqj.Email() == "" {
			fmt.Printf("263 Error email is blank so stale record")
			return nil
		}
	*/

	fmt.Printf("bgj: %+v\n", bqj)

	detail := JobDetail{
		//--------------------------------------------------
		Email:   bqj.Email(),
		State:   StateString(status.State),
		Updated: time.Now(),
	}

	if status.Err() != nil {
		fmt.Printf("269 Error: %+v\n", status)
		detail.State = "Done"
		j.Detail = detail
		return nil
	}

	/*
		// Potential to improve performance by only query when insert job (not update job)
		key := datastore.NewKey(ctx, "Reservation", j.Name.ProjectId, 0, nil)
		reservation := new(Reservation)
		log.Debugf(ctx, "reservation debug, datastore key: %v", key)
		err := datastore.Get(ctx, key, reservation)
		if err != nil {
			return fmt.Errorf("Line 243, can't get from datastore: %v", err)
		}

		detail.ReservationID = reservation.Reservation_Id
		detail.Slots = int64(reservation.Reservation_Slot)
		log.Debugf(ctx, "detail.ReservvationID: %v", detail.ReservationID)
	*/

	config, err := bqj.Config()
	if err != nil {
		return fmt.Errorf("Error getting config: %+v\n", err)
	}
	fmt.Printf("query config Line 294: %+v\n", config)
	switch config.(type) {
	case *bigquery.QueryConfig:
		queryConfig, ok := config.(*bigquery.QueryConfig)
		if !ok {
			break
		}
		detail.Type = "Query"
		detail.Dst = queryConfig.Dst.FullyQualifiedName()
		detail.Priority = fmt.Sprintf("%v", queryConfig.Priority)
		stats, ok := status.Statistics.Details.(*bigquery.QueryStatistics)
		if !ok {
			break
		}
		detail.StatementType = stats.StatementType
		detail.Query = fmt.Sprintf("%+v\n", queryConfig.Q)
		fmt.Printf("310 before append: %+v\n", time.Now().String())
		fmt.Printf("311 stats:Timeline: %+v\n", stats.Timeline)
		detail.Timeline = convertTimeline(stats.Timeline)
		tableNames := make([]string, len(stats.ReferencedTables))
		for i, t := range stats.ReferencedTables {
			tableNames[i] = t.FullyQualifiedName()
		}
		detail.Src = strings.Join(tableNames, ",")
	case *bigquery.CopyConfig:
		detail.Type = "Copy"
		copyConfig, ok := config.(*bigquery.CopyConfig)
		if !ok {
			break
		}
		detail.Dst = copyConfig.Dst.FullyQualifiedName()
		tableNames := make([]string, len(copyConfig.Srcs))
		for i, t := range copyConfig.Srcs {
			tableNames[i] = t.FullyQualifiedName()
		}
		detail.Src = strings.Join(tableNames, ",")
	case *bigquery.ExtractConfig:
		detail.Type = "Extract"
		extractConfig, ok := config.(*bigquery.ExtractConfig)
		if !ok {
			break
		}
		detail.Dst = strings.Join(extractConfig.Dst.URIs, ",")
		detail.Src = extractConfig.Src.FullyQualifiedName()
	case *bigquery.LoadConfig:
		detail.Type = "Load"
		loadConfig, ok := config.(*bigquery.LoadConfig)
		if !ok {
			break
		}
		detail.Dst = loadConfig.Dst.FullyQualifiedName()
	default:
		fmt.Printf("Unable to identify Config of type %T", config)
	}
	j.Detail = detail
	return nil
}

func getJobInfo(ctx context.Context, p string) error {

	bqc, err := bigquery.NewClient(ctx, p)
	if err != nil {
		return err
	}

	// Creates a client.
	dsClient, err := datastore.NewClient(ctx, p)
	if err != nil {
		fmt.Printf("Failed to create client: %v", err)
	}

	dsJobs := make([]*Job, 0)
	query := datastore.NewQuery("Job").Filter("Name.ProjectId =", p)
	//fmt.Printf("108 bigquery records from datastore  %+v\n", query)
	dsJobKeys, err := dsClient.GetAll(ctx, query, &dsJobs)
	if err != nil {
		fmt.Printf("112: error : %+v\n", query)
		return err
	}

	//fmt.Printf("117 dsJobKeys records from datastore  %+v\n", dsJobKeys)

	for _, job := range dsJobs {
		// require job hosted project give app engine sa bigquery admin permission
		fmt.Printf("122: Before JobFromID %+v\n", job)

		j, err := bqc.JobFromID(ctx, job.Name.JobId)
		if err != nil {
			fmt.Printf("918: error JobFromID %v\n", err)
			return err
		}
		fmt.Printf("128: Get job info from bigquery client %+v\n", j)

		// set condition to get job detail for running jobs only

		fmt.Printf("917 Calling detail : %+v\n", j)
		job.GetDetail(ctx, j, bqc)
		fmt.Printf("923 after GetDetail():  %+v\n", job)
	}

	dsJobMap := make(map[string]*Job, len(dsJobs))
	for _, j := range dsJobs {
		dsJobMap[j.Name.String()] = j
	}

	for _, state := range []bigquery.State{bigquery.Running, bigquery.Pending} {

		fmt.Printf("268 bigquery state  %+v\n", state)
		jobIt := bqc.Jobs(ctx)
		jobIt.AllUsers = true
		jobIt.State = state

		for {
			j, err := jobIt.Next()
			fmt.Printf("275 bigquery state  %+v\n", j)
			if err == iterator.Done {
				break
			} else if err != nil {
				return err
			}
			fmt.Printf("281 bigquery state  %+v\n", j)
			k := BqJobKey(j, p)
			fmt.Printf("283 jobIt: %+v\n", k)

			if job, exists := dsJobMap[k]; exists {

				fmt.Printf("288 bigquery job exists in dsJobMap  %+v\n", job)

				// set condition to get job detail for running jobs only
				if job.Detail.State != "Done" {
					job.GetDetail(ctx, j, bqc)
				}
				fmt.Printf("294 job.Detail.State  %+v\n", job.Detail.State)
				fmt.Printf("295 Key [%+v] and value for dsJobMap  %+v\n", k, dsJobMap[k])

				delete(dsJobMap, k)

			} else {
				fmt.Printf("297 Couldn't find DS entry for %+v\n", k)
			}

		}

	}
	// set condition for running jobs only
	if _, err := dsClient.PutMulti(ctx, dsJobKeys, dsJobs); err != nil {
		fmt.Printf("Error saving keys: %v\n", err)
	}

	return nil

}
func printReservations(ctx context.Context, p string) {

	// Creates a client.
	client, err := datastore.NewClient(ctx, p)
	if err != nil {
		fmt.Printf("Failed to create client: %v", err)
	}

	// Sets the kind for the new entity.
	fmt.Println("hello world")
	kind := "Reservation"
	key := datastore.NameKey(kind, "anand-bq-test-1", nil)
	reservation := new(Reservation)
	fmt.Println("reservation debug, datastore key: ", key)

	err = client.Get(ctx, key, reservation)
	if err != nil {
		fmt.Println("error: ", err)
	}

	fmt.Println("Query : ", key, reservation.Reservation_Id, reservation.Reservation_Slot)

}
func testDataStore(ctx context.Context, p string) {
	client, err := datastore.NewClient(ctx, p)
	if err != nil {
		fmt.Println("error: ", err)
	}
	jname := &JobName{
		JobId:     "anand-testing",
		Location:  "TEST",
		ProjectId: "anand-test"}
	jdetail := &JobDetail{
		Type:  "Query",
		State: "Done"}
	jstat := &JobStatistics{
		CreateTime: time.Now(),
		EndTime:    time.Now(),
		StartTime:  time.Now()}

	j := &Job{
		Name:      *jname,
		UserEmail: "abc@abc.com",
		Stats:     *jstat,
		Detail:    *jdetail}

	key := datastore.NameKey("Task", j.Name.String(), nil)
	key, err = client.Put(ctx, key, j)
	if err != nil {
		fmt.Println("error: ", err)
	}

	/*
		_, err = client.Put(ctx, datastore.IncompleteKey("Task", nil), j)
		if err != nil {
			fmt.Println("put: ", err)
		}
	*/

}
func main() {
	file, _ := os.Open("config.json")
	defer file.Close()
	_ = json.NewDecoder(file)

	ctx := context.Background()
	// Set your Google Cloud Platform project ID.
	projectID := "anand-bq-test-2"
	testDataStore(ctx, projectID)

	//printReservations(ctx, projectID)
	//getJobInfo(ctx, projectID)
}
