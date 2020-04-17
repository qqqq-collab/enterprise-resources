terraform {
  required_version = ">= 0.12"
}

# provider block and features block are now required
# https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/CHANGELOG.md#200-february-24-2020
provider "azurerm" {
  version = "~>2.4"
  features {} 
}

provider "local" {
  version = "~>1.4"
}

provider "null" {
  version = "~>2.1"
}

provider "random" {
  version = "~>2.2"
}

provider "template" {
  version = "~>2.1"
}

