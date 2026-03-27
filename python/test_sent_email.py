#!/usr/bin/env python3

import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

EMAIL_FROM = os.getenv("PIPELINE_EMAIL_FROM", "replace-me@example.com")
EMAIL_TO = os.getenv("PIPELINE_EMAIL_TO", "replace-me@example.com")
EMAIL_PASSWORD = os.getenv("PIPELINE_EMAIL_PASSWORD")

SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587

def send_email(subject, body):
    if not EMAIL_PASSWORD:
        raise RuntimeError("Set PIPELINE_EMAIL_PASSWORD before running this script")

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

    print("Email sent")

if __name__ == "__main__":

    send_email("Test Email", "Pipeline email working")
