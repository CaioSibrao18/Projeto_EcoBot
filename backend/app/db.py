import pymysql
from dotenv import load_dotenv
import os

# Carrega as variáveis de ambiente do arquivo .env
load_dotenv()

def get_db_connection():
    try:
       
        connection = pymysql.connect(
            user=os.getenv('DB_USER'),       
            password=os.getenv('DB_PASSWORD'),  
            database=os.getenv('DB_NAME'),  
            cursorclass=pymysql.cursors.DictCursor 
        )
        return connection
    except pymysql.Error as e:
        print(f"Erro ao conectar ao banco de dados: {e}")
        return None