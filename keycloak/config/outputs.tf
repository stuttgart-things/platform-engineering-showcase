output "apps_client_secret" {
  value = keycloak_openid_client.apps.client_secret
  sensitive = true
}
