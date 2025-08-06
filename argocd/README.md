# ARGOCD

## DEPLOY

```bash
## GENERATE PASSWORD

sudo apt -y install apache2-utils
ADMINPASSWORD=$(htpasswd -nbBC 10 "" 'Test2025!' | tr -d ':\n')
ADMINPASSWORDMTIME=$(echo $(date +%FT%T%Z))

echo ${ADMINPASSWORD}
echo ${ADMINPASSWORDMTIME}

## DEPLOY
helmfile apply -f argocd.yaml
```

## POSTGRESDB CONFIG

```bash
kubectl apply -f postgresdb/app.yaml
```
