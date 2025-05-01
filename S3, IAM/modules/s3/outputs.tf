output "main_s3_bucket" {
  value = {
    name = aws_s3_bucket.main.bucket
    arn  = aws_s3_bucket.main.arn
    id   = aws_s3_bucket.main.id
  }
}

output "replica_s3_bucket" {
  value = {
    name = aws_s3_bucket.replica.bucket
    arn  = aws_s3_bucket.replica.arn
    id   = aws_s3_bucket.replica.id
  }
}