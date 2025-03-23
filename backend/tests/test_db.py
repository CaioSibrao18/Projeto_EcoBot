from db import get_db_connection

def test_database_connection():

    connection = get_db_connection()

    if connection:
        try:
            with connection.cursor() as cursor:
             
                cursor.execute("SELECT * FROM usuarios")
                result = cursor.fetchall()
                print("Usuários:", result)
        except Exception as e:
            print(f"Erro ao executar a consulta: {e}")
        finally:
      
            connection.close()
            print("Conexão com o banco de dados fechada.")
    else:
        print("Não foi possível conectar ao banco de dados.")

# Executa o teste de conexão
if __name__ == "__main__":
    test_database_connection()