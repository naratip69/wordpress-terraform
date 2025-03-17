resource "aws_s3_bucket" "s3" {
  bucket  = var.bucket_name

  tags = {
    Name = "midterm-s3"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_owner" {
  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.s3.id

  # Ensure "Block all public access" is disabled
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_owner,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.s3.id
  acl = "public-read"
}
