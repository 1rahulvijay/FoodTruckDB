from flask import Flask
from redis import Redis
import logging

def create_app(config_class='app.config.ProductionConfig'):
    """Application factory."""
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Configure logging
    logging.basicConfig(level=app.config['LOG_LEVEL'])
    logger = logging.getLogger(__name__)
    logger.info("Starting Flask application.")

    # Initialize Redis
    app.redis_client = Redis.from_url(app.config['REDIS_URL'])

    # Register blueprints
    from app.routes import routes
    app.register_blueprint(routes)

    # Start initial data fetch if cache is empty
    from app.tasks import fetch_tableau_data
    cache = DataCache(app.redis_client)
    if not cache.get_data('tableau_data'):
        logger.info("No cached data found, initiating background fetch.")
        fetch_tableau_data.delay()

    return app
