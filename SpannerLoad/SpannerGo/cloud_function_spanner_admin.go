package spannertools


import (
	"context"
	"log" 
	"encoding/json" // Encoding and Decoding Package
	"fmt" 
	instance "cloud.google.com/go/spanner/admin/instance/apiv1"
	instancepb "google.golang.org/genproto/googleapis/spanner/admin/instance/v1"
	"google.golang.org/genproto/protobuf/field_mask"

)


// PubSubMessage is the payload of a Pub/Sub event. Please refer to the docs for
// additional information regarding Pub/Sub events.
type PubSubMessage struct {
	Data []byte `json:"data"`
}

// ScaleInstance consumes a Pub/Sub message.
func ScaleInstance(ctx context.Context, m PubSubMessage) error {
	log.Println(string(m.Data))
	var info map[string]interface{}
    err := json.Unmarshal([]byte(m.Data),&info)
	if err != nil {
		log.Println("Error: ", err)
		return nil
	}
	instanceID := info["incident"].(map[string]interface{})["resource"].(map[string]interface{})["labels"].(map[string]interface{})["instance_id"]
	log.Println("Instance id: ", instanceID)
	// args := []string{"spanner", "instances", "describe", instanceID.(string)}
	// cmd := exec.Command("gcloud", args...)
	// cmd.Stdout = os.Stdout
	// cmd.Stderr = os.Stderr
	// if err := cmd.Run(); err != nil {
	// 	log.Println("Error: ", err)
	// 	return nil
	// }
	//ctx := context.Background()
	c,err := instance.NewInstanceAdminClient(ctx)
	if err != nil {
		log.Println("Error: ", err)
		return nil
	}
	var instanceName = fmt.Sprintf("projects/%s/instances/%s", "anand-bq-test-2", instanceID)
	var req = &instancepb.GetInstanceRequest{Name: instanceName}		
	resp, err := c.GetInstance(ctx, req)
	if err != nil {
		log.Println("Error: ", err)
		return nil
	}
	// TODO: Use resp.
	log.Println("Name in the response: ", resp.GetName())
	log.Println("Display in the response: ", resp.GetDisplayName())
	log.Println("Node response: ", resp.GetNodeCount())

	var req2 = &instancepb.UpdateInstanceRequest{
		Instance: &instancepb.Instance{
			Name:      instanceName,
			//NodeCount: resp.GetNodeCount()+1, //uncomment this line to increment the node count by 1
			NodeCount: resp.GetNodeCount(),
		},
		FieldMask: &field_mask.FieldMask{
			Paths: []string{"node_count"},
		},
	}
	op, err := c.UpdateInstance(ctx, req2)
	if err != nil {
		log.Printf("failed new admin client. err=%+v\n", err)
		return nil
	}

	resp2, err := op.Wait(ctx)
	if err != nil {
		log.Printf("failed new admin client. err=%+v\n", err)
		return nil
	}
	log.Printf("resp is %+v\n", resp2)

	return nil
}