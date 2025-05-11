from datetime import datetime
from db import get_db_connection
import pymysql

class ResultModel:
    @staticmethod
    def save_result(usuario_id, acertos, tempo_segundos):
  
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    sql = """
                    INSERT INTO desempenho 
                    (usuario_id, acertos, tempo_segundos, jogado_em)
                    VALUES (%s, %s, %s, %s)
                    """
                    cursor.execute(sql, (
                        usuario_id, 
                        acertos, 
                        tempo_segundos,
                        datetime.now()
                    ))
                    
                    connection.commit()
                    return True
            except pymysql.Error as e:
                print(f"Erro ao salvar resultado: {e}")
                return False
            finally:
                connection.close()
        return False
    @staticmethod
    def get_results(usuario_id=None, limit=None):
        conn = None
        try:
            conn = get_db_connection()
            with conn.cursor() as cursor:
              
                base_query = """
                    SELECT id, usuario_id, acertos, tempo_segundos, jogado_em,
                        porcentagem, tempo_por_questao
                    FROM desempenho
                """
                
                conditions = []
                params = []
                
                if usuario_id:
                    conditions.append("usuario_id = %s")
                    params.append(usuario_id)
                
                where_clause = (" WHERE " + " AND ".join(conditions)) if conditions else ""
                limit_clause = " LIMIT %s" if limit else ""
                
                if limit:
                    params.append(limit)
                
                full_query = base_query + where_clause + " ORDER BY jogado_em DESC" + limit_clause
                
                cursor.execute(full_query, params)
                results = cursor.fetchall()
                
                return {
                    'status': 'success',
                    'results': results,
                    'count': len(results)
                }
                
        except Exception as e:
            return {
                'status': 'error',
                'message': str(e),
                'details': traceback.format_exc()
            }
        finally:
            if conn:
                conn.close()

    @staticmethod
    def get_user_performance_stats(usuario_id, weeks=4):
     
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    sql = """
                    SELECT 
                        AVG(acertos/total_questoes)*100 as avg_accuracy,
                        AVG(tempo_segundos/total_questoes) as avg_speed,
                        STD(acertos/total_questoes)*100 as consistency,
                        COUNT(*) as attempts
                    FROM desempenho
                    WHERE usuario_id = %s
                    AND jogado_em >= %s
                    """
                    date_threshold = datetime.now() - timedelta(weeks=weeks)
                    cursor.execute(sql, (usuario_id, date_threshold))
                    return cursor.fetchone()
            except pymysql.Error as e:
                print(f"Erro ao buscar estatísticas: {e}")
                return None
            finally:
                connection.close()
        return None