resource "aws_s3_bucket" "wordpress_uploads" {
  bucket        = var.bucket_name
  force_destroy = true
  acl           = "public-read"

  tags = {
    Name        = "wordpress-uploads"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_ownership_controls" "wordpress_uploads" {
  bucket = aws_s3_bucket.wordpress_uploads.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_policy" "wordpress_uploads_policy" {
  bucket = aws_s3_bucket.wordpress_uploads.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.wordpress_uploads.bucket}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "wordpress_s3_policy" {
  name        = "wordpress-s3-policy"
  description = "Policy to allow WordPress EC2 instance to access S3 for file uploads"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
          "s3-object-lambda:*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.wordpress_uploads.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.wordpress_uploads.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "wordpress_instance_role" {
  name = "${var.bucket_name}-wordpress-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "wordpress_s3_policy_attachment" {
  policy_arn = aws_iam_policy.wordpress_s3_policy.arn
  role       = aws_iam_role.wordpress_instance_role.name
}

resource "aws_iam_instance_profile" "wordpress_instance_profile" {
  name = "${var.bucket_name}-wordpress-instance-profile"
  role = aws_iam_role.wordpress_instance_role.name
}
