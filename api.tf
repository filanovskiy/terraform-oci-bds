resource "oci_functions_application" "bds-demo-app" {
  #Required
  compartment_id = local.compartment_ocid
  display_name   = "bds-demo-application"
  subnet_ids     = tolist([module.vcn.subnet_ids, ])

  #Optional
  // config = "${var.application_config}"
  freeform_tags = { "environment" = "bds-demo" }
}

resource "oci_functions_function" "bds-demo-function" {
  #Required
  application_id = oci_functions_application.bds-demo-app.id
  display_name   = "bds-demo-function"
  image          = "iad.ocir.io/oraclebigdatadb/alexey/hello-java:0.0.2"
  memory_in_mbs  = "128"

  #Optional
  freeform_tags      = { "environment" = "bds-demo" }
  timeout_in_seconds = "60"
}

resource "oci_functions_invoke_function" "bds-demo-function-invoke" {
  #Required
  function_id = oci_functions_function.bds-demo-function.id
}

/* resource "oci_apigateway_gateway" "test_gateway" {
  #Required
  compartment_id = local.compartment_ocid
  endpoint_type  = "Oracle Function"
  subnet_id      = module.vcn.subnet_ids

  #Optional
  display_name  = "bds-demo-api-gw"
  freeform_tags = { "environment" = "bds-demo" }
} */