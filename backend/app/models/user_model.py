from datetime import datetime, timedelta
import secrets
import random
import string
from bcrypt import hashpw, gensalt, checkpw
from db import get_db_connection
import pymysql
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

class UserModel:
    @staticmethod
    def find_by_email(email):
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
        try:
            try:
                data_nascimento = datetime.strptime(data_nascimento, '%d/%m/%Y').strftime('%Y-%m-%d')
            except ValueError:
                pass

            senha_hash = hashpw(senha.encode('utf-8'), gensalt()).decode('utf-8')

            connection = get_db_connection()
            if not connection:
                return {"success": False, "error": "Sem conexão com o banco"}

            with connection.cursor() as cursor:
                cursor.execute("SELECT id FROM usuarios WHERE email = %s", (email,))
                result = cursor.fetchone()

                if result and isinstance(result, tuple) and len(result) == 1:
                    return {"success": False, "error": "Email já cadastrado"}

                cursor.execute("""
                    INSERT INTO usuarios 
                    (nome, data_nascimento, genero, email, senha)
                    VALUES (%s, %s, %s, %s, %s)
                """, (nome, data_nascimento, genero, email, senha_hash))

                connection.commit()
                return {"success": True, "id": cursor.lastrowid}

        except pymysql.Error as e:
            connection.rollback()
            return {"success": False, "error": "Erro no banco de dados: " + str(e)}
        except Exception as e:
            return {"success": False, "error": "Erro no processamento: " + str(e)}
        finally:
            if connection:
                connection.close()

    @staticmethod
    def create_password_reset_code(user_id, code, expires_at):
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("""
                        UPDATE usuarios
                        SET reset_token = %s, reset_token_expiracao = %s
                        WHERE id = %s
                    """, (code, expires_at, user_id))
                    connection.commit()
                    return cursor.rowcount > 0
            except pymysql.Error as e:
                connection.rollback()
                return False
            finally:
                connection.close()
        return False

    @staticmethod
    def validate_reset_code(user_id, code):
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("""
                        SELECT id FROM usuarios
                        WHERE id = %s
                        AND reset_token = %s
                        AND reset_token_expiracao > NOW()
                    """, (user_id, code))
                    return cursor.fetchone() is not None
            except pymysql.Error as e:
                return False
            finally:
                connection.close()
        return False

    @staticmethod
    def generate_reset_token(user_id):
        token = secrets.token_urlsafe(32)
        expires_at = datetime.now() + timedelta(minutes=30)

        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("""
                        UPDATE usuarios 
                        SET reset_token = %s, 
                            reset_token_expiracao = %s 
                        WHERE id = %s
                    """, (token, expires_at, user_id))
                    connection.commit()
                    return token if cursor.rowcount > 0 else None
            except pymysql.Error as e:
                connection.rollback()
                return None
            finally:
                connection.close()
        return None

    @staticmethod
    def reset_password_with_token(token, new_password):
        senha_hash = hashpw(new_password.encode('utf-8'), gensalt()).decode('utf-8')
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
                connection.rollback()
                return False
            finally:
                connection.close()
        return False

    @staticmethod
    def verify_password(senha_hash, senha):
        try:
            return checkpw(senha.encode('utf-8'), senha_hash.encode('utf-8'))
        except Exception as e:
            return False

    @staticmethod
    def email_exists(email):
        connection = get_db_connection()
        if connection:
            try:
                with connection.cursor() as cursor:
                    cursor.execute("SELECT id FROM usuarios WHERE email = %s", (email,))
                    return cursor.fetchone() is not None
            except Exception as e:
                return True
            finally:
                connection.close()
        return False

    @staticmethod
    def send_reset_code_email(to_email, code):
        from_email = "seu-email@gmail.com"
        from_password = "sua-senha-do-email"

        subject = "Código de Reset de Senha"
        body = f"Seu código de reset de senha é: {code}. Ele irá expirar em 15 minutos."

        msg = MIMEMultipart()
        msg['From'] = from_email
        msg['To'] = to_email
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'plain'))

        try:
            server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
            server.login(from_email, from_password)
            text = msg.as_string()
            server.sendmail(from_email, to_email, text)
            server.quit()
            return True
        except Exception as e:
            print(f"Erro ao enviar e-mail: {e}")
            return False

    @staticmethod
    def initiate_password_reset(email):
        code = ''.join(random.choices(string.digits, k=6))
        expires_at = datetime.now() + timedelta(minutes=15)

        user = UserModel.find_by_email(email)
        if not user:
            return {"success": False, "error": "Email não encontrado."}

        if not UserModel.create_password_reset_code(user['id'], code, expires_at):
            return {"success": False, "error": "Erro ao criar o código de reset."}

        if not UserModel.send_reset_code_email(user['email'], code):
            return {"success": False, "error": "Erro ao enviar código para o e-mail."}

        return {"success": True, "message": "Código de reset enviado para o e-mail."}
