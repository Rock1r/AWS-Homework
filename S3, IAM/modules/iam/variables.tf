variable "main_s3_bucket" {
  description = "Main S3 bucket object"
  type = object({
    name = string
    arn  = string
    id   = string
  })
}

variable "replica_s3_bucket" {
  description = "Replica S3 bucket object"
  type = object({
    name = string
    arn  = string
    id   = string
  })
}
