import json
import time
from flask import Blueprint, request, jsonify
from services.supabase_client import SupabaseClient
from utils.send_gpt import send_gpt
from services.chat_query_service import ChatQueryService
import logging
import os

logger = logging.getLogger("persona_bot")
bot_data_bp = Blueprint('bot_data_bp', __name__)
supabase_client: SupabaseClient = SupabaseClient.get_instance()

@bot_data_bp.route('/bot/data', methods=['POST'])
def chat_with_bot():
    data = request.json

    new_data = data.get('new_data')
    if not new_data:
        return jsonify({"error": "Missing 'new_data'"}), 400
    
    bot = data.get("bot_public_id")
    if not bot:
        return jsonify({"error": "Missing 'bot'"}), 400
    
    bot_information = supabase_client.get_bot_with_public_id(bot)
    if not bot_information :
        return jsonify({"error": "Bot doesn't exist, weird."}), 400

    chatQueryService : ChatQueryService = ChatQueryService(bot_information.data["bot_public_id"])
    chatQueryService.upsert_node(new_data)


    # This route can be called even if the user isn't connected so we retire the token part
    # token = data.get('token')
    
    return jsonify({
        "response": "noice insertion noice"
    })

