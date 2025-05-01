
resource "aws_s3_bucket" "main" {
  bucket = "aws53iam"

}

resource "aws_s3_bucket_versioning" "main_bucket_versioning" {
  depends_on = [aws_s3_bucket.main]
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "replica" {
  bucket = "aws53iam1"

}

resource "aws_s3_bucket_versioning" "replica_bucket_versioning" {
  depends_on = [aws_s3_bucket.replica]
  bucket = aws_s3_bucket.replica.id
  versioning_configuration {
    status = "Enabled"
  }
}