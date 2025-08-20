output "id" {
  description = "The ID of the created Keycloak OpenID client"
  value       = keycloak_openid_client.this.id
}

output "client_id" {
  description = "The Keycloak client ID"
  value       = keycloak_openid_client.this.client_id
}

output "client_secret" {
  description = "The client secret (only available for confidential clients)"
  value       = keycloak_openid_client.this.client_secret
  sensitive   = true
}
