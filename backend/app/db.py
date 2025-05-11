import pymysql
from dotenv import load_dotenv
import os
from datetime import datetime

load_dotenv()

def get_db_connection():
 
    try:
        connection = pymysql.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME'),
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except pymysql.Error as e:
        print(f"Erro ao conectar ao banco de dados: {e}")
        return None

def insert_performance(usuario_id, acertos, tempo_segundos, total_questoes):
   
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
            INSERT INTO desempenho 
            (usuario_id, acertos, tempo_segundos, jogado_em, total_questoes)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                usuario_id,
                acertos,
                tempo_segundos,
                datetime.now(),
                total_questoes
            ))
            conn.commit()
            return cursor.lastrowid
    except pymysql.Error as e:
        print(f"Erro ao inserir desempenho: {e}")
        return None
    finally:
        if conn:
            conn.close()

def get_player_history(usuario_id, limit=5):
  
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
            SELECT 
                acertos,
                total_questoes,
                ROUND((acertos/total_questoes)*100, 2) as porcentagem,
                tempo_segundos,
                jogado_em
            FROM desempenho
            WHERE usuario_id = %s
            ORDER BY jogado_em DESC
            LIMIT %s
            """
            cursor.execute(sql, (usuario_id, limit))
            return cursor.fetchall()
    except pymysql.Error as e:
        print(f"Erro ao buscar histórico: {e}")
        return []
    finally:
        if conn:
            conn.close()

def get_avg_performance(usuario_id):

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
            SELECT 
                AVG(acertos) as avg_acertos,
                AVG(tempo_segundos) as avg_tempo,
                AVG((acertos/total_questoes)*100) as avg_porcentagem
            FROM desempenho
            WHERE usuario_id = %s
            """
            cursor.execute(sql, (usuario_id))
            return cursor.fetchone()
    except pymysql.Error as e:
        print(f"Erro ao calcular médias: {e}")
        return None
    finally:
        if conn:
            conn.close()

def get_all_training_data():
  
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            sql = """
            SELECT 
                usuario_id,
                acertos,
                total_questoes,
                (acertos/total_questoes)*100 as porcentagem,
                tempo_segundos,
                jogado_em
            FROM desempenho
            WHERE total_questoes > 0
            """
            cursor.execute(sql)
            return cursor.fetchall()
    except pymysql.Error as e:
        print(f"Erro ao buscar dados de treino: {e}")
        return []
    finally:
        if conn:
            conn.close()

def get_users(user_id=None, page=None, per_page=None):
      
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
      
                sql = """
                SELECT 
                    id,
                    nome,
                    email,
                    data_nascimento,
                    genero,
                    criado_em
                FROM usuarios
                """
                
              
                params = []
                if user_id:
                    sql += " WHERE id = %s"
                    params.append(user_id)
                
        
                elif page and per_page:
                    offset = (page - 1) * per_page
                    sql += " LIMIT %s OFFSET %s"
                    params.extend([per_page, offset])
                
                cursor.execute(sql, params or None)
                
                if user_id:
                    user = cursor.fetchone()
                    if user:
                     
                        if user.get('data_nascimento'):
                            user['data_nascimento'] = user['data_nascimento'].isoformat()
                        if user.get('criado_em'):
                            user['criado_em'] = user['criado_em'].isoformat()
                    return user
                else:
                    users = cursor.fetchall()
                    for user in users:
                        if user.get('data_nascimento'):
                            user['data_nascimento'] = user['data_nascimento'].isoformat()
                        if user.get('criado_em'):
                            user['criado_em'] = user['criado_em'].isoformat()
                    return users
                    
        except pymysql.Error as e:
            print(f"Erro ao buscar usuários: {e}")
            return None if user_id else []
        finally:
            if conn:
                conn.close()