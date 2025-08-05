# DAGGER

## PY LINT

[daggervers](https://daggerverse.dev/mod/github.com/act3-ai/dagger/python@1886b9cd94972fc0bebcdc72f8aad685711d747f)
[module-code]https://github.com/act3-ai/dagger/blob/python/v0.1.4/python/main.go


```bash
dagger call --src dagger/python-webapp \
-m github.com/act3-ai/dagger/python@python/v0.1.4 lint

dagger call --src python-webapp \
-m github.com/act3-ai/dagger/python@python/v0.1.4 lint \
--skip "ruff-check,pyright,ruff-format,pylint"

dagger call --src python-webapp \
-m github.com/act3-ai/dagger/python@python/v0.1.4 lint \
--ignore-error=true
```


## BUILD IMAGE

```bash
dagger call -m https://github.com/stuttgart-things/dagger/docker@v0.31.1 \
build-and-push \
--source dagger/python-webapp \
--repository-name dagger/python-webapp \
--registry-url ttl.sh \
--tag 1.2.3 \
-vv --progress plain
```


## SCAN IMAGE

```bash
dagger call -m https://github.com/stuttgart-things/dagger/trivy@v0.31.1 scan-image \
--image-ref ttl.sh/dagger/python-webapp:1.2.3 \
--progress plain -vv \
export --path=/tmp/python-webapp-trivy.json
```
