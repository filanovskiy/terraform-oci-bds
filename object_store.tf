data "oci_objectstorage_namespace" "bds-demo-namespace" {

    #Optional
    compartment_id = locals.compartment_id
}


resource "oci_objectstorage_bucket" "tpcds-text-bc" {
    #Required
    compartment_id = locals.compartment_id
    name = "tpcds_text"
    namespace = oci_objectstorage_namespace.bds-demo-namespace

    #Optional 
    freeform_tags = { "environment" = "bds-demo" }
}

resource "oci_objectstorage_preauthrequest" "bds_preauthenticated_request" {
    #Required
    access_type = "AnyObjectWrite"
    bucket = oci_objectstorage_bucket.tpcds-text-bc
    name = "tpcds-text-pre-auth"
    namespace = oci_objectstorage_namespace.bds-demo-namespace
    time_expires = "${var.preauthenticated_request_time_expires}"
}

/* data "oci_objectstorage_preauthrequest" "test_preauthenticated_request" {
    #Required
    bucket = "${var.preauthenticated_request_bucket}"
    namespace = "${var.preauthenticated_request_namespace}"
    par_id = "${oci_objectstorage_preauthrequest.test_par.id}"
}
 */
 output par{
     value = oci_objectstorage_preauthrequest.bds_preauthenticated_request
 }