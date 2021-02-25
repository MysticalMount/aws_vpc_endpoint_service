# aws_vpc_endpoint_service
Rewrites aws_vpc_endpoint_service data source in bash for use with TerraForm external data source

MysticalMount - Script to retrieve AWS VPC endpoint - until we can upgrade Terraform this will replace the data source "aws_vpc_endpoint_service"
Issues with this data source arose since AWS introduced new types of endpoints for S3 which can result in multiple results being returned, which
the AWS provider v2.7 (included with TF 11 automatically) - cannot handle without error.
 
HCP document about the issue:
https://discuss.hashicorp.com/t/notice-aws-vpc-endpoint-service-error-multiple-vpc-endpoint-services-matched/20472)

It uses the HCP TF external data source to take in JSON input from TF: <region> <service> <servicetype>
It outputs the endpoint name if it is found - which it should be as long as there isn't an error in the input

# Pre-reqs
- Linux host OS (that can run bash scripts)
- jq
- AWS cli
- Valid AWS cli credentials at the time the script is expected to run

# Usage
Populate the input variables as required:
- Region - AWS region
- Service - Uses a filter on the servicename so something like s3 or dynamodb will suffice
- ServiceType - Interface or Gateway

A list and count can be used for the input variables if more than one endpoint service name is required.

# Example output
When running the input as specified in example.tf, the output produced is as per the output var:

    terraform apply
    data.external.endpoint_services: Refreshing state...

    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

    Outputs:

    result = com.amazonaws.eu-west-2.s3
