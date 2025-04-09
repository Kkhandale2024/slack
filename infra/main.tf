
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.1"

  project_id   = "my-project-44865-424207"
  network_name = "test-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    # {
    #   subnet_name   = "${local.name}-subnet-public-1"
    #   subnet_ip     = "10.10.10.0/24"
    #   subnet_region = "us-central1"
    # },

   {
    subnet_name           = "subnet-private-1"
    subnet_ip             = "10.10.20.0/24"
    subnet_region         = "us-central1"
    subnet_private_access = "true"
    subnet_flow_logs      = "true"
    description           = "This subnet has a description"
   },

  # {
  #   subnet_name           = "${local.name}-subnet-private-2"
  #   subnet_ip             = "10.10.30.0/24"
  #   subnet_region         = "us-central1"
  #   subnet_private_access = "true"
  #   subnet_flow_logs      = "true"
  #   description           = "This subnet has used for GKE"
  # }
]

# secondary_ranges = {
#   subnet-public-1 = [
#     {
#       range_name    = "${local.name}-subnet-private-1-secondary-01"
#       ip_cidr_range = "192.168.64.0/24"
#     },
#   ],
#   subnet-public-2 = [
#     {
#       range_name    = "${local.name}-subnet-private-2-secondary-01"
#       ip_cidr_range = "192.168.128.0/24"
#    },
#      ]
#   }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    },

  ]
}