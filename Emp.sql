import pandas as pd
import random

class DataHandler:
    def __init__(self):
        self.df = pd.DataFrame({
            "employee": ["A", "B", "A", "C", "B", "D", "E", "A", "C"],
            "department": ["HR", "IT", "HR", "IT", "Finance", "HR", "IT", "Finance", "HR"],
            "requests": [10, 20, 15, 5, 25, 30, 10, 15, 25],
            "time_spent": [30, 40, 35, 20, 50, 60, 45, 55, 35],
            "status": [random.choice(["Completed", "Pending", "Rejected"]) for _ in range(9)]
        })

    def get_metrics(self):
        avg_requests = float(self.df["requests"].mean())
        total_requests = int(self.df["requests"].sum())
        avg_time_spent = float(self.df["time_spent"].mean())
        requests_by_employee = self.df.groupby("employee")["requests"].sum().to_dict()
        avg_time_by_department = self.df.groupby("department")["time_spent"].mean().to_dict()
        
        efficiency = {emp: round(reqs / (self.df[self.df["employee"] == emp]["time_spent"].sum() / 60), 2) for emp, reqs in requests_by_employee.items()}
        request_status_count = self.df["status"].value_counts().to_dict()

        return {
            "avg_requests": avg_requests,
            "total_requests": total_requests,
            "avg_time_spent": avg_time_spent,
            "requests_by_employee": requests_by_employee,
            "avg_time_by_department": avg_time_by_department,
            "efficiency": efficiency,
            "request_status_count": request_status_count
        }
