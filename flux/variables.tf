variable "github_token" {
  description = "GitHub personal access token"
}

variable "github_organization" {
  description = "GitHub organization"
}

variable "git_email" {
  description = "Email to use as git committer of flux"
}

variable "git_user" {
  description = "Username to use as git committer of flux"
}

variable "github_repo" {
  description = "Name of the GitHub repository"
}

variable "github_repo_owner" {
  description = ""
}

variable "tiller_namespace" {
  description = "Set an alternative Tiller namespace, here default `tiller-system`"
  default     = "tiller-system"
}

variable "flux_version" {
  description = ""
  default     = "0.3.2"
}
