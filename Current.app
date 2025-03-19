from flask import Blueprint, render_template, current_app
from .tableau_client import TableauClient
from .data_handler import Metrics
from .utils import Utils
import logging

main_bp = Blueprint('main', __name__)
logger = logging.getLogger(__name__)

@main_bp.route('/', methods=['GET', 'POST'])
def index():
    logger.info('Starting index route')
    # Get configuration from app.config
    token_name = current_app.config['TOKEN_NAME']
    token_value = current_app.config['TOKEN_VALUE']
    site_id = current_app.config['SITE_ID']
    server_url = current_app.config['SERVER_URL']
    view_ids = current_app.config['VIEWS']

    # Fetch data from Tableau
    tableau_client = TableauClient(token_name, token_value, site_id, server_url)
    tableau_client.sign_in()
    df_dicts = Utils.run_parallel_view_fetch(tableau_client, view_ids)
    tableau_client.sign_out()

    # Process metrics
    metrics_instance = Metrics(df_dicts, current_app.config)
    metrics_data = metrics_instance.get_metrics()

    # Render the template with metrics data
    logger.info('Rendering template with metrics data')
    return render_template("index.html", metrics=metrics_data)
