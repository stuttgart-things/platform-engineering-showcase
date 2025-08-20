# KEYCLOAK

## CREATE KEYCLOAK-CLUSTER

```bash
KUBECONFIG_PATH=~/.kube/kind-keycloak

mkdir -p ~/.kube || true

kind create cluster \
--config keycloak-cluster.yaml \
--kubeconfig ${KUBECONFIG_PATH}

export KUBECONFIG=${KUBECONFIG_PATH}
kubectl get nodes
```

## DELOY KEYCLOAK

```bash
export KEYCLOAK_ADMIN_PASSWORD="REPLACE-ME" # pragma: allowlist secret
helmfile apply -f keycloak.yaml
```

## EXECUTE BASE KEYCLOAK-SETUP

```bash
cd base

export TF_VAR_keycloak_client_id="admin-cli"
export TF_VAR_keycloak_username="admin"
export TF_VAR_keycloak_password="<REPLACE-ME>"
export TF_VAR_keycloak_url="http://localhost:31634"
export TF_VAR_keycloak_realm="master"
export TF_VAR_realm_name="apps"

terraform init --upgrade
terraform apply

cd -
```

## OPTION: CONFIGURE KEYCLOAK FOR GRAFANA

```bash
cd grafana/config

export TF_VAR_keycloak_client_id="admin-cli"
export TF_VAR_keycloak_username="admin"
export TF_VAR_keycloak_password="<REPLACE-ME>"
export TF_VAR_keycloak_url="http://localhost:31634"
export TF_VAR_keycloak_realm="master"
export TF_VAR_realm_name="apps"
export TF_VAR_grafana_url="http://$(hostname -f):31633"

terraform init --upgrade
terraform apply
terraform output --json

# OPTIONAL OUTPUT: LOGOUT ADDRESS (FOR TESTING)
echo http://$(hostname -f):31634/realms/apps/protocol/openid-connect/logout?redirect_uri=http:/$(hostname -f):31635/


cd -
```

## OPTION: DEPLOY GRAFANA

```bash
export KIND_HOST=$(hostname -f)
helmfile apply -f grafana/deploy/grafana.yaml

kubectl -n grafana edit cm grafana-deployment
# ADD
#data:
#  grafana.ini: |
#  [auth.generic_oauth]
#  client_secret = <GET-FROM-TERRAFORM-OUTPUT>

kubectl delete po --all -n grafana
```

## OPTION: CONFIGURE KEYCLOAK FOR GITEA

```bash
cd gitea/config

export TF_VAR_keycloak_client_id="admin-cli"
export TF_VAR_keycloak_username="admin"
export TF_VAR_keycloak_password="<REPLACE-ME>"
export TF_VAR_keycloak_url="http://localhost:31634"
export TF_VAR_keycloak_realm="master"
export TF_VAR_realm_name="apps"
export TF_VAR_gitea_url="http://$(hostname -f):31635"

terraform init --upgrade
terraform apply
terraform output --json

export GITEA_CLIENT_SECRET=$(terraform output --json | jq -r '.gitea_client_secret.value')

cd -
```

## OPTION: DEPLOY GITEA

```bash
export KIND_HOST=$(hostname -f)
helmfile apply -f gitea/deploy/gitea.yaml
```

## CLEAN-UP

```bash
kind delete clusters keycloak-cluster
```
