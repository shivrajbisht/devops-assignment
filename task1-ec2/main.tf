provider "aws" {
	region	= "ap-south-1"
}

module "ec2_instance"	 {
	source	= 	"../modules/ec2-instances"
	
	ami_id	= 	var.ami_id
	environment	= var.environment
	owner	=	var.owner

	prevent_destroy_instance  = var.prevent_destroy_instance

	instances = var.instances
}
