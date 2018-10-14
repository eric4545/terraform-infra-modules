# Changelog

## 2018-10-14

- Install `Chaoskube` in namespace `chaoskube`, disable by default

## 2018-10-13

- Created a self sign cert `istio-ingressgateway-certs` in namespace `istio-system`, use cloudflare as Front SSL

## 2018-09-18

- Install `sealed-secrets` in namespace `kube-system`, disable by default

## 2018-09-17

- Disable istio egress gateway by default
- Able is enable/disable istio control pane
- Able is enable/disable istio egress gateway
- Able is enable/disable cert-manager
- Able is enable/disable external-dns
- Able is enable/disable kubernetes-dashboard
- Able is enable/disable stackdriver-adapter

## 2018-09-16

- Install addon `kubernetes-dashboard` in namespace `kubernetes-dashboard`
- Install addon `external-dns` in namespace `external-dns`
- Install addon `custom-metrics-stackdriver-adapter` in namespace `custom-metrics`
- Change `tiller` to use `secret` store
