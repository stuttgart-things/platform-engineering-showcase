resource "keycloak_user" "jane_doe" {
  realm_id = keycloak_realm.apps.id
  username = "jane"
  enabled  = true

  first_name = "Jane"
  last_name  = "Doe"
  email      = "jane.doe@example.com"

  initial_password {
    value     = "S3cureP@ssword!"
    temporary = false
  }
}

resource "keycloak_user_groups" "jane_groups" {
  realm_id = keycloak_realm.apps.id
  user_id  = keycloak_user.jane_doe.id

  group_ids = [
    keycloak_group.apps_admin.id
  ]
}

resource "keycloak_user" "testuser" {
  realm_id = keycloak_realm.apps.id
  username = "admin"
  enabled  = true

  initial_password {
    value     = "66WCzbsf9werZBKf8KDhp3aQbEPbYdBLQeVOaJFW" # pragma: allowlist secret
    temporary = false
  }
}

resource "keycloak_group" "apps_admin" {
  realm_id = keycloak_realm.apps.id
  name     = "apps-admin"
}

resource "keycloak_user_groups" "user_groups" {
  realm_id = keycloak_realm.apps.id
  user_id  = keycloak_user.testuser.id

  group_ids = [
    keycloak_group.apps_admin.id
  ]
}
