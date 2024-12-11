import json
import time
from flask import Blueprint, request, jsonify
from services.supabase_client import SupabaseClient
from utils.send_gpt import send_gpt
from services.chat_query_service import ChatQueryService
import logging
import os

version_bp = Blueprint('version_bp', __name__)

@version_bp.route('/version', methods=['POST'])
def version():
    print("Receive '/version' request")
    return jsonify({
        "version": "1.0.0"
    })