variable "realm_id" {
  type        = string
  description = "ID of the Keycloak realm"
}

variable "client_id" {
  type        = string
  description = "Client ID"
}

variable "name" {
  type        = string
  description = "Name of the client"
}

variable "enabled" {
  type        = bool
  description = "Whether the client is enabled"
  default     = true
}

variable "access_type" {
  type        = string
  description = "Access type (e.g., CONFIDENTIAL, PUBLIC, BEARER-ONLY)"
  default     = "CONFIDENTIAL"
}

variable "standard_flow_enabled" {
  type        = bool
  description = "Whether the standard flow is enabled"
  default     = true
}

variable "direct_access_grants_enabled" {
  type        = bool
  description = "Whether direct access grants are enabled"
  default     = false
}

variable "valid_redirect_uris" {
  type        = list(string)
  description = "List of valid redirect URIs"
  default     = []
}

variable "base_url" {
  type        = string
  description = "Base URL for the client"
  default     = null
}

variable "admin_url" {
  type        = string
  description = "Admin URL for the client"
  default     = null
}

variable "web_origins" {
  type        = list(string)
  description = "List of allowed web origins"
  default     = []
}
