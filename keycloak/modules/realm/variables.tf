variable "realm_name" {
  type        = string
  description = "The name of the Keycloak realm"
}

variable "groups" {
  type        = list(string)
  default     = []
  description = "List of group names to create"
}

variable "users" {
  type = list(object({
    username         = string
    enabled          = optional(bool, true)
    first_name       = optional(string)
    last_name        = optional(string)
    email            = optional(string)
    initial_password = optional(object({
      value     = string
      temporary = optional(bool, false)
    }))
    groups = optional(list(string), [])
  }))
  default     = []
  description = "List of users with optional group memberships"
}
