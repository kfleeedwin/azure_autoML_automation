# Terraform Infrastructure

## Purpose

This folder provisions the Azure resource foundation required by the rest of the repository. It separates infrastructure creation from AML operational workflows so that resources can be created once and then reused by Ansible and the endpoint tests.

## What It Provisions

The Terraform root module composes two child modules:

- `modules/sa`: Azure Storage resources
- `modules/ml`: Azure Machine Learning dependencies such as workspace storage, container registry, key vault, application insights, and AML workspace

The resulting outputs are designed to feed the local Ansible variable model.

## Requirements

- Terraform 1.5+
- AzureRM provider 3.100+
- Random provider 3.6+
- Azure credentials available to Terraform

## Primary Variables

The root module expects values for:

- `subscription_id`
- `location`
- `allow_public_network_access`
- any naming choices required by your environment

Review `variables.tf` and the child module variable files before applying.

## Initialization And Apply

```bash
cd ~/public_repo/terraform
terraform init
terraform plan \
  -var 'subscription_id=<subscription-id>' \
  -var 'location=<azure-region>' \
  -var 'allow_public_network_access=true'
terraform apply \
  -var 'subscription_id=<subscription-id>' \
  -var 'location=<azure-region>' \
  -var 'allow_public_network_access=true'
```

## Outputs

The root module publishes:

- resource group name
- storage account metadata
- AML workspace metadata
- key vault metadata
- application insights metadata
- container registry metadata

Those outputs are commonly exported into `ansible/group_vars/all/tf.yml` for downstream playbooks.

## Reuse Notes

- Replace placeholder defaults with values appropriate for your subscription and naming standards.
- Decide whether public network access is acceptable for your environment.
- Do not commit generated state files or tfvars that contain real environment details.
- Consider remote state, stricter network controls, and role assignments if you want to adapt this for a production grade deployment.
