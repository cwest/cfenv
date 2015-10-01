# CFEnv

Example sinatra app which exposes the [Cloud Foundry](http://cloudfoundry.org) instance index when the app is deployed to Cloud Foundry.

## Deployment

```
$ cf push
```

## Horizontally Scale

```
$ cf scale -i cfenv
```

## Customization

Modify `manifest.yml` to change the running characteristics of the app in Cloud Foundry.