output "instance_ids" {
	description = "Map of instance name to the instance ID"
	value	= {
	for k, v in aws_instance.this : k => v.id
	}
}


output "private_ips" {
	description = "Map of Instance name to Private IP"
	value = {
	for k,v in aws_instance.this : k => v.private_ip
	}
}
