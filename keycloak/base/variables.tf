variable "users" {
  description = "List of Keycloak users to create"
  type = list(object({
    username   = string
    first_name = optional(string)
    last_name  = optional(string)
    email      = optional(string)
    initial_password = object({
      value     = string
      temporary = bool
    })
    groups = optional(list(string))
  }))
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

variable "realm_groups" {
  type        = list(string)
  description = "List of groups to create in the realm"
}

variable "realm_name" {
  type        = string
  description = "Name of the realm to create"
}
