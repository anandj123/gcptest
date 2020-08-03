package main
 
import (
	instance "cloud.google.com/go/spanner/admin/instance/apiv1"
	instancepb "google.golang.org/genproto/googleapis/spanner/admin/instance/v1"
	"context"
    "fmt"  
	"encoding/json" 
	"google.golang.org/genproto/protobuf/field_mask"

)
// JSON mapping
var JSON = `{"incident": {"incident_id": "0.lq4eyvmi4f8e","resource_id": "","resource_name": "anand-bq-test-2 Cloud Spanner Instance labels {instance_id=test-1, location=us-east1, instance_config=regional-us-east1}","resource": {"type": "spanner_instance","labels": {"instance_config":"regional-us-east1","instance_id":"test-1","location":"us-east1"}},"resource_type_display_name": "Cloud Spanner Instance","metric":{"type": "spanner.googleapis.com/instance/cpu/utilization", "displayName": "CPU utilization"},"started_at": 1596382203,"policy_name": "pubsub-autoscale","condition_name": "Cloud Spanner Instance - CPU utilization","condition": {"name":"projects/anand-bq-test-2/alertPolicies/8922086060380677122/conditions/8922086060380679401","displayName":"Cloud Spanner Instance - CPU utilization","conditionThreshold":{"filter":"metric.type=\"spanner.googleapis.com/instance/cpu/utilization\" resource.type=\"spanner_instance\"","aggregations":[{"alignmentPeriod":"60s","perSeriesAligner":"ALIGN_MEAN"}],"comparison":"COMPARISON_GT","thresholdValue":0.01,"duration":"60s","trigger":{"count":1}}},"url": "https://console.cloud.google.com/monitoring/alerting/incidents/0.lq4eyvmi4f8e?project=anand-bq-test-2","state": "closed","ended_at": 1596382533,"summary": "CPU utilization for anand-bq-test-2 Cloud Spanner Instance labels {instance_id=test-1, location=us-east1, instance_config=regional-us-east1} with metric labels {database=hello, region=us-east1} returned to normal with a value of 0.005."},"version": "1.2"}`

func main() {
	var info map[string]interface{}
    json.Unmarshal([]byte(JSON),&info)
	instanceID := info["incident"].(map[string]interface{})["resource"].(map[string]interface{})["labels"].(map[string]interface{})["instance_id"]
    // Print the output from info map.
	fmt.Println("instance configuration",info["incident"].(map[string]interface{})["resource"].(map[string]interface{})["labels"].(map[string]interface{})["instance_config"])
	fmt.Println(instanceID)
	fmt.Println(info["incident"].(map[string]interface{})["resource"].(map[string]interface{})["labels"].(map[string]interface{})["location"])
	// args := []string{"spanner", "instances", "describe", instanceID.(string)}
	// cmd := exec.Command("gcloud", args...)
	// cmd.Stdout = os.Stdout
	// cmd.Stderr = os.Stderr
	// if err := cmd.Run(); err != nil {
	// 	fmt.Println("Error : ", err)
	// }


	ctx := context.Background()
	

	c,err := instance.NewInstanceAdminClient(ctx)
	if err != nil {
		// TODO: Handle error.
	}
	var instanceName = fmt.Sprintf("projects/%s/instances/%s", "anand-bq-test-2", instanceID)
	
	var req = &instancepb.GetInstanceRequest{Name: instanceName}		
	resp, err := c.GetInstance(ctx, req)
	if err != nil {
		// TODO: Handle error.
	}
	// TODO: Use resp.
	fmt.Println("Name in the response: ", resp.GetName())
	fmt.Println("Display in the response: ", resp.GetDisplayName())
	fmt.Println("Node response: ", resp.GetNodeCount())


	req2 := &instancepb.UpdateInstanceRequest{
		Instance: &instancepb.Instance{
			Name:      instanceName,
			NodeCount: resp.GetNodeCount()+1,
		},
		FieldMask: &field_mask.FieldMask{
			Paths: []string{"node_count"},
		},
	}
	op, err := c.UpdateInstance(ctx, req2)
	if err != nil {
		fmt.Printf("failed new admin client. err=%+v\n", err)
	}

	resp2, err := op.Wait(ctx)
	if err != nil {
		fmt.Printf("failed new admin client. err=%+v\n", err)
	}
	fmt.Printf("resp is %+v\n", resp2)

}