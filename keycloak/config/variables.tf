variable "client_id" {
  type        = string
  default     = "apps"
  description = "The client ID for apps"
}

variable "name" {
  type        = string
  default     = "apps"
  description = "The display name of the client"
}

variable "enabled" {
  type        = bool
  default     = true
}

variable "access_type" {
  type        = string
  default     = "CONFIDENTIAL"
}

variable "standard_flow_enabled" {
  type        = bool
  default     = true
}

variable "direct_access_grants_enabled" {
  type        = bool
  default     = true
}

variable "valid_redirect_uris" {
  type        = list(string)
}

variable "base_url" {
  type        = string
}

variable "admin_url" {
  type        = string
}

variable "web_origins" {
  type        = list(string)
  default     = ["*"]
}

variable "keycloak_client_id" {
  type    = string
  default = "admin-cli"
}

variable "keycloak_username" {
  type = string
}

variable "keycloak_password" {
  type      = string
  sensitive = true
}

variable "keycloak_url" {
  type = string
}

variable "keycloak_realm" {
  type    = string
  default = "master"
}
