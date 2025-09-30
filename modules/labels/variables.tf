variable "labels" {
  type = map(list(object({
    name        = string
    color       = string
    description = string
  })))
}
