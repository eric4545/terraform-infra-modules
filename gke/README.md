# gke

The module will create following resource

- Latest GKE cluster if version not provided
  - Will apply update when new version available
- Google service account
  - GCR
  - GKE Cluster
- Install helm `tiller` in namespace `tiller-system`
- Install `cert-manager` in namespace `cert-manager`
- Install `istio` in namespace `istio-system`
- Install `kubernetes-dashboard` in namespace `kubernetes-dashboard`
- Install `external-dns` in namespace `external-dns`
  - Only support cloudflare now
- Install `custom-metrics-stackdriver-adapter` in namespace `custom-metrics`
- Install `sealed-secrets` in namespace `kube-system`

## Prerequisite

- `helm`@~2.10
- `gcloud`
  - `gcloud auth login`
  - `gcloud auth application-default login`
  - `gcloud config set project $PROJECT_ID`
  - `gcloud config unset container/use_client_certificate`
- `kubectl`
- `jq`

## Outputs

## TODO

- [x] Auto install gcr pull secret
- [x] Auto install helm tiller
- [x] Auto install istio
  - [x] Download from https://github.com/istio/istio/releases
- [x] Auto install external dns
- [ ] VPC-native (alias IP)
- [ ] Master authorized networks

## FAQ

- Q: Error from server (Forbidden): namespaces is forbidden: User "client" cannot create namespaces at the cluster scope: Unknown user "client"
  - A: `gcloud config unset container/use_client_certificate`
- exit status 1. Output: Release "istio" does not exist. Installing it now.
  Error: customresourcedefinitions.apiextensions.k8s.io "gateways.networking.istio.io" already exists
  - A: Clean up istio
    `kubectl delete -f /tmp/istio-release/istio-1.0.0/install/kubernetes/helm/istio/templates/crds.yaml -n istio-system`
- Q: Get gcr key
  - A: `terraform output -module=gke gcr_key`

## Reference

- [google-gke from terrafrom](https://github.com/terraform-providers/terraform-provider-kubernetes/tree/master/_examples/google-gke)
