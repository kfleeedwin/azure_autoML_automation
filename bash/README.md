# Bash Endpoint Tests

## Purpose

This folder contains lightweight shell scripts for validating deployed Azure ML managed online endpoints. Each script resolves the current workspace and resource group from local state, retrieves the active scoring URI and endpoint key from Azure, submits a representative inference payload, and prints the result.

## Local State Requirements

The scripts assume a locally generated state file exists at a path similar to:

- `ansible/group_vars/all/tf.yml`

That file is expected to contain at least:

- `resource_group_name`
- `ml_workspace.name`

These scripts are therefore most useful after the Terraform and Ansible workflows have already completed.

## Runtime Requirements

- Bash
- Azure CLI authenticated with access to the target AML workspace
- `jq`
- `curl`

## Typical Flow

1. Provision infrastructure with Terraform.
2. Export Terraform outputs into the Ansible variable file.
3. Use Ansible to deploy the target online endpoint.
4. Execute the corresponding Bash script to validate inference.

## Example

```bash
cd ~/public_repo/bash
chmod +x test_endpoint_titanic.sh
./test_endpoint_titanic.sh
```

## Script Behavior

Each test script typically:

- loads the local Terraform exported state file
- resolves the AML resource group and workspace name
- queries Azure ML for the current scoring URI
- retrieves the endpoint primary key
- sends a representative JSON payload to the endpoint
- prints the prediction or response fragment

## Reuse Notes

- Adjust hardcoded state file paths if your checkout path differs.
- Treat these scripts as smoke tests, not full model evaluation.
- Keep endpoint keys dynamic and local; do not hardcode them into the scripts.
