data "oci_objectstorage_namespace" "bds-demo-namespace" {

  #Optional
  compartment_id = local.compartment_ocid
}

/* output "ns"{
    value=
} */

resource "oci_objectstorage_bucket" "tpcds-text-bc" {
  #Required
  compartment_id = local.compartment_ocid
  name           = "tpcds_text"
  namespace      = data.oci_objectstorage_namespace.bds-demo-namespace.namespace

  #Optional 
  freeform_tags = { "environment" = "bds-demo" }
}

resource "oci_objectstorage_preauthrequest" "bds_preauthenticated_request" {
  #Required
  access_type  = "AnyObjectWrite"
  bucket       = oci_objectstorage_bucket.tpcds-text-bc.name
  name         = "tpcds-text-pre-auth"
  namespace    = data.oci_objectstorage_namespace.bds-demo-namespace.namespace
  time_expires = "2022-08-25T21:10:29.600Z"
}

/* output par {
  value = oci_objectstorage_preauthrequest.bds_preauthenticated_request
}  */