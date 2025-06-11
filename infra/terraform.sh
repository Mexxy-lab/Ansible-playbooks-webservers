#!/bin/bash

set -e

cd "$(dirname "$0")"

# Set default values
AWS_REGION="${AWS_REGION:-us-east-1}"
AMI_ID="${AMI_ID:-ami-0c55b159cbfafe1f0}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t2.micro}"

# Export values into .tfvars file dynamically
cat > terraform.auto.tfvars <<EOF
aws_region = "${AWS_REGION}"
ami_id = "${AMI_ID}"
instance_type = "${INSTANCE_TYPE}"
EOF

if [[ "$1" == "destroy" ]]; then
  echo "💣 Destroying infrastructure..."
  terraform destroy -auto-approve
else
  echo "🚀 Initializing Terraform..."
  terraform init

  echo "✅ Validating configuration..."
  terraform validate

  echo "🧩 Planning changes..."
  terraform plan -out=tfplan

  echo "🛠️  Applying infrastructure..."
  terraform apply -auto-approve tfplan

  echo "🌐 Public IP:"
  terraform output instance_public_ip
fi
