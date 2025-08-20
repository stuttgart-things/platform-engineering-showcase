module "grafana_client" {
  source  = "../../modules/openid-client"  # path to your reusable module

  realm_id                     = "apps"
  client_id                    = "grafana"
  name                         = "Grafana"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  valid_redirect_uris          = [format("%s/login/generic_oauth", var.grafana_url)]
  base_url                     = var.grafana_url
  admin_url                    = var.grafana_url
  web_origins                  = ["*"]
}

output "grafana_client_secret" {
  value     = module.grafana_client.client_secret
  sensitive = true
}

terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.2"
    }
  }
}

provider "keycloak" {
  client_id = var.keycloak_client_id
  username  = var.keycloak_username
  password  = var.keycloak_password
  url       = var.keycloak_url
  realm     = var.keycloak_realm
}

# Keycloak Provider Variables
variable "keycloak_client_id" {
  type        = string
  description = "Keycloak client ID for authentication"
}

variable "keycloak_username" {
  type        = string
  description = "Admin username for Keycloak"
}

variable "keycloak_password" {
  type        = string
  sensitive   = true
  description = "Admin password for Keycloak"
}

variable "keycloak_url" {
  type        = string
  description = "URL of the Keycloak instance"
}

variable "keycloak_realm" {
  type        = string
  description = "Master realm for Keycloak provider"
}

variable "grafana_url" {
  type        = string
  description = "URL of the Grafana instance"
}
