# Create IAM Policy for S3 Full Access

resource "aws_iam_policy" "s3_full_access" {

  name        = "S3FullAccessPolicy"
  description = "Grant full access to S3"

  tags = {
    Name = "midterm-ec2-s3-policy"
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::*"
      }
    ]

  })
}

# Create IAM Role for EC2 with S3 Full Access
resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-role"

  tags = {
    Name = "midterm-ec2-s3-role"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach S3 Full Access Policy to the EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_full_access.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "midterm-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
