# Newcomer Guide

## Scope and assumptions

This repository is an **operator-focused automation project** for Azure infrastructure, Azure ML workflows, and endpoint validation. It assumes:

- You are running in an authorized Azure subscription.
- You have contributor-level permissions (or equivalent scoped permissions) for target resources.
- You will keep generated state and credentials local.

## What this repo does

This repository automates a full Azure Machine Learning (AML) workflow:

1. Provision Azure infrastructure with Terraform.
2. Export Terraform outputs into Ansible variables.
3. Use Ansible playbooks to create AML compute, register data, launch AutoML jobs, and deploy online endpoints.
4. Validate endpoint inference with Bash smoke tests.
5. Optionally orchestrate repeated steps from Python.

## Top-level structure

- `terraform/`: creates Azure resources (storage, AML workspace and dependencies).
- `ansible/`: operational playbooks for data assets, compute, jobs, model registration, endpoint deployment.
- `bash/`: endpoint smoke-test scripts using `az`, `curl`, and `jq`.
- `python/`: helper scripts for sequential orchestration and email notifications.

## How components connect

- Terraform root module composes `modules/sa` and `modules/ml`.
- Terraform outputs are transformed into `ansible/group_vars/all/tf.yml` (local, uncommitted).
- Ansible reads `tf.yml` and writes runtime state files in `ansible/state/`.
- Bash scripts read `tf.yml` and query endpoint metadata at runtime.

## Important generated local files

These are intentionally not committed and may contain secrets:

- `ansible/group_vars/all/tf.yml`
- `ansible/state/*.yml`
- `ansible/files/postman/.env`

## Safe execution model (recommended)

For security and change control, follow this sequence:

1. **Read-only validation first**: confirm Azure context and workspace targets before apply/deploy.
2. **Plan before change**: run Terraform plan and review intended changes.
3. **Scoped execution**: run one playbook at a time and inspect generated state.
4. **Endpoint verification**: test inference only after deployment succeeds.
5. **Post-run hygiene**: keep state local, rotate secrets if exposed, and avoid committing generated files.

## Typical execution sequence

1. `terraform init && terraform plan` in `terraform/`.
2. `terraform apply` only after plan review.
3. Export Terraform outputs into `ansible/group_vars/all/tf.yml`.
4. Run compute and data registration playbooks.
5. Run AutoML playbooks.
6. Run best-model and register-model playbooks.
7. Deploy online endpoint playbooks.
8. Run Bash endpoint tests.

## High-value checks before running changes

```bash
# 1) Verify account and subscription context
az account show --output table

# 2) Confirm Terraform formatting/validation
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate

# 3) Dry-run Ansible task impact where possible
ansible-playbook -i ansible/inventory.ini ansible/playbook_AzureML_compute_cluster_create.yml --check
```

## Things newcomers should watch for

- Several scripts/playbooks expect fixed local paths (for example under `$HOME/azure_auomation_dev`).
- Endpoint deployment is quota-sensitive; playbooks often deploy one selected model first.
- State files are part of the execution contract between playbooks.
- Endpoint keys and storage keys are sensitive; never hardcode them.
- The public repository is sanitized; you must generate local runtime state yourself.

## Suggested next learning path

1. Read `README.md`, then each folder README (`terraform/`, `ansible/`, `python/`, `bash/`).
2. Inspect one end-to-end path (for example Titanic):
   - AutoML playbook
   - best-model discovery playbook
   - register-model playbook
   - endpoint deployment playbook
   - bash smoke test
3. Add a new dataset/model by cloning one existing pattern.
4. Improve reproducibility by parameterizing hardcoded paths and documenting state contracts explicitly.
5. Add lightweight CI checks (`terraform validate`, `ansible-lint`, shellcheck for `bash/`) to catch regressions early.
