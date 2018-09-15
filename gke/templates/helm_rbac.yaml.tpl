apiVersion: v1
kind: Namespace
metadata:
  name: tiller-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: tiller-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller-system-cluster-rule
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: tiller-system
