# SET TETKON-PIPELINE STATUS ON GITEA COMMIT

## DEPLOY

```bash
# GITEA

# TEKTON-PIPELINES


## DEPLOY TEKTON-RESULTS

```bash
# CREATE PVC FOR STORING LOGS
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: tekton-logs
  namespace: tekton-pipelines
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

```bash
kubectl apply -f - <<EOF
apiVersion: operator.tekton.dev/v1alpha1
kind: TektonResult
metadata:
  name: result
spec:
  targetNamespace: tekton-pipelines
  db_enable_auto_migration: true
  log_level: debug
  logs_api: true
  logs_type: File
  logs_buffer_size: 32768
  logs_path: /logs
  auth_disable: true
  logging_pvc_name: tekton-logs
EOF
```


https://docs.alauda.io/alauda-devops-pipelines/4.0/results/quick_start.html










## CONFIGURE GITEA

```bash

```


## RUN-PIPELINE

```bash


```
