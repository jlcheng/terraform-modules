# terraform-modules

Modules to be referenced with 

	module "ecs-cluster" {
	    source  = "git::https://github.com/jlcheng/terraform-modules.git//ecs-cluster"
		version = "1.0.0"
		env        = "e"
  		cluster_id = "alpha"
	}


