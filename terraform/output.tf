output "internal_ip_address_bastion" {
  value = yandex_compute_instance.bastion-server.network_interface.0.ip_address
}
output "external_ip_address_bastion" {
  value = yandex_compute_instance.bastion-server.network_interface.0.nat_ip_address
}

output "internal_ip_address_nginx1" {
  value = yandex_compute_instance_group.vm-group.instances.0.network_interface.0.ip_address
}

output "internal_ip_address_nginx2" {
  value = yandex_compute_instance_group.vm-group.instances.1.network_interface.0.ip_address
}

output "internal_ip_address_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.ip_address
}  

output "external_ip_address_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "internal_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}  

output "external_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "internal_ip_address_elastic" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
} 


