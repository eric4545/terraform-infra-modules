# eks

## Prerequisite

- `kubectl` client bin install
  <!-- - ~~aws credentials are stored in ~/.aws/credentials -->

## Manual

- terragrunt output kubeconfig > ~/.kube/config

## Developmment

- terragrunt apply --terragrunt-source ../../../../../terraform-infra-modules//eks

## Alternative

- eksctl

## References

https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html
https://www.hashicorp.com/blog/hashicorp-announces-terraform-support-aws-kubernetes
