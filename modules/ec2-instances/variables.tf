variable "instances" {
	description	= "MAP for instance configuration"
	type	= map(object({
	instance_type	= string
	key_name	= string

	root_volume = object({
	type	= string
	size	= number
	})
	}))
}

variable "ami_id" {
	description = "AMI ID to use for all instances in ap-south-1"
	type	= string
	default	= "ami-0f58b397bc5c1f2e8" # Amazon Linux 2023 , ap-soouth-1
}

variable "environment" {
	description  = "Environment name e.g dev, stage, prod"
	type	= string
}

variable "owner" {
	description = "Owner name for tagging"
	type	=	string
}

variable "prevent_destroy_instance" {
	description = "Name of the instances (map key)	that should be protected for accidental deletion"
	type	= string
}


