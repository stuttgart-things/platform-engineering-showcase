# TEKTON-BASE

## DEPLOY

```bash
kubectl apply -k https://github.com/stuttgart-things/helm/cicd/crds/tekton?ref=v1.2.1
helmfile apply -f tekton-base.yaml.gotmpl
```

## PIPELINERUNS
