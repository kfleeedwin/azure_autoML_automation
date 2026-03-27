# Azure Static Web Apps + linked Azure Function from AML endpoint state

This version is tightened to an Ansible repo layout that already has AML endpoint state files under `./state/online_endpoint*.yml`.

## What it does

- Reads and merges `./state/online_endpoint*.yml`
- Automatically resolves the target AML endpoint from either:
  - `azure_ml_target_model_name` (default: `diabetes-best-model`), or
  - `azure_ml_target_endpoint_name`
- Pulls `scoring_uri` and `primary_key` from the selected state entry
- Writes those values into the Azure Function App settings
- Deploys a Static Web App frontend and links the Function App as `/api`
- Writes a new state file to `./state/static_web_app_diabetes.yml`

## Expected AML endpoint state shape

Example input file under `./state/online_endpoint_diabetes.yml`:

```yaml
diabetes-online-endpoint:
  deployment_name: blue
  endpoint_name: diabetes-online-endpoint
  instance_count: 1
  instance_type: Standard_D2as_v4
  model_name: diabetes-best-model
  model_version: '1'
  primary_key: REDACTED
  scoring_uri: https://<endpoint-name>.<region>.inference.ml.azure.com/score
```

## Required variables

Pass these at runtime:

- `resource_group_name`
- `static_web_app_name`
- `azure_function_app_name`
- `function_storage_account_name`

Optional:

- `azure_location` (default: `southeastasia`)
- `azure_ml_target_model_name` (default: `diabetes-best-model`)
- `azure_ml_target_endpoint_name` (overrides model-name matching when set)
- `web_app_title`
- `web_app_description`

## Example run

```bash
ansible-playbook deploy_swa_functions_from_state.yml \
  -e resource_group_name=<resource-group> \
  -e azure_location=southeastasia \
  -e static_web_app_name=<static-web-app-name> \
  -e azure_function_app_name=<function-app-name> \
  -e function_storage_account_name=<storage-account-name>
```

If you want to select by endpoint name instead of model name:

```bash
ansible-playbook deploy_swa_functions_from_state.yml \
  -e resource_group_name=<resource-group> \
  -e static_web_app_name=<static-web-app-name> \
  -e azure_function_app_name=<function-app-name> \
  -e function_storage_account_name=<storage-account-name> \
  -e azure_ml_target_endpoint_name=diabetes-online-endpoint
```

## Files rendered into your repo

- `./files/swa_diabetes_app/frontend/index.html`
- `./files/swa_diabetes_app/frontend/staticwebapp.config.json`
- `./files/swa_diabetes_app/functionapp/function_app.py`
- `./files/swa_diabetes_app/functionapp/host.json`
- `./files/swa_diabetes_app/functionapp/requirements.txt`
- `./files/swa_diabetes_app/functionapp.zip`
- `./state/static_web_app_diabetes.yml`

## Tooling assumptions

The controller running Ansible has:

- Azure CLI (`az`)
- Node + npm
- `swa` CLI or permission for the playbook to install it with npm
- `zip`

## Notes

- Static Web Apps must be `Standard` or `Dedicated` to link an existing Function App.
- The Function App is created on Linux Consumption and deployed by zip deploy.
- This starter keeps the Function route anonymous because the frontend calls it through the linked Static Web App backend.
- The AML endpoint key never goes into the browser. It stays in Function App settings.
