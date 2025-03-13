from flask import Flask, jsonify, request
import pandas as pd
from concurrent.futures import ThreadPoolExecutor
from config import API_CONFIG

app = Flask(__name__)

# Load sample dataset (Replace this with a real DB if needed)
df = pd.read_csv("backend\data.csv")

@app.route("/filters", methods=["GET"])
def get_filters():
    """Return unique employee and department names for dropdowns."""
    employees = df["employee"].unique().tolist()
    departments = df["department"].unique().tolist()
    return jsonify({"employees": employees, "departments": departments})

@app.route("/metrics", methods=["GET"])
def get_metrics():
    """Fetch filtered KPIs and execute them in parallel."""
    employees = request.args.getlist("employee")
    departments = request.args.getlist("department")

    filtered_df = df.copy()

    # Apply filters (if "All" is selected, don't filter)
    if employees and "All" not in employees:
        filtered_df = filtered_df[filtered_df["employee"].isin(employees)]
    if departments and "All" not in departments:
        filtered_df = filtered_df[filtered_df["department"].isin(departments)]

    results = {}
    with ThreadPoolExecutor() as executor:
        futures = {
            "avg_requests": executor.submit(lambda: filtered_df["requests"].mean()),
            "total_requests": executor.submit(lambda: filtered_df["requests"].sum()),
            "avg_time_spent": executor.submit(lambda: filtered_df["time_spent"].mean()),
        }
        for key, future in futures.items():
            results[key] = future.result()

    # Grouped results
    results.update({
        "requests_by_employee": filtered_df.groupby("employee")["requests"].sum().to_dict(),
        "avg_time_by_department": filtered_df.groupby("department")["time_spent"].mean().to_dict(),
    })

    return jsonify(results)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=API_CONFIG["PORT"], debug=True)
