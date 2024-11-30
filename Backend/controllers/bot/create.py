# TODO : Create a route for the bot creation in python
import json
import time
from flask import Blueprint, request, jsonify
from services.supabase_client import SupabaseClient
from utils.send_gpt import send_gpt
from services.chat_query_service import ChatQueryService
import logging
import os

logger = logging.getLogger("persona_bot")
create_bot_data_bp = Blueprint('create_bot_data_bp', __name__)
supabase_client: SupabaseClient = SupabaseClient.get_instance()



@create_bot_data_bp.route('/bot/create', methods=['POST'])
def add_bot():
    data = request.json

    bot_public_id = data.get("botPublicId")
    if not bot_public_id:
        return jsonify({"error": "Missing 'botPublicId'"}), 400

    bot_name = data.get("botName")

    if not bot_name:
        return jsonify({"error": "Missing 'botName'"}), 400
    
    # this field isnt necessary so i get it and if he is not here, i just don't use it
    bot_description = data.get("description")

    # This is also "unnecessary"
    bot_knowledge = data.get("knowledges")

    token = data.get('token')
    supabase_profile = supabase_client.get_profile_from_jwt(token)

    if not supabase_profile:
        return jsonify({"error": "Not a good token !"}), 400

    logger.info("Will create bot with name : '" + bot_name + "' and id : '" + bot_public_id + "'")
    supabase_client.create_bot(supabase_profile.data["id"], bot_public_id, bot_name, bot_description)
    chatqueryService : ChatQueryService = ChatQueryService(bot_public_id)
    for knowledge in bot_knowledge:
        chatqueryService.upsert_node(knowledge)

    return jsonify({"response": "Success !"})