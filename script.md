## Demo Build

```sh
cf push
open http://cfenv.bosh-lite.com/

git checkout enterprise-features
cf create-service p-redis shared-vm cfenv-redis
cf bind-service cfenv cfenv-redis
cf push
open http://cfenv.bosh-lite.com/

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
git checkout master
```
