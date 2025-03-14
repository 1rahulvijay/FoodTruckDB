from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from concurrent.futures import ThreadPoolExecutor


class KPIApp:
    def __init__(self):
        self.app = Flask(__name__)
        CORS(self.app)  # Enable CORS
        self.df = self.load_data()
        self.setup_routes()

    def load_data(self):
        """Loads the sample data into a Pandas DataFrame."""
        data = {
            "employee": ["A", "B", "A", "C", "B"],
            "department": ["HR", "IT", "HR", "IT", "Finance"],
            "requests": [10, 20, 15, 5, 25],
            "time_spent": [30, 40, 35, 20, 50],
        }
        return pd.DataFrame(data)

    def calculate_avg(self, df, column):
        return {column: df[column].mean()}

    def calculate_total(self, df, column):
        return {column: df[column].sum()}

    def pivot_sum_by(self, df, group_by_column, value_column):
        return df.groupby(group_by_column)[value_column].sum().to_dict()

    def pivot_avg_by(self, df, group_by_column, value_column):
        return df.groupby(group_by_column)[value_column].mean().to_dict()

    def convert_numpy(obj):
        if isinstance(
            obj, (np.integer, np.int64)
        ):  # Convert NumPy integers to Python int
            return int(obj)
        elif isinstance(
            obj, (np.floating, np.float64)
        ):  # Convert NumPy floats to Python float
            return float(obj)
        elif isinstance(obj, np.ndarray):  # Convert NumPy arrays to lists
            return obj.tolist()
        return obj  # Leave text and other data types unchanged

    def setup_routes(self):
        """Defines the API routes."""

        @self.app.route("/filters", methods=["GET"])
        def get_filters():
            employees = sorted(self.df["employee"].unique().tolist())
            departments = sorted(self.df["department"].unique().tolist())
            return jsonify({"employees": employees, "departments": departments})

        @self.app.route("/metrics", methods=["GET"])
        def get_metrics():
            include_kpis = request.args.get("include_kpis", "true").lower() == "true"
            include_pivots = (
                request.args.get("include_pivots", "true").lower() == "true"
            )
            employees = request.args.getlist("employee")
            departments = request.args.getlist("department")

            filtered_df = self.df.copy()
            if employees:
                filtered_df = filtered_df[filtered_df["employee"].isin(employees)]
            if departments:
                filtered_df = filtered_df[filtered_df["department"].isin(departments)]

            results = {}

            functions = {
                "avg_requests": lambda df: self.calculate_avg(df, "requests"),
                "total_requests": lambda df: self.calculate_total(df, "requests"),
                "avg_time_spent": lambda df: self.calculate_avg(df, "time_spent"),
            }

            if include_kpis:
                with ThreadPoolExecutor() as executor:
                    future_to_metric = {
                        executor.submit(func, filtered_df): name
                        for name, func in functions.items()
                    }
                    for future in ThreadPoolExecutor().as_completed(future_to_metric):
                        metric_name = future_to_metric[future]
                        try:
                            results[metric_name] = future.result()
                        except Exception as e:
                            results[metric_name] = f"Error: {str(e)}"

            if include_pivots:
                results.update(
                    {
                        "requests_by_employee": self.pivot_sum_by(
                            filtered_df, "employee", "requests"
                        ),
                        "avg_time_by_department": self.pivot_avg_by(
                            filtered_df, "department", "time_spent"
                        ),
                    }
                )

            results = {
                k: self.convert_numpy(v) for k, v in results.items()
            }  # Convert NumPy types
            return jsonify(results)

    def run(self):
        """Runs the Flask app."""
        self.app.run(debug=True)


if __name__ == "__main__":
    app_instance = KPIApp()
    app_instance.run()
