# Lattice `master` Deployment

```sh
vagrant up # from lattice download
ltc target local.lattice.cf
git checkout master
```

## Buildpack

```sh
ltc build-droplet cfenv https://github.com/cloudfoundry/ruby-buildpack.git
ltc launch-droplet cfenv cfenv -- ruby app.rb
open cfenv.local.lattice.cf
```

## Docker

```sh
ltc create cfenv-docker caseywest/cfenv-docker:master
open cfenv-docker.local.lattice.cf
```

## Teardown

```sh
ltc rm cfenv
ltc rm cfenv-docker
```

---

# Cloud Foundry `master` Deployment

```sh
cf target -o pivotal -s demo # already created org and space
cf enable-feature-flag diego_docker
```

## Buildpack

```sh
cf push
open http://cfenv.bosh-lite.com/
```

## Docker

```sh
cf push --docker-image caseywest/cfenv-docker:master cfenv-docker
open http://cfenv-docker.bosh-lite.com/
```

## Teardown

```sh
cf delete cfenv
cf delete cfenv-docker
```

---

# Lattice `enterprise-features` Deployment

```sh
ltc create redis redis --timeout=5m --memory-mb=128 --tcp-route=6379 \
  --monitor-command="redis-cli --scan"
git checkout enterprise-features
```

## Buildpack

```sh
ltc build-droplet cfenv-redis https://github.com/cloudfoundry/ruby-buildpack.git
ltc launch-droplet cfenv-redis cfenv-redis \
  --env REDIS_URL=redis://local.lattice.cf:6379 -- ruby app.rb
```

## Docker

```sh
ltc create cfenv-docker-redis caseywest/cfenv-docker:enterprise-features \
  --env REDIS_URL=redis://local.lattice.cf:6379
```

---

# Cloud Foundry `enterprise-features` Deployment

```sh
cf marketplace
cf create-service redis shared-vm cfenv-redis
```

## Buildpack

```sh
cf bind-service cfenv cfenv-redis
cf push
open http://cfenv.bosh-lite.com/
```

## Docker

```sh
cf bind-service cfenv-docker cfenv-redis
cf push --docker-image caseywest/cfenv-docker:enterprise-features cfenv-docker
open http://cfenv-docker.bosh-lite.com/
```

## Demo Scalability

```sh
cf scale -i 5 cfenv
cf app cfenv
cf logs cfenv
open http://cfenv.bosh-lite.com/
```

---

## Demo Teardown

```sh
cf unbind-service cfenv cfenv-redis
cf delete-service cfenv-redis
cf delete cfenv
cf delete cfenv-docker
git checkout master
```
