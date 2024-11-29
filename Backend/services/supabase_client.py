from supabase import create_client, Client
from config import SUPABASE_URL, SUPABASE_KEY, SUPABASE_JWT_SECRET
import jwt
from jwt import InvalidTokenError
import logging

logger = logging.getLogger("persona_bot")

class SupabaseClient:
    _instance = None

    def __init__(self):
        if SupabaseClient._instance is not None:
            raise Exception("This class is a singleton, don't call constructor but get_instance instead.")
        self.client: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

    def verify_jwt(self, token):
        try:
            decoded_token = jwt.decode(token, SUPABASE_JWT_SECRET, algorithms=["HS256"], audience="authenticated")
            return decoded_token
        except InvalidTokenError as e:
            print(f"Invalid token: {e}")
            return None
            
    def get_profile_from_jwt(self, token):
        profile = self.verify_jwt(token=token)
        if profile == None :
            return None
        return self.get_profile_with_email(profile["email"])
    
    def get_profile_with_email(self, email):
        try :
            return self.client.table('profiles').select('*').eq('email', email).single().execute()
        except :
            return None
    
    def get_bot_with_public_id(self, bot_id):
        try :
            return self.client.table('bots').select('*').eq('bot_public_id', bot_id).single().execute()
        except :
            return None

    def add_bot_to_saved(self, bot_id, user_id):
        try :
            return self.client.table('saved_bots').upsert({"bot_id": bot_id, "user_id": user_id}).execute()
        except Exception as e :
            logger.error(e)
            return None

    def create_bot(self, user_id: str, bot_public_id: str, bot_name: str, description: str):
        # When I create a bot, I don't directly insert all Data in QDrant, I do it after cause the logics to talk with
        # ChatQueryService shouldn't be in the SupabaseClient
        try :
            return self.client.table('bots').insert({
                "created_by": user_id,
                "bot_public_id": bot_public_id,
                "description": description,
                "name": bot_name
            }).execute()
        except :
            return None
    
    @staticmethod
    def get_instance():
        if SupabaseClient._instance is None:
            logger.info("Initialized SupabaseClient")
            SupabaseClient._instance = SupabaseClient()
        return SupabaseClient._instance