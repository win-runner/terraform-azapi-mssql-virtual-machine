output "resource_id" {
  value       = azapi_resource.mssql_virtual_machine.id
  description = <<DESC
The ID of the SQL Virtual Machine.
DESC
}

output "resource_identity" {
  value       = azapi_resource.mssql_virtual_machine.identity
  description = <<DESC
The identity of the SQL Virtual Machine.
DESC
}
