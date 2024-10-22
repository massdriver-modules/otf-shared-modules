variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_s3_bucket" "main" {
  bucket = "${var.name_prefix}-opentofu-state-${random_string.suffix.result}"
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
