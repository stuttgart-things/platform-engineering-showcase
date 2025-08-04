# DAGGER


https://daggerverse.dev/mod/github.com/act3-ai/dagger/python@1886b9cd94972fc0bebcdc72f8aad685711d747f

https://github.com/act3-ai/dagger/blob/python/v0.1.4/python/main.go


dagger call --src dagger -m github.com/act3-ai/dagger/python@python/v0.1.4 lint --skip "ruff-check,pyright,ruff-format,pylint"

dagger call --src dagger -m github.com/act3-ai/dagger/python@python/v0.1.4 lint --ignore-error=true