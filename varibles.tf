variable tenancy_ocid {
}
variable compartment_name {
}
/* variable compartment_ocid {
  default=oci_identity_compartment.bds-demo-compartment.id
}
 */
variable "bds_instance_cluster_admin_password" {
}
variable home_region {
}
variable region {
}
variable ssh_public_key {
}
variable ssh_keys_prefix {
}
variable ssh_private_key {
}
variable bds_cluster_name {
}
variable vm_image_id {
  type = map
  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    ap-hyderabad-1   = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaaix234khpifwwj3dk56kuccwjmg2dkp6ohywusccduebruggrpexq"
    ap-melbourne-1   = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaa7a2p2sezcdkbclvtjkcbnc6rjt4a5r53pr4s3lw7l42hktw4klra"
    ap-mumbai-1      = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaanwfcq3baulkm73kcimzymx7qgfpoja2b56wgwhopjjgrz4om67zq"
    ap-osaka-1       = "ocid1.image.oc1.ap-osaka-1.aaaaaaaacatv3hltk6i3oxgegebmecd2ucp6ky5qiyeksj53dcxnjkg2bzbq"
    ap-seoul-1       = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaqkq5kzgr5ofegy4yhx4z3rjqil7n4gcaaw6vrodj2f2463jwb35q"
    ap-sydney-1      = "ocid1.image.oc1.ap-sydney-1.aaaaaaaao3vineoljixw657cxmbemwasdgirfy6yfgaljqsvy2dq7wzj2l4q"
    ap-tokyo-1       = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaapjdxul7sl5m726x46fnuinb3fisawuuo7dz5ig72bonvd3d5743a"
    ca-montreal-1    = "ocid1.image.oc1.ca-montreal-1.aaaaaaaamcmyjjewzrw7qz66lnsl4hf7mkaznw6iyrrdwc22z56vltj36mka"
    ca-toronto-1     = "ocid1.image.oc1.ca-toronto-1.aaaaaaaaatrbgo5w66d54ig53rdj5wpxtcqyl4rcrvhbh3upyw2audmjbyea"
    eu-amsterdam-1   = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaaie5km236l53ymcvpwufyb2srtc3hw2pa6astfjdafzlxxdv5nfsq"
    eu-frankfurt-1   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaavz6p7tyrczcwd5uvq6x2wqkbwcrjjbuohbjomtzv32k5bq24rsha"
    eu-zurich-1      = "ocid1.image.oc1.eu-zurich-1.aaaaaaaa5ganyj57k2dqyik4m4btpuq23le3e7clh56rjhgz6fekvtoyazqa"
    me-jeddah-1      = "ocid1.image.oc1.me-jeddah-1.aaaaaaaasnvw2crg3ifjtboya3kg2c2kjchqqh4fwxwd74zx7mhikhch4vha"
    sa-saopaulo-1    = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa36l36hud3764qtgfcwko3uxlxht4fsy6m2ojirr2wroobkg446pa"
    uk-gov-london-1  = "ocid1.image.oc4.uk-gov-london-1.aaaaaaaa2l5o2kn27bk2kluxumoe4rrwt7hl3a3vbhhs2hrjxgshm75fdmba"
    uk-london-1      = "ocid1.image.oc1.uk-london-1.aaaaaaaaz57okycdlykwzwegouf6p4fl6leo3mf7zs2setxxbls26hctpkgq"
    us-ashburn-1     = "ocid1.image.oc1.iad.aaaaaaaahjkmmew2pjrcpylaf6zdddtom6xjnazwptervti35keqd4fdylca"
    us-gov-ashburn-1 = "ocid1.image.oc3.us-gov-ashburn-1.aaaaaaaaneeyv672johkcvrpswr6zpjo67n7n6ya6zh26mibowvauhhkbdlq"
    us-gov-chicago-1 = "ocid1.image.oc3.us-gov-chicago-1.aaaaaaaakssecvwmoqavttlwusgb67zulznfspv34ewjbhqp5226ijsyoz2a"
    us-gov-phoenix-1 = "ocid1.image.oc3.us-gov-phoenix-1.aaaaaaaatohoga7ltqm4rgt55m444tqwefdgflyp7pejpucil2rcm4qnp5qa"
    us-langley-1     = "ocid1.image.oc2.us-langley-1.aaaaaaaauchq36gd66ixrr5e5k7gpyli53kby56nbyztimml3aukfa3igt7a"
    us-luke-1        = "ocid1.image.oc2.us-luke-1.aaaaaaaanqhrjcbc2ye5wkgeokf5w6lekfetiszimgds7d7xjhty6po7klfa"
    us-phoenix-1     = "ocid1.image.oc1.phx.aaaaaaaav3isrmykdh6r3dwicrdgpmfdv3fb3jydgh4zqpgm6yr5x3somuza"
  }
}