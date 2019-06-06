resource "random_string" "postgres-password" {
  length = "16"
  special = "true"
  override_special = "!#$%^&*()"
}

resource "azurerm_postgresql_server" "codecov" {
  name                = "codecov-enterprise"
  location            = "${azurerm_resource_group.codecov-enterprise.location}"
  resource_group_name = "${azurerm_resource_group.codecov-enterprise.name}"

  sku {
    name = "${var.postgres_sku["name"]}"
    capacity = "${var.postgres_sku["capacity"]}"
    tier = "${var.postgres_sku["tier"]}"
    family = "${var.postgres_sku["family"]}"
  }

  storage_profile {
    storage_mb = "${var.postgres_storage_profile["storage_mb"]}"
    backup_retention_days = "${var.postgres_storage_profile["backup_retention_days"]}"
    geo_redundant_backup = "${var.postgres_storage_profile["geo_redundant_backup"]}"
  }

  administrator_login          = "codecov"
  administrator_login_password = "${random_string.postgres-password.result}"
  version                      = "9.6"
  ssl_enforcement              = "Disabled"
}

resource "azurerm_postgresql_database" "codecov" {
  name                = "codecov"
  resource_group_name = "${azurerm_resource_group.codecov-enterprise.name}"
  server_name         = "${azurerm_postgresql_server.codecov.name}"
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_virtual_network_rule" "codecov-postgres" {
  name                = "postgresql-vnet-rule"
  resource_group_name = "${azurerm_resource_group.codecov-enterprise.name}"
  server_name         = "${azurerm_postgresql_server.codecov.name}"
  subnet_id           = "${azurerm_subnet.codecov.id}"
  ignore_missing_vnet_service_endpoint = "true"
}

resource "azurerm_redis_cache" "codecov" {
  name                = "codecov-enterprise"
  location            = "${azurerm_resource_group.codecov-enterprise.location}"
  resource_group_name = "${azurerm_resource_group.codecov-enterprise.name}"
  capacity            = "1"
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = "true"
  minimum_tls_version = "1.2"
  subnet_id           = "${azurerm_subnet.codecov.id}"

  redis_configuration {
    enable_authentication = "false"
  }
}
