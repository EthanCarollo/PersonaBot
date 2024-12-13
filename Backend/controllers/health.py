import json
import time
from flask import Blueprint, request, jsonify
from services.supabase_client import SupabaseClient
from utils.send_gpt import send_gpt
import logging
import os

logger = logging.getLogger("persona_bot")
supabase_client: SupabaseClient = SupabaseClient.get_instance()
health_bp = Blueprint('health_bp', __name__)

@health_bp.route('/health', methods=['POST'])
def health():
    logger.info("Receive '/health' request")
    maintenance = supabase_client.get_is_maintenance()
    if maintenance == None :
        logger.error("Maintenance is none in the DB, row : remote_config, should fix that.")
    return jsonify({
        "isAlive": maintenance.data["value"] == "false"
    })