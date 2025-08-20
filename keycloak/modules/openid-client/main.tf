resource "keycloak_openid_client" "this" {
  realm_id                     = var.realm_id
  client_id                    = var.client_id
  name                         = var.name
  enabled                      = var.enabled
  access_type                  = var.access_type
  standard_flow_enabled        = var.standard_flow_enabled
  direct_access_grants_enabled = var.direct_access_grants_enabled
  valid_redirect_uris          = var.valid_redirect_uris
  base_url                     = var.base_url
  admin_url                    = var.admin_url
  web_origins                  = var.web_origins
}
