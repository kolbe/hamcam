package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"

	"fmt"
	"log"
	"os"
)

func main() {

	if len(os.Args) != 2 {
		log.Fatal("No filename given on command line")
	}

	file, err := os.Open(os.Args[1]) // For read access.
	if err != nil {
		log.Fatal(err)
	}

	svc := s3.New(session.New())

	fmt.Println("Gonna upload " + os.Args[1])

	input := &s3.PutObjectInput{
		Body:   file,
		Bucket: aws.String("www.lakeunion.live"),
		Key:    aws.String("cam.jpeg"),
	}

	result, err := svc.PutObject(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	fmt.Println(result)

}
