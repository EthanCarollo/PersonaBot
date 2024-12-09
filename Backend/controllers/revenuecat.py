import json
import time
from flask import Blueprint, request, jsonify
from services.supabase_client import SupabaseClient
from utils.send_gpt import send_gpt
from services.chat_query_service import ChatQueryService
import logging
import os

logger = logging.getLogger("persona_bot")
revenue_cat_bp = Blueprint('revenue_cat_bp', __name__)
supabase_client: SupabaseClient = SupabaseClient.get_instance()

@revenue_cat_bp.route('/revenuecat', methods=['POST'])
def revenuecat():
    data = request.json
    print(data)