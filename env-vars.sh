#!/bin/sh
# Required for the OCI Provider
export TF_VAR_tenancy_ocid=""
export TF_VAR_compartment_name="bds-pm-tf-auto"
export TF_VAR_region="us-ashburn-1"
export TF_VAR_home_region="us-phoenix-1"
export TF_VAR_bds_instance_cluster_admin_password=`echo 'Init01#'|openssl base64`
export TF_VAR_ssh_keys_prefix="./userdata/demoBDSkey"
export TF_VAR_ssh_public_key=$(cat $TF_VAR_ssh_keys_prefix.pub)
export TF_VAR_ssh_private_key=$(cat $TF_VAR_ssh_keys_prefix)