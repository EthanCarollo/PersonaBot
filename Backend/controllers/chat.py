import json
import time
from flask import Blueprint, request, jsonify
from transformers import AutoModelForCausalLM, AutoTokenizer
from openai import OpenAI
from services.supabase_client import SupabaseClient
from openai import OpenAI
from services.chat_query_service import ChatQueryService
import logging
import os

logger = logging.getLogger("persona_bot")
chat_bp = Blueprint('extract_text', __name__)
client = OpenAI()
supabase_client = SupabaseClient.get_instance()

@chat_bp.route('/chat', methods=['POST'])
def chat():
    start_time = time.time()
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


def send_gpt(text):
    response = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": text,
            }
        ],
        model="gpt-4o-mini"
    )
    return response.choices[0].message.content