resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # Serverless pricing (Free Tier eligible)
  hash_key     = "id"              # Primary Key

  attribute {
    name = "id"
    type = "S" # String
  }

  # Enable Point-in-Time Recovery (Backup best practice)
  point_in_time_recovery {
    enabled = true
  }

  # Server-Side Encryption
  server_side_encryption {
    enabled = true
  }

  tags = var.tags
}