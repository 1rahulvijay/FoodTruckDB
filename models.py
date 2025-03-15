import json
import logging
import requests
from redis import Redis

class DataFetcher:
    """Class to handle data fetching from Tableau Server."""
    def __init__(self, server_url, api_token):
        self.server_url = server_url
        self.api_token = api_token
        self.logger = logging.getLogger(__name__)

    def fetch_data(self):
        """Fetch data from Tableau Server."""
        try:
            headers = {'Authorization': f'Bearer {self.api_token}'}
            response = requests.get(f'{self.server_url}/api/data', headers=headers, timeout=600)
            response.raise_for_status()
            data = response.json()
            self.logger.info("Successfully fetched data from Tableau Server.")
            return json.dumps(data)
        except Exception as e:
            self.logger.error(f"Failed to fetch data: {str(e)}")
            raise

class DataCache:
    """Class to manage caching with Redis."""
    def __init__(self, redis_client: Redis):
        self.redis = redis_client
        self.logger = logging.getLogger(__name__)

    def set_data(self, key, value, ttl=3600):
        """Cache data with an optional time-to-live (TTL)."""
        try:
            self.redis.setex(key, ttl, value)
            self.logger.info(f"Cached data with key: {key}")
        except Exception as e:
            self.logger.error(f"Failed to cache data: {str(e)}")
            raise

    def get_data(self, key):
        """Retrieve data from cache."""
        try:
            data = self.redis.get(key)
            return json.loads(data) if data else None
        except Exception as e:
            self.logger.error(f"Failed to retrieve cached data: {str(e)}")
            return None

class MetricComputer:
    """Class to compute metrics from data."""
    def __init__(self, data):
        self.data = data
        self.logger = logging.getLogger(__name__)

    def compute(self, metric_name):
        """Compute a specific metric."""
        try:
            if not self.data:
                raise ValueError("No data available for computation")
            # Example computation (customize based on actual data structure)
            if metric_name == "total_count":
                return len(self.data)
            elif metric_name == "avg_value":
                return sum(d.get("value", 0) for d in self.data) / len(self.data)
            self.logger.info(f"Computed metric: {metric_name}")
            return None
        except Exception as e:
            self.logger.error(f"Error computing metric {metric_name}: {str(e)}")
            return None
