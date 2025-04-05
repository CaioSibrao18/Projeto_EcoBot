# app/models/result_model.py
from datetime import datetime
from db import get_db_connection
import pymysql

class ResultModel:
    @staticmethod
    def save_result(usuario_id, jogo, dificuldade, acertos, tempo_segundos):
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    sql = """
                    INSERT INTO desempenho 
                    (usuario_id, jogo, dificuldade, acertos, tempo_segundos)
                    VALUES (%s, %s, %s, %s, %s)
                    """
                    cursor.execute(sql, (usuario_id, jogo, dificuldade, acertos, tempo_segundos))
                    connection.commit()
                    return True
            except pymysql.Error as e:
                print(f"Erro ao salvar resultado: {e}")
                return False
            finally:
                connection.close()
        return False

    @staticmethod
    def get_results(usuario_id=None, jogo=None, dificuldade=None):
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    sql = """
                    SELECT * FROM desempenho
                    WHERE 1=1
                    """
                    params = []
                    
                    if usuario_id:
                        sql += " AND usuario_id = %s"
                        params.append(usuario_id)
                    if jogo:
                        sql += " AND jogo = %s"
                        params.append(jogo)
                    if dificuldade:
                        sql += " AND dificuldade = %s"
                        params.append(dificuldade)
                    
                    sql += " ORDER BY jogado_em DESC"
                    
                    cursor.execute(sql, params)
                    return cursor.fetchall()
            except pymysql.Error as e:
                print(f"Erro ao buscar resultados: {e}")
                return []
            finally:
                connection.close()
        return []