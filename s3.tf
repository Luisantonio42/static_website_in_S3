locals {
  site_dir   = "${path.module}/build"
  site_files = fileset(local.site_dir, "**/*")
}

resource "random_id" "bucket_suffix" {
  byte_length = 6
}

resource "aws_s3_bucket" "static_website_bucket" {
  bucket = "static-website-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "static_website_access_block" {
  bucket                  = aws_s3_bucket.static_website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static_website_public_read" {
  bucket = aws_s3_bucket.static_website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "static_website_config" {
  bucket = aws_s3_bucket.static_website_bucket.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_s3_object" "site_files" {
  for_each = local.site_files

  bucket = aws_s3_bucket.static_website_bucket.id
  key    = each.value
  source = "${local.site_dir}/${each.value}"

  etag = filemd5("${local.site_dir}/${each.value}")
  content_type = lookup({
    "html" = "text/html; charset=utf-8"
    "css"  = "text/css; charset=utf-8"
    "js"   = "application/javascript; charset=utf-8"
    "json" = "application/json; charset=utf-8"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "svg"  = "image/svg+xml"
    "ico"  = "image/x-icon"
    "txt"  = "text/plain; charset=utf-8"
  }, lower(regex("[^.]+$", each.value)), "application/octet-stream")
}
