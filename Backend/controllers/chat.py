import json
import time
from flask import Blueprint, request, jsonify
from services.supabase_client import SupabaseClient
from utils.send_gpt import send_gpt
from services.chat_query_service import ChatQueryService
import logging
import os

logger = logging.getLogger("persona_bot")
chat_bp = Blueprint('chat_bp', __name__)
supabase_client: SupabaseClient = SupabaseClient.get_instance()

@chat_bp.route('/chat', methods=['POST'])
def chat():
    data = request.json

    text = data.get('text')
    if not text:
        return jsonify({"error": "Missing 'text'"}), 400

    result = send_gpt(text)

    # This route can be called even if the user isn't connected so we retire the token part
    # token = data.get('token')
    
    return jsonify({
        "response": result
    })


@chat_bp.route('/chat_with_bot', methods=['POST'])
def chat_with_bot():
    data = request.json

    text = data.get('text')
    if not text:
        return jsonify({"error": "Missing 'text'"}), 400
    
    bot = data.get("bot_public_id")
    if not bot:
        return jsonify({"error": "Missing 'bot'"}), 400
    
    bot_information = supabase_client.get_bot_with_public_id(bot)
    if not bot_information :
        return jsonify({"error": "Bot doesn't exist, weird."}), 400

    logger.warning(f"Receive in chat_with_bot : {bot}")

    token = data.get('token')

    if not token :
        return jsonify({"error": "Missing 'token'."}), 400

    profile = supabase_client.get_profile_from_jwt(token)

    supabase_client.new_message_with_bot(bot_information.data["bot_public_id"], profile.data["id"], text, "user")

    chatQueryService : ChatQueryService = ChatQueryService(bot_information.data["bot_public_id"], bot_information.data["instruction"])
    result = chatQueryService.chat(text)

    supabase_client.new_message_with_bot(bot_information.data["bot_public_id"], profile.data["id"], result.response, "bot")
    
    # Result is of type AgentChatResponse 
    # https://docs.llamaindex.ai/en/stable/api_reference/chat_engines/
    return jsonify({
        "response": result.response
    })

