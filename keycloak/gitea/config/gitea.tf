module "gitea_client" {
  source  = "../../modules/openid-client"  # path to your reusable module

  realm_id                     = "apps"
  client_id                    = "gitea"
  name                         = "Gitea"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  valid_redirect_uris          = [format("%s/user/oauth2/keycloak/callback/*", var.gitea_url)]
  base_url                     = var.gitea_url
  admin_url                    = var.gitea_url
  web_origins                  = ["*"]
}

output "gitea_client_secret" {
  value     = module.gitea_client.client_secret
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

variable "gitea_url" {
  type        = string
  description = "URL of the Grafana instance"
}
