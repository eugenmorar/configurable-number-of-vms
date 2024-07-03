variable "vm_count" {
	description = "VMs instance count" 
    type        = number
	default = 2
}

variable "vm_flavor" { 
	description = "VMs ubuntu 24.04 ami"
	type        = string
}

variable "vm_type" {
	description = "VMs ec2 instance type"
	type        = string
}

