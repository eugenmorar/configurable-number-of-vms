output "ping_results" {
  value = [data.local_file.results_file.content]
}

output "public_ips" {
  value = tomap({ for k, v in aws_instance.vm-instance[*] : k => v.public_ip})
}

output "private_ips" {
  value = tomap({ for k, v in aws_instance.vm-instance[*] : k => v.private_ip})
}

output "passwords" {
  value = tomap({ for k, v in random_password.password[*] : k => v.result})
  sensitive = true
}

