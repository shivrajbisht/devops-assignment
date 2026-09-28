variable "account_a_id" {
	description  = "AWS Account A ID"
	type	= string
	default	= "000000000000"
}

variable "account_b_id" {
	description	= "AWS Account B ID"
	type	=  string
	default	=  "111111111111"
}

variable "s3_bucket_name" {
	description  = "Name of the S3 Bucket that RoleC will have access to"
	type	= string
	default	=  "devops-assignment-app-bucket"
}

variable "group2_users" {
	description	= "Two named users for group2 (full console + CLI Access)"
	type	=   list(string)
	default =  ["alice", "bob"]
}
