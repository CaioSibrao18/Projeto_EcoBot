from datetime import datetime, timedelta
import secrets
from bcrypt import hashpw, gensalt, checkpw
from db import get_db_connection
import pymysql

class UserModel:
    @staticmethod
    def find_by_email(email):
        """Retorna um dicionário com os dados do usuário ou None"""
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("""
                        SELECT id, nome, email, senha, reset_token, reset_token_expiracao 
                        FROM usuarios WHERE email = %s
                    """, (email,))
                    return cursor.fetchone()
            except pymysql.Error as e:
                print(f"Erro ao buscar usuário: {e}")
                return None
            finally:
                connection.close()
        return None

    @staticmethod
    def create_user(nome, data_nascimento, genero, email, senha):
        """Retorna o ID do novo usuário ou None em caso de erro"""
        try:
            print(f"Tentando criar usuário: {email}")
            
            # Conversão de data
            try:
                data_nascimento = datetime.strptime(data_nascimento, '%d/%m/%Y').strftime('%Y-%m-%d')
            except ValueError as e:
                print(f"Erro na conversão de data: {e}")
                return None

            # Hash da senha
            senha_hash = hashpw(senha.encode('utf-8'), gensalt()).decode('utf-8')
            
            connection = get_db_connection()
            if not connection:
                print("Falha na conexão com o banco")
                return None

            try:
                with connection.cursor() as cursor:
                    # Verifica se email existe primeiro
                    cursor.execute("SELECT id FROM usuarios WHERE email = %s", (email,))
                    if cursor.fetchone():
                        print("Email já existe no banco")
                        return None
                    
                    # Cria o usuário
                    sql = """
                    INSERT INTO usuarios 
                    (nome, data_nascimento, genero, email, senha)
                    VALUES (%s, %s, %s, %s, %s)
                    """
                    cursor.execute(sql, (nome, data_nascimento, genero, email, senha_hash))
                    connection.commit()
                    
                    user_id = cursor.lastrowid
                    print(f"Usuário criado com ID: {user_id}")
                    return user_id

            except pymysql.Error as e:
                print(f"Erro no banco de dados: {e}")
                connection.rollback()
                return None
            finally:
                connection.close()

        except Exception as e:
            print(f"Erro inesperado: {e}")
            return None

    @staticmethod
    def initiate_password_reset(email):
        """Retorna o token gerado ou None em caso de erro"""
        token = secrets.token_urlsafe(32)
        expiracao = datetime.now() + timedelta(hours=1)
        
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("""
                        UPDATE usuarios 
                        SET reset_token = %s, reset_token_expiracao = %s 
                        WHERE email = %s
                    """, (token, expiracao, email))
                    connection.commit()
                    return token if cursor.rowcount > 0 else None
            except pymysql.Error as e:
                print(f"Erro ao iniciar redefinição de senha: {e}")
                return None
            finally:
                connection.close()
        return None

    @staticmethod
    def validate_reset_token(token):
        """Valida se o token existe e não expirou"""
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("""
                        SELECT email FROM usuarios 
                        WHERE reset_token = %s 
                        AND reset_token_expiracao > NOW()
                    """, (token,))
                    result = cursor.fetchone()
                    return result is not None
            except pymysql.Error as e:
                print(f"Erro ao validar token: {e}")
                return False
            finally:
                connection.close()
        return False

    @staticmethod
    def reset_password(token, nova_senha):
        """Retorna True se bem-sucedido, False caso contrário"""
        senha_hash = hashpw(nova_senha.encode('utf-8'), gensalt()).decode('utf-8')
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("""
                        UPDATE usuarios 
                        SET senha = %s, 
                            reset_token = NULL, 
                            reset_token_expiracao = NULL 
                        WHERE reset_token = %s 
                        AND reset_token_expiracao > NOW()
                    """, (senha_hash, token))
                    connection.commit()
                    return cursor.rowcount > 0
            except pymysql.Error as e:
                print(f"Erro ao redefinir senha: {e}")
                return False
            finally:
                connection.close()
        return False

    @staticmethod
    def verify_password(senha_hash, senha):
        """Verifica se a senha corresponde ao hash"""
        return checkpw(senha.encode('utf-8'), senha_hash.encode('utf-8'))
    
    @staticmethod
    def email_exists(email):
        """Verifica se o email já está cadastrado"""
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("SELECT id FROM usuarios WHERE email = %s", (email,))
                    return cursor.fetchone() is not None
            except Exception as e:
                print(f"Erro ao verificar email: {e}")
                return True
            finally:
                connection.close()
        return False