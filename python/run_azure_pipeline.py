#!/usr/bin/env python3

import subprocess
import sys
import smtplib
import os
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# =========================
# CONFIGURATION
# =========================

BASE_DIR = os.path.expanduser("~/azure_auomation_dev")
ANSIBLE_DIR = os.path.join(BASE_DIR, "ansible")
TERRAFORM_DIR = os.path.join(BASE_DIR, "terraform")

EMAIL_FROM = os.getenv("PIPELINE_EMAIL_FROM", "replace-me@example.com")
EMAIL_TO = os.getenv("PIPELINE_EMAIL_TO", "replace-me@example.com")
EMAIL_PASSWORD = os.getenv("PIPELINE_EMAIL_PASSWORD")

SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587

LOG_FILE = os.path.join(BASE_DIR, "run_azure_pipeline.log")

# =========================
# COMMAND LIST
# =========================

commands = [

    {
        "name": "Terraform state cleanup",
        "cmd": "terraform state rm $(terraform state list)",
        "cwd": TERRAFORM_DIR
    },

    {
        "name": "Terraform apply ML module",
        "cmd": "terraform apply -replace=random_string.ml_suffix -target=module.ml -auto-approve",
        "cwd": TERRAFORM_DIR
    },

    {
        "name": "Terraform refresh state",
        "cmd": "terraform apply -refresh-only -auto-approve",
        "cwd": TERRAFORM_DIR
    },

    {
        "name": "Export Terraform outputs",
        "cmd": """terraform output -json | jq '
{
  resource_group_name: .resource_group_name.value,
  storage_accounts: .storage_accounts.value,
  container_registry: .container_registry.value,
  ml_workspace: (.ml_workspace.value // null),
  key_vault: (.key_vault.value // null),
  application_insights: (.application_insights.value // null)
}' > ../ansible/group_vars/all/tf.yml""",
        "cwd": TERRAFORM_DIR
    },

    {
        "name": "Create AML compute cluster",
        "cmd": "ansible-playbook -i inventory.ini playbook_AzureML_compute_cluster_create.yml",
        "cwd": ANSIBLE_DIR
    },

#    {
#        "name": "Create AML compute instance",
#        "cmd": "ansible-playbook -i inventory.ini playbook_AzureML_compute_instance_create.yml",
#        "cwd": ANSIBLE_DIR
#    },

    {
        "name": "AutoML Diabetes",
        "cmd": "ansible-playbook -i inventory.ini playbook_AzureML_AutoML_diabetes_data.yml",
        "cwd": ANSIBLE_DIR
    },

    {
        "name": "AutoML Bike Rental",
        "cmd": "ansible-playbook -i inventory.ini playbook_AzureML_AutoML_bike_rental_data.yml",
        "cwd": ANSIBLE_DIR
    },

    {
        "name": "AutoML Titanic",
        "cmd": "ansible-playbook -i inventory.ini playbook_AzureML_AutoML_titanic_data.yml",
        "cwd": ANSIBLE_DIR
    },

    {
        "name": "AutoML Temperature Forecast",
        "cmd": "ansible-playbook -i inventory.ini playbook_AzureML_AutoML_temp_forecast_data.yml",
        "cwd": ANSIBLE_DIR
    }

]

# =========================
# LOG FUNCTION
# =========================

def log(msg):

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    line = f"[{timestamp}] {msg}"

    print(line)

    with open(LOG_FILE, "a") as f:
        f.write(line + "\n")


# =========================
# EMAIL FUNCTION
# =========================

def send_email(subject, body):

    try:
        if not EMAIL_PASSWORD:
            log("Email skipped: PIPELINE_EMAIL_PASSWORD is not set")
            return

        msg = MIMEMultipart()

        msg["From"] = EMAIL_FROM
        msg["To"] = EMAIL_TO
        msg["Subject"] = subject

        msg.attach(MIMEText(body, "plain"))

        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)

        server.starttls()

        server.login(EMAIL_FROM, EMAIL_PASSWORD)

        server.send_message(msg)

        server.quit()

        log("Email sent")

    except Exception as e:

        log(f"Email failed: {str(e)}")


# =========================
# RUN COMMAND FUNCTION
# =========================

def run_command(step):

    name = step["name"]

    cmd = step["cmd"]

    cwd = step["cwd"]

    log(f"START: {name}")

    result = subprocess.run(
        cmd,
        cwd=cwd,
        shell=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True
    )

    if result.returncode != 0:

        log(f"FAILED: {name}")

        log(result.stderr)

        send_email(
            f"Pipeline FAILED at step: {name}",
            result.stderr
        )

        sys.exit(1)

    log(f"SUCCESS: {name}")


# =========================
# MAIN FUNCTION
# =========================

def main():

    log("===== PIPELINE START =====")

    for step in commands:

        run_command(step)

    log("===== PIPELINE SUCCESS =====")

    send_email(
        "Pipeline SUCCESS",
        "All Terraform and Ansible steps completed successfully."
    )


# =========================
# ENTRY POINT
# =========================

if __name__ == "__main__":

    main()
