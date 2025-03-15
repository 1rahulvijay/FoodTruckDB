from flask import Blueprint, render_template, request, jsonify
from app.tasks import compute_metric
from app.models import DataCache

routes = Blueprint('routes', __name__)

@routes.route('/')
def index():
    """Render the main page."""
    return render_template('index.html')

@routes.route('/data', methods=['GET'])
def get_data():
    """Get filtered data from cache."""
    cache = DataCache(current_app.redis_client)
    data = cache.get_data('tableau_data')
    if not data:
        return jsonify({"error": "Data not available, fetching in background"}), 503

    filters = request.args.to_dict()
    # Apply filters (example logic, customize as needed)
    filtered_data = [
        d for d in data if all(d.get(k) == v for k, v in filters.items())
    ]
    return jsonify(filtered_data)

@routes.route('/metrics', methods=['POST'])
def compute_metrics():
    """Compute multiple metrics in parallel."""
    metric_names = request.json.get('metrics', [])
    if not metric_names:
        return jsonify({"error": "No metrics specified"}), 400

    # Launch parallel tasks
    from celery.group import group
    tasks = group(compute_metric.s(name) for name in metric_names)
    result = tasks.apply_async()
    return jsonify({"task_id": result.id})

@routes.route('/task/<task_id>', methods=['GET'])
def task_status(task_id):
    """Check the status of a Celery task."""
    from celery.result import AsyncResult
    task = AsyncResult(task_id)
    if task.state == 'PENDING':
        return jsonify({"status": "Pending"})
    elif task.state == 'SUCCESS':
        return jsonify({"status": "Success", "results": task.result})
    else:
        return jsonify({"status": task.state})
