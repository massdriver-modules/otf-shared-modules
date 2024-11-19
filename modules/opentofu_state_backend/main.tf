variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "enable_versioning" {
  type        = bool
  description = "Enable bucket versioning"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_s3_bucket" "main" {
  bucket = "${var.name_prefix}-opentofu-state-${random_string.suffix.result}"
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.main.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "main" {
  name         = "${var.name_prefix}-opentofu-locks-${random_string.suffix.result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "bucket_name" {
  description = "Name of the s3 bucket"
  value       = aws_s3_bucket.main.bucket
}

output "dynamodb_table_name" {
  description = "Name of the dynamodb table used for locking"
  value       = aws_dynamodb_table.main.name
}

output "usage" {
  description = "Example state backend configuration"
  value       = <<EOF
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.main.bucket}"
    key            = "A_UNIQUE_IDENTIFIER_FOR_YOUR_ROOT_MODULES/terraform.tfstate"
    dynamodb_table = "${aws_dynamodb_table.main.name}"
  }
}
EOF
}
