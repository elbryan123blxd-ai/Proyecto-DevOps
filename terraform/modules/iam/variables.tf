variable "name_prefix" {
  description = "Prefijo de naming de los roles IAM"
  type        = string
}

variable "github_repo" {
  description = "Repo de GitHub, formato owner/repo (ej: elbryan123blxd-ai/Proyecto-DevOps)"
  type        = string
}

variable "tags" {
  description = "Tags extra"
  type        = map(string)
  default     = {}
}