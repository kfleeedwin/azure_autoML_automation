# Python Utilities

## Purpose

This folder contains helper scripts that support the broader Terraform and Ansible workflow. The scripts cover pipeline orchestration, SMTP based notifications, and direct Azure Vision API usage examples.

## Included Scripts

- `run_azure_pipeline.py`: sequential local runner for Terraform and Ansible steps with logging and optional email notification
- `azure_vision_api.py`: CLI client for Azure Vision image analysis using either an image URL or local file
- `azure_vision_api_post.py`: minimal direct POST example for the Azure Vision endpoint
- `test_sent_email.py` and `test_sent_gmail.py`: SMTP notification tests

## Environment Requirements

- Python 3.10+
- `requests`
- network access to Azure APIs and SMTP endpoints when those features are used

Setup example:

```bash
cd ~/public_repo
python3 -m venv .venv
source .venv/bin/activate
pip install requests
```

If you use `run_azure_pipeline.py`, the following external tools must also be available in `PATH`:

- Terraform
- Ansible
- Azure CLI
- `jq`

## Configuration

The public repo uses environment variables instead of embedded credentials.

Relevant variables include:

- `PIPELINE_EMAIL_FROM`
- `PIPELINE_EMAIL_TO`
- `PIPELINE_EMAIL_PASSWORD`
- `AZURE_VISION_ENDPOINT`
- `AZURE_VISION_KEY`

## Usage Examples

Azure Vision from an image URL:

```bash
python azure_vision_api.py \
  --image-url https://learn.microsoft.com/azure/cognitive-services/computer-vision/images/windows-kitchen.jpg \
  --endpoint "$AZURE_VISION_ENDPOINT" \
  --key "$AZURE_VISION_KEY"
```

Azure Vision from a local file:

```bash
python azure_vision_api.py \
  --image-file images/objects.jpg \
  --endpoint "$AZURE_VISION_ENDPOINT" \
  --key "$AZURE_VISION_KEY"
```

Pipeline execution:

```bash
export PIPELINE_EMAIL_FROM="you@example.com"
export PIPELINE_EMAIL_TO="alerts@example.com"
export PIPELINE_EMAIL_PASSWORD="<smtp-app-password>"
python run_azure_pipeline.py
```

## Reuse Notes

- `run_azure_pipeline.py` assumes fixed base directories and may need path adjustment after checkout.
- Email notification is optional; the script skips mail if `PIPELINE_EMAIL_PASSWORD` is unset.
- These scripts are operator utilities, not a packaged Python library.
