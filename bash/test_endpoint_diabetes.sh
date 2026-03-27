#!/usr/bin/env bash

# =====================================#
# DIABETES                             #
# Endpoint: diabetes-online-endpoint   #
# =====================================#

set -euo pipefail

TF_STATE_FILE="$HOME/azure_auomation_dev/ansible/group_vars/all/tf.yml"

[[ -f "$TF_STATE_FILE" ]] || { echo "State file not found: $TF_STATE_FILE"; exit 1; }

RESOURCE_GROUP=$(jq -er '.resource_group_name' "$TF_STATE_FILE")
WORKSPACE_NAME=$(jq -er '.ml_workspace.name' "$TF_STATE_FILE")

SCORING_URI=$(az ml online-endpoint show \
  --name diabetes-online-endpoint \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --query scoring_uri -o tsv)

PRIMARY_KEY=$(az ml online-endpoint get-credentials \
  --name diabetes-online-endpoint \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --query primaryKey -o tsv)

RESULT=$(curl -s -X POST "$SCORING_URI" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PRIMARY_KEY" \
  -d '{
    "input_data": {
      "columns": [
        "PatientID",
        "Pregnancies",
        "PlasmaGlucose",
        "DiastolicBloodPressure",
        "TricepsThickness",
        "SerumInsulin",
        "BMI",
        "DiabetesPedigree",
        "Age"
      ],
      "data": [
        [1, 2, 138, 62, 35, 0, 33.6, 0.127, 47]
      ]
    }
  }' | jq '.[0]') 

  echo "Result for diabetes prediction: $RESULT"
