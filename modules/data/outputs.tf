output "aws_availability_zone_names" {
  description = "List of availability zone names"
  value       = data.aws_availability_zones.available.names
}
