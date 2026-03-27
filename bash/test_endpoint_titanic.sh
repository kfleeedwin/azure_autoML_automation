#!/usr/bin/env bash

# ===================================#
# TITANIC                            #
# Endpoint: titanic-online-endpoint  # 
# ===================================#

set -euo pipefail

TF_STATE_FILE="$HOME/azure_auomation_dev/ansible/group_vars/all/tf.yml"

[[ -f "$TF_STATE_FILE" ]] || { echo "State file not found: $TF_STATE_FILE"; exit 1; }

RESOURCE_GROUP=$(jq -er '.resource_group_name' "$TF_STATE_FILE")
WORKSPACE_NAME=$(jq -er '.ml_workspace.name' "$TF_STATE_FILE")

SCORING_URI=$(az ml online-endpoint show \
  --name titanic-online-endpoint \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --query scoring_uri -o tsv)

PRIMARY_KEY=$(az ml online-endpoint get-credentials \
  --name titanic-online-endpoint \
  --resource-group "$RESOURCE_GROUP" \
  --workspace-name "$WORKSPACE_NAME" \
  --query primaryKey -o tsv)

RESULT=$(curl -s -X POST "$SCORING_URI" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $PRIMARY_KEY" \
  -d '{
    "input_data": {
      "columns": [
        "PassengerId",
        "Pclass",
        "Name",
        "Sex",
        "Age",
        "SibSp",
        "Parch",
        "Ticket",
        "Fare",
        "Cabin",
        "Embarked"
      ],
      "data": [
        [1, 3, "Braund, Mr. Owen Harris", "male", 22.0, 1, 0, "A/5 21171", 7.25, "", "S"]
      ]
    }
  }' | jq '.[0]') 

echo "Result for titanic prediction: $RESULT"
