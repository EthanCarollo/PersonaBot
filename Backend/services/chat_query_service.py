from llama_index.core import VectorStoreIndex, StorageContext
from llama_index.vector_stores.qdrant import QdrantVectorStore
from config import QDRANT_HOST, QDRANT_PORT
from qdrant_client import QdrantClient
from qdrant_client.http import models
from llama_index.core.schema import TextNode
import logging

logger = logging.getLogger("persona_bot")

class ChatQueryService:
    def __init__(self, collection_name: str):
        self.client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT, timeout= 20)
        self.collection_name = collection_name
        self.chat_engine = None
        self.vector_store = None
        self._initialize_collection()

    def _initialize_collection(self):
        if not self.client.collection_exists(self.collection_name):
            logger.info(f"Creating collection '{self.collection_name}'")
            self.client.create_collection(
                collection_name=self.collection_name,
                vectors_config=models.VectorParams(size=1536, distance=models.Distance.COSINE),
            )
        
        self.vector_store = QdrantVectorStore(client=self.client, collection_name=self.collection_name)
        storage_context = StorageContext.from_defaults(vector_store=self.vector_store)
        self.index = VectorStoreIndex([], storage_context=storage_context, dimension=1536)
        self.chat_engine = self.index.as_chat_engine()
        
    def get_all_information(self):
        try:
            response = self.client.scroll(collection_name=self.collection_name, limit=1000000)
            return response[0]
        except Exception as e:
            raise RuntimeError(f"Failed to fetch information from collection '{collection_name}': {str(e)}")

    def upsert_node(self, node_text, metadata={}):
        nodes = [TextNode(text=node_text, metadata=metadata)]
        nodes = self.index._get_node_with_embedding(nodes)
        self.vector_store.add(nodes)

    def chat(self, chat_str: str):
        """Perform a simple query and return the results."""
        if not self.chat_engine:
            raise ValueError("Chat engine is not initialized.")
        return self.chat_engine.chat(chat_str)