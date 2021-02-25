#!/bin/bash
# MysticalMount - Script to retrieve AWS VPC endpoint - until we can upgrade Terraform this will replace the data source "aws_vpc_endpoint_service"
# Issues with this data source arose since AWS introduced new types of endpoints for S3 which can result in mutiple results being returned, which
# the AWS provider v2.7 (included with TF 11 automatically) - cannot handle without error.
# 
# HCP document about the issue:
# https://discuss.hashicorp.com/t/notice-aws-vpc-endpoint-service-error-multiple-vpc-endpoint-services-matched/20472)
#
# It uses the HCP TF external data source to take in JSON input from TF: <region> <service> <servicetype>
# It outputs the endpoint name if it is found - which it should be as long as there isnt an error in the input

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
  test -f $(which aws) || error_exit "aws cli command not detected in path, please install it"
}

function parse_input() {
  # jq reads from stdin so we don't have to set up any inputs, but let's validate the outputs
  eval "$(jq -r '@sh "export VPCE_REGION=\(.vpce_region) VPCE_SERVICE=\(.vpce_service) VPCE_TYPE=\(.vpce_type)"')"
  if [[ -z "${VPCE_REGION}" ]]; then export VPCE_REGION=none; fi
  if [[ -z "${VPCE_SERVICE}" ]]; then export VPCE_SERVICE=none; fi
  if [[ -z "${VPCE_TYPE}" ]]; then export VPCE_TYPE=none; fi
}

function get_endpoint() {
  return_json=$(aws ec2 describe-vpc-endpoint-services --filter Name=service-name,Values=*${VPCE_SERVICE}* --region=${VPCE_REGION})
  endpoint=$(jq -c -r '.ServiceDetails[] | select( .ServiceType[].ServiceType | contains("'${VPCE_TYPE}'"))| .ServiceName ' <<< $return_json)
}

function produce_output() {
  jq -n \
    --arg endpoint "$endpoint" \
    '{"endpoint":$endpoint}'
}

# main()
check_deps
parse_input
get_endpoint
# The below line can be uncommented to help resolve issues
# echo "In: ${VPCE_REGION} ${VPCE_SERVICE} ${VPCE_TYPE} Out: ${endpoint}" > ${VPCE_SERVICE}.log
produce_output