output "resource_group_name" {
  value = azurerm_resource_group.botit.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.Botit_vm.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.Botit_ssh.private_key_pem
  sensitive = true
}