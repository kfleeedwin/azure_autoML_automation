# Ansible Automation

## Purpose

This folder contains the operational workflow for Azure Machine Learning and related Azure services. The playbooks handle data registration, compute provisioning, AutoML job submission, best model discovery, model registration, managed online endpoint deployment, and local state generation for downstream steps.

## Functional Scope

- Create AML datastores and register data assets
- Create AML compute clusters and compute instances
- Launch AutoML jobs for multiple datasets
- Retrieve and register best models
- Deploy managed online endpoints and capture scoring URIs and keys
- Generate local helper files for endpoint validation and manual testing

## Required Inputs

Most playbooks assume one or more of the following are present:

- `group_vars/all/tf.yml` containing exported Terraform outputs
- local execution state in `state/`
- source datasets under `files/`
- an authenticated Azure CLI session

The committed `group_vars/all/tf.yml.example` file documents the expected structure of the Terraform derived variables.

## Generated State

Playbooks under this folder generate files in `state/`. Those files are intentionally excluded from version control because they may contain:

- storage access keys
- AML registered model metadata
- scoring URIs
- online endpoint primary keys

Treat `state/` as local runtime output, not source.

## Environment Setup

```bash
cd ~/public_repo
python3 -m venv .venv
source .venv/bin/activate
pip install ansible
ansible-galaxy collection install -r ansible/requirements.yml
az login
az extension add --name ml
```

## Suggested Execution Order

1. Export Terraform outputs into `group_vars/all/tf.yml`.
2. Generate any required storage key state locally.
3. Create AML compute resources.
4. Register datastores and data assets.
5. Run the desired AutoML playbooks.
6. Retrieve and register the best models.
7. Deploy managed online endpoints.
8. Generate local endpoint env files only on your machine.

## Example Commands

```bash
cd ~/public_repo/ansible
ansible-playbook -i inventory.ini playbook_AzureML_compute_cluster_create.yml
ansible-playbook -i inventory.ini playbook_register_datastore_and_data_assets.yml
ansible-playbook -i inventory.ini playbook_AzureML_AutoML_titanic_data.yml
ansible-playbook -i inventory.ini playbook_automl_get_best_model.yml
ansible-playbook -i inventory.ini playbook_automl_register_best_model.yml
ansible-playbook -i inventory.ini playbook_automl_online_endpoint_deployment_titanic.yml
```

## Reuse Notes

- Review playbooks for Azure region, quota, and SKU assumptions.
- Endpoint deployment workflows deliberately write sensitive values into local state for convenience.
- This folder is structured for iterative local execution rather than a fully stateless CI pipeline.
