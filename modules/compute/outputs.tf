output "attacker_instance_id" {
  value       = aws_instance.attacker.id
  description = "Attacker EC2 instance ID"
}

output "victim_instance_id" {
  value       = aws_instance.victim.id
  description = "Victim EC2 instance ID"
}

output "victim_quarantine_sg_id" {
  value       = aws_security_group.victim_quarantine.id
  description = "Quarantine SG ID"
}

output "victim_normal_sg_id" {
  value       = aws_security_group.victim_normal.id
  description = "Normal SG ID for victim"
}

output "attacker_private_ip" {
  value       = aws_instance.attacker.private_ip
  description = "Private IP of attacker EC2"
}

output "victim_private_ip" {
  value       = aws_instance.victim.private_ip
  description = "Private IP of victim EC2"
}

output "victim_public_ip" {
  value       = aws_instance.victim.public_ip
  description = "Private IP of victim EC2"
}

output "attacker_public_ip" {
  value       = aws_instance.attacker.public_ip
  description = "Public IP of attacker EC2"
}

