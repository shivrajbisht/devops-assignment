output "instance_ids" {
	description = "Map the Instance name to the Instance ID"
	value	= module.ec2_instance.instance_ids
}

output "private_ips" {
	description = "Map the Instance name with private IP"
	value	= module.ec2_instance.private_ips
}
