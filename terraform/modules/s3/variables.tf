variable "buckets" {
  type = list(object({
    name = string
    department = string
  }))
  description = "List of S3 buckets to be created with their department names"
}