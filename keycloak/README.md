# KEYCLOAK

## KEYCLOAK BASE SETUP

<details><summary>CREATE KEYCLOAK-CLUSTER</summary>

```bash
# TASKFILE
task create-kind-cluster

# MANUAL
KUBECONFIG_PATH=~/.kube/keycloak-cluster

mkdir -p ~/.kube || true

kind create cluster \
--config keycloak-cluster.yaml \
--kubeconfig ${KUBECONFIG_PATH}
```

```bash
# COMMECT
KUBECONFIG_PATH=~/.kube/keycloak-cluster
export KUBECONFIG=${KUBECONFIG_PATH}
kubectl get nodes
```

</details>

<details><summary>DELOY KEYCLOAK</summary>

```bash
export KEYCLOAK_ADMIN_PASSWORD=$(gum input --placeholder="Enter keycloak password") # pragma: allowlist secret
echo $KEYCLOAK_ADMIN_PASSWORD # pragma: allowlist secret

#export HELMFILE_CACHE_HOME=/tmp/helm-cache-keycloak
helmfile apply -f keycloak.yaml

kubectl wait --for=condition=ready pod --all -n keycloak --timeout=300s
```

</details>

<details><summary>EXECUTE BASE KEYCLOAK-SETUP</summary>

```bash
cd base

# INITIAL PW FOR KEYCLOAK USERS
INITIAL_PASSWORD=$(date +%s | sha256sum | base64 | head -c 15)
echo ${INITIAL_PASSWORD}

VARS_FOLER=/tmp/platform-engineering-showcase/keycloak
VARS_NAME=terraform.tfvars.json

# EXAMPLE VARS FILE - COULD BE CHANGED
mkdir -p ${VARS_FOLER}

cat <<EOF > ${VARS_FOLER}/${VARS_NAME}
{
  "realm_groups": ["apps-admin"],
  "users": [
    {
      "username": "carlo",
      "first_name": "Carlo",
      "last_name": "Coxx",
      "email": "carlo.coxx@example.com",
      "initial_password": {
        "value": "${INITIAL_PASSWORD}$",
        "temporary": false
      },
      "groups": ["apps-admin"]
    },
    {
      "username": "admin",
      "initial_password": {
        "value": "${INITIAL_PASSWORD}$",
        "temporary": false
      },
      "groups": ["apps-admin"]
    }
  ]
}
EOF

export TF_VAR_keycloak_client_id="admin-cli"
export TF_VAR_keycloak_username="admin"
export TF_VAR_keycloak_password=${KEYCLOAK_ADMIN_PASSWORD}
# SET/FROM KEYCLOAK DEPLOYMENT STEP
export TF_VAR_keycloak_url="http://$(hostname -f):31634"
export TF_VAR_keycloak_realm="master"
export TF_VAR_realm_name="apps"

export KUBE_CONFIG_PATH=${KUBECONFIG_PATH}
terraform init --upgrade
terraform apply --auto-approve -var-file=${VARS_FOLER}/${VARS_NAME}

cd -
```

</details>

## OPTION: GRAFANA

<details><summary>CONFIGURE KEYCLOAK FOR GRAFANA</summary>

```bash
cd grafana/config

export TF_VAR_keycloak_client_id="admin-cli"
export TF_VAR_keycloak_username="admin"
export TF_VAR_keycloak_password=${KEYCLOAK_ADMIN_PASSWORD} # SET/FROM KEYCLOAK DEPLOYMENT STEP
export TF_VAR_keycloak_url="http://$(hostname -f):31634"
export TF_VAR_keycloak_realm="master"
export TF_VAR_realm_name="apps"
export TF_VAR_grafana_url="http://$(hostname -f):31633"

export KUBE_CONFIG_PATH=${KUBECONFIG_PATH}
terraform init --upgrade
terraform apply --auto-approve

export GRAFANA_CLIENT_SECRET=$(terraform output --json | jq -r '.grafana_client_secret.value')
echo ${GRAFANA_CLIENT_SECRET}

echo Check Keycloak: http://$(hostname -f):31634

cd -
```

</details>

<details><summary>DEPLOY GRAFANA</summary>

```bash
# DEPLOY
export KIND_HOST=$(hostname -f)
helmfile apply -f grafana/deploy/grafana.yaml

# ADD CLIENT SECRET
kubectl -n observability patch cm grafana-deployment \
  --type merge \
  -p "$(kubectl -n observability get cm grafana-deployment -o json \
    | jq ".data[\"grafana.ini\"] |= ( sub(\"client_id = grafana\"; \"client_id = grafana\nclient_secret = ${GRAFANA_CLIENT_SECRET}\") )")"

kubectl -n grafana get cm grafana-deployment -n observability -o yaml

# RESTART
kubectl delete po --all -n observability

echo Check Grafana: http://$(hostname -f):31633

# OPTIONAL OUTPUT: LOGOUT ADDRESS (FOR TESTING)
echo http://$(hostname -f):31634/realms/apps/protocol/openid-connect/logout?redirect_uri=http:/$(hostname -f):31633/

cd -
```

</details>

## OPTION: GITEA

<details><summary>CONFIGURE KEYCLOAK FOR GITEA</summary>

```bash
cd gitea/config

export TF_VAR_keycloak_client_id="admin-cli"
export TF_VAR_keycloak_username="admin"
export TF_VAR_keycloak_password=${KEYCLOAK_ADMIN_PASSWORD} # SET/FROM KEYCLOAK DEPLOYMENT STEP
export TF_VAR_keycloak_url="http://localhost:31634"
export TF_VAR_keycloak_realm="master"
export TF_VAR_realm_name="apps"
export TF_VAR_gitea_url="http://$(hostname -f):31635"

terraform init --upgrade
terraform apply --auto-approve

export GITEA_CLIENT_SECRET=$(terraform output --json | jq -r '.gitea_client_secret.value')
echo ${GITEA_CLIENT_SECRET}

cd -
```

</details>

<details><summary>DEPLOY GITEA</summary>

```bash
export KIND_HOST=$(hostname -f)
helmfile apply -f gitea/deploy/gitea.yaml

echo Check Gitea: http://$(hostname -f):31635

echo http://$(hostname -f):31634/realms/apps/protocol/openid-connect/logout?redirect_uri=http:/$(hostname -f):31635/
```

</details>

## CLEAN-UP

<details><summary>DELETE CLUSTER</summary>

```bash
kind delete clusters keycloak-cluster
```

</details>

<details><summary>REMOVE TERRAFORM STATE FILES</summary>

```bash
# BASE
rm -rf base/.terraform*
rm -rf base/terraform*

# GRAFANA
rm -rf grafana/config/.terraform*
rm -rf grafana/config/terraform*

# GITEA
rm -rf gitea/config/.terraform*
rm -rf gitea/config/terraform*
```

</details>
