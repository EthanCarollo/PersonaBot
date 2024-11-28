from utils.logger import configure_logger
import logging

configure_logger()
logger = logging.getLogger("xlinks")

from flask import Flask
from flask_cors import CORS
from services.supabase_client import SupabaseClient
from services.chat_query_service import ChatQueryService
import config
import json

def create_app():
    from controllers.chat import chat_bp
    from controllers.bot.data import bot_data_bp
    from controllers.bot.create import create_bot_data_bp
    
    # Trust CORS from everywhere
    app = Flask(__name__)
    CORS(app, resources={r"/*": {"origins": "*"}})
    
    app.register_blueprint(chat_bp)
    app.register_blueprint(bot_data_bp)
    app.register_blueprint(create_bot_data_bp)
    return app

supabase_client : SupabaseClient = SupabaseClient.get_instance()

logger.good("Launching application")
app = create_app()