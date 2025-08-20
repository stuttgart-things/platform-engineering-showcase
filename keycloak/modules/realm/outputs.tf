output "realm_id" {
  value = keycloak_realm.this.id
}

output "group_ids" {
  value = { for g, res in keycloak_group.groups : g => res.id }
}

output "user_ids" {
  value = { for u, res in keycloak_user.users : u => res.id }
}
