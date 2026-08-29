# memory.py
import chromadb
def init_chroma(path="chroma_db"):
    client = chromadb.Client()
    return client
