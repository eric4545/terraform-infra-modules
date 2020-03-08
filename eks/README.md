# eks

## Prerequisite

- `kubectl` client bin install
  <!-- - ~~aws credentials are stored in ~/.aws/credentials -->

## Inputs

| Name                 | Description                                                                                               |  Type  |      Default       | Required |
| -------------------- | --------------------------------------------------------------------------------------------------------- | :----: | :----------------: | :------: |
| aws\_cni\_version    |                                                                                                           | string |      `"v1.3"`      |    no    |
| aws\_region          | AWS resource locate                                                                                       | string | `"ap-southeast-1"` |    no    |
| cluster\_name        | Set cluster_name to override                                                                              | string | `"terraform-eks"`  |    no    |
| env                  | Set environment                                                                                           | string |    `"testing"`     |    no    |
| master\_version      | (Optional) Desired Kubernetes master version. If you do not specify a value, the default version is used. | string |      `"1.11"`      |    no    |
| private\_subnet\_ids |                                                                                                           |  list  |        n/a         |   yes    |
| public\_subnet\_ids  |                                                                                                           |  list  |        n/a         |   yes    |
| vpc\_id              |                                                                                                           | string |        n/a         |   yes    |
| whitelist\_ip        |                                                                                                           | string |        n/a         |   yes    |
| worker\_version      | (Optional) Desired Kubernetes worker version. If you do not specify a value, the default version is used. | string |      `"1.11"`      |    no    |

## Outputs

| Name                   | Description |
| ---------------------- | ----------- |
| debugger\_private\_key |             |
| kubeconfig             |             |

## Manual

- terragrunt output kubeconfig > ~/.kube/config

## Developmment

- terragrunt apply --terragrunt-source ../../../../../terraform-infra-modules//eks

## Alternative

- eksctl

## References

https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html
https://www.hashicorp.com/blog/hashicorp-announces-terraform-support-aws-kubernetes
