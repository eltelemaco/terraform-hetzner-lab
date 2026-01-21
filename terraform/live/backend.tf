terraform {
    cloud {
      organization = "TelemacoInfraLabs"

       workspaces {
         name = "terraform-hetzner-lab"
       }
    }


#   backend "remote" {
#     organization = "TelemacoInfraLabs"

#     workspaces {
#       name = "terraform-hetzner-lab"
#     }
#   }
}