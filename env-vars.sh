#!/bin/sh
# Required for the OCI Provider
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaazo7h6yqgac7aunojr2tjsxux3ipdyamc3fgkvz7lubvdtsjyf4gq"
#export TF_VAR_compartment_ocid="ocid1.compartment.oc1..aaaaaaaaqfrh6ndx3miiikntt4ih5v252c5l3o24qbj7mjsaqcoilwss52oq"
export TF_VAR_compartment_name="bds-pm-tf-auto"
export TF_VAR_region="us-ashburn-1"
export TF_VAR_home_region="us-phoenix-1"
export TF_VAR_bds_instance_cluster_admin_password="V2VsY29tZTE="
export TF_VAR_ssh_keys_prefix="./userdata/demoBDSkey"
export TF_VAR_ssh_public_key=$(cat $TF_VAR_ssh_keys_prefix.pub)
export TF_VAR_ssh_private_key=$(cat $TF_VAR_ssh_keys_prefix)