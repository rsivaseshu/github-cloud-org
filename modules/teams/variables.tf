variable "teams" {
  type = map(object({
    description = string
    privacy     = string
    members     = list(string)
  }))
}
