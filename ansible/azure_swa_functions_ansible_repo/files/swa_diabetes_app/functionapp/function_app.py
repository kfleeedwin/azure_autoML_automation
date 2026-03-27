import json
import os
import requests
import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

COLUMNS = [
    "PatientID",
    "Pregnancies",
    "PlasmaGlucose",
    "DiastolicBloodPressure",
    "TricepsThickness",
    "SerumInsulin",
    "BMI",
    "DiabetesPedigree",
    "Age"
]

@app.route(route="predict", methods=["POST"])
def predict(req: func.HttpRequest) -> func.HttpResponse:
    try:
        body = req.get_json()

        row = [
            int(body["PatientID"]),
            int(body["Pregnancies"]),
            float(body["PlasmaGlucose"]),
            float(body["DiastolicBloodPressure"]),
            float(body["TricepsThickness"]),
            float(body["SerumInsulin"]),
            float(body["BMI"]),
            float(body["DiabetesPedigree"]),
            int(body["Age"]),
        ]

        aml_payload = {
            "input_data": {
                "columns": COLUMNS,
                "data": [row],
                "index": [0]
            }
        }

        aml_uri = os.environ["AML_SCORING_URI"]
        aml_key = os.environ["AML_API_KEY"]
        aml_endpoint_name = os.environ.get("AML_ENDPOINT_NAME", "n/a")
        aml_model_name = os.environ.get("AML_MODEL_NAME", "n/a")
        aml_model_version = os.environ.get("AML_MODEL_VERSION", "n/a")

        aml_resp = requests.post(
            aml_uri,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {aml_key}",
            },
            json=aml_payload,
            timeout=30,
        )
        aml_resp.raise_for_status()
        raw = aml_resp.json()

        prediction = None

        if isinstance(raw, list) and raw:
            prediction = bool(int(raw[0]))
        elif isinstance(raw, dict):
            if "result" in raw and isinstance(raw["result"], list) and raw["result"]:
                prediction = bool(int(raw["result"][0]))
            elif "predictions" in raw and isinstance(raw["predictions"], list) and raw["predictions"]:
                prediction = bool(int(raw["predictions"][0]))
            elif "output" in raw and isinstance(raw["output"], list) and raw["output"]:
                prediction = bool(int(raw["output"][0]))

        return func.HttpResponse(
            json.dumps({
                "prediction": prediction,
                "label": "true" if prediction else "false",
                "aml_endpoint": aml_endpoint_name,
                "model": aml_model_name,
                "model_version": aml_model_version,
                "raw": raw
            }),
            mimetype="application/json",
            status_code=200
        )

    except Exception as e:
        return func.HttpResponse(
            json.dumps({
                "error": str(e)
            }),
            mimetype="application/json",
            status_code=500
        )