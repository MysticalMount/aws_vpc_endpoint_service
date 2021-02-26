data "external" "endpoint_services" {
  program = ["bash", "./custom_scripts/get_endpoint_service.sh"]

  query = {
    vpce_region  = "eu-west-2"
    vpce_service = "s3"
    vpce_type    = "Gateway"
  }
}

output "result" {
  value = "${data.external.endpoint_services.result.servicename}"
}
