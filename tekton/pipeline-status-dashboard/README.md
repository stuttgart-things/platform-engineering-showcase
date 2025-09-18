# SET PIPELINE STATUS ON GITEA COMMIT + LINK TO TEKTON-DASHBOARD

## DEPLOYMENT + CONFIGURATION

<details><summary>DEPLOY GITEA+TEKTON</summary>

```bash
helmfile apply -f gitea-tekton.yaml
```

</details>

<details><summary>ENABLE TEKTON-DASHBOARD</summary>

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

</details>

<details><summary>CREATE NODEPORT SERVICE FOR DASHBOARD </summary>

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

</details>

<details><summary>ACCESS GITEA+TEKTON-PIPELINES</summary>

```bash
# GITEA
echo http://$(hostname -f):30083

# DEFAULT USER
#gitea_admin
#r8sA8CPHD9!bt6d

# TEKTON-DASHBOARD
echo http://$(hostname -f):31445
```

</details>

## CONFIGURATION

<details><summary>CREATE REPO + COMMIT TEST FILES</summary>

+ GET COMMIT SHA

</details>

<details><summary>OPTIONAL: TEST GITEA STATUS API w/ CURL</summary>

```bash
curl -X POST \
  "https://$(hostname -f):30083/api/v1/repos/skywalker//baseapp-sdk/statuses/1eea9ebeddde9… \
  -H "Authorization: token 2b2b5ed6005276e4afcd0d833edce4b9ce4dbdc7" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "success",
    "target_url": "https://gitea.example.come",
    "description": "Build succeeded",
    "context": "continuous-integration/manual"
  }'
```

</details>

<details><summary>CREATE GITEA TOKEN ON CLUSTER</summary>

```bash
kubectl create secret generic gitea \
  --from-literal=token=<REPLACE-ME>
```

</details>

<details><summary>CREATE TEKTON RESOURCES</summary>

```bash
kubectl create ns tekton-ci
kubectl apply -f resources/git.yaml -n tekton-ci
kubectl apply -f resources/set-gitea-status.yaml -n tekton-ci
kubectl apply -f resources/pipeline.yaml -n tekton-ci
```

</details>

<details><summary>START TASKRUN (TESTING)</summary>

```bash
tkn -n tekton-ci \
task start gitea-set-status \
-p GITEA_PROTOCOL=http \
-p GITEA_HOST="$(hostname -f):30083" \
-p REPO_FULL_NAME=gitea_admin/source \
-p COMMIT_SHA=80b8528fcea3c0ca416732c455b6dd30f9da49d4 \
-p STATE=success \
-p DESCRIPTION="Build & Deploy Successful" \
-p DASHBOARD_URL="http://$(hostname -f):31445" \
-p CONTEXT="continuous-integration/tekton" \
-p API_PATH_PREFIX="/api/v1" \
-p GITEA_TOKEN_SECRET_NAME=gitea \
-p PIPELINERUN_NAME=TASKRUN \
-p GITEA_TOKEN_SECRET_KEY=token
```

</details>

<details><summary>CREARE PIPELINERUN</summary>

```bash
PR_NAME=set-gitea-commit-status-$(date +%s%N | sha256sum | head -c 16)
kubectl apply -f - <<EOF
---
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: ${PR_NAME}
  namespace: tekton-ci
spec:
  pipelineRef:
    name: git-clone-and-set-status
  workspaces:
    - name: source-repo
      volumeClaimTemplate:
        spec:
          accessModes: [ "ReadWriteOnce" ]
          resources:
            requests:
              storage: 1Gi
  params:
    - name: repository-url
      value: "http://$(hostname -f):30083/gitea_admin/source.git"
    - name: revision
      value: "main"
    - name: gitea-host
      value: "$(hostname -f):30083"
    - name: repo-full-name
      value: "gitea_admin/source"
    - name: gitea-protocol
      value: "http"
    - name: status-description
      value: "Pipeline started"
    - name: commit-sha
      value: 80b8528fcea3c0ca416732c455b6dd30f9da49d4
    - name: dashboard-url
      value: "http://$(hostname -f):31445"
EOF
sleep 5
tkn -n tekton-ci pr logs -f ${PR_NAME}
```

</details>