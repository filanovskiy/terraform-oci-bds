# API Gateway Blogpost
# https://blogs.oracle.com/developers/creating-your-first-api-gateway-in-the-oracle-cloud

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
  image          = "iad.ocir.io/oraclebigdatadb/alexey/hello-java:0.0.3"
  memory_in_mbs  = "128"

  #Optional
  freeform_tags      = { "environment" = "bds-demo" }
  timeout_in_seconds = "60"
}

resource "oci_functions_invoke_function" "bds-demo-function-invoke" {
  depends_on = [oci_identity_policy.allow_bds_read_oci_resources]
  #Required
  function_id = oci_functions_function.bds-demo-function.id
}

resource "oci_apigateway_gateway" "bds-demo-gateway" {
  #Required
  compartment_id = local.compartment_ocid
  endpoint_type  = "PUBLIC"
  subnet_id      = module.vcn.subnet_ids

  #Optional
  display_name  = "bds-demo-api-gw"
  freeform_tags = { "environment" = "bds-demo" }
}


resource "oci_apigateway_deployment" "bds-demo-gw-deployment-http" {
  #Required
  compartment_id = local.compartment_ocid
  gateway_id     = oci_apigateway_gateway.bds-demo-gateway.id
  path_prefix    = "/http"

  specification {
    request_policies {
      cors {
        #Required
        allowed_origins = ["*"]
      }
      rate_limiting {
        #Required
        rate_in_requests_per_second = "10"
        rate_key                    = "CLIENT_IP"
      }
    }
    routes {
      #Required
      backend {
        #Required
        type = "HTTP_BACKEND"
        url  = "https://api.weather.gov"
      }
      path    = "/api"
      methods = ["GET"]
    }
  }
  #Optional
  display_name  = "http-api-gw-deployment"
  freeform_tags = { "environment" = "bds-demo" }
}

resource "oci_apigateway_deployment" "bds-demo-gw-deployment-fn" {
  #Required
  compartment_id = local.compartment_ocid
  gateway_id     = oci_apigateway_gateway.bds-demo-gateway.id
  path_prefix    = "/fn"

  specification {

    request_policies {
      cors {
        #Required
        allowed_origins = ["*"]
      }

      rate_limiting {
        #Required
        rate_in_requests_per_second = "10"
        rate_key                    = "CLIENT_IP"
      }
    }

    routes {
      #Required
      backend {
        #Required
        type        = "ORACLE_FUNCTIONS_BACKEND"
        function_id = oci_functions_function.bds-demo-function.id
      }
      path    = "/api"
      methods = ["GET"]
    }
  }

  #Optional
  display_name  = "fn-api-gw-deployment"
  freeform_tags = { "environment" = "bds-demo" }
}