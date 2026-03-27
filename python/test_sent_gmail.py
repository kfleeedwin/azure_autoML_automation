#!/usr/bin/env python3

import smtplib
import os
from email.mime.text import MIMEText

EMAIL_FROM = os.getenv("PIPELINE_EMAIL_FROM", "replace-me@example.com")
EMAIL_TO = os.getenv("PIPELINE_EMAIL_TO", "replace-me@example.com")
APP_PASSWORD = os.getenv("PIPELINE_EMAIL_PASSWORD")

if not APP_PASSWORD:
    raise RuntimeError("Set PIPELINE_EMAIL_PASSWORD before running this script")

msg = MIMEText("Pipeline completed successfully")
msg["Subject"] = "Azure ML Pipeline Result"
msg["From"] = EMAIL_FROM
msg["To"] = EMAIL_TO

server = smtplib.SMTP("smtp.gmail.com", 587)
server.ehlo()

server.starttls()
server.ehlo()

server.login(EMAIL_FROM, APP_PASSWORD)

server.send_message(msg)

server.quit()

print("SUCCESS: Email sent to Outlook")



