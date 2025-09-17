# stuttgart-things/platform-engineering-showcase/kyverno

## DEPLOYMENT

<details><summary>DEPLOY w/ HELMFILE</summary>

```bash
helmfile apply -f deployment/kyverno.yaml
```

</details>

## USECASE ADD SECRET TO DEPLOYMENT

<details><summary>CREATE REQUIREMENTS</summary>

```bash
kubectl apply -f policies/deployment-secret-usecase/ns-sa-secret.yaml
```

</details>

<details><summary>TEST w/ DEPLOYMENT EXAMPLE</summary>

```bash
# APPLY POLICY
kubectl apply -f policies/deployment-secret-usecase/policy.yaml

# APPLY DEPLOYMENT EXAMPLE
kubectl apply -f policies/deployment-secret-usecase/deployment.yaml
```

</details>
