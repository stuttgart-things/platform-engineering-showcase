dagger call -m github.com/stuttgart-things/dagger/kyverno@v0.31.2 validate --policy /home/sthings/projects/bosch/platform-engineering-showcase/kyverno/policies --resource /home/sthings/projects/bosch/platform-engineering-showcase/crossplane/postgres-db/backstage/resources -vv --progress plain



dagger -m github.com/valorl/daggerverse/git-files-changed@e8b25b9c6589f13b362dcaf94acda967f26f6700   call files   --source .   --head-ref HEAD   --base-ref origin/main