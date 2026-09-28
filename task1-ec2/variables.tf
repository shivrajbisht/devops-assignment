variable "ami_id" {
	description = "AMI ID for ap-south-1"
	type	= string
	default	= "ami-0f58b397bc5c1f2e8" # Amazon Linux 2
}

variable "owner" {
	description = "Owner name for tagging"
	type	= string
	default	= "shivraj"
}

variable "environment" {
	description = "Environment Name"
	type	= string
	default	= "dev"
}

variable "prevent_destroy_instance" {
	description = "Instance name to protect from accidental deletion"
	type	= string
	default = "app-server"
}

variable "instances" {
	description = "Map of 5 instance configuration"
	type	= map(object({
		instance_type	= string
		key_name	= string
		
		root_volume	= object({
			type = string
			size	= number
		})
	
	}))
	
}


