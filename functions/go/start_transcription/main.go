package main

import (
	"context"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/transcribe"
)

var s3Client *s3.Client
var transcribeClient *transcribe.Client

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO())

	if err != nil {
		log.Fatalf("Fail to Load AWS SDK: %v\n", err)
	}

	s3Client = s3.NewFromConfig(cfg)
	transcribeClient = transcribe.NewFromConfig(cfg)
}

func Handler(ctx context.Context, evt events.S3Event) error {
	for _, record := range evt.Records {
		fmt.Println(record.S3.Bucket.Name)
		fmt.Println(record.S3.Object.Key)
	}

	return nil
}

func main() {
	lambda.Start(Handler)
}
