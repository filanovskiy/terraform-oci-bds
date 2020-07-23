data "oci_objectstorage_namespace" "bds-demo-namespace" {
  #Optional
  compartment_id = local.compartment_ocid
}
// bucket for tpcds text
resource "oci_objectstorage_bucket" "tpcds-text-bc" {
  #Required
  compartment_id = local.compartment_ocid
  name           = "tpcds_text"
  namespace      = data.oci_objectstorage_namespace.bds-demo-namespace.namespace

  #Optional 
  freeform_tags = { "environment" = "bds-demo" }
}

resource "oci_objectstorage_preauthrequest" "bds_preauth_tpcds" {
  #Required
  access_type  = "AnyObjectWrite"
  bucket       = oci_objectstorage_bucket.tpcds-text-bc.name
  name         = "tpcds-text-pre-auth"
  namespace    = data.oci_objectstorage_namespace.bds-demo-namespace.namespace
  time_expires = "3000-08-25T21:10:29.600Z"
}

// Bucke for bike rental data from New York City’s Citi Bike bicycle sharing servic

resource "oci_objectstorage_bucket" "bikes" {
  #Required
  compartment_id = local.compartment_ocid
  name           = "bikes_data"
  namespace      = data.oci_objectstorage_namespace.bds-demo-namespace.namespace

  #Optional 
  freeform_tags = { "environment" = "bds-demo" }
}

resource "oci_objectstorage_preauthrequest" "bds_preauth_bikes" {
  #Required
  access_type  = "AnyObjectWrite"
  bucket       = oci_objectstorage_bucket.bikes.name
  name         = "bikes-pre-auth"
  namespace    = data.oci_objectstorage_namespace.bds-demo-namespace.namespace
  time_expires = "3000-08-25T21:10:29.600Z"
}

