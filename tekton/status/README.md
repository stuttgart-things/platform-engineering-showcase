# SET TETKON-PIPELINE STATUS ON GITEA COMMIT

## DEPLOY TEKTON + GITEA

```bash
helmfile apply -f gitea-tekton.yaml
```

## ENABLE TEKTON-DASHBOARD

```bash
kubectl apply -f - <<EOF
apiVersion: operator.tekton.dev/v1alpha1
kind: TektonDashboard
metadata:
  name: dashboard
spec:
  targetNamespace: tekton-pipelines
EOF
```

## CREATE DASHBOARD SERVICE

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: tekton-dashboard-nodeport
  namespace: tekton-pipelines
spec:
  type: NodePort
  selector:
    app.kubernetes.io/component: dashboard
    app.kubernetes.io/part-of: tekton-dashboard
  ports:
    - name: http
      port: 9097
      targetPort: 9097
      nodePort: 31445
EOF
```

## START TASKRUN (TESTING)

```bash
tkn -n tekton-ci \
task start gitea-set-status \
-p GITEA_PROTOCOL=http \
-p GITEA_HOST="maverick.tiab.labda.sva.de:30083" \
-p REPO_FULL_NAME=gitea_admin/source \
-p COMMIT_SHA=80b8528fcea3c0ca416732c455b6dd30f9da49d4 \
-p STATE=success \
-p DESCRIPTION="Build & Deploy Successful" \
-p DASHBOARD_URL="http://maverick.tiab.labda.sva.de:31445" \
-p CONTEXT="continuous-integration/tekton" \
-p API_PATH_PREFIX="/api/v1" \
-p GITEA_TOKEN_SECRET_NAME=gitea \
-p GITEA_TOKEN_SECRET_KEY=token
```
