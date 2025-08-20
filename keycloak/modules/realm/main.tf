resource "keycloak_realm" "this" {
  realm   = var.realm_name
  enabled = true
}

resource "keycloak_group" "groups" {
  for_each = toset(var.groups)

  realm_id = keycloak_realm.this.id
  name     = each.value
}

resource "keycloak_user" "users" {
  for_each = { for u in var.users : u.username => u }

  realm_id   = keycloak_realm.this.id
  username   = each.value.username
  enabled    = lookup(each.value, "enabled", true)
  first_name = lookup(each.value, "first_name", null)
  last_name  = lookup(each.value, "last_name", null)
  email      = lookup(each.value, "email", null)

  dynamic "initial_password" {
    for_each = each.value.initial_password != null ? [each.value.initial_password] : []
    content {
      value     = initial_password.value["value"]
      temporary = lookup(initial_password.value, "temporary", false)
    }
  }
}

resource "keycloak_user_groups" "user_groups" {
  for_each = { for u in var.users : u.username => u if length(lookup(u, "groups", [])) > 0 }

  realm_id = keycloak_realm.this.id
  user_id  = keycloak_user.users[each.key].id

  group_ids = [for g in each.value.groups : keycloak_group.groups[g].id]
}
