import os
from dotenv import load_dotenv
from llama_index.embeddings.openai import OpenAIEmbedding
from llama_index.core import Settings

load_dotenv()

SUPABASE_URL = os.environ.get("SUPABASE_URL", None)
SUPABASE_KEY = os.environ.get("SUPABASE_KEY", None)
SUPABASE_JWT_SECRET = os.environ.get("SUPABASE_JWT_SECRET", None)

# To check more information about QDrant
# https://qdrant-x4sogoos8w884okosoc4wccw.ethan-folio.fr:6333/dashboard
QDRANT_HOST = "qdrant-x4sogoos8w884okosoc4wccw.ethan-folio.fr"
QDRANT_PORT = 6333

# Configure the normal embedding for OpenAI
Settings.chunk_size = 1536
Settings.embed_model = OpenAIEmbedding()