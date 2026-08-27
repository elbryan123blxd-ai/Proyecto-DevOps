variable "name_prefix" {
  description = "Prefijo de naming de los roles IAM"
  type        = string
}

variable "github_repo" {
  description = "Repo de GitHub, formato owner/repo (ej: elbryan123blxd-ai/Proyecto-DevOps)"
  type        = string
}

variable "github_oidc_thumbprints" {
  description = "Thumbprints SHA-1 (hex) candidatos de token.actions.githubusercontent.com. Para GitHub AWS ya usa su biblioteca de CAs (Let's Encrypt/ISRG), pero si no reconoce la firma cae al thumbprint. Incluimos el canónico histórico (6938fd4d), la raíz ISRG actual (ab9d0263) y las 3 hojas del JWKS (ca435a/38e9b3/4f3e9a). Limpiar tras confirmar cuál funciona."
  type        = list(string)
  default = [
    "ca435a638a8cfed6b89364e064e08460b91c6250",
    "38e9b30b3a023a1b72309921a69a42fcc496c42c",
    "4f3e9ad8c9a6f5eb3173006f4fa630e28f43dce9",
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "ab9d0263244dd0326eb67015705a667e79cfe998",
  ]
}

variable "tags" {
  description = "Tags extra"
  type        = map(string)
  default     = {}
}