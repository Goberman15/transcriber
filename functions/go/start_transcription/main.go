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
)

var transcribeClient *transcribe.Client

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO())

	if err != nil {
		log.Fatalf("Fail to Load AWS SDK: %v\n", err)
	}

	transcribeClient = transcribe.NewFromConfig(cfg)
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
		audioFilename := splittedKey[len(splittedKey)-1]
		ext := filepath.Ext(audioFilename)
		fileName := audioFilename[:len(audioFilename)-len(ext)]
		outputKey := fmt.Sprintf("%s/%s.json", path, fileName)

		params := &transcribe.StartTranscriptionJobInput{
			Media: &types.Media{
				MediaFileUri: &sourcePath,
			},
			TranscriptionJobName: &fileName,
			LanguageCode:         types.LanguageCodeIdId,
			// IdentifyMultipleLanguages: aws.Bool(true),
			// LanguageOptions: []types.LanguageCode{
			// 	types.LanguageCodeArSa,
			// 	types.LanguageCodeIdId,
			// },
			OutputBucketName: &bucketName,
			OutputKey:        &outputKey,
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
