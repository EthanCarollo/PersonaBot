# TODO : Create a route for the bot adding in python
import json
import time
from flask import Blueprint, request, jsonify
from services.supabase_client import SupabaseClient
from utils.send_gpt import send_gpt
from services.chat_query_service import ChatQueryService
import logging
import os

logger = logging.getLogger("persona_bot")
add_bot_bp = Blueprint('add_bot_bp', __name__)
supabase_client: SupabaseClient = SupabaseClient.get_instance()


@add_bot_bp.route('/bot/add', methods=['POST'])
def add_bot():
    bot_id = data.get("bot_id")
    if not bot:
        return jsonify({"error": "Missing 'bot_id'"}), 400

    token = data.get('token')
    supabase_client.get_profile_from_jwt(token)
    pass