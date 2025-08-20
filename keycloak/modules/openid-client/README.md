

```bash
module "my_client" {
  source  = "./modules/keycloak_openid_client"

  realm_id                     = keycloak_realm.apps.id
  client_id                    = "my-app"
  name                         = "My Application"
  enabled                      = true
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  valid_redirect_uris          = ["https://my-app.example.com/*"]
  base_url                     = "https://my-app.example.com"
  admin_url                    = "https://my-app.example.com/admin"
  web_origins                  = ["https://my-app.example.com"]
}

output "my_client_secret" {
  value     = module.my_client.client_secret
  sensitive = true
}
```
