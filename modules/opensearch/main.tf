resource "aws_opensearch_domain" "intellidoc" {
  domain_name           = var.domain_name
  engine_version        = "OpenSearch_2.11"

  cluster_config {
    instance_type = "t3.small.search"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp3"
  }

    access_policies = jsonencode({
    Version = "2012-10-17",
    Statement = [
    {
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::245994248859:role/SaveAndIndex_role"
      },
      Action = [
        "es:ESHttpPut",
        "es:ESHttpPost",
        "es:ESHttpGet"
      ],
      Resource = "arn:aws:es:us-east-1:245994248859:domain/intellidoc-engine/*"
    }
  ]
})

  advanced_security_options {
    enabled                        = false
    internal_user_database_enabled = false
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  tags = {
    Project = "IntelliDoc"
  }
}

data "aws_caller_identity" "current" {}
