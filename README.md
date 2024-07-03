# configurable-number-of-vms
This repo implements the following requirements using aws and terraformȘ

* the code must be able create a configurable number of VMs (any number between 2 and 100); for each VM the following parameters can be specified: the VM flavor, the VM image
* VM admin passwords must be generated automatically and should be different on each VM
* the VMs should reside in the same network VPC or virtual net and should be able to ping each other
* the code have to automatically run a ping from one VM to each other in a round-robin fashion (example for 3 VMs: VM 0 ping VM 1, VM 1 ping VM 2 and VM 2 ping VM 0) and record the result (fail/pass between source and destination)
* the results (ping outputs) must be aggregated in one terraform output variabl

## Create
To provision this example, populate terraform.tfvars with the required variables for vm_flavor, vm_count and vm_type.\
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
vm_flavor	The base image for VMs.	string	n/a	yes
vm_type	Instance type for this group of VMs.	string	n/a	yes
vm_count	The number of instances.	number	2	yes


## How it works
The tf code creates 13 supporting resources for $vm_count amount of ec2 instances of flavor $vm_flavor. A vpc, a public subnet, an internet gateway, a security group (with ssh access) and a route table (with default gateway) will be provided to deliver public conectivity to newly created instances. The password is generated randomly and configured as a root password using an userData commmand.

In order to test the conectivity between VMs the null_script will fire every time the public_ip is changed and wait for instances to be alive before running a custom script that will ping $NEXT_PRIVATE_IP.

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
  "0" = "10.110.15.221"
  "1" = "10.110.7.47"
  "2" = "10.110.11.234"
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
  ping from 10.110.7.47 to 10.110.11.234 is successfull
  ping from 10.110.11.234 to 10.110.15.221 is successfull
  ping from 10.110.15.221 to 10.110.7.47 is successfull

  EOT,
]

```

## Destroy
For destroying this profile run the following command.

```
terraform destroy -var-file=terraform.tfvars

```