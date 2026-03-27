# Azure Automation Public Repo

## Overview

This repository packages a reusable Azure automation workflow for infrastructure provisioning, Azure Machine Learning asset management, model training, online endpoint deployment, and inference validation. It combines Terraform for infrastructure, Ansible for Azure ML operations, Python for helper tooling, and Bash for endpoint smoke tests.

The public version is sanitized. Generated state, access keys, endpoint credentials, local editor files, and other environment specific artifacts are intentionally excluded or replaced with placeholders.

## Objectives

- Provision baseline Azure resources required for AML workflows.
- Register datastores and data assets from local or remote datasets.
- Execute Azure ML AutoML experiments for several sample problems.
- Register selected models and deploy managed online endpoints.
- Validate endpoint behavior with lightweight test scripts.
- Provide enough structure for another engineer to reproduce the workflow in a separate Azure subscription.

## Repository Layout

- `ansible/`: operational playbooks for AML data, compute, model, and endpoint workflows.
- `terraform/`: Azure infrastructure modules and root composition.
- `python/`: helper scripts for orchestration, SMTP notifications, and Azure Vision examples.
- `bash/`: shell scripts for endpoint inspection and inference smoke testing.

## End To End Flow

1. Provision Azure resources with Terraform.
2. Export Terraform outputs into the local Ansible variable model.
3. Run Ansible playbooks to create compute, register data, and launch ML jobs.
4. Register best models and deploy managed online endpoints.
5. Execute Bash tests against the deployed endpoints.

## Environment Requirements

A reusable setup should include:

- Linux, macOS, or WSL with Bash
- Terraform 1.5+
- Python 3.10+
- Azure CLI and the Azure ML extension
- Ansible and the `community.general` collection
- `jq` and `curl`
- Azure credentials with permission to create and query the required resources

## Local State Requirements

This project depends on generated local files that are not committed in the public repo.

Important examples:

- `ansible/group_vars/all/tf.yml`: exported Terraform outputs consumed by Ansible
- `ansible/state/*.yml`: AML state, model metadata, endpoint URIs, and derived credentials
- `ansible/files/postman/.env`: local endpoint environment values for manual testing

These files should be generated locally for each environment and treated as sensitive.

## Recommended Setup

```bash
cd ~/public_repo
python3 -m venv .venv
source .venv/bin/activate
pip install ansible requests
ansible-galaxy collection install -r ansible/requirements.yml
az login
az extension add --name ml
terraform -chdir=terraform init
```

## Reproduction Guidance

1. Set Terraform variables for your subscription, region, and naming scheme.
2. Apply Terraform and verify outputs.
3. Create `ansible/group_vars/all/tf.yml` from your Terraform outputs.
4. Run the Ansible workflow in dependency order.
5. Generate local endpoint state and validate deployments with the Bash scripts.
6. Keep all generated state and credentials local.

## Security Notes

- Do not commit generated state files, tfvars, endpoint keys, or storage credentials.
- Review any script that writes local state before using it in CI or on a shared workstation.
- Treat online endpoint primary keys and datastore keys as secrets.

## License

This repository is released under the MIT License. See `LICENSE` for details.

Additional details are documented in `ansible/README.md`, `terraform/README.md`, `python/README.md`, and `bash/README.md`.
