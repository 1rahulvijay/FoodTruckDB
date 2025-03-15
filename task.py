from celery import Celery
from app import create_app
from app.models import DataFetcher, DataCache

app = create_app()
celery = Celery(app.name, broker=app.config['CELERY_BROKER_URL'])
celery.conf.update(app.config)

@celery.task(bind=True, max_retries=3)
def fetch_tableau_data(self):
    """Background task to fetch data from Tableau Server."""
    try:
        fetcher = DataFetcher(app.config['TABLEAU_SERVER_URL'], app.config['TABLEAU_API_TOKEN'])
        cache = DataCache(app.redis_client)
        data = fetcher.fetch_data()
        cache.set_data('tableau_data', data)
        return {"status": "success"}
    except Exception as e:
        self.retry(exc=e, countdown=60)

@celery.task
def compute_metric(metric_name):
    """Background task to compute a metric."""
    cache = DataCache(app.redis_client)
    data = cache.get_data('tableau_data')
    computer = MetricComputer(data)
    result = computer.compute(metric_name)
    return {metric_name: result}

# Schedule periodic data fetching
celery.conf.beat_schedule = {
    'fetch-tableau-data-hourly': {
        'task': 'app.tasks.fetch_tableau_data',
        'schedule': 3600.0,  # Every hour
    },
}
