from chromadb import Client

client = Client()
db = client.create_database('starko_memory')
print('[OK] Paměťový engine připraven')
