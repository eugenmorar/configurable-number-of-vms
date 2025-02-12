# configurable-number-of-vms
This repo implements the following requirements using aws and terraform:

* the code creates a configurable number of VMs (any number between 2 and 100)
* for each VM specify VM flavor and VM image
* VM admin passwords must be generated automatically and should be different on each VM
* the VMs should reside in the same network VPC or virtual net and should be able to ping each other
* the code automatically ping instances in a round-robin fashion (VM0-> VM1, VM1->VM2, VM2->VM0) 
* record the ping_result (fail/pass between source and destination) into one terraform output variable

## Create
To provision this example, populate terraform.tfvars with the required variables for vm_flavor, vm_count and vm_type.
```
vm_flavor = "ami-04b70fa74e45c3917"
vm_count = 3
vm_type = "t2.micro"
```

(1) Initialize the project than (2) generate the execution plan and after that (3) apply the tf manifests.
```
terraform init 
terraform plan 
terraform apply -var-file=terraform.tfvars
```

But before launch make this preparatory step (0) create a new certificate in your own aws account and download the .pem locally. Modify the code to connect at aws with your own certificate.

## Variables

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- | 
| vm_flavor | The base image for VMs | string | n/a | yes |
| vm_type |	Instance type for this group of VMs | string | n/a | yes |
| vm_count | The number of instances | number | 2 | yes |


## How it works
The tf code creates 13 supporting resources for $vm_count amount of ec2 instances of flavor $vm_flavor. A vpc, a public subnet, an internet gateway, a security group (with ssh access) and a route table (with default gateway) will be provided to deliver public conectivity to newly created instances. The password is generated randomly and configured as a root password using an userData commmand.

In order to test the conectivity between VMs the null_script will be fired (once) after the creation of VMs verifying with a remote_exec if the instances are ready before running a local_exec script that will ping $NEXT_PRIVATE_IP.

## Results
```
.../configurable-number-of-vms# terraform output public_ips
tomap({
  "0" = "44.220.177.176"
  "1" = "44.199.236.187"
  "2" = "3.237.203.54"
})

.../configurable-number-of-vms# terraform output private_ips
tomap({
  "0" = "10.110.0.100"
  "1" = "10.110.1.128"
  "2" = "10.110.9.154"
})

#Passwords are just for show. Don't use real creds in plain code! 
.../configurable-number-of-vms# terraform output passwords
tomap({
  "0" = "<MBAo=}Bt]nO3#_Z"
  "1" = "z}Pm-{vkw_R(r%j$"
  "2" = "(U1p=x+C7vmbg&XZ"
})

.../configurable-number-of-vms# terraform output ping_results
[
  <<-EOT
  ping from VM[0]-10.110.0.100 to VM[1]-10.110.1.128 is successfull
  ping from VM[2]-10.110.9.154 to VM[0]-10.110.0.100 is successfull
  ping from VM[1]-10.110.1.128 to VM[2]-10.110.9.154 is successfull

  EOT,
]

```

## Destroy
For destroying this profile run the following command.

```
terraform destroy -var-file=terraform.tfvars

```