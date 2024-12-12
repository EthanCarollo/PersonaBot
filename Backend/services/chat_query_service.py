from llama_index.core import VectorStoreIndex, StorageContext
from llama_index.vector_stores.qdrant import QdrantVectorStore
from config import QDRANT_HOST, QDRANT_PORT
from qdrant_client import QdrantClient
from llama_index.core.memory import ChatMemoryBuffer
from qdrant_client.http import models
from llama_index.core.schema import TextNode
import logging
from llama_index.core import ChatPromptTemplate
from llama_index.core.llms import ChatMessage, MessageRole

logger = logging.getLogger("persona_bot")

class ChatQueryService:
    _instances = {}

    def __new__(cls, collection_name: str, user_id: str = "none", instruction: str = None):
        key = f"{collection_name}:{user_id}"
        if key not in cls._instances:
            instance = super(ChatQueryService, cls).__new__(cls)
            cls._instances[key] = instance
        return cls._instances[key]


    def __init__(self, collection_name: str, user_id: str, instruction: str = None):
        if not hasattr(self, "initialized"):
            self.client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT, timeout=20)
            self.collection_name = collection_name
            self.user_id = user_id
            self.chat_engine = None
            self.vector_store = None
            self.instruction = instruction
            self._initialize()
            self.initialized = True

    def _initialize(self):
        logger.info(f"Initializing bot : {self.collection_name} for {self.user_id}")
        if not self.client.collection_exists(self.collection_name):
            logger.info(f"Creating collection '{self.collection_name}'")
            self.client.create_collection(
                collection_name=self.collection_name,
                vectors_config=models.VectorParams(size=1536, distance=models.Distance.COSINE),
            )
        self.vector_store = QdrantVectorStore(client=self.client, collection_name=self.collection_name)
        storage_context = StorageContext.from_defaults(vector_store=self.vector_store)
        self.index = VectorStoreIndex([], storage_context=storage_context, dimension=1536)
        memory = ChatMemoryBuffer.from_defaults(token_limit=1500)
        self.chat_engine = self.index.as_chat_engine(
            memory=memory,
            system_prompt=(self.instruction)
        )
        
    def get_all_information(self):
        try:
            response = self.client.scroll(collection_name=self.collection_name, limit=1000000)
            return response[0]
        except Exception as e:
            raise RuntimeError(f"Failed to fetch information from collection '{self.collection_name}': {str(e)}")

    def upsert_node(self, node_text, metadata={}):
        nodes = [TextNode(text=node_text, metadata=metadata)]
        nodes = self.index._get_node_with_embedding(nodes)
        self.vector_store.add(nodes)

    def chat(self, chat_str: str):
        """Perform a simple query and return the results."""
        if not self.chat_engine:
            raise ValueError("Chat engine is not initialized.")
        result = self.chat_engine.chat(chat_str)
        logger.warning(result)
        return result

    @staticmethod
    def delete_collection(collection_name: str):
        """Static method to delete a collection from Qdrant."""
        client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT, timeout=20)
        try:
            if client.collection_exists(collection_name):
                logger.info(f"Deleting collection '{collection_name}'")
                client.delete_collection(collection_name=collection_name)
                logger.info(f"Collection '{collection_name}' deleted successfully.")
            else:
                logger.warning(f"Collection '{collection_name}' does not exist.")
        except Exception as e:
            logger.error(f"Failed to delete collection '{collection_name}': {str(e)}")