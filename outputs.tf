output "registry_id" {
  value       = module.ecr.registry_id
  description = "Registry ID"
}

output "repository_name" {
  value       = module.ecr.repository_name
  description = "Name of first repository created"
}

output "repository_url" {
  value       = module.ecr.repository_url
  description = "URL of first repository created"
}

