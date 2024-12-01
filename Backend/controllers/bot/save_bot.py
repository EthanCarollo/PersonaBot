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
    data = request.json
    bot_id = data.get("bot_id")
    if not bot_id:
        return jsonify({"error": "Missing 'bot_id'"}), 400

    token = data.get('token')
    if not token:
        return jsonify({"error": "Missing 'token'"}), 400
    supabase_profile = supabase_client.get_profile_from_jwt(token)

    if not supabase_profile:
        return jsonify({"error": "Not a good token !"}), 400

    number_of_bot = supabase_client.get_number_of_bot(supabase_profile.data["id"])
    if can_add_bot(supabase_profile.data["role"], number_of_bot):
        supabase_client.add_bot_to_saved(bot_id, supabase_profile.data["id"])
        return jsonify({"success": "Success !"})
    else :
        return jsonify({"error": "Can't add bot"})

def can_add_bot(role: str, number_of_bot: int) -> bool:
    if role == "pro":
        return True
    if role == "free":
        # If the user is free, he can't add more than 2 bots
        if number_of_bot >= 2:
            return False
        return True
    return True