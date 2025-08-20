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

module "apps_realm" {
  source     = "../modules/realm"
  realm_name = var.realm_name
  groups = var.realm_groups
  users = var.users
}

output "grafana_realm_id" {
  value = module.apps_realm.realm_id
}

output "grafana_user_ids" {
  value = module.apps_realm.user_ids
}

output "grafana_group_ids" {
  value = module.apps_realm.group_ids
}
