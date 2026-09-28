locals	{
	# Find the instances that need lifecycle protection
	protected_instance	= 	var.prevent_destroy_instance
}

resource "aws_instance" "this" {
	for_each	= var.instances
	
	ami	=	var.ami_id
	instance_type	=	each.value.instance_type
	key_name	=	each.value.key_name


	root_block_device {
		volume_type	= each.value.root_volume.type
		volume_size	= each.value.root_volume.size
		encrypted	= true
	}
	
	tags = {
		Name	= each.key
		Environment	= var.environment
		Owner	= var.owner
	}

	lifecycle {
		prevent_destroy = each.key == local.protected_instance ? true : false
	}
}
