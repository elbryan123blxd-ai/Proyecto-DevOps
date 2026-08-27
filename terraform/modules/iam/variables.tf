variable "name_prefix" {
  description = "Prefijo de naming de los roles IAM"
  type        = string
}

variable "github_repo" {
  description = "Repo de GitHub, formato owner/repo (ej: elbryan123blxd-ai/Proyecto-DevOps)"
  type        = string
}

variable "github_oidc_thumbprints" {
  description = "Thumbprints SHA-1 (hex) de los certificados de firma (JWKS x5c) de token.actions.githubusercontent.com"
  type        = list(string)
  default = [
    "ca435a638a8cfed6b89364e064e08460b91c6250",
    "38e9b30b3a023a1b72309921a69a42fcc496c42c",
    "4f3e9ad8c9a6f5eb3173006f4fa630e28f43dce9",
  ]
}

variable "tags" {
  description = "Tags extra"
  type        = map(string)
  default     = {}
}