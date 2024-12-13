import json
import time
from flask import Blueprint, request, jsonify
from services.supabase_client import SupabaseClient
from utils.send_gpt import send_gpt
import logging
import os

logger = logging.getLogger("persona_bot")
supabase_client: SupabaseClient = SupabaseClient.get_instance()
version_bp = Blueprint('version_bp', __name__)

@version_bp.route('/version', methods=['POST'])
def version():
    logger.info("Receive '/version' request")
    version = supabase_client.get_app_version()
    if version == None :
        logger.error("Version is none in the DB, row : remote_config, should fix that.")
    return jsonify({
        "version": version.data["value"]
    })