# GITEA + TEKTON-PIPELINES


```bash
tkn pipeline start demo-pipeline \
-n tekton-ci \
-p git-repo-url=http://example.com/myrepo.git \
-p git-revision=abc123 \
 --showlog
```


```bash
kubectl run curltest --rm -i --tty --image=curlimages/curl --restart=Never   -- curl -X POST   -H "Content-Type: application/json"   -d '{
        "after": "abc123def456",
        "repository": {
          "clone_url": "http://maverick.tiab.labda.sva.de:30083/gitea_admin/source.git"
        }
      }'   http://el-gitea-listener.tekton-ci.svc.cluster.local
```


1. 📥 Find the EventListener URL (internal or external)
You already used it in your `curl` command:
```bash
http://el-gitea-listener.tekton-ci.svc.cluster.local
````


This URL is only reachable **within the cluster**. If Gitea also runs inside the same cluster, this cluster URL is sufficient.

---

2. 🪝 Configure a Webhook in Gitea

**a)** Go to your repository in Gitea
Path:

```bash
http://<GITEA-URL>/<user>/<repo>/settings/hooks
````


**b)** Choose:
`Add Webhook` → **Gitea** (or **Custom Webhook**)

**c)** Fill in the following:

| Field         | Value                                                       |
|---------------|-------------------------------------------------------------|
| Target URL    | `http://el-gitea-listener.tekton-ci.svc.cluster.local`     |
| Content-Type  | `application/json`                                          |
| Trigger On    | Push Events (or whatever you need)                          |
| Secret        | *(optional, but recommended to verify in Tekton)*          |

---

3. ✅ Test the Webhook

A simple commit/push in your repository should now trigger the Tekton EventListener — just like your manual `curl` test.
