import json
import time
from flask import Blueprint, request, jsonify
from services.supabase_client import SupabaseClient
from utils.send_gpt import send_gpt
import logging
import os

health_bp = Blueprint('health_bp', __name__)

@health_bp.route('/health', methods=['POST'])
def health():
    print("Receive '/health' request")
    return jsonify({
        "isAlive": True
    })