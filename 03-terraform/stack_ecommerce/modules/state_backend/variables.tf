# state_backend/variables.tf
variable "environment" {
  description = "Nom de l'environnement (prod, staging...)"
  type        = string
}