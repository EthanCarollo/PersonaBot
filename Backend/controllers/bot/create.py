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