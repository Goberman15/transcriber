package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/transcribe"
	"github.com/aws/aws-sdk-go-v2/service/transcribe/types"
	"github.com/joho/godotenv"
)

var transcribeClient *transcribe.Client

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO())

	if err != nil {
		log.Fatalf("Fail to Load AWS SDK: %v\n", err)
	}

	transcribeClient = transcribe.NewFromConfig(cfg)

	err = godotenv.Load()

	if err != nil {
		log.Fatalf("Fail to Load .env file: %v\n", err)
	}
}

func Handler(ctx context.Context, evt events.S3Event) error {
	for _, record := range evt.Records {
		bucketName := record.S3.Bucket.Name
		objectKey := record.S3.Object.Key

		sourcePath := fmt.Sprintf("s3://%s/%s", bucketName, objectKey)

		splittedKey := strings.Split(objectKey, "/")

		if len(splittedKey) < 3 {
			return fmt.Errorf("invalid object key: %s", objectKey)
		}

		path := fmt.Sprintf("%s/%s", os.Getenv("transcript_prefix"), strings.Join(splittedKey[1:len(splittedKey)-1], "/"))
		fileName := filepath.Base(splittedKey[len(splittedKey)-1])

		params := &transcribe.StartTranscriptionJobInput{
			Media: &types.Media{
				MediaFileUri: &sourcePath,
			},
			TranscriptionJobName: &fileName,
			LanguageOptions: []types.LanguageCode{
				types.LanguageCodeArSa,
				types.LanguageCodeIdId,
			},
			OutputBucketName: &bucketName,
			OutputKey:        &path,
		}

		fmt.Println("Start Transcription Job of", fileName)
		_, err := transcribeClient.StartTranscriptionJob(context.Background(), params)

		if err != nil {
			return fmt.Errorf("fail to start transcription job: %v", err)
		}
		fmt.Println("Success Starting Transcription Job of", fileName)
	}

	return nil
}

func main() {
	lambda.Start(Handler)
}
