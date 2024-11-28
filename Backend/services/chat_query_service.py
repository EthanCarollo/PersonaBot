from llama_index.core import VectorStoreIndex, StorageContext
from llama_index.vector_stores.qdrant import QdrantVectorStore
from config import QDRANT_HOST, QDRANT_PORT
from qdrant_client import QdrantClient
from qdrant_client.http import models
import logging

logger = logging.getLogger("persona_bot")

class ChatQueryService:
    def __init__(self, collection_name: str):
        self.client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT, timeout= 20)
        self.collection_name = collection_name
        self.query_engine = None
        self._initialize_collection()

    def _initialize_collection(self):
        if not self.client.collection_exists(self.collection_name):
            logger.info(f"Creating collection '{self.collection_name}'")
            self.client.create_collection(
                collection_name=self.collection_name,
                vectors_config=models.VectorParams(size=1536, distance=models.Distance.COSINE),
            )
        
        vector_store = QdrantVectorStore(client=self.client, collection_name=self.collection_name)
        storage_context = StorageContext.from_defaults(vector_store=vector_store)
        self.index = VectorStoreIndex([], storage_context=storage_context, dimension=1536)
        self.query_engine = self.index.as_query_engine()

    def query(self, query_str: str):
        """Perform a simple query and return the results."""
        if not self.query_engine:
            raise ValueError("Query engine is not initialized.")
        return self.query_engine.query(query_str)
