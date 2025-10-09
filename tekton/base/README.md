# TEKTON-BASE

## DEPLOY

<details><summary>INSTALL REQUIREMENTS</summary>

```bash
brew install helmfile tektoncd-cli
#brew install kubectl helm k9s
helmfile init --force
```

</details>

<details><summary>INSTALL TEKTON</summary>

```bash
# export KUBECONFIG=~/.kube/tekton - EXAMPLE PATH
kubectl apply -k https://github.com/stuttgart-things/helm/cicd/crds/tekton?ref=v1.2.1
helmfile apply -f tekton-base.yaml.gotmpl
kubectk create ns tekton-ci
```

</details>

## PIPELINERUN-REQUIREMENTS

<details><summary>CREATE SECRETS</summary>

## CREATE SSH USER-CREDS AS SECRET

```bash
kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: ansible-credentials
  namespace: tekton-ci
type: Opaque
stringData:
  ANSIBLE_USER: ""
  ANSIBLE_PASSWORD: ""
EOF
```

## CREATE SSH USER-CREDS AS SECRET

secret must exist, values doesnt matter if you're not using vault.

```bash
kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: vault
  namespace: tekton-ci
type: Opaque
stringData:
  VAULT_NAMESPACE: root
  VAULT_ROLE_ID: ""
  VAULT_SECRET_ID: ""
  VAULT_ADDR: ""
EOF
```

</details>

## CREATE PIPELINERUNS

<details><summary>INSTALL REQUIREMENTS</summary>

```bash
brew tap kcl-lang/tap
brew install kcl
brew install go-task/tap/go-task gum kubectl
```

</details>

<details><summary>GENERATE ANSIBLE PIPELINERUNS</summary>

```bash
export TASK_X_REMOTE_TASKFILES=1
task --taskfile https://raw.githubusercontent.com/stuttgart-things/platform-engineering-showcase/refs/heads/main/taskfiles/tekton-runs.yaml create:ansible:pipelinerun
```

</details>
